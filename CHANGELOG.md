# Changelog

All notable changes to the Grace Engineering Integrex 100-IV ST post processor will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### To Be Added
- B-axis output for upper turret positioning
- C-axis positioning for live tool orientation
- Sub-spindle part transfer operations
- Balanced cutting with M562/M563
- Cross-machining control with G110/G111
- P-code waiting (P1-P99999999)
- Advanced tool life management
- Extended work offsets (G54.1)

---

## [0.5.0] - 2026-01-06

### Added - Phase 4: Threading Cycles (Cycles Portion Complete - 40%)
- **G76** - Compound threading cycle (multi-pass automatic)
  - First G76 block: P(cycle params) Q(min cut) R(finish allowance)
  - Second G76 block: X(final) Z(end) R(taper) P(depth) Q(first cut) F(pitch)
  - Automatic calculation of stepdowns from cycle points
  - Infeed angle control (typically 30° × 2 = 60°)
  - Spring passes (finish passes) support
  - Chamfer width control
  - Material allowance for finish pass
- **G92** - Simple threading cycle (single pass)
  - Direct thread cutting with X, Z, R(taper), F(pitch)
  - Used for manual control or simple threads
- **useSimpleThread** property - Choose G92 or G76
- **moveToThreadStart()** helper - Position to thread start with clearance
- **getNumberOfCyclePoints()** helper - Get total cycle points
- **getCyclePoint()** helper - Get specific cycle point data
- **isLastCyclePoint()** helper - Detect last point in multi-pass threading

### Added - Threading Format Definitions
- **threadP1Format** - G76 P parameter (6-digit AABBCC format)
- **threadPQFormat** - G76 P/Q/R values (thread depth/cut/allowance)
- **g92RFormat** - G92 R taper parameter

### Added - Threading Output Variables
- **threadP1Output** - G76 cycle parameters (repeat/chamfer/angle)
- **threadP2Output** - G76 thread depth
- **threadQOutput** - G76 minimum/first cut depth
- **threadROutput** - G76 finish allowance or taper
- **g92ROutput** - G92 taper amount

### Changed
- Threading operations now use G76 compound threading by default
- Option to use G92 simple threading via useSimpleThread property
- Thread parameters automatically calculated from operation settings
- Multi-pass threading fully supported

### Technical Notes
- G76 P format: AABBCC where AA=spring passes, BB=chamfer width, CC=cutting angle
- Thread depth is radial (not diameter) as per Mazak specification
- Taper positive if taper goes down (increasing diameter toward end)
- First pass depth and minimum depth of cut auto-calculated
- Compatible with Autodesk Fusion threading operations

### File Statistics
- **Lines of Code:** 2,529 (+167 from v0.4.5)
- **Functions Added:** 5 threading helpers
- **New Formats:** 3 threading formats
- **New Output Variables:** 5 threading outputs
- **New Properties:** 1 (useSimpleThread)

### Phase 4 Cycles Status
- Drilling/Tapping/Boring: ✅ Complete (100%)
- Threading: ✅ Complete (100%)
- **Overall Cycles:** ✅ 40% Phase 4 Complete

### Still Needed in Phase 4
- B-Axis Control: ⏳ Pending (0%)
- C-Axis Control: ⏳ Pending (0%)
- Sub-Spindle: ⏳ Pending (0%)

---

## [0.4.5] - 2026-01-06

### Added - Phase 4: Drilling & Tapping Cycles (Partial)
- **onCycle()** function for cycle initialization
- **onCyclePoint()** function for drilling/tapping/boring operations
- **onCycleEnd()** function for cycle cancellation
- **G81** - Standard drilling cycle
- **G82** - Counter boring cycle (drilling with dwell)
- **G73** - High-speed peck drilling (chip breaking)
- **G83** - Peck drilling cycle (full retract)
- **G84/G74** - Tapping cycles (RH/LH)
- **G85** - Boring/reaming cycle
- **G86** - Boring with spindle stop and rapid retract
- **G88** - Manual boring cycle
- **G89** - Boring with dwell
- **repositionToCycleClearance()** helper for cycle positioning
- **getCommonCycle()** helper for cycle parameter formatting
- **clamp()** helper for value limiting
- **isFirstCyclePoint()** helper for multi-point cycles
- **getCurrentDirection()** helper for tool orientation
- **isProbeOperation()** helper for probe detection

### Added - Format Definitions
- **spatialFormat** - For cycle parameters (Q, R, P)
- **milliFormat** - For dwell times in milliseconds

### Added - Modal Groups
- **gRetractModal** - G98/G99 retract mode
- **gAbsIncModal** - G90/G91 absolute/incremental
- **gRotationModal** - For coordinate rotation

### Added - Cycle Tracking
- **cycleExpanded** - Track if cycle is linearized
- **cycleDirection** - Track cycle direction
- **cycleSubprogramIsActive** - Track subprogram state

### Changed
- Drilling operations now use canned cycles instead of linearization
- Tapping operations properly handle RH/LH orientation
- Boring cycles with proper spindle control

### Technical Notes
- Cycle parameters: R (retract), Q (peck depth), P (dwell ms)
- Multi-point cycles supported (drill patterns)
- Automatic cycle linearization fallback for unsupported cycles
- Plane selection automatic (G17/G18/G19)

### File Statistics
- **Lines of Code:** 2,362 (+336 from v0.4.0)
- **Functions Added:** 9
- **New Formats:** 2
- **New Modal Groups:** 3
- **Drilling Cycles:** 10 types implemented

### Phase 4 Status
- Drilling/Tapping/Boring: ✅ Complete (100%)
- B-Axis Control: ⏳ Pending (0%)
- C-Axis Control: ⏳ Pending (0%)
- Threading: ⏳ Pending (0%)
- Sub-Spindle: ⏳ Pending (0%)
- **Overall Phase 4:** 🔄 20% Complete

---

## [0.4.0] - 2026-01-06

### Added - Phase 3: Motion Implementation
- **onRapid()** function for G0 rapid positioning
- **onLinear()** function for G1 linear interpolation with feed control
- **onCircular()** function for G2/G3 circular interpolation
  - Radius mode (R___) support
  - IJK mode support
  - Plane selection (G17/G18/G19)
  - Arc linearization for complex cases
- **getFeed()** helper for feed rate management
- **getCurrentPosition()** helper for position tracking
- **getCircularPlane()** helper for automatic plane detection
- **linearize()** function for breaking complex arcs into segments
- **forceFeed()**, **forceXYZ()**, **forceABC()** helper functions
- **rFormat** format definition for arc radius values
- **iOutput**, **jOutput**, **kOutput** variables for IJK arc offsets
- **toDeg()** and **toRad()** conversion helpers

### Changed
- Y-axis now properly enabled/disabled per turret in motion functions
- Feed rate now respects G94/G95 mode (feed per min vs feed per rev)
- Motion functions integrate with machine state tracking

### Technical Notes
- Complete basic motion control now functional
- Supports turning operations (G18 plane, diameter mode)
- Supports milling operations (G17/G19 planes)
- Arc output matches Mazak Matrix specifications

### File Statistics
- **Lines of Code:** 2,026 (+250 from v0.3.1)
- **Functions Added:** 11 (3 major + 8 helpers)
- **New Formats:** 1 (rFormat)
- **New Outputs:** 3 (I, J, K)

---

## [0.3.1] - 2026-01-06

### Fixed - CRITICAL
- **xFormat diameter mode fix:** Added `type:FORMAT_REAL` and `scale:2` to xFormat
  - Ensures X-axis values output as diameters instead of radius
  - Example: 25mm radius now correctly outputs as X50.0 (diameter)
  - **Impact:** Without this fix, all turning operations would produce parts 50% undersize
  - See `docs/xformat_fix_documentation.md` for detailed explanation

### Added
- Comprehensive documentation of diameter mode issue and fix
- Technical explanation with examples

### Changed
- xFormat definition now matches reference post implementation
- Added inline comments explaining diameter mode scaling

---

## [0.3.0] - 2026-01-05

### Added - Phase 2: Matrix Control M-Codes
- **G109 L1/L2** turret selection implementation in onSection()
- **M901/M902** spindle selection (1st/2nd spindle)
- **M200/M300** milling mode enable for 1st/2nd spindle
- **M202/M302** milling mode disable for 1st/2nd spindle
- **M203** milling spindle normal rotation with speed
- **M950** waiting code for turret synchronization
- Complete **onSection()** implementation
  - Turret selection and switching
  - Spindle selection
  - Milling mode control
  - Tool changes with T-codes
  - Tool ID code support (D-code)
  - Work offset selection (G54-G59)
  - Spindle start with speed validation
  - Feed mode selection (G94/G95)
  - Coolant control
- Complete **onSectionEnd()** implementation
  - Spindle stop
  - Milling mode disable
  - Coolant off
  - M950 synchronization (when needed)
  - M30 section termination

### Added - Helper Functions
- **getSpindle()** - Determine TOOL or PART spindle
- **getToolTypeName()** - Get human-readable tool type
- **isFirstSection()** / **isLastSection()** - Section position checks
- **isToolChangeNeeded()** - Tool change detection
- **isNewWorkOffset()** - Work offset change detection
- **isNewWorkPlane()** - Work plane change detection
- **isNewSpindle()** - Spindle change detection
- **forceWorkPlane()** - Force work plane reset
- **setCoolant()** - Coolant control (basic implementation)

### Changed
- Machine state tracking now fully integrated
- Section management complete
- Tool management complete
- Program structure now matches Matrix control compound machining format

### Technical Notes
- G109 structure follows Mazak programming manual specification
- Each turret section properly terminated with M30
- M950 automatically inserted when turret changes
- Spindle speeds validated against machine limits

---

## [0.2.0] - 2026-01-05

### Added - Phase 1: Foundation Setup
- Complete **onOpen()** implementation
  - Program header with machine identification
  - Grace Engineering branding
  - Machine configuration summary
  - Critical operator warnings
  - Initial G-codes (G21/G20, G18, G90, G94, G49, G54)
  - Mazak Matrix program start/end characters (%)
- Complete **onClose()** implementation
  - Spindle stop all (main, sub, live)
  - Milling mode disable
  - Coolant off
  - Return to home position (G53)
  - M30 program end
  - Safety checks
- **defineMachine()** function with Grace Engineering specifications
  - Dual turret configuration (gotMultiTurret = true)
  - Y-axis on both turrets (±105mm)
  - B-axis on upper turret only (0-90°)
  - Sub-spindle support
  - Spindle speed limits (5060/6000/12000 RPM)
  - Axis travel limits from i-100S specification
- **activateMachine()** function for turret-specific configuration
  - Per-turret axis enable/disable
  - B-axis availability per turret
  - Machine configuration setup
  - Spindle axis definition
  - Linear axis limits
  - TCP settings

### Changed
- Updated all header documentation
- Clarified that this is a standalone, definitive post (no external files)
- Added axis travel specifications to header

---

## [0.1.0] - 2026-01-05

### Added - Initial Skeleton
- Basic post processor structure
- Header with comprehensive machine documentation
- Property definitions for user configuration
  - controllerType (Matrix/Smooth)
  - maximumSpindleSpeedMain (5060 RPM)
  - maximumSpindleSpeedSub (6000 RPM)
  - maximumSpindleSpeedLive (12000 RPM)
  - showSequenceNumbers
  - sequenceNumberStart/Increment
  - useRadius (arc format)
  - useCycles
  - optionalStop
  - homePositionZ/homePositionSubZ
- Format definitions
  - G/M/N code formats
  - X/Y/Z coordinate formats
  - B/C rotary axis formats
  - Feed, spindle, tool formats
- Global variables
  - Machine configuration flags
  - Turret configuration
  - Spindle limits
  - Axis limits
- Machine state tracking object
- Complete **getCode()** function with all Matrix M-codes
  - Spindle selection (M901/M902)
  - Milling mode (M200/M300/M202/M302)
  - Spindle rotation (M203/M204/M303/M304/M3/M4/M5/M205/M305)
  - Chuck control (M206/M207/M306/M307)
  - Spindle clamping (M210/M212/M310/M312)
  - B-axis control (M107/M108)
  - Polar interpolation (G12.1/G13.1)
  - Feed modes (G94/G95)
  - CSS (G96/G97)
  - Synchronization (M511/M513)
  - Torque control (M508/M509)
  - Part catcher (M248/M249)
  - Tailstock (M841/M843)
  - Coolant (M129/M9)
  - Balanced cutting (M562/M563)
- Utility functions
  - writeBlock() with sequence number support
  - writeComment() / formatComment()
  - formatSequenceNumber()
- Function stubs for main callbacks
  - onOpen() - stub
  - onClose() - stub
  - onSection() - stub
  - onSectionEnd() - stub
  - onLinear() - stub
  - onRapid() - stub
  - onCircular() - stub

### Technical Foundation
- Based on `mazak_integrex_i-100s.cps` reference post
- Configured specifically for Grace Engineering IN1004ST
- All machine parameters from adjusted parameter sheet (Serial 195369)
- Heavily commented for maintainability

---

## Version Naming Convention

This post processor uses semantic versioning:

- **Major (X.0.0):** Complete redesign, breaking changes
- **Minor (0.X.0):** New features, phase completions
- **Patch (0.0.X):** Bug fixes, minor improvements

### Phase Correlation
- v0.1.0 - Skeleton
- v0.2.0 - Phase 1 Complete
- v0.3.0 - Phase 2 Complete
- v0.3.1 - Critical Fix
- v0.4.0 - Phase 3 Complete
- v0.5.0 - Phase 4 Complete (planned)
- v0.6.0 - Phase 5 Complete (planned)
- v0.7.0 - Phase 6 Complete (planned)
- v0.8.0 - Phase 7 Complete (planned)
- v0.9.0 - Phase 8 Complete (planned)
- v1.0.0 - Production Release

---

## Links

- [Development Status](DEVELOPMENT_STATUS.md)
- [Technical Notes](TECHNICAL_NOTES.md)
- [README](README.md)
