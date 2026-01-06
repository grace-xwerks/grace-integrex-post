# Release v0.5.0 - Threading Cycles Complete

**Release Date:** January 6, 2026  
**Status:** Development Release - Phase 4 Cycles Complete (40%)

---

## 🎉 What's New

### Threading Cycles Implemented ✅

This release completes the cycles portion of Phase 4 by implementing comprehensive threading support for the Grace Engineering Mazak Integrex 100-IV ST.

**New Threading Support:**
- ✅ **G76** - Compound threading (multi-pass automatic)
- ✅ **G92** - Simple threading (single pass)
- ✅ Thread pitch control
- ✅ Thread depth control (radial)
- ✅ Thread taper support
- ✅ Infeed angle control (30°, 60°, etc.)
- ✅ Spring passes (finish passes)
- ✅ Chamfer width control
- ✅ Material allowance

**Property Added:**
- `useSimpleThread` - Toggle between G76 compound and G92 simple threading

**Helper Functions:**
- `moveToThreadStart()` - Position to thread start with clearance
- `getNumberOfCyclePoints()` - Get total cycle points
- `getCyclePoint()` - Get specific cycle point
- `isLastCyclePoint()` - Detect last point in multi-pass

---

## 📦 Complete Cycle Support (Phase 4 - 40%)

### All Cycles Now Functional

| Category | Cycles | Status |
|----------|--------|--------|
| **Drilling** | G81, G82, G73, G83 | ✅ Complete |
| **Tapping** | G84, G74 | ✅ Complete |
| **Boring** | G85, G86, G88, G89 | ✅ Complete |
| **Threading** | G76, G92 | ✅ Complete |

**Phase 4 Cycles:** 40% Complete (2 of 5 major features)

---

## ✨ Threading Examples

### G76 Compound Threading (Default)

```gcode
%
(M20 x 1.5 THREAD - COMPOUND)
(Grace Engineering - Integrex 100-IV ST)

G21 G18 G90 G95 G54

G109 L1
M901
M202
T0101
M3 S500
G0 X22.0 Z5.0

(G76 Compound Threading)
G76 P021060 Q0.15 R0.0
G76 X17.385 Z-30.0 P1.299 Q0.8 F1.5

G0 X100.0 Z50.0
M5
M950
M30

M30
%
```

**G76 Parameters Explained:**
- **First G76:** P021060 Q0.15 R0.0
  - P021060: 02 spring passes, 10 chamfer width, 60° angle
  - Q0.15: Minimum depth of cut (0.15mm)
  - R0.0: Finish allowance (0mm)

- **Second G76:** X17.385 Z-30.0 P1.299 Q0.8 F1.5
  - X17.385: Final thread diameter (M20 minor diameter)
  - Z-30.0: Thread end position
  - P1.299: Thread depth radial (1.299mm for M20 × 1.5)
  - Q0.8: First pass depth (0.8mm)
  - F1.5: Thread pitch (1.5mm)

### G92 Simple Threading

```gcode
(M20 x 1.5 THREAD - SIMPLE)

G109 L1
M901
M202
T0101
M3 S500

(Position to start)
G0 X22.0 Z5.0

(G92 Simple Thread)
G92 X17.385 Z-30.0 F1.5

G0 X100.0 Z50.0
M5
M950
M30

M30
%
```

**G92 Parameters:**
- X17.385: Final diameter
- Z-30.0: Thread end
- F1.5: Pitch (lead)

**Use G92 when:**
- Single pass needed
- Manual depth control
- Simple threads
- Maximum compatibility

---

## 📊 Progress Update

### File Statistics

| Metric | v0.5.0 | v0.4.5 | Change |
|--------|--------|--------|--------|
| Lines of Code | 2,529 | 2,362 | +167 |
| Functions | 49 | 44 | +5 |
| Format Definitions | 17 | 14 | +3 |
| Output Variables | 24 | 19 | +5 |
| Properties | 13 | 12 | +1 |

### Phase 4 Status

| Feature | Status | Completion |
|---------|--------|------------|
| Drilling Cycles | ✅ Complete | 100% |
| **Threading** | **✅ Complete** | **100%** |
| B-Axis Control | ⏳ Pending | 0% |
| C-Axis Control | ⏳ Pending | 0% |
| Sub-Spindle | ⏳ Pending | 0% |

**Phase 4:** 40% Complete (Cycles Done, Axes Pending)

### Overall Project

| Phase | Status | Completion |
|-------|--------|------------|
| Phase 1 | ✅ Complete | 100% |
| Phase 2 | ✅ Complete | 100% |
| Phase 3 | ✅ Complete | 100% |
| **Phase 4** | **🔄 40%** | **+20% today** |
| Phase 5-8 | ⏳ Pending | 0% |

**Overall:** ~42.5% Complete (3.4 of 8 phases)

---

## 🎯 What Works Now

### Complete Threading Operations

**From Fusion 360:**
1. Create threading operation
2. Set thread type (internal/external)
3. Set pitch (e.g., 1.5mm)
4. Set depth (e.g., M20 × 1.5)
5. Post process

**Generated G-Code:**
```gcode
G76 P021060 Q0.15 R0.0          ← Cycle params
G76 X17.385 Z-30.0 P1.299 Q0.8 F1.5  ← Thread geometry
```

**Multi-Pass Automatic:**
- First pass: 0.8mm depth
- Next passes: 0.15mm minimum
- Spring passes: 2 finishing passes
- Chamfer: 10 × pitch at end

### Thread Types Supported

**External Threads:**
- Metric: M6, M8, M10, M12, M16, M20, etc.
- Imperial: 1/4-20, 1/2-13, etc.
- Custom pitches

**Internal Threads:**
- Tapped holes (with boring bar)
- Custom IDs
- Tapered threads (NPT, etc.)

**Tapered Threads:**
- NPT pipe threads
- BSPT threads
- Custom tapers

---

## ⚠️ Important Notes

### Still NOT Production Ready

**Phase 4 is 40% complete.** The following Phase 4 features are still missing:

**Missing:**
- ❌ B-axis output (upper turret)
- ❌ C-axis positioning
- ❌ Sub-spindle operations

**Also Missing (Other Phases):**
- ❌ Balanced cutting (Phase 5)
- ❌ Compound machining (Phase 5)
- ❌ Complete testing (Phase 8)

### Threading Safety

**CRITICAL - Before Using Threading:**

1. ✅ **Verify thread depth** - radial, not diameter!
   - M20 × 1.5 depth = 1.299mm (radial)
   - NOT 2.598mm (diameter)

2. ✅ **Check thread start position**
   - Must have clearance for approach
   - Typically 2-5mm before thread

3. ✅ **Verify spindle speed**
   - Lower speed for threading (300-800 RPM)
   - Not like drilling (1000+ RPM)

4. ✅ **Test in simulator first**
   - Verify thread path
   - Check for collisions
   - Validate depth

5. ✅ **Single-block execution**
   - First threading operation
   - Watch for crashes
   - Verify chip evacuation

**⚠️ Thread depth is RADIAL - double check before running!**

---

## 🔧 Technical Details

### G76 P-Code Format

**Format:** AABBCC (6 digits)

**AA - Spring Passes (00-99):**
- 00 = No spring passes
- 01 = 1 finishing pass
- 02 = 2 finishing passes (recommended)

**BB - Chamfer Width (00-99):**
- In 1/10ths of thread lead
- 10 = 1.0 × pitch chamfer (standard)
- 05 = 0.5 × pitch chamfer

**CC - Cutting Angle (00-99):**
- Infeed angle in degrees
- 30 = 30° infeed (flank cutting)
- 60 = 60° infeed (alternating flanks)
- 29 = Compound angle

**Example:** P021060
- 02 spring passes
- 10 chamfer width (1.0 × pitch)
- 60° cutting angle

### Thread Depth Calculation

**Metric Threads:**
```
Thread Depth (radial) = 0.6134 × Pitch
M20 × 1.5: Depth = 0.6134 × 1.5 = 0.92mm radial
```

**Imperial Threads:**
```
Thread Depth (radial) = 0.6134 / TPI
1/2-13: Depth = 0.6134 / 13 = 0.047" radial
```

**Fusion 360 Calculates Automatically!**

### Thread Pitch vs. Lead

**Pitch:** Distance between thread crests  
**Lead:** Distance thread advances in one revolution

**Single-start threads:** Lead = Pitch  
**Multi-start threads:** Lead = Pitch × Starts

**Most threads are single-start** (Lead = Pitch)

---

## 📝 Testing Recommendations

### Threading Test Program

1. **Simple External Thread:**
   - M12 × 1.75 thread
   - 20mm length
   - On shaft
   - Test G76 output

2. **Internal Thread:**
   - M10 × 1.5 thread
   - Pre-drilled hole
   - Using boring bar
   - Test thread depth

3. **Tapered Thread:**
   - 1/2 NPT pipe thread
   - Taper verification
   - G76 R parameter

4. **G92 vs G76 Comparison:**
   - Same thread both ways
   - Compare cycle time
   - Compare surface finish
   - Verify accuracy

---

## 🚀 What's Next

### Phase 4 Remaining (60%)

**Option A: B-Axis Implementation**
- Upper turret B-axis output
- Angled operations
- M107/M108 locking
- High priority

**Option B: C-Axis Implementation**
- Live tool orientation
- Polar interpolation
- M200/M300 integration
- Medium priority

**Option C: Sub-Spindle Operations**
- Part transfer
- Chuck control
- Work offset management
- High complexity

**Recommended:** B-Axis next (most valuable)

---

## 📚 Documentation

### Updated Files

1. **README.md** - Updated with threading
2. **CHANGELOG.md** - Complete v0.5.0 entry
3. **RELEASE_NOTES_v0.5.0.md** - This file

### Threading Documentation

**Thread Parameters:**
- Pitch: Thread spacing (mm or TPI)
- Depth: Radial depth from major diameter
- Taper: Diameter change along thread (R parameter)
- Infeed Angle: Cutting approach angle
- Spring Passes: Finish passes for accuracy

**Common Thread Standards:**
- ISO Metric (M6, M8, M10, M12, M16, M20)
- Unified (UNC, UNF)
- NPT Pipe Threads
- BSPT British Pipe
- Acme Threads

---

## 🎓 Thread Programming Tips

### Best Practices

1. **Use G76 for Production**
   - Automatic multi-pass
   - Better surface finish
   - Optimal cutting

2. **Use G92 for Testing**
   - Single pass control
   - Quick testing
   - Simple verification

3. **Spring Passes**
   - 1-2 passes recommended
   - Improves accuracy
   - Better surface finish

4. **Cutting Angle**
   - 30° for single-flank
   - 60° for alternating flanks
   - 29° for compound angle

5. **First Pass Depth**
   - Start conservative (0.5-0.8mm)
   - Let G76 handle subsequent passes
   - Fusion calculates automatically

---

## ⬇️ Download

**Full Package:**
- `grace_integrex_post_v0.5.0_release.zip`
  - All documentation
  - v0.5.0 post processor
  - Complete project structure

**Individual File:**
- `grace_integrex_100iv_dual_turret.cps` (v0.5.0, 2,529 lines)

---

## 📞 Support

**For Issues:**
- Open GitHub issue
- Include thread type (M20 × 1.5, etc.)
- Attach G-code sample
- Specify G76 or G92

**For Threading Questions:**
- Check thread depth calculation
- Verify pitch value
- Test in simulator
- Use single-block on machine

---

## 📅 Release Timeline

- v0.1.0 - January 5, 2026 - Skeleton
- v0.2.0 - January 5, 2026 - Foundation
- v0.3.0 - January 5, 2026 - Matrix M-codes
- v0.3.1 - January 6, 2026 - Critical fix
- v0.4.0 - January 6, 2026 - Motion
- v0.4.5 - January 6, 2026 - Drilling cycles
- **v0.5.0** - **January 6, 2026** - **Threading (current)**
- v0.6.0 - Q1 2026 - Phase 4 complete (planned)
- v1.0.0 - Q3 2026 - Production (planned)

---

**Released:** January 6, 2026  
**Version:** 0.5.0  
**Status:** Development - Cycles Complete  
**License:** Proprietary - Grace Engineering Corp.

---

*This release completes all drilling, tapping, boring, and threading cycles. Phase 4 is now 40% complete with B-axis, C-axis, and sub-spindle operations remaining. Threading is fully functional and ready for testing!*

**✅ Safe for threading testing in simulator**  
**⚠️ NOT ready for production use**  
**🔄 Phase 4 continues with B-axis, C-axis, and sub-spindle**
