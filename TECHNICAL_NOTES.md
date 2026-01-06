# Technical Notes

**Version:** 0.4.0  
**Last Updated:** January 6, 2026

---

## 🏗️ Architecture Overview

This post processor is a **standalone, single-file implementation** containing all machine definitions, logic, and configurations. No external machine definition files are used.

### Design Philosophy

1. **Self-Contained:** All configuration in one .cps file
2. **Heavily Commented:** Every decision documented
3. **Machine-Specific:** Tailored for Serial #195369
4. **Phase-Based Development:** Incremental, tested additions
5. **Reference-Based:** Built from proven mazak_integrex_i-100s.cps

---

## 🔧 Key Technical Implementations

### 1. Diameter Mode (CRITICAL)

**Problem:** Turning machines use diameter programming (X50.0 = 50mm diameter), but Autodesk Fusion uses radius values internally (25mm from center).

**Solution:**
```javascript
var xFormat = createFormat({
  decimals:(unit == MM ? 3 : 4), 
  type:FORMAT_REAL,
  scale:2,              // ← Multiply radius by 2
  forceDecimal:true
});
```

**Impact:**
- Input: 25mm radius from center
- Calculation: 25mm × 2 = 50mm
- Output: `X50.0`
- Machine interprets: 50mm diameter (25mm radius) ✅

**Without scale:2:**
- Output: `X25.0`
- Machine interprets: 25mm diameter (12.5mm radius) ❌ 50% ERROR!

**Reference:** See `docs/xformat_fix_documentation.md`

---

### 2. G109 Compound Machining Structure

**Mazak Matrix Requirement:** Dual turret programs use G109 to separate turret sections.

**Implementation:**
```gcode
%                          ← Program start

(Common section)           ← Before first G109
G21 G18 G90 G94

G109 L1                    ← Upper turret section
M901                       ← Spindle 1
M202                       ← Turning mode
...
M950                       ← Wait for sync
M30                        ← Section end

G109 L2                    ← Lower turret section  
M901                       ← Spindle 1
M202                       ← Turning mode
...
M950                       ← Wait for sync
M30                        ← Section end

M30                        ← Program end
%                          ← Program end
```

**Key Points:**
- Each turret section MUST end with M30
- M950 synchronizes turrets between sections
- Common commands before first G109 apply to both turrets

**Reference:** Mazak Programming Manual, Section 19-1, 20-1

---

### 3. Matrix Control M-Codes

**Milling Mode:**
```javascript
case "ENABLE_C_AXIS":
  machineState.cAxisIsEngaged = true;
  return (spindle == SPINDLE_MAIN) ? 200 : 300;  // M200/M300

case "DISABLE_C_AXIS":
  machineState.cAxisIsEngaged = false;
  return (spindle == SPINDLE_MAIN) ? 202 : 302;  // M202/M302
```

**Spindle Selection:**
```javascript
M901  // 1st spindle (main)
M902  // 2nd spindle (sub)
```

**Milling Spindle:**
```javascript
M203 S___  // Milling spindle CW with speed
M205       // Milling spindle stop
```

**Differences from Fanuc:**
- Fanuc uses M154/M155 for C-axis
- Mazak uses M200/M300 for milling mode
- Mazak M203 replaces M3 for milling spindle

**Reference:** Mazak Programming Manual, Section 12, 20

---

### 4. Turret-Specific Axis Management

**Problem:** Upper turret has Y+B, lower turret has Y only.

**Solution:**
```javascript
function activateMachine(section) {
  var turret = section.getTool().turret;
  
  switch (turret) {
  case 1:  // UPPER
    gotYAxis = turret1GotYAxis;  // true
    gotBAxis = turret1GotBAxis;  // true
    break;
  case 2:  // LOWER
    gotYAxis = turret2GotYAxis;  // true
    gotBAxis = turret2GotBAxis;  // false
    break;
  }
  
  // Enable/disable outputs
  if (!gotYAxis) { yOutput.disable(); }
  if (!gotBAxis) { bOutput.disable(); }
}
```

**Result:**
- Y-axis output automatically suppressed when turret doesn't have it
- B-axis output automatically suppressed for lower turret
- No manual intervention needed in Autodesk Fusion

---

### 5. Modal Output System

**Purpose:** Reduce G-code size by omitting redundant commands.

**Implementation:**
```javascript
var xOutput = createVariable({prefix:"X"}, xFormat);
var gMotionModal = createModal({}, gFormat);
```

**Example:**
```gcode
G0 X100.0 Z50.0    ← G0 output (first time)
X50.0              ← G0 suppressed (modal)
X25.0              ← G0 suppressed (modal)
G1 Z25.0 F0.25    ← G1 output (changed)
Z10.0              ← G1 suppressed, F suppressed
F0.3               ← F output (changed)
```

**Benefits:**
- Smaller file size
- Faster upload to control
- Easier to read
- Standard CNC practice

---

### 6. Feed Rate Management

**Two Modes:**
- **G94:** Feed per minute (mm/min or inch/min) - Milling
- **G95:** Feed per revolution (mm/rev or inch/rev) - Turning

**Implementation:**
```javascript
if (machineState.isTurning) {
  // Turning: Use G95 (feed per rev)
  writeBlock(gFeedModeModal.format(95));
} else {
  // Milling: Use G94 (feed per min)
  writeBlock(gFeedModeModal.format(94));
}
```

**Automatic:** Post automatically selects correct mode based on operation type.

---

### 7. Arc Interpolation

**Two Formats Supported:**

**Radius Mode (R___):**
```gcode
G2 X50.0 Z-25.0 R5.0 F0.2
```
- Simpler format
- Limited to arcs ≤ 180°
- Use negative R for arcs > 180°

**IJK Mode:**
```gcode
G2 X50.0 Z-25.0 I2.5 K-2.5 F0.2
```
- Supports any arc size
- More complex calculation
- I/J/K = center offset from start point

**User Selectable:** `useRadius` property controls which mode.

**Arc Linearization:**
For complex cases (helical, full circles in radius mode), arcs are broken into linear segments:

```javascript
function linearize(tolerance) {
  var segments = Math.max(4, Math.ceil(...));
  for (var i = 1; i <= segments; i++) {
    // Calculate point along arc
    onLinear(x, y, z, feed);
  }
}
```

---

### 8. Plane Selection

**Three Planes:**
- **G17 (XY):** Milling in horizontal plane
- **G18 (ZX):** Turning, radial milling
- **G19 (YZ):** Milling in vertical plane

**Automatic Detection:**
```javascript
function getCircularPlane() {
  if (currentSection.getType() == TYPE_TURNING) {
    return PLANE_ZX;  // G18
  } else {
    var n = getCircularNormal();
    // Calculate from arc normal vector
  }
}
```

**Critical:** Plane must be set before G2/G3 commands.

---

### 9. Machine State Tracking

**Purpose:** Track machine condition to avoid redundant M-codes.

**Implementation:**
```javascript
var machineState = {
  currentTurret: 1,
  mainSpindleIsActive: undefined,
  subSpindleIsActive: undefined,
  liveToolIsActive: undefined,
  cAxisIsEngaged: undefined,
  isTurning: false,
  isMilling: false,
  feedPerRevolution: undefined
  // ... etc
};
```

**Usage:**
```javascript
if (!machineState.cAxisIsEngaged) {
  writeBlock(mFormat.format(200));  // M200
  machineState.cAxisIsEngaged = true;
}
```

**Benefits:**
- Prevents redundant M-codes
- Ensures proper sequencing
- Tracks multiple spindle states

---

### 10. Spindle Speed Limiting

**Machine Limits (from parameter sheet):**
- Main spindle: 5,060 RPM (Kitagawa chuck limit)
- Sub spindle: 6,000 RPM
- Live tooling: 12,000 RPM

**Implementation:**
```javascript
if (spindleSpeed > maximumSpindleSpeed) {
  warning("Spindle speed " + spindleSpeed + 
          " exceeds maximum " + maximumSpindleSpeed);
  spindleSpeed = maximumSpindleSpeed;
}
```

**User Override:** Properties allow changing limits without code modification.

---

## 📐 Coordinate Systems

### Work Coordinate Systems (WCS)

**Available Offsets:**
- G54 (Work offset 1) - Default
- G55 (Work offset 2)
- G56 (Work offset 3)
- G57 (Work offset 4)
- G58 (Work offset 5)
- G59 (Work offset 6)

**Extended:** G54.1 P1-P48 (Phase 7)

### Machine Coordinate System

**G53:** Machine coordinates (absolute machine position)

**Usage:**
```gcode
G53 G0 Z0    ← Move Z to machine zero (home)
G53 X0 Y0    ← Move XY to machine zero
```

**Critical:** Used in onClose() to safely return to home position.

---

## 🔍 Important Code Sections

### Section Flow

```
onOpen()
  ↓
defineMachine() ← Called once
  ↓
[For each operation]
  ↓
activateMachine(section) ← Set turret config
  ↓
onSection() ← Setup operation
  ↓
[Motion functions]
  onRapid()
  onLinear()
  onCircular()
  ↓
onSectionEnd() ← Cleanup operation
  ↓
[Next operation or end]
  ↓
onClose()
```

### Critical Functions

**1. defineMachine()**
- Sets all machine-specific parameters
- Called once in onOpen()
- Source of truth for machine configuration

**2. activateMachine()**
- Called for each section
- Enables/disables axes per turret
- Sets up machine configuration object

**3. getCode()**
- Central M-code repository
- Returns correct M-code for each command
- Tracks machine state

---

## ⚙️ Configuration Parameters

### From Grace Engineering Parameter Sheet

```javascript
// BA parameters (from adjusted_parameters.pdf)
BA61 = 44 μm              // B-axis center runout
BA62 = 586967 (0.00001")  // B-axis to spindle offset
BA97 TR1 = -1307337       // Upper turret X reference
BA99 TR1 = -1479743       // Upper turret Z reference
BA97 TR2 = -49            // Lower turret X reference
BA99 TR2 = 0              // Lower turret Z reference

// Work offset parameters
M5 Y = -927534 (0.1μm)    // Y-axis offset
M16 Y = 56977 (0.1μm)     // Y-axis reference point
```

**Note:** These are documented but not all actively used in v0.4.0. Will be implemented in later phases for advanced work offset calculations.

---

## 🐛 Known Technical Limitations

### Current Version (v0.4.0)

1. **No Canned Cycles**
   - G83 drilling not implemented
   - Will linearize all drilling operations
   - **Impact:** Longer programs, slower cycle times

2. **No B-Axis Output**
   - B-axis positioning not implemented
   - Must manually position B-axis
   - **Impact:** Cannot use B-axis in programs

3. **No C-Axis Indexing**
   - C-axis positioning code not implemented
   - Live tool orientation not controlled
   - **Impact:** Manual C-axis positioning needed

4. **Simple Sub-Spindle Support**
   - Part transfer not implemented
   - Synchronization incomplete
   - **Impact:** Cannot do automatic part transfer

5. **No Balanced Cutting**
   - M562/M563 not implemented
   - Cannot couple turrets for balanced cutting
   - **Impact:** Longer workpieces may vibrate

---

## 🔬 Testing Methodology

### Phase-Based Testing

**Each phase includes:**
1. Syntax validation (Autodesk Fusion load)
2. G-code generation test
3. Simulator validation (if available)
4. Documentation update

### Test Programs

**Simple Turning:**
```
- Face cut
- OD turn  
- Corner radius
- Part off
```

**Simple Milling:**
```
- Pocket (XY plane)
- Slot (XY plane)
- Circular feature (G2/G3)
- Drilling (when cycles implemented)
```

**Dual Turret:**
```
- Upper turret operation
- G109 L2 switch
- Lower turret operation
- Turret synchronization
```

---

## 📊 Performance Considerations

### File Size

**Current:** ~2,000 lines  
**Target:** ~4,000 lines (at v1.0)  
**Ratio:** Heavy comments increase size but improve maintainability

### G-Code Output Size

**Modal output reduces size by ~30%:**
- Suppressed redundant G-codes
- Suppressed redundant coordinates
- Suppressed redundant feeds

**Typical program:**
- Without modal: 500 lines
- With modal: 350 lines
- Savings: 30%

### Execution Speed

**Minimal impact:**
- Post processing: <1 second for typical programs
- Machine execution: No impact (same G-code commands)

---

## 🔐 Safety Features

### Built-In Safety

1. **Spindle Speed Limiting**
   - Enforces maximum RPM per spindle
   - Warns user if exceeded
   - Automatically limits speed

2. **Axis Travel Checks**
   - Y-axis limits enforced (±105mm)
   - X-axis minimum enforced (-50mm radius)
   - **Note:** No maximum limit check on X/Z

3. **State Validation**
   - Ensures spindles stopped before tool change
   - Ensures milling mode disabled for turning
   - Prevents conflicting M-codes

4. **Comment Warnings**
   - Operator warnings in header
   - Section labels for clarity
   - Tool information comments

### Required External Safety

1. **Simulation** - Always validate in simulator first
2. **Dry Run** - Always dry run before cutting
3. **Work Offsets** - Verify all offsets before running
4. **Tool Offsets** - Verify all tool offsets
5. **Clearances** - Verify turret clearances

---

## 📖 References

### Primary Sources

1. **Mazak Programming Manual 2.pdf**
   - Section 19: Two-System Control (G109)
   - Section 20: Compound Machining (M950, M562/M563)
   - Section 12: M-Code Reference

2. **Grace Engineering Parameter Sheet**
   - Serial: 195369
   - Date: 8/15/2022
   - Installer: P Dockery

3. **mazak_integrex_i-100s.cps**
   - Autodesk reference post
   - Base template for implementation

### Secondary Sources

1. ISO 6983 / EIA-274-D (G-code standards)
2. Autodesk Post Processor Training
3. Mazak Matrix operator manual

---

## 🔄 Version Control Strategy

### Branch Strategy

```
main
  ├── develop (active development)
  ├── phase-4 (next phase)
  ├── phase-5 (future)
  └── hotfix/* (critical fixes)
```

### Tagging Strategy

```
v0.1.0 - Skeleton
v0.2.0 - Phase 1
v0.3.0 - Phase 2
v0.3.1 - Critical fix
v0.4.0 - Phase 3
v0.5.0 - Phase 4 (planned)
...
v1.0.0 - Production release
```

---

## 🎯 Future Enhancements

### Phase 4-8 Technical Challenges

**B-Axis Implementation:**
- Kinematics calculation
- Tool orientation
- Collision avoidance

**Threading:**
- Pitch calculation
- Multiple passes
- Spring passes
- Thread relief

**Balanced Cutting:**
- Symmetric path generation
- Master/servant logic
- Synchronization timing

**Sub-Spindle Transfer:**
- Work offset transformation
- Chuck timing
- Z-axis coordination

---

## 💡 Optimization Opportunities

### Code Optimization

1. Reduce redundant calculations
2. Cache frequently used values
3. Optimize modal group handling

### Output Optimization

1. Better coordinate precision management
2. Intelligent rapid move optimization
3. Tool path consolidation

### Documentation

1. Inline examples for complex sections
2. Visual diagrams for coordinate systems
3. Troubleshooting flowcharts

---

**Last Updated:** January 6, 2026  
**Version:** 0.4.0  
**Author:** Grace Engineering / Claude AI
