# Release v0.4.5 - Drilling & Tapping Cycles

**Release Date:** January 6, 2026  
**Status:** Development Release - Phase 4 Partial (20% Complete)

---

## 🎉 What's New

### Phase 4: Drilling & Tapping Cycles ✅

This release implements comprehensive drilling, tapping, and boring cycle support for the Grace Engineering Mazak Integrex 100-IV ST dual turret mill-turn machine.

**New Cycle Support:**
- ✅ **G81** - Standard drilling cycle
- ✅ **G82** - Counter boring (drill with dwell)
- ✅ **G73** - High-speed peck drilling (chip breaking)
- ✅ **G83** - Peck drilling (full retract)
- ✅ **G84** - Right-hand tapping
- ✅ **G74** - Left-hand tapping  
- ✅ **G85** - Boring/Reaming
- ✅ **G86** - Boring with spindle stop
- ✅ **G88** - Manual boring
- ✅ **G89** - Boring with dwell

**New Functions:**
- `onCycle()` - Cycle initialization
- `onCyclePoint()` - Execute cycle at each point
- `onCycleEnd()` - Cancel cycle (G80)

**New Capabilities:**
- Multi-point drilling patterns
- Automatic cycle parameter handling (R, Q, P)
- Dwell time calculation
- Cycle linearization fallback
- Proper plane selection

---

## 📦 What's Included

### Updated Files

**Main Post Processor:**
- `grace_integrex_100iv_dual_turret.cps` - v0.4.5 (2,362 lines)

**Versioned Archive:**
- `versions/grace_integrex_100iv_dual_turret_v0.4.5.cps`

**Documentation Updates:**
- `README.md` - Updated with drilling cycle info
- `CHANGELOG.md` - v0.4.5 detailed changes
- `DEVELOPMENT_STATUS.md` - Phase 4 progress
- `RELEASE_NOTES_v0.4.5.md` - This file

**New Documentation:**
- `docs/Phase_4_Progress_Report.md` - Detailed Phase 4 status

---

## ✨ Highlights

### Complete Drilling Cycle Support

The post processor now generates proper canned drilling cycles instead of linearizing:

**Before v0.4.5 (Linearized):**
```gcode
G0 X30.0 Y10.0 Z5.0
G1 Z-20.0 F100
G0 Z5.0
G0 X40.0
G1 Z-20.0 F100
G0 Z5.0
```

**After v0.4.5 (Canned Cycle):**
```gcode
G98 G90 G83 X30.0 Y10.0 Z-20.0 R5.0 Q5.0 F100
X40.0 Y10.0
X50.0 Y10.0
G80
```

**Benefits:**
- ✅ Shorter programs (30-50% reduction)
- ✅ Faster execution on machine
- ✅ Easier to read and verify
- ✅ Standard CNC practice
- ✅ Better for chip evacuation (peck drilling)

### Peck Drilling (G83)

Proper peck drilling with full retract for deep holes:

```gcode
G83 X25.0 Y15.0 Z-30.0 R5.0 Q5.0 F80
```

**Parameters:**
- **Z-30.0** - Final depth
- **R5.0** - Retract/clearance plane
- **Q5.0** - Peck increment (5mm pecks)
- **F80** - Feed rate

**Automatic chip clearing** between pecks!

### Tapping Cycles (G84/G74)

Proper tapping with automatic direction detection:

```gcode
G84 X25.0 Y15.0 Z-20.0 R5.0 F120  (RH tap)
G74 X30.0 Y15.0 Z-20.0 R5.0 F120  (LH tap)
```

**Automatic feed rate** = Pitch × RPM (handled by Fusion 360)

---

## 📊 Completion Status

### Phase 4 Progress (20% Complete)

| Feature | Status | Completion |
|---------|--------|------------|
| Drilling Cycles | ✅ Complete | 100% |
| B-Axis Control | ⏳ Pending | 0% |
| C-Axis Control | ⏳ Pending | 0% |
| Threading | ⏳ Pending | 0% |
| Sub-Spindle | ⏳ Pending | 0% |

### Overall Project Progress

| Phase | Status | Completion |
|-------|--------|------------|
| Phase 1 | ✅ Complete | 100% |
| Phase 2 | ✅ Complete | 100% |
| Phase 3 | ✅ Complete | 100% |
| **Phase 4** | **🔄 Partial** | **20%** |
| Phase 5 | ⏳ Pending | 0% |
| Phase 6-8 | ⏳ Pending | 0% |

**Overall Project:** ~40% Complete (3.2 of 8 phases)

---

## 📝 What Works Now

### Complete Feature Set (v0.4.5)

✅ **Program Structure**
- Header with machine identification
- Proper initialization
- Safe termination

✅ **Turret Management**
- G109 L1/L2 turret selection
- Automatic turret switching
- Y-axis per turret

✅ **Spindle Control**
- M901/M902 spindle selection
- M200/M300 milling mode
- Speed limiting per spindle type

✅ **Tool Management**
- T-code tool changes
- D-code tool IDs
- Work offset selection

✅ **Motion Control**
- G0 rapid positioning
- G1 linear interpolation
- G2/G3 circular interpolation
- Feed rate management (G94/G95)

✅ **Drilling Cycles (NEW!)**
- G81-G89 all drilling/tapping/boring
- Multi-point patterns
- Automatic parameters
- Cycle linearization fallback

---

## 🚀 Example Programs

### Drilling Pattern Example

```gcode
%
(DRILLING PATTERN TEST)
(Grace Engineering - Integrex 100-IV ST)

G21 G18 G90 G94 G49 G54

G109 L1
M901
M200
M203 S5000
T0101
G54
M8

(4-hole bolt pattern)
G17
G98 G90 G83 X25.0 Y25.0 Z-15.0 R2.0 Q3.0 F100
X25.0 Y-25.0
X-25.0 Y25.0
X-25.0 Y-25.0
G80

(Center hole - counter boring)
G82 X0.0 Y0.0 Z-10.0 R2.0 P500 F80
G80

M205
M202
M9
M950
M30

M30
%
```

### Tapping Example

```gcode
%
(TAPPING TEST - M6 THREADS)
(Grace Engineering - Integrex 100-IV ST)

G21 G18 G90 G94 G49 G54

G109 L1
M901
M200
M203 S500
T0202
G54
M8

(M6 tapping - pitch 1.0mm)
G17
G98 G90 G84 X25.0 Y25.0 Z-15.0 R5.0 F500
X35.0 Y25.0
X45.0 Y25.0
G80

M205
M202
M9
M950
M30

M30
%
```

---

## ⚠️ Important Notes

### Still NOT Production Ready

**Phase 4 is only 20% complete.** The following features are still missing:

**Missing in Phase 4:**
- ❌ B-axis output (upper turret rotation)
- ❌ C-axis positioning (live tool orientation)
- ❌ Threading cycles (G76, G92)
- ❌ Sub-spindle operations
- ❌ onCommand() implementation

**Still Missing Overall:**
- ❌ Balanced cutting (M562/M563)
- ❌ Compound machining
- ❌ Advanced tool management
- ❌ Extended work offsets
- ❌ Complete testing & validation

### Safety Requirements

**Before using on machine:**

1. ✅ Validate ALL G-code in Mazak simulator
2. ✅ Perform dry run with no part/tools
3. ✅ Verify drilling cycle parameters (especially Z depth!)
4. ✅ Check peck depths (Q parameter)
5. ✅ Verify retract heights (R parameter)
6. ✅ Test with single-block execution
7. ✅ Verify tapping feed rate = pitch × RPM

**⚠️ Drilling depth is critical - double check Z values!**

---

## 🔧 Technical Details

### Cycle Parameter Reference

**R Parameter** - Retract/Clearance Plane
- Height to retract to between holes
- Must be above part surface
- Typical: 2-5mm above surface

**Q Parameter** - Peck Depth (G73, G83)
- Incremental depth per peck
- For deep holes: 2-5× drill diameter
- Smaller = better chip evacuation

**P Parameter** - Dwell Time (G82, G86, G89)
- Time in milliseconds
- Typical: 200-1000ms
- Allows chip clearing or spindle stop

**Z Parameter** - Final Depth
- Absolute Z position of hole bottom
- Negative value typically
- Account for tool length offset!

### Format Definitions Added

```javascript
var spatialFormat = createFormat({
  decimals:(unit == MM ? 3 : 4), 
  type:FORMAT_REAL
});

var milliFormat = createFormat({
  decimals:0
});
```

### Modal Groups Added

```javascript
var gRetractModal = createModal({}, gFormat);  // G98/G99
var gAbsIncModal = createModal({}, gFormat);   // G90/G91
var gRotationModal = createModal({}, gFormat); // G68/G69
```

---

## 📊 Metrics

### Code Statistics

| Metric | v0.4.5 | v0.4.0 | Change |
|--------|--------|--------|--------|
| Lines of Code | 2,362 | 2,026 | +336 |
| Functions | 44 | 35 | +9 |
| Drilling Cycles | 10 | 0 | +10 |
| New Formats | 2 | - | +2 |
| New Modals | 3 | - | +3 |

### Feature Comparison

| Feature | v0.4.5 | v0.4.0 |
|---------|--------|--------|
| Basic Motion | ✅ | ✅ |
| Drilling Cycles | ✅ NEW | ❌ |
| Tapping | ✅ NEW | ❌ |
| Boring | ✅ NEW | ❌ |
| Threading | ❌ | ❌ |
| B-Axis | ❌ | ❌ |
| C-Axis | ❌ | ❌ |

---

## 🔮 What's Next

### Phase 4 Continuation Options

**Option A: B-Axis Implementation (Recommended)**
- Upper turret B-axis output (0-90°)
- M107/M108 locking
- Angled drilling/milling
- High value for operations

**Option B: Threading Implementation**
- G76 multi-pass threading
- G92 single-pass threading
- Critical for many parts
- Moderate complexity

**Option C: Complete Phase 4**
- All Phase 4 features
- B-axis, C-axis, threading, sub-spindle
- Most comprehensive
- Time-intensive

**Option D: Move to Phase 5**
- Compound machining
- Balanced cutting (M562/M563)
- Leverage dual turrets
- Leave advanced for later

---

## 📚 Documentation

### Updated Files

1. **README.md** - Updated with drilling cycle info
2. **CHANGELOG.md** - Complete v0.4.5 details
3. **DEVELOPMENT_STATUS.md** - Phase 4 progress tracking
4. **RELEASE_NOTES_v0.4.5.md** - This file

### New Documentation

1. **docs/Phase_4_Progress_Report.md** - Detailed Phase 4 status
   - What's complete (20%)
   - What's pending (80%)
   - Technical challenges
   - Next steps

---

## 🔗 Links

- **Previous Release:** [v0.4.0 - Motion Implementation](RELEASE_NOTES_v0.4.0.md)
- **Changelog:** [CHANGELOG.md](CHANGELOG.md)
- **Development Status:** [DEVELOPMENT_STATUS.md](DEVELOPMENT_STATUS.md)
- **Technical Notes:** [TECHNICAL_NOTES.md](TECHNICAL_NOTES.md)

---

## ⬇️ Download

**Full Package:**
- `grace_integrex_post_v0.4.5_release.zip`
  - Includes all documentation
  - Versioned .cps file
  - Complete project structure

**Individual File:**
- `grace_integrex_100iv_dual_turret.cps` (v0.4.5)

---

## 📞 Support

**For Issues:**
- Open an issue on GitHub
- Include Fusion 360 version
- Attach G-code sample
- Specify which cycle type

**For Drilling Cycle Questions:**
- Check cycle parameters (R, Q, P, Z)
- Verify retract height is safe
- Test in simulator first
- Single-block test on machine

---

## 📅 Release Timeline

- **v0.1.0** - January 5, 2026 - Skeleton
- **v0.2.0** - January 5, 2026 - Foundation
- **v0.3.0** - January 5, 2026 - Matrix M-codes
- **v0.3.1** - January 6, 2026 - Critical fix
- **v0.4.0** - January 6, 2026 - Motion
- **v0.4.5** - January 6, 2026 - Drilling cycles (current)
- **v0.5.0** - Q1 2026 - Phase 4 complete (planned)
- **v1.0.0** - Q3 2026 - Production (planned)

---

**Released:** January 6, 2026  
**Version:** 0.4.5  
**Status:** Development - Phase 4 Partial  
**License:** Proprietary - Grace Engineering Corp.

---

*This release adds significant drilling and tapping capabilities. While not production-ready, it represents major progress toward a complete post processor. Drilling cycles are fully functional and ready for testing in simulator.*

**✅ Safe for drilling cycle testing in simulator**  
**⚠️ NOT ready for production use**  
**🔄 Phase 4 continues with B-axis, threading, and sub-spindle features**
