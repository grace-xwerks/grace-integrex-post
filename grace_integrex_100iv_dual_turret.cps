/**
 * ============================================================================
 * GRACE ENGINEERING - MAZAK INTEGREX 100-IV ST DUAL TURRET POST PROCESSOR
 * ============================================================================
 * 
 * IMPORTANT: This is a STANDALONE, DEFINITIVE post processor.
 *            ALL machine definitions are contained within this file.
 *            NO external machine definition files are used or required.
 *            This is the single source of truth for this machine.
 * 
 * Machine: Mazak Integrex 100-IV ST (Model IN1004ST)
 * Serial: 195369
 * Control: Mazak Matrix (Matrix Nexus)
 * Customer: Grace Engineering Corp
 * 
 * MACHINE CONFIGURATION:
 * - Upper Turret (HD1/TR1): Y-axis (±105mm), B-axis (0-90°), C-axis, Live tools
 * - Lower Turret (HD2/TR2): Y-axis (±105mm), C-axis, Live tools
 * - Main Spindle: 5,060 RPM max (Kitagawa 6" 3-jaw chuck)
 * - Sub Spindle: 6,000 RPM max (Standard chuck)
 * - Live Tooling: 12,000 RPM max (both turrets)
 * 
 * AXIS TRAVELS (from Integrex i-100S specifications):
 * - X-axis: -50mm minimum (radius mode), no maximum limit check
 * - Y-axis: -105mm to +105mm (both turrets)
 * - Z-axis: Software limits only (±100000mm for calculation purposes)
 * - B-axis: 0° to 90° (upper turret only)
 * - C-axis: 0° to 360° (cyclic, both spindles)
 * 
 * DEVELOPMENT PHASES:
 * [X] Phase 1: Foundation Setup (Multi-turret enabled, Y-axes, spindle limits)
 *     - onOpen() implemented with program header and initialization
 *     - onClose() implemented with safe shutdown sequence
 *     - Machine configuration function complete
 *     - Turret activation function complete
 * [X] Phase 2: Matrix Control M-Codes (G109, M901/M902, M200/M300, M562/M563)
 *     - G109 L1/L2 turret selection implemented
 *     - M901/M902 spindle selection implemented
 *     - M200/M300/M202/M302 milling mode control implemented
 *     - M203 milling spindle rotation implemented
 *     - M950 waiting code for turret synchronization implemented
 *     - Tool change (T-codes) and tool ID codes implemented
 *     - Work offset (G54-G59) implemented
 *     - Spindle start/stop with speed limits enforced
 *     - onSection() and onSectionEnd() fully functional
 * [X] Phase 3: Motion Implementation (Linear, Rapid, Circular)
 *     - onRapid() implemented (G0 rapid positioning)
 *     - onLinear() implemented (G1 linear interpolation with feed)
 *     - onCircular() implemented (G2/G3 arc interpolation)
 *     - Radius mode (R___) and IJK mode support
 *     - Plane selection (G17/G18/G19)
 *     - Arc linearization for complex cases
 *     - Feed rate management (G94/G95)
 *     - Y-axis output per turret (enabled/disabled based on turret)
 * [🔄] Phase 4: Advanced Operation Logic (Cycles, Sub-spindle, Threading)
 *     - onCycle() implemented (cycle setup)
 *     - onCyclePoint() implemented (drilling, tapping, boring, threading)
 *     - onCycleEnd() implemented (G80 cancel)
 *     - G81 - Drilling cycle
 *     - G82 - Counter boring (drilling with dwell)
 *     - G73 - High-speed peck drilling
 *     - G83 - Peck drilling (full retract)
 *     - G84/G74 - Tapping (RH/LH)
 *     - G85 - Boring/Reaming
 *     - G86 - Boring with spindle stop
 *     - G88 - Manual boring
 *     - G89 - Boring with dwell
 *     - G76 - Compound threading (multi-pass)
 *     - G92 - Simple threading (single pass)
 *     - Thread depth, pitch, taper, infeed angle
 *     - Threading helper functions
 *     - Cycle parameter handling (R, Q, P)
 *     - [ ] B-axis control (upper turret)
 *     - [ ] C-axis positioning
 *     - [ ] Sub-spindle operations
 * [ ] Phase 5: Compound Machining (Separate, Parallel, Balanced cutting)
 * [ ] Phase 6: Tool Management (Advanced offsets, turret-specific libraries)
 * [ ] Phase 7: Work Coordinate Systems (Advanced WCS, spindle offsets)
 * [ ] Phase 8: Testing & Validation
 * 
 * Version: 0.5.0 - Phase 4 Cycles Complete
 * Date: January 2026
 * Status: DEVELOPMENT - All cycles functional (drilling, tapping, threading)
 * Author: Grace Engineering / Claude AI
 * 
 * CHANGELOG:
 * v0.5.0 - Phase 4 Cycles Complete: Threading cycles implemented
 *          - G76 compound threading (multi-pass with automatic stepdown)
 *          - G92 simple threading (single pass)
 *          - Thread depth, pitch, taper support
 *          - Infeed angle control
 *          - Spring passes (finish passes)
 *          - useSimpleThread property (G92 vs G76)
 *          - Threading helper functions
 *          - Phase 4 Cycles: 40% complete (drilling + threading done)
 * v0.4.5 - Phase 4 Partial: Drilling and tapping cycles implemented
 *          - onCycle(), onCyclePoint(), onCycleEnd() complete
 *          - G81-G89 drilling/tapping/boring cycles
 *          - Cycle parameter handling (R, Q, P)
 *          - Cycle linearization fallback
 * v0.4.0 - Phase 3 Complete: Motion functions implemented (G0, G1, G2, G3)
 * v0.3.1 - Critical Fix: Added scale:2 to xFormat for diameter mode
 *          This ensures X-axis values are output as diameters (not radius)
 *          Example: Radius 25mm → Output X50.0 (diameter)
 * v0.3.0 - Phase 2 Complete: Matrix M-Codes implemented
 * v0.2.0 - Phase 1 Complete: Foundation setup
 * v0.1.0 - Initial skeleton structure
 * 
 * ============================================================================
 */

// ============================================================================
// SECTION 1: BASIC POST PROCESSOR INFORMATION
// ============================================================================

description = "Grace Engineering - Integrex 100-IV ST Dual Turret";
vendor = "Mazak";
vendorUrl = "https://www.mazak.com";
legal = "Copyright (C) 2026 by Grace Engineering Corp.";
certificationLevel = 2;
minimumRevision = 45909;

longDescription = "Custom post processor for Grace Engineering Mazak Integrex 100-IV ST " +
                  "with dual turrets (upper and lower), Y-axes on both turrets, B-axis on " +
                  "upper turret, and sub-spindle. Matrix (Nexus) control.";

extension = "eia";               // Output file extension (.eia for Mazak Matrix)
programNameIsInteger = false;    // Program names can include letters
setCodePage("ascii");            // Character encoding

// Define machine capabilities
capabilities = CAPABILITY_MILLING | CAPABILITY_TURNING;
tolerance = spatial(0.002, MM);

// Circular motion parameters
minimumChordLength = spatial(0.25, MM);
minimumCircularRadius = spatial(0.01, MM);
maximumCircularRadius = spatial(1000, MM);
minimumCircularSweep = toRad(0.01);
maximumCircularSweep = toRad(180);
allowHelicalMoves = true;
allowedCircularPlanes = undefined; // Allow any circular motion
allowSpiralMoves = false;
allowFeedPerRevolutionDrilling = true;
highFeedrate = (unit == IN) ? 400 : 5000;

// ============================================================================
// SECTION 2: USER-CONFIGURABLE PROPERTIES
// ============================================================================
// These properties appear in the Autodesk Fusion post processor dialog

properties = {
  //--------------------------------------------------------------------------
  // MACHINE CONFIGURATION GROUP
  //--------------------------------------------------------------------------
  controllerType: {
    title      : "Controller model",
    description: "Select the controller model",
    group      : "configuration",
    type       : "enum",
    values     : [
      "Matrix",      // Matrix Nexus (our machine)
      "Smooth"       // Smooth control (not our machine, but kept for compatibility)
    ],
    value      : "Matrix",  // Default to Matrix for Grace Engineering machine
    scope      : "post"
  },

  // Main spindle maximum RPM (Kitagawa 6" 3-jaw chuck limitation)
  maximumSpindleSpeedMain: {
    title      : "Max spindle speed (Main)",
    description: "Maximum RPM for main spindle (limited by Kitagawa 6\" chuck)",
    group      : "configuration",
    type       : "integer",
    range      : [0, 10000],
    value      : 5060,      // Grace Engineering specific: Kitagawa chuck limit
    scope      : "post"
  },

  // Sub-spindle maximum RPM
  maximumSpindleSpeedSub: {
    title      : "Max spindle speed (Sub)",
    description: "Maximum RPM for sub-spindle",
    group      : "configuration",
    type       : "integer",
    range      : [0, 10000],
    value      : 6000,      // Grace Engineering specific: Sub-spindle limit
    scope      : "post"
  },

  // Live tooling maximum RPM (both turrets)
  maximumSpindleSpeedLive: {
    title      : "Max spindle speed (Live tooling)",
    description: "Maximum RPM for live tooling on both turrets",
    group      : "configuration",
    type       : "integer",
    range      : [0, 20000],
    value      : 12000,     // Grace Engineering specific: Live tool limit
    scope      : "post"
  },

  // Part catcher control
  usePartCatcher: {
    title      : "Use part catcher",
    description: "Output part catcher M-codes during part-off operations",
    group      : "configuration",
    type       : "boolean",
    value      : true,
    scope      : "post"
  },

  // Tailstock (if equipped - verify with Grace Engineering)
  useTailStock: {
    title      : "Use tailstock",
    description: "Enable tailstock support M-codes",
    group      : "configuration",
    type       : "boolean",
    value      : false,     // TODO: Verify if Grace machine has tailstock
    scope      : "post"
  },

  //--------------------------------------------------------------------------
  // FORMATTING GROUP
  //--------------------------------------------------------------------------
  showSequenceNumbers: {
    title      : "Use sequence numbers",
    description: "Output N-codes on blocks",
    group      : "formats",
    type       : "enum",
    values     : [
      {title:"Yes", id:"true"},
      {title:"No", id:"false"},
      {title:"Only on tool change", id:"toolChange"}
    ],
    value      : "toolChange",
    scope      : "post"
  },

  sequenceNumberStart: {
    title      : "Start sequence number",
    description: "First sequence number (N-code)",
    group      : "formats",
    type       : "integer",
    value      : 10,
    scope      : "post"
  },

  sequenceNumberIncrement: {
    title      : "Sequence number increment",
    description: "Increment value for each N-code",
    group      : "formats",
    type       : "integer",
    value      : 10,
    scope      : "post"
  },

  //--------------------------------------------------------------------------
  // PREFERENCES GROUP
  //--------------------------------------------------------------------------
  useRadius: {
    title      : "Radius arcs",
    description: "Output arcs using R instead of IJK",
    group      : "preferences",
    type       : "boolean",
    value      : true,
    scope      : "post"
  },

  useCycles: {
    title      : "Use canned cycles",
    description: "Use G-code drilling cycles (G83, G87, etc.)",
    group      : "preferences",
    type       : "boolean",
    value      : true,
    scope      : "post"
  },

  useSimpleThread: {
    title      : "Use simple threading",
    description: "Use G92 simple threading instead of G76 compound threading",
    group      : "preferences",
    type       : "boolean",
    value      : false,
    scope      : "post"
  },

  optionalStop: {
    title      : "Optional stop",
    description: "Output M01 optional stop codes",
    group      : "preferences",
    type       : "boolean",
    value      : true,
    scope      : "post"
  },

  //--------------------------------------------------------------------------
  // HOME POSITIONS GROUP
  //--------------------------------------------------------------------------
  homePositionZ: {
    title      : "G53 home position Z (Main spindle)",
    description: "Z-axis machine coordinate for home position",
    group      : "homePositions",
    type       : "number",
    value      : 0,
    scope      : "post"
  },

  homePositionSubZ: {
    title      : "G53 home position Z (Sub-spindle)",
    description: "Z-axis machine coordinate for sub-spindle home",
    group      : "homePositions",
    type       : "number",
    value      : 0,
    scope      : "post"
  }
};

// ============================================================================
// SECTION 3: FORMAT DEFINITIONS
// ============================================================================
// Define how numeric values are formatted in the output

var gFormat = createFormat({prefix:"G", decimals:1});
var mFormat = createFormat({prefix:"M", decimals:0});
var nFormat = createFormat({prefix:"N", decimals:0});

// CRITICAL: xFormat uses scale:2 for DIAMETER MODE in turning operations
// This means Fusion outputs radius values (e.g., 25mm) but the machine expects
// diameter values (e.g., X50.). The scale:2 multiplies radius by 2 for output.
var xFormat = createFormat({decimals:(unit == MM ? 3 : 4), type:FORMAT_REAL, scale:2, forceDecimal:true});
var yFormat = createFormat({decimals:(unit == MM ? 3 : 4), type:FORMAT_REAL, forceDecimal:true});
var zFormat = createFormat({decimals:(unit == MM ? 3 : 4), type:FORMAT_REAL, forceDecimal:true});
var xyzFormat = createFormat({decimals:(unit == MM ? 3 : 4), type:FORMAT_REAL, forceDecimal:true});
var bFormat = createFormat({prefix:"B", decimals:3, type:FORMAT_REAL, forceDecimal:true, scale:DEG});
var cFormat = createFormat({prefix:"C", decimals:3, type:FORMAT_REAL, forceDecimal:true, scale:DEG});

var feedFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:true});
var pitchFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:true});
var rFormat = createFormat({decimals:(unit == MM ? 3 : 4), type:FORMAT_REAL, forceDecimal:true}); // Radius for arcs
var spatialFormat = createFormat({decimals:(unit == MM ? 3 : 4), type:FORMAT_REAL});  // For cycle parameters
var milliFormat = createFormat({decimals:0});  // Milliseconds for dwell
var threadP1Format = createFormat({decimals:0, minDigitsLeft:6}); // G76 P parameter (AABBCC format)
var threadPQFormat = createFormat({decimals:(unit == MM ? 3 : 4), type:FORMAT_REAL}); // G76 P/Q/R values
var g92RFormat = createFormat({decimals:(unit == MM ? 3 : 4), type:FORMAT_REAL}); // G92 R taper
var toolFormat = createFormat({decimals:0});
var rpmFormat = createFormat({decimals:0});
var secFormat = createFormat({decimals:3, forceDecimal:true});
var taperFormat = createFormat({decimals:1, scale:DEG});

var xOutput = createVariable({prefix:"X"}, xFormat);
var yOutput = createVariable({prefix:"Y"}, yFormat);
var zOutput = createVariable({prefix:"Z"}, zFormat);
var aOutput = createVariable({prefix:"A"}, bFormat);  // Note: A is disabled, but defined
var bOutput = createVariable({prefix:"B"}, bFormat);
var cOutput = createVariable({prefix:"C"}, cFormat);
var iOutput = createVariable({prefix:"I", force:true}, xyzFormat);  // Arc center offset X
var jOutput = createVariable({prefix:"J", force:true}, xyzFormat);  // Arc center offset Y
var kOutput = createVariable({prefix:"K", force:true}, xyzFormat);  // Arc center offset Z
var feedOutput = createVariable({prefix:"F"}, feedFormat);
var pitchOutput = createVariable({prefix:"F"}, pitchFormat);
var sOutput = createVariable({prefix:"S", force:true}, rpmFormat);

// Threading output variables
var threadP1Output = createVariable({prefix:"P", force:true}, threadP1Format);  // G76 P (cycle params)
var threadP2Output = createVariable({prefix:"P", force:true}, threadPQFormat);  // G76 P (thread depth)
var threadQOutput = createVariable({prefix:"Q", force:true}, threadPQFormat);   // G76 Q (depth/pass)
var threadROutput = createVariable({prefix:"R", force:true}, threadPQFormat);   // G76 R (allowance/taper)
var g92ROutput = createVariable({prefix:"R", force:true}, g92RFormat);         // G92 R (taper)

// Modal groups (these prevent redundant output of G/M codes)
var gMotionModal = createModal({}, gFormat);
var gPlaneModal = createModal({onchange:function () {gMotionModal.reset();}}, gFormat);
var gFeedModeModal = createModal({}, gFormat);
var gSpindleModeModal = createModal({}, gFormat);
var gUnitModal = createModal({}, gFormat);
var gCycleModal = createModal({}, gFormat);
var gRetractModal = createModal({}, gFormat);
var gAbsIncModal = createModal({}, gFormat);
var gRotationModal = createModal({}, gFormat);
var gPolarModal = createModal({}, gFormat);

// ============================================================================
// SECTION 4: GLOBAL VARIABLES
// ============================================================================

// Machine configuration flags - set by defineMachine()
var gotMultiTurret = true;              // TRUE for Grace Engineering (dual turret)
var gotSecondarySpindle = true;         // TRUE for Grace Engineering (sub-spindle)
var turret1GotYAxis = true;             // TRUE - Upper turret has Y-axis
var turret2GotYAxis = true;             // TRUE - Lower turret has Y-axis
var turret1GotBAxis = true;             // TRUE - Upper turret has B-axis
var turret2GotBAxis = false;            // FALSE - Lower turret does NOT have B-axis
var gotBAxis = true;                    // Initially true, changes per turret
var gotYAxis = true;                    // Initially true, changes per turret
var bAxisIsManual = false;              // FALSE - B-axis is programmable

// Axis travel limits (set by defineMachine())
var yAxisMinimum;                       // Will be set to -105mm
var yAxisMaximum;                       // Will be set to +105mm
var xAxisMinimum;                       // Will be set per machine (radius value)

// Spindle speed limits (verified from Grace Engineering parameter sheet)
var maximumSpindleSpeedMain = 5060;     // Main spindle (Kitagawa 6" chuck)
var maximumSpindleSpeedSub = 6000;      // Sub-spindle
var maximumSpindleSpeedLive = 12000;    // Live tooling (both turrets)

// Current active turret (1=Upper, 2=Lower)
var activeTurret = 1;

// Sequence number tracking
var sequenceNumber;
var showSequenceNumbers;

// Tool tracking
var currentTool;
var lastSpindleSpeed = 0;
var lastSpindleDirection;

// Cycle tracking
var cycleExpanded = false;
var cycleDirection = new Vector(0, 0, 0);
var cycleSubprogramIsActive = false;

// Operational state flags
var optionalSection = false;
var operationSupportsTCP = false;

// ============================================================================
// SECTION 5: MACHINE STATE TRACKING
// ============================================================================
// This object tracks the current state of the machine to avoid redundant
// M-codes and ensure proper sequencing

var machineState = {
  // Turret state
  currentTurret                 : 1,          // 1=Upper, 2=Lower
  
  // Spindle states
  liveToolIsActive              : undefined,  // Live tool spindle active?
  mainSpindleIsActive           : undefined,  // Main spindle active?
  subSpindleIsActive            : undefined,  // Sub-spindle active?
  mainSpindleBrakeIsActive      : undefined,  // Main spindle brake engaged?
  subSpindleBrakeIsActive       : undefined,  // Sub-spindle brake engaged?
  
  // Chuck/clamping states
  mainChuckIsClamped            : undefined,  // Main chuck clamped?
  subChuckIsClamped             : undefined,  // Sub-chuck clamped?
  
  // Axis states
  cAxisIsEngaged                : undefined,  // C-axis mode active?
  tailstockIsActive             : false,      // Tailstock engaged?
  
  // Milling mode states
  usePolarInterpolation         : false,      // G12.1 polar mode active?
  usePolarCoordinates           : false,      // XZC coordinate mode?
  axialCenterDrilling           : false,      // Center drilling mode?
  currentBAxisOrientationTurning: new Vector(0, 0, 0),
  
  // Spindle synchronization states
  spindlesAreAttached           : false,      // Spindles mechanically connected?
  spindlesAreSynchronized       : false,      // Spindle speed sync active?
  stockTransferIsActive         : false,      // Part transfer in progress?
  cAxesAreSynchronized          : false,      // C-axes synchronized?
  
  // Feed mode
  feedPerRevolution             : undefined,  // G95 (feed per rev) vs G94 (feed per min)
  
  // Turret balancing
  turretsAreBalanced            : false,      // M562 balanced cutting active?
  
  // Other
  isTurning                     : false,      // Current operation is turning?
  isMilling                     : false       // Current operation is milling?
};

// ============================================================================
// SECTION 6: M-CODE DEFINITIONS (MATRIX CONTROL SPECIFIC)
// ============================================================================
/**
 * Returns the appropriate M-code for a given command
 * @param {string} code - Command identifier
 * @param {number} spindle - SPINDLE_MAIN or SPINDLE_SUB
 * @returns {number} - M-code number
 */
function getCode(code, spindle) {
  switch (code) {
  
  //--------------------------------------------------------------------------
  // SPINDLE SELECTION (Matrix Control Specific)
  //--------------------------------------------------------------------------
  case "SELECT_SPINDLE_MAIN":
    return 901;  // M901 - Select 1st spindle (main)
  
  case "SELECT_SPINDLE_SUB":
    return 902;  // M902 - Select 2nd spindle (sub)

  //--------------------------------------------------------------------------
  // MILLING MODE CONTROL (Matrix Control Specific)
  //--------------------------------------------------------------------------
  case "ENABLE_C_AXIS":  // Enable milling mode
    machineState.cAxisIsEngaged = true;
    // M200 = Milling mode ON for 1st spindle
    // M300 = Milling mode ON for 2nd spindle
    return (spindle == SPINDLE_MAIN) ? 200 : 300;
  
  case "DISABLE_C_AXIS":  // Disable milling mode
    machineState.cAxisIsEngaged = false;
    // M202 = Milling mode OFF for 1st spindle
    // M302 = Milling mode OFF for 2nd spindle
    return (spindle == SPINDLE_MAIN) ? 202 : 302;

  //--------------------------------------------------------------------------
  // SPINDLE ROTATION
  //--------------------------------------------------------------------------
  case "START_SPINDLE_CW":
    switch (spindle) {
    case SPINDLE_MAIN:
      machineState.mainSpindleIsActive = true;
      return 203;  // M203 - Main spindle CW (also milling spindle normal rotation)
    case SPINDLE_SUB:
      machineState.subSpindleIsActive = true;
      return 303;  // M303 - Sub-spindle CW
    case SPINDLE_LIVE:
      machineState.liveToolIsActive = true;
      return 3;    // M3 - Live tool CW
    }
    break;
  
  case "START_SPINDLE_CCW":
    switch (spindle) {
    case SPINDLE_MAIN:
      machineState.mainSpindleIsActive = true;
      return 204;  // M204 - Main spindle CCW
    case SPINDLE_SUB:
      machineState.subSpindleIsActive = true;
      return 304;  // M304 - Sub-spindle CCW
    case SPINDLE_LIVE:
      machineState.liveToolIsActive = true;
      return 4;    // M4 - Live tool CCW
    }
    break;
  
  case "STOP_SPINDLE":
    lastSpindleSpeed = 0;
    lastSpindleDirection = undefined;
    sOutput.reset();
    switch (spindle) {
    case SPINDLE_MAIN:
      machineState.mainSpindleIsActive = false;
      return 205;  // M205 - Main spindle stop
    case SPINDLE_SUB:
      machineState.subSpindleIsActive = false;
      return 305;  // M305 - Sub-spindle stop
    case SPINDLE_LIVE:
      machineState.liveToolIsActive = false;
      return 5;    // M5 - Live tool stop
    }
    break;

  //--------------------------------------------------------------------------
  // CHUCK CONTROL
  //--------------------------------------------------------------------------
  case "CLAMP_CHUCK":
    return (spindle == SPINDLE_MAIN) ? 207 : 307;  // M207/M307
  
  case "UNCLAMP_CHUCK":
    return (spindle == SPINDLE_MAIN) ? 206 : 306;  // M206/M306

  //--------------------------------------------------------------------------
  // SPINDLE CLAMPING (for C-axis positioning)
  //--------------------------------------------------------------------------
  case "CLAMP_SPINDLE":
    return (spindle == SPINDLE_MAIN) ? 210 : 310;  // M210/M310
  
  case "UNCLAMP_SPINDLE":
    return (spindle == SPINDLE_MAIN) ? 212 : 312;  // M212/M312

  //--------------------------------------------------------------------------
  // B-AXIS CONTROL (Upper turret only)
  //--------------------------------------------------------------------------
  case "LOCK_B_AXIS":
    return 107;  // M107 - Lock B-axis
  
  case "UNLOCK_B_AXIS":
    return 108;  // M108 - Unlock B-axis

  //--------------------------------------------------------------------------
  // MULTI-AXIS CONTROL
  //--------------------------------------------------------------------------
  case "LOCK_MULTI_AXIS":
    return spindle == SPINDLE_MAIN ? 14 : 114;
  
  case "UNLOCK_MULTI_AXIS":
    return spindle == SPINDLE_MAIN ? 15 : 115;

  //--------------------------------------------------------------------------
  // POLAR INTERPOLATION (Matrix Control)
  //--------------------------------------------------------------------------
  case "POLAR_INTERPOLATION_ON":
    // G12.1 activates polar interpolation
    // P2 specifies 2nd spindle (sub-spindle)
    return (spindle == SPINDLE_MAIN) ? gPolarModal.format(12.1) : gPolarModal.format(12.1) + " P2";
  
  case "POLAR_INTERPOLATION_OFF":
    return gPolarModal.format(13.1);  // G13.1 deactivates polar interpolation

  //--------------------------------------------------------------------------
  // FEED MODE
  //--------------------------------------------------------------------------
  case "FEED_MODE_UNIT_REV":
    machineState.feedPerRevolution = true;
    return 95;  // G95 - Feed per revolution
  
  case "FEED_MODE_UNIT_MIN":
    machineState.feedPerRevolution = false;
    return 94;  // G94 - Feed per minute

  //--------------------------------------------------------------------------
  // CONSTANT SURFACE SPEED
  //--------------------------------------------------------------------------
  case "CONSTANT_SURFACE_SPEED_ON":
    return 96;  // G96 - CSS on
  
  case "CONSTANT_SURFACE_SPEED_OFF":
    return 97;  // G97 - CSS off

  //--------------------------------------------------------------------------
  // SPINDLE SYNCHRONIZATION (for part transfer)
  //--------------------------------------------------------------------------
  case "SPINDLE_SYNCHRONIZATION_PHASE":
    return 511;  // M511 - Phase synchronization
  
  case "SPINDLE_SYNCHRONIZATION_PHASE_OFF":
    return 513;  // M513 - Stop synchronization
  
  case "SPINDLE_SYNCHRONIZATION_SPEED":
    return 511;  // M511 - Speed synchronization
  
  case "SPINDLE_SYNCHRONIZATION_SPEED_OFF":
    return 513;  // M513 - Stop synchronization

  //--------------------------------------------------------------------------
  // TORQUE CONTROL (for part transfer)
  //--------------------------------------------------------------------------
  case "TORQUE_SKIP_ON":
    return 508;  // M508 - Torque skip on
  
  case "TORQUE_SKIP_OFF":
    return 509;  // M509 - Torque skip off

  //--------------------------------------------------------------------------
  // PART CATCHER
  //--------------------------------------------------------------------------
  case "PART_CATCHER_ON":
    return 248;  // M248 - Part catcher forward
  
  case "PART_CATCHER_OFF":
    return 249;  // M249 - Part catcher back

  //--------------------------------------------------------------------------
  // TAILSTOCK
  //--------------------------------------------------------------------------
  case "TAILSTOCK_ON":
    machineState.tailstockIsActive = true;
    return 841;  // M841 - Tailstock forward
  
  case "TAILSTOCK_OFF":
    machineState.tailstockIsActive = false;
    return 843;  // M843 - Tailstock back

  //--------------------------------------------------------------------------
  // COOLANT / AIR BLAST
  //--------------------------------------------------------------------------
  case "AIR_BLAST_ON":
    return 129;  // M129 - Air blast on
  
  case "AIR_BLAST_OFF":
    return 9;    // M9 - Air blast off

  //--------------------------------------------------------------------------
  // BALANCED CUTTING (Dual Turret Specific)
  //--------------------------------------------------------------------------
  case "BALANCE_TURRETS_ON":
    machineState.turretsAreBalanced = true;
    return 562;  // M562 - Couple turrets for balanced cutting
  
  case "BALANCE_TURRETS_OFF":
    machineState.turretsAreBalanced = false;
    return 563;  // M563 - Uncouple turrets

  //--------------------------------------------------------------------------
  // UNKNOWN CODE ERROR
  //--------------------------------------------------------------------------
  default:
    error(localize("Command " + code + " is not defined."));
    return 0;
  }
  return 0;
}

// ============================================================================
// SECTION 7: MACHINE CONFIGURATION FUNCTION
// ============================================================================
/**
 * Defines the specific configuration for Grace Engineering Integrex 100-IV ST
 * 
 * CRITICAL: This function contains ALL machine definitions for this post processor.
 *           NO external machine definition files are used. This is the single
 *           authoritative source for all machine parameters and configurations.
 * 
 * Machine specifications are based on:
 * - Grace Engineering adjusted parameter sheet (Serial #195369, dated 8/15/2022)
 * - Mazak Integrex i-100S base specifications
 * - Operator verification of Y-axis travel (±105mm)
 */
function defineMachine() {
  // CRITICAL: These values are specific to Grace Engineering machine
  // Serial: 195369, Model: IN1004ST
  
  //--------------------------------------------------------------------------
  // TURRET CONFIGURATION
  //--------------------------------------------------------------------------
  gotMultiTurret = true;           // DUAL TURRET machine
  turret1GotYAxis = true;          // Upper turret HAS Y-axis
  turret2GotYAxis = true;          // Lower turret HAS Y-axis
  turret1GotBAxis = true;          // Upper turret HAS B-axis
  turret2GotBAxis = false;         // Lower turret NO B-axis
  
  //--------------------------------------------------------------------------
  // SPINDLE CONFIGURATION
  //--------------------------------------------------------------------------
  gotSecondarySpindle = true;      // HAS sub-spindle
  
  //--------------------------------------------------------------------------
  // AXIS TRAVEL LIMITS (from Integrex i-100S specifications)
  //--------------------------------------------------------------------------
  // Y-axis limits (both turrets, ±105mm confirmed by operator)
  yAxisMinimum = toPreciseUnit(-105, MM);  // -105mm = -4.134 inches
  yAxisMaximum = toPreciseUnit(105, MM);   // +105mm = +4.134 inches
  
  // X-axis minimum (radius value, from i-100S specification)
  xAxisMinimum = toPreciseUnit(-50, MM);   // -50mm = -1.969 inches (RADIUS MODE)
  
  //--------------------------------------------------------------------------
  // SPINDLE SPEED LIMITS (from Grace Engineering parameter sheet)
  //--------------------------------------------------------------------------
  maximumSpindleSpeedMain = getProperty("maximumSpindleSpeedMain");  // 5060 RPM (Kitagawa chuck)
  maximumSpindleSpeedSub = getProperty("maximumSpindleSpeedSub");    // 6000 RPM
  maximumSpindleSpeedLive = getProperty("maximumSpindleSpeedLive");  // 12000 RPM (live tools)
  
  //--------------------------------------------------------------------------
  // MACHINE PARAMETERS (from adjusted parameter sheet dated 8/15/2022)
  //--------------------------------------------------------------------------
  // BA61 = 44 μm (B-axis center runout)
  // BA62 = 586967 (0.00001") = 58.6967" (B-axis to spindle offset)
  // BA97 TR1 = -1307337 (0.00001") (Upper turret X reference)
  // BA99 TR1 = -1479743 (0.00001") (Upper turret Z reference)
  // BA97 TR2 = -49 (0.00001") (Lower turret X reference)
  // BA99 TR2 = 0 (0.00001") (Lower turret Z reference)
  // M5 Y = -927534 (0.1μm) = -92.7534 mm (Y-axis offset)
  // M16 Y = 56977 (0.1μm) = 5.6977 mm (Y-axis reference point)
  
  // These parameters are documented here for reference but will be used
  // in work offset calculations in later development phases
  
  //--------------------------------------------------------------------------
  // B-AXIS CONFIGURATION
  //--------------------------------------------------------------------------
  gotBAxis = true;                 // Initially true (changes per turret)
  bAxisIsManual = false;           // B-axis is PROGRAMMABLE (not manual)
  gotDoorControl = false;          // Door control not implemented
  
  //--------------------------------------------------------------------------
  // B-AXIS OUTPUT FORMAT
  //--------------------------------------------------------------------------
  if (bAxisIsManual) {
    // Manual B-axis (not our case)
    bFormat.setPrefix("(B=");
    bFormat.setSuffix(")");
    bOutput.setFormat(bFormat);
  } else {
    // Programmable B-axis (our case)
    bFormat.setPrefix("B");
    bFormat.setSuffix("");
    bOutput.setFormat(bFormat);
  }
}

// ============================================================================
// SECTION 8: TURRET ACTIVATION FUNCTION
// ============================================================================
/**
 * Activates the appropriate turret and configures axes based on the current
 * operation/section. This function is called for each operation in Autodesk Fusion.
 * 
 * @param {object} section - Current operation section from Fusion
 * @returns {number} - Active turret number (1 or 2)
 */
function activateMachine(section) {
  
  //--------------------------------------------------------------------------
  // TCP (TOOL CENTER POINT) SETTING
  //--------------------------------------------------------------------------
  // TCP is used for 5-axis operations (B-axis + C-axis on upper turret)
  operationSupportsTCP = section.isMultiAxis() && getProperty("useTCP");
  
  //--------------------------------------------------------------------------
  // TURRET SELECTION
  //--------------------------------------------------------------------------
  var turret = 1;  // Default to upper turret
  
  if (gotMultiTurret) {
    // Get turret assignment from Autodesk Fusion tool definition
    turret = section.getTool().turret;
    
    // Handle unspecified turret (should not happen with proper setup)
    if (turret == 0) {
      warningOnce(localize("Turret has not been specified. Using Turret 1 (Upper) as default."), 
                  WARNING_TURRET_UNSPECIFIED);
      turret = 1;
    }
    
    // Ensure turret is defined
    turret = turret == undefined ? 1 : turret;
    
    // Configure machine based on active turret
    switch (turret) {
    case 1:  // UPPER TURRET (HD1/TR1)
      gotYAxis = turret1GotYAxis;    // Y-axis available
      gotBAxis = turret1GotBAxis;    // B-axis available
      break;
      
    case 2:  // LOWER TURRET (HD2/TR2)
      gotYAxis = turret2GotYAxis;    // Y-axis available
      gotBAxis = false;               // B-axis NOT available
      break;
      
    default:
      error(subst(localize("Turret %1 is not supported"), turret));
      return turret;
    }
  } else {
    // Single turret mode (not used, but kept for safety)
    gotYAxis = turret1GotYAxis;
  }
  
  //--------------------------------------------------------------------------
  // DISABLE UNSUPPORTED AXES
  //--------------------------------------------------------------------------
  // Disable axis outputs for axes not available on current turret
  if (!gotYAxis) {
    yOutput.disable();
  } else {
    yOutput.enable();
  }
  
  // A-axis is never used on this machine
  aOutput.disable();
  
  // B-axis enable/disable based on turret
  if (!gotBAxis) {
    bOutput.disable();
  } else {
    bOutput.enable();
  }
  
  //--------------------------------------------------------------------------
  // MACHINE CONFIGURATION SETUP
  //--------------------------------------------------------------------------
  // Define rotary axes (B and C)
  var bAxis;
  var cAxis;
  
  if (section.getSpindle() == SPINDLE_PRIMARY) {
    // Primary (main) spindle configuration
    bAxis = createAxis({
      coordinate: 1,
      table: false,
      axis: [0, -1, 0],      // B-axis direction
      range: [0, 90],         // 0° to 90° (Grace Engineering specific)
      preference: 0,
      tcp: true
    });
    cAxis = createAxis({
      coordinate: 2,
      table: true,
      axis: [0, 0, 1],       // C-axis direction
      range: [0, 359.9999],  // Full 360° rotation
      cyclic: true,
      preference: 0,
      tcp: false
    });
  } else {
    // Secondary (sub) spindle configuration
    bAxis = createAxis({
      coordinate: 1,
      table: false,
      axis: [0, 1, 0],       // B-axis direction (reversed for sub-spindle)
      range: [0, 90],
      preference: 0,
      tcp: true
    });
    cAxis = createAxis({
      coordinate: 2,
      table: true,
      axis: [0, 0, -1],      // C-axis direction (reversed for sub-spindle)
      range: [0, 359.9999],
      cyclic: true,
      preference: 0,
      tcp: false
    });
  }
  
  // Create machine configuration based on available axes
  if (gotBAxis) {
    // Both B and C axes (upper turret only)
    machineConfiguration = new MachineConfiguration(bAxis, cAxis);
    bOutput.enable();
  } else {
    // C-axis only (lower turret)
    machineConfiguration = new MachineConfiguration(cAxis);
    bOutput.disable();
  }
  
  //--------------------------------------------------------------------------
  // SPINDLE AXIS DEFINITION
  //--------------------------------------------------------------------------
  // Define the spindle axis direction based on turret and operation type
  if (!gotBAxis || bAxisIsManual || (turret == 2)) {
    // Lower turret or when B-axis is not available
    if ((getMachiningDirection(section) == MACHINING_DIRECTION_AXIAL) && !section.isMultiAxis()) {
      machineConfiguration.setSpindleAxis(new Vector(0, 0, 1));  // Axial (Z-direction)
    } else {
      machineConfiguration.setSpindleAxis(new Vector(1, 0, 0));  // Radial (X-direction)
    }
  } else {
    // Upper turret with B-axis
    if (section.spindle == SPINDLE_PRIMARY) {
      machineConfiguration.setSpindleAxis(new Vector(0, 0, 1));   // Main spindle
    } else {
      machineConfiguration.setSpindleAxis(new Vector(0, 0, -1));  // Sub-spindle
    }
  }
  
  //--------------------------------------------------------------------------
  // LINEAR AXES LIMITS
  //--------------------------------------------------------------------------
  var xAxisMaximum = 10000;  // Don't check X-axis maximum limit
  yAxisMinimum = gotYAxis ? yAxisMinimum : 0;
  yAxisMaximum = gotYAxis ? yAxisMaximum : 0;
  
  var xAxis = createAxis({
    actuator: "linear",
    coordinate: 0,
    table: true,
    axis: [1, 0, 0],
    range: [xAxisMinimum, xAxisMaximum]
  });
  
  var yAxis = createAxis({
    actuator: "linear",
    coordinate: 1,
    table: true,
    axis: [0, 1, 0],
    range: [yAxisMinimum, yAxisMaximum]
  });
  
  var zAxis = createAxis({
    actuator: "linear",
    coordinate: 2,
    table: true,
    axis: [0, 0, 1],
    range: [-100000, 100000]
  });
  
  machineConfiguration.setAxisX(xAxis);
  machineConfiguration.setAxisY(yAxis);
  machineConfiguration.setAxisZ(zAxis);
  
  //--------------------------------------------------------------------------
  // RETRACT/RECONFIGURE SETTINGS
  //--------------------------------------------------------------------------
  var safeRetractDistance = (unit == IN) ? 1 : 25;  // Retract distance
  var safeRetractFeed = (unit == IN) ? 20 : 500;     // Retract feedrate
  var safePlungeFeed = (unit == IN) ? 10 : 250;      // Plunge feedrate
  var stockExpansion = new Vector(
    toPreciseUnit(0.1, IN),
    toPreciseUnit(0.1, IN),
    toPreciseUnit(0.1, IN)
  );
  
  machineConfiguration.enableMachineRewinds();
  machineConfiguration.setSafeRetractDistance(safeRetractDistance);
  machineConfiguration.setSafeRetractFeedrate(safeRetractFeed);
  machineConfiguration.setSafePlungeFeedrate(safePlungeFeed);
  machineConfiguration.setRewindStockExpansion(stockExpansion);
  
  //--------------------------------------------------------------------------
  // MULTI-AXIS FEEDRATE SETTINGS
  //--------------------------------------------------------------------------
  machineConfiguration.setMultiAxisFeedrate(
    operationSupportsTCP ? FEED_FPM : FEED_DPM,  // Feed mode
    99999,                                        // Maximum DPM value
    DPM_COMBINATION,                              // DPM calculation method
    0.5,                                          // DPM tolerance
    unit == MM ? 1.0 : 1.0                       // Rotary/linear accuracy ratio
  );
  
  //--------------------------------------------------------------------------
  // SET MACHINE VENDOR/MODEL
  //--------------------------------------------------------------------------
  machineConfiguration.setVendor("Mazak");
  machineConfiguration.setModel("Integrex 100-IV ST (IN1004ST)");
  setMachineConfiguration(machineConfiguration);
  
  // Optimize multi-axis angles if this is a multi-axis operation
  if (section.isMultiAxis()) {
    section.optimizeMachineAnglesByMachine(machineConfiguration, OPTIMIZE_AXIS);
  }
  
  // Update machine state
  machineState.currentTurret = turret;
  
  return turret;
}

// ============================================================================
// SECTION 9: UTILITY FUNCTIONS
// ============================================================================

/**
 * Writes a formatted block of code with optional sequence numbers
 */
function writeBlock() {
  var text = formatWords(arguments);
  if (!text) {
    return;
  }
  
  var seqno = "";
  var opskip = "";
  
  if (showSequenceNumbers == "true") {
    seqno = formatSequenceNumber();
  }
  
  if (optionalSection) {
    opskip = "/";
  }
  
  if (text) {
    writeWords(opskip, seqno, text);
  }
}

/**
 * Formats and outputs a comment
 */
function writeComment(text) {
  writeln(formatComment(text));
}

/**
 * Formats a comment string
 */
function formatComment(text) {
  return "(" + String(filterText(String(text).toUpperCase(), permittedCommentChars))
    .replace(/[()]/g, "") + ")";
}

/**
 * Generates and increments sequence numbers
 */
function formatSequenceNumber() {
  if (sequenceNumber > 99999) {
    sequenceNumber = getProperty("sequenceNumberStart");
  }
  var seqno = "N" + sequenceNumber;
  sequenceNumber += getProperty("sequenceNumberIncrement");
  return seqno;
}

/**
 * Helper function to check if two directions are the same
 */
function isSameDirection(dir1, dir2) {
  var threshold = 0.0001;
  return Math.abs(dir1.x - dir2.x) < threshold &&
         Math.abs(dir1.y - dir2.y) < threshold &&
         Math.abs(dir1.z - dir2.z) < threshold;
}

/**
 * Helper function to check if operation is 3D
 */
function is3D() {
  return currentSection.isMultiAxis() || 
         (currentSection.getType() == TYPE_MILLING);
}

/**
 * Get a specific section by ID
 */
function getSection(id) {
  return getProperty("sections")[id];
}

/**
 * Get current section ID
 */
function getCurrentSectionId() {
  return currentSection.getId();
}

/**
 * Get previous section
 */
function getPreviousSection() {
  if (isFirstSection()) {
    return null;
  }
  return getSection(getCurrentSectionId() - 1);
}

// ============================================================================
// SECTION 10: MAIN POST PROCESSOR FUNCTIONS (STUBS - TO BE IMPLEMENTED)
// ============================================================================
// These functions are called by Autodesk Fusion at specific points during post
// processing. Phase 2 has implemented onSection and onSectionEnd.
// Remaining functions will be implemented in Phase 3 and 4.

/**
 * Called once at the beginning of post processing
 * Phase 1: Foundation Setup - Program initialization and header
 */
function onOpen() {
  
  //--------------------------------------------------------------------------
  // INITIALIZE MACHINE CONFIGURATION
  //--------------------------------------------------------------------------
  // This MUST be called first to set all machine-specific parameters
  defineMachine();
  
  // Store B-axis capability for later reference
  turret1GotBAxis = gotBAxis;
  
  //--------------------------------------------------------------------------
  // HANDLE RADIUS/DIAMETER MODE ARC OUTPUT
  //--------------------------------------------------------------------------
  if (getProperty("useRadius")) {
    maximumCircularSweep = toRad(90); // Avoid center calculation errors for CNC
  }
  
  //--------------------------------------------------------------------------
  // INITIALIZE SEQUENCE NUMBERING
  //--------------------------------------------------------------------------
  sequenceNumber = getProperty("sequenceNumberStart");
  showSequenceNumbers = getProperty("showSequenceNumbers");
  
  //--------------------------------------------------------------------------
  // PROGRAM HEADER - IDENTIFICATION AND WARNINGS
  //--------------------------------------------------------------------------
  writeln("%");  // Program start character for Mazak Matrix
  
  // Program number/name
  if (programName) {
    writeComment("PROGRAM: " + programName);
  }
  if (programComment) {
    writeComment(programComment);
  }
  
  writeComment("");
  writeComment("=======================================================");
  writeComment("GRACE ENGINEERING - INTEGREX 100-IV ST DUAL TURRET");
  writeComment("Machine Serial: 195369");
  writeComment("Control: Mazak Matrix (Nexus)");
  writeComment("=======================================================");
  writeComment("");
  
  // Post processor version info
  writeComment("Post Processor: grace_integrex_100iv_dual_turret.cps");
  writeComment("Version: 0.2.0 - Phase 1 Complete (Foundation)");
  writeComment("Status: DEVELOPMENT - Operations not yet implemented");
  writeComment("Date: " + new Date().toLocaleDateString());
  writeComment("");
  
  // Machine configuration summary
  writeComment("MACHINE CONFIGURATION:");
  writeComment("  Upper Turret (TR1): Y-axis, B-axis, Live tools");
  writeComment("  Lower Turret (TR2): Y-axis, Live tools");
  writeComment("  Main Spindle: " + getProperty("maximumSpindleSpeedMain") + " RPM max");
  writeComment("  Sub Spindle: " + getProperty("maximumSpindleSpeedSub") + " RPM max");
  writeComment("  Live Tooling: " + getProperty("maximumSpindleSpeedLive") + " RPM max");
  writeComment("");
  
  // Critical warnings for operator
  writeComment("CRITICAL OPERATIONAL NOTES:");
  writeComment("  - Verify work offsets before running program");
  writeComment("  - Check tool offsets for all turrets");
  writeComment("  - Verify chuck jaw configuration");
  writeComment("  - Run in graphics/simulation mode first");
  writeComment("");
  
  //--------------------------------------------------------------------------
  // PROGRAM SETUP - INITIAL MODE SETTINGS
  //--------------------------------------------------------------------------
  
  // Unit mode (G20=inch, G21=mm)
  if (unit == MM) {
    writeBlock(gUnitModal.format(21));  // G21 - Metric mode
  } else {
    writeBlock(gUnitModal.format(20));  // G20 - Inch mode
  }
  
  // Plane selection for turning (G18 = ZX plane)
  writeBlock(gPlaneModal.format(18));   // G18 - ZX plane (turning)
  
  // Absolute coordinate mode
  writeBlock(gFormat.format(90));       // G90 - Absolute programming
  
  // Feed mode
  writeBlock(gFeedModeModal.format(94)); // G94 - Feed per minute (initial)
  
  // Cancel tool length compensation
  writeBlock(gFormat.format(49));       // G49 - Cancel tool length offset
  
  // Cancel work offset (will be set per section)
  writeBlock(gFormat.format(54));       // G54 - Default work offset
  
  writeComment("INITIALIZATION COMPLETE");
  writeComment("");
}

/**
 * Called once at the end of post processing
 * Phase 1: Foundation Setup - Program termination
 */
function onClose() {
  
  writeComment("");
  writeComment("PROGRAM TERMINATION");
  
  //--------------------------------------------------------------------------
  // ENSURE ALL OPERATIONS ARE COMPLETE
  //--------------------------------------------------------------------------
  
  // Make sure spindles are stopped
  if (machineState.mainSpindleIsActive) {
    writeBlock(mFormat.format(getCode("STOP_SPINDLE", SPINDLE_MAIN)));
  }
  if (machineState.subSpindleIsActive) {
    writeBlock(mFormat.format(getCode("STOP_SPINDLE", SPINDLE_SUB)));
  }
  if (machineState.liveToolIsActive) {
    writeBlock(mFormat.format(getCode("STOP_SPINDLE", SPINDLE_LIVE)));
  }
  
  // Ensure milling mode is off
  if (machineState.cAxisIsEngaged) {
    if (machineState.mainSpindleIsActive !== false) {
      writeBlock(mFormat.format(getCode("DISABLE_C_AXIS", SPINDLE_MAIN)));
    }
    if (machineState.subSpindleIsActive !== false) {
      writeBlock(mFormat.format(getCode("DISABLE_C_AXIS", SPINDLE_SUB)));
    }
  }
  
  // Turn off coolant
  writeBlock(mFormat.format(9));  // M9 - Coolant off
  
  //--------------------------------------------------------------------------
  // RETURN TO SAFE POSITION
  //--------------------------------------------------------------------------
  
  // Move to machine home position (G53 = machine coordinate system)
  writeComment("Return to home position");
  
  // Z-axis to home
  if (getProperty("homePositionZ") != 0) {
    writeBlock(gFormat.format(53), gMotionModal.format(0), 
               "Z" + xyzFormat.format(getProperty("homePositionZ")));
  }
  
  // Sub-spindle Z-axis to home (if sub-spindle was used)
  if (gotSecondarySpindle && getProperty("homePositionSubZ") != 0) {
    writeBlock(gFormat.format(53), gMotionModal.format(0), 
               "B" + xyzFormat.format(getProperty("homePositionSubZ")));  // B = W-axis
  }
  
  // X and Y to home (safe position)
  writeBlock(gFormat.format(53), gMotionModal.format(0), "X0 Y0");
  
  //--------------------------------------------------------------------------
  // PROGRAM END
  //--------------------------------------------------------------------------
  
  writeComment("");
  writeComment("=======================================================");
  writeComment("END OF PROGRAM");
  writeComment("Machine: Integrex 100-IV ST (Serial 195369)");
  writeComment("Grace Engineering Corp");
  writeComment("=======================================================");
  
  writeBlock(mFormat.format(30));  // M30 - Program end and reset
  writeln("%");  // Program end character for Mazak Matrix
}

/**
 * Called at the start of each operation/section
 * Phase 2: Matrix Control M-Codes - Section initialization with G109, M901/M902, M200/M300
 */
function onSection() {
  var insertToolCall = isToolChangeNeeded("number") || currentSection.isMultiAxis() && 
                       !isFirstSection() && (getPreviousSection().isMultiAxis() != currentSection.isMultiAxis());
  var newWorkOffset = isNewWorkOffset() || insertToolCall;
  var newWorkPlane = isNewWorkPlane() || insertToolCall;
  var newSpindle = isNewSpindle();
  
  // Initialize section
  var forceToolAndRetract = optionalSection && !currentSection.isOptional();
  optionalSection = currentSection.isOptional();
  
  //--------------------------------------------------------------------------
  // DETERMINE TURRET FOR THIS SECTION
  //--------------------------------------------------------------------------
  activeTurret = activateMachine(currentSection);
  
  //--------------------------------------------------------------------------
  // OUTPUT G109 TURRET SELECTION (Matrix Control Specific)
  //--------------------------------------------------------------------------
  // G109 L1 = Upper turret (HD1/TR1)
  // G109 L2 = Lower turret (HD2/TR2)
  
  if (gotMultiTurret) {
    if (machineState.currentTurret != activeTurret || isFirstSection()) {
      writeComment("");
      writeComment("=".repeat(60));
      writeComment("TURRET SELECTION: " + (activeTurret == 1 ? "UPPER (TR1/HD1)" : "LOWER (TR2/HD2)"));
      writeComment("=".repeat(60));
      
      // Output G109 turret selection code
      writeBlock(gFormat.format(109), "L" + activeTurret);
      
      machineState.currentTurret = activeTurret;
    }
  }
  
  //--------------------------------------------------------------------------
  // SECTION HEADER COMMENTS
  //--------------------------------------------------------------------------
  writeln("");
  if (hasParameter("operation-comment")) {
    var comment = getParameter("operation-comment");
    if (comment) {
      writeComment(comment);
    }
  }
  
  var showToolZMin = true;
  if (showToolZMin) {
    if (is3D()) {
      var zRange = currentSection.getGlobalZRange();
      var numberOfSections = getNumberOfSections();
      var zMin = zRange.getMinimum();
      writeComment("ZMIN: " + xyzFormat.format(zMin));
    }
  }
  
  //--------------------------------------------------------------------------
  // DETERMINE SPINDLE (SPINDLE_MAIN, SPINDLE_SUB, SPINDLE_LIVE)
  //--------------------------------------------------------------------------
  var spindleToUse = getSpindle(TOOL);
  var partSpindle = getSpindle(PART);
  
  //--------------------------------------------------------------------------
  // OUTPUT M901/M902 SPINDLE SELECTION (Matrix Control Specific)
  //--------------------------------------------------------------------------
  // M901 = Select 1st spindle (main)
  // M902 = Select 2nd spindle (sub)
  
  if (partSpindle == SPINDLE_MAIN) {
    writeBlock(mFormat.format(getCode("SELECT_SPINDLE_MAIN")));  // M901
    writeComment("Main spindle selected");
  } else if (partSpindle == SPINDLE_SUB) {
    writeBlock(mFormat.format(getCode("SELECT_SPINDLE_SUB")));   // M902
    writeComment("Sub-spindle selected");
  }
  
  //--------------------------------------------------------------------------
  // DETERMINE OPERATION TYPE (TURNING vs MILLING)
  //--------------------------------------------------------------------------
  machineState.isTurning = (currentSection.getType() == TYPE_TURNING);
  
  if (machineState.isTurning) {
    // TURNING OPERATION
    machineState.isMilling = false;
    writeComment("Operation type: TURNING");
    
    // Ensure milling mode is OFF for turning
    if (machineState.cAxisIsEngaged) {
      writeBlock(mFormat.format(getCode("DISABLE_C_AXIS", partSpindle)));  // M202 or M302
      writeComment("Milling mode disabled");
    }
    
  } else {
    // MILLING OPERATION (or drilling, tapping, etc.)
    machineState.isMilling = true;
    writeComment("Operation type: MILLING");
    
    //------------------------------------------------------------------------
    // OUTPUT M200/M300 MILLING MODE ENABLE (Matrix Control Specific)
    //------------------------------------------------------------------------
    // M200 = Milling mode ON for 1st spindle
    // M300 = Milling mode ON for 2nd spindle
    
    if (!machineState.cAxisIsEngaged) {
      writeBlock(mFormat.format(getCode("ENABLE_C_AXIS", partSpindle)));  // M200 or M300
      writeComment("Milling mode enabled");
    }
  }
  
  //--------------------------------------------------------------------------
  // TOOL CHANGE
  //--------------------------------------------------------------------------
  if (insertToolCall || isFirstSection()) {
    forceWorkPlane();
    
    // Stop any active spindle before tool change
    if (machineState.mainSpindleIsActive || machineState.subSpindleIsActive || 
        machineState.liveToolIsActive) {
      onCommand(COMMAND_STOP_SPINDLE);
    }
    
    var tool = currentSection.getTool();
    
    //------------------------------------------------------------------------
    // OUTPUT TOOL CHANGE (T-code format: T####T#### or T######)
    //------------------------------------------------------------------------
    // Format 1: T0101 (tool 01, offset 01)
    // Format 2: T010101 (tool 01, offset 01, extended)
    // Tool ID Code from Fusion should be placed in Product ID field
    
    if (tool.number > 99) {
      writeComment("WARNING: Tool number exceeds 99");
    }
    
    // Build T-code based on tool type
    var compensationOffset = tool.isTurningTool() ? tool.compensationOffset : tool.lengthOffset;
    if (compensationOffset > 99) {
      warning(localize("Compensation offset is out of range."));
    }
    
    // T-code format: Tool number + Offset number
    // Example: T0101 = Tool 1, Offset 1
    var tCode = toolFormat.format(tool.number * 100 + compensationOffset);
    
    writeBlock("T" + tCode);
    
    // Add M6 tool change code if required (depends on machine configuration)
    // Some Mazak controls require M6, others just use T-code
    // writeBlock(mFormat.format(6));  // Uncomment if M6 is required
    
    // Tool ID Code (from Product ID in Fusion)
    if (tool.productId) {
      writeBlock("D" + tool.productId);
      writeComment("Tool ID Code: " + tool.productId);
    }
    
    currentTool = tool.number;
    
    writeComment("Tool: T" + toolFormat.format(tool.number) + " - " + getToolTypeName(tool.type));
    if (tool.comment) {
      writeComment("  " + tool.comment);
    }
    writeComment("  Diameter: " + xyzFormat.format(tool.diameter) + "mm");
  }
  
  //--------------------------------------------------------------------------
  // START SPINDLE
  //--------------------------------------------------------------------------
  var spindleSpeed = currentSection.getTool().spindleRPM;
  var maximumSpindleSpeed = (spindleToUse == SPINDLE_LIVE) ? 
                            maximumSpindleSpeedLive : 
                            (partSpindle == SPINDLE_MAIN) ? 
                            getProperty("maximumSpindleSpeedMain") : 
                            getProperty("maximumSpindleSpeedSub");
  
  if (spindleSpeed > maximumSpindleSpeed) {
    warning(subst(localize("Spindle speed %1 RPM exceeds maximum %2 RPM for this spindle."), 
                  spindleSpeed, maximumSpindleSpeed));
    spindleSpeed = maximumSpindleSpeed;
  }
  
  var spindleDir = tool.clockwise ? "CW" : "CCW";
  
  if (machineState.isTurning) {
    // Turning operation - use main/sub spindle M-codes
    writeComment("Spindle: " + spindleSpeed + " RPM " + spindleDir);
    writeBlock(
      sOutput.format(spindleSpeed),
      mFormat.format(tool.clockwise ? 
                     getCode("START_SPINDLE_CW", partSpindle) : 
                     getCode("START_SPINDLE_CCW", partSpindle))
    );
    
  } else {
    // Milling operation
    // M203 S___ = Milling spindle normal rotation with speed
    writeComment("Milling spindle: " + spindleSpeed + " RPM " + spindleDir);
    writeBlock(
      mFormat.format(203),  // M203 - Milling spindle rotation
      sOutput.format(spindleSpeed)
    );
  }
  
  //--------------------------------------------------------------------------
  // WORK OFFSET (G54-G59)
  //--------------------------------------------------------------------------
  if (newWorkOffset) {
    var workOffset = currentSection.workOffset;
    if (workOffset == 0) {
      warningOnce(localize("Work offset has not been specified. Using G54 as default."), WARNING_WORK_OFFSET);
      workOffset = 1;
    }
    if (workOffset > 0) {
      if (workOffset > 6) {
        error(localize("Work offset out of range (1-6 = G54-G59)."));
        return;
      } else {
        writeBlock(gFormat.format(53 + workOffset));  // G54-G59
        writeComment("Work offset: G" + (53 + workOffset));
      }
    }
  }
  
  //--------------------------------------------------------------------------
  // FEED MODE (G94 or G95)
  //--------------------------------------------------------------------------
  if (machineState.isTurning) {
    // Turning typically uses feed per revolution
    if (!machineState.feedPerRevolution) {
      writeBlock(gFeedModeModal.format(getCode("FEED_MODE_UNIT_REV")));  // G95
    }
  } else {
    // Milling typically uses feed per minute
    if (machineState.feedPerRevolution) {
      writeBlock(gFeedModeModal.format(getCode("FEED_MODE_UNIT_MIN")));  // G94
    }
  }
  
  //--------------------------------------------------------------------------
  // COOLANT ON
  //--------------------------------------------------------------------------
  setCoolant(tool.coolant);
  
  writeComment("Section initialized - ready for machining");
  writeComment("");
}

/**
 * Helper function to get spindle (TOOL or PART)
 */
function getSpindle(part) {
  // TOOL = spindle that drives the cutting tool
  // PART = spindle that holds the workpiece
  if (part == TOOL) {
    return (currentSection.getType() == TYPE_TURNING) ? 
           currentSection.spindle : SPINDLE_LIVE;
  } else {
    return currentSection.spindle;
  }
}

/**
 * Helper function to get tool type name
 */
function getToolTypeName(toolType) {
  switch (toolType) {
  case TOOL_DRILL:
    return "Drill";
  case TOOL_DRILL_CENTER:
    return "Center Drill";
  case TOOL_DRILL_SPOT:
    return "Spot Drill";
  case TOOL_DRILL_BLOCK:
    return "Block Drill";
  case TOOL_MILLING_END_FLAT:
    return "Flat End Mill";
  case TOOL_MILLING_END_BALL:
    return "Ball End Mill";
  case TOOL_MILLING_END_BULLNOSE:
    return "Bullnose End Mill";
  case TOOL_MILLING_CHAMFER:
    return "Chamfer Mill";
  case TOOL_MILLING_FACE:
    return "Face Mill";
  case TOOL_MILLING_SLOT:
    return "Slot Mill";
  case TOOL_MILLING_RADIUS:
    return "Radius Mill";
  case TOOL_MILLING_DOVETAIL:
    return "Dovetail Mill";
  case TOOL_MILLING_TAPERED:
    return "Tapered Mill";
  case TOOL_MILLING_LOLLIPOP:
    return "Lollipop Mill";
  case TOOL_TAP_RIGHT_HAND:
    return "Tap (RH)";
  case TOOL_TAP_LEFT_HAND:
    return "Tap (LH)";
  case TOOL_REAMER:
    return "Reamer";
  case TOOL_BORING_BAR:
    return "Boring Bar";
  case TOOL_TURNING_GENERAL:
    return "Turning Tool";
  case TOOL_TURNING_THREADING:
    return "Threading Tool";
  case TOOL_TURNING_GROOVING:
    return "Grooving Tool";
  case TOOL_TURNING_BORING:
    return "Boring Tool";
  case TOOL_TURNING_CUSTOM:
    return "Custom Turning Tool";
  default:
    return "Unknown Tool";
  }
}

/**
 * Helper function to check if this is the first section
 */
function isFirstSection() {
  return getCurrentSectionId() == 0;
}

/**
 * Helper function to check if this is the last section
 */
function isLastSection() {
  return getCurrentSectionId() == (getNumberOfSections() - 1);
}

/**
 * Helper function to check if tool change is needed
 */
function isToolChangeNeeded(key) {
  if (isFirstSection()) {
    return true;
  }
  var previousTool = getPreviousSection().getTool();
  var currentTool = currentSection.getTool();
  
  if (key == "number") {
    return previousTool.number != currentTool.number;
  }
  return false;
}

/**
 * Helper function to check if work offset changed
 */
function isNewWorkOffset() {
  if (isFirstSection()) {
    return true;
  }
  return getPreviousSection().workOffset != currentSection.workOffset;
}

/**
 * Helper function to check if work plane changed
 */
function isNewWorkPlane() {
  if (isFirstSection()) {
    return true;
  }
  // Compare work planes
  return !isSameDirection(getPreviousSection().workPlane.forward, 
                          currentSection.workPlane.forward);
}

/**
 * Helper function to check if spindle changed
 */
function isNewSpindle() {
  if (isFirstSection()) {
    return false;
  }
  return getPreviousSection().spindle != currentSection.spindle;
}

/**
 * Helper function to force work plane
 */
function forceWorkPlane() {
  // Force work plane reset
  // Implementation depends on machine configuration
}

/**
 * Helper function to set coolant
 */
function setCoolant(coolant) {
  // TODO: Phase 3 - Implement coolant control
  // M8 = Coolant on
  // M9 = Coolant off
  if (coolant != COOLANT_OFF) {
    writeBlock(mFormat.format(8));  // M8 - Coolant on
  }
}

/**
 * Called at the end of each operation/section
 * Phase 2: Matrix Control M-Codes - Section cleanup with proper shutdown and M950 waiting
 */
function onSectionEnd() {
  
  writeComment("");
  writeComment("Section end - Cleanup");
  
  //--------------------------------------------------------------------------
  // TURN OFF COOLANT
  //--------------------------------------------------------------------------
  writeBlock(mFormat.format(9));  // M9 - Coolant off
  
  //--------------------------------------------------------------------------
  // STOP SPINDLE
  //--------------------------------------------------------------------------
  if (machineState.isMilling) {
    // Milling operation - stop milling spindle first
    writeBlock(mFormat.format(205));  // M205 - Milling spindle stop
    
    // Then disable milling mode (M202/M302)
    var partSpindle = getSpindle(PART);
    writeBlock(mFormat.format(getCode("DISABLE_C_AXIS", partSpindle)));  // M202 or M302
    writeComment("Milling mode disabled");
    
  } else if (machineState.isTurning) {
    // Turning operation - stop main/sub spindle
    var partSpindle = getSpindle(PART);
    writeBlock(mFormat.format(getCode("STOP_SPINDLE", partSpindle)));  // M205 or M305
  }
  
  //--------------------------------------------------------------------------
  // COMPOUND MACHINING WAITING CODE (M950)
  //--------------------------------------------------------------------------
  // M950 is used to synchronize operations when using dual turrets
  // This ensures one turret waits for the other to complete before proceeding
  // 
  // M950 is CRITICAL for:
  // - Sequential operations (one turret after another)
  // - Parallel operations (both turrets working simultaneously)
  // - Balanced cutting (synchronized symmetrical movement)
  //
  // NOTE: In single-turret mode or when turrets don't need synchronization,
  //       M950 can be omitted to save cycle time
  
  if (gotMultiTurret && !isLastSection()) {
    // Check if next section uses a different turret or requires synchronization
    var nextSection = getSection(getCurrentSectionId() + 1);
    var nextTurret = nextSection.getTool().turret;
    
    if (nextTurret != activeTurret) {
      // Turret is changing - output M950 for synchronization
      writeComment("M950 - Wait for turret synchronization");
      writeBlock(mFormat.format(950));
    }
  }
  
  //--------------------------------------------------------------------------
  // SECTION TERMINATION (M30)
  //--------------------------------------------------------------------------
  // Each G109 section must end with M30
  // This tells the controller that this turret's section is complete
  writeBlock(mFormat.format(30));  // M30 - Program end for this section
  
  writeComment("");
}

/**
 * Called for each linear movement (G1)
 * Phase 3: Motion Implementation - Linear interpolation with feed
 */
function onLinear(_x, _y, _z, feed) {
  // Format coordinates - only output if changed from previous position
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  var f = getFeed(feed);
  
  // Only output if at least one axis has moved
  if (x || y || z) {
    writeBlock(gMotionModal.format(1), x, y, z, f);  // G1 - Linear interpolation
  }
}

/**
 * Helper function to format and manage feed rate
 */
function getFeed(f) {
  // Determine if we're using feed per revolution (G95) or feed per minute (G94)
  if (machineState.feedPerRevolution) {
    // Feed per revolution (mm/rev or inch/rev)
    return feedOutput.format(f);
  } else {
    // Feed per minute (mm/min or inch/min)
    return feedOutput.format(f);
  }
}

/**
 * Called for each rapid movement (G0)
 * Phase 3: Motion Implementation - Rapid positioning
 */
function onRapid(_x, _y, _z) {
  // Format coordinates - only output if changed from previous position
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  
  // Only output if at least one axis has moved
  if (x || y || z) {
    writeBlock(gMotionModal.format(0), x, y, z);  // G0 - Rapid positioning
    forceFeed();  // Force feed output on next linear move after rapid
  }
}

/**
 * Helper function to force feed output on next move
 */
function forceFeed() {
  feedOutput.reset();
}

/**
 * Called for each circular movement (G2/G3)
 * Phase 3: Motion Implementation - Circular interpolation (arcs)
 */
function onCircular(clockwise, cx, cy, cz, x, y, z, feed) {
  
  // Determine G-code: G2 (clockwise) or G3 (counterclockwise)
  // Note: Direction may be mirrored depending on plane and spindle
  var directionCode = clockwise ? 2 : 3;
  
  // Get current position for calculating IJK offsets
  var start = getCurrentPosition();
  
  // Format endpoint coordinates
  var x_out = xOutput.format(x);
  var y_out = yOutput.format(y);
  var z_out = zOutput.format(z);
  var f = getFeed(feed);
  
  //--------------------------------------------------------------------------
  // RADIUS MODE (R___) vs IJK MODE
  //--------------------------------------------------------------------------
  if (getProperty("useRadius")) {
    // RADIUS MODE - Use R parameter for arc
    var r = getCircularRadius();
    
    // For arcs > 180°, use negative radius
    if (toDeg(getCircularSweep()) > (180 + 1e-9)) {
      r = -r;
    }
    
    // Determine which plane we're arcing in
    switch (getCircularPlane()) {
    case PLANE_XY:  // G17 plane (milling XY)
      writeBlock(
        gPlaneModal.format(17),
        gMotionModal.format(directionCode),
        x_out, y_out, z_out,
        "R" + rFormat.format(r),
        f
      );
      break;
      
    case PLANE_ZX:  // G18 plane (turning)
      writeBlock(
        gPlaneModal.format(18),
        gMotionModal.format(directionCode),
        x_out, y_out, z_out,
        "R" + rFormat.format(r),
        f
      );
      break;
      
    case PLANE_YZ:  // G19 plane (milling YZ)
      writeBlock(
        gPlaneModal.format(19),
        gMotionModal.format(directionCode),
        x_out, y_out, z_out,
        "R" + rFormat.format(r),
        f
      );
      break;
      
    default:
      // Unsupported plane - linearize the arc
      linearize(tolerance);
    }
    
  } else {
    // IJK MODE - Use I, J, K offsets from start to center
    
    // Calculate IJK offsets (center - start)
    var i_offset = cx - start.x;
    var j_offset = cy - start.y;
    var k_offset = cz - start.z;
    
    // Determine which plane we're arcing in
    switch (getCircularPlane()) {
    case PLANE_XY:  // G17 plane (milling XY)
      writeBlock(
        gPlaneModal.format(17),
        gMotionModal.format(directionCode),
        x_out, y_out, z_out,
        iOutput.format(i_offset),
        jOutput.format(j_offset),
        f
      );
      break;
      
    case PLANE_ZX:  // G18 plane (turning)
      writeBlock(
        gPlaneModal.format(18),
        gMotionModal.format(directionCode),
        x_out, y_out, z_out,
        iOutput.format(i_offset),
        kOutput.format(k_offset),
        f
      );
      break;
      
    case PLANE_YZ:  // G19 plane (milling YZ)
      writeBlock(
        gPlaneModal.format(19),
        gMotionModal.format(directionCode),
        x_out, y_out, z_out,
        jOutput.format(j_offset),
        kOutput.format(k_offset),
        f
      );
      break;
      
    default:
      // Unsupported plane - linearize the arc
      linearize(tolerance);
    }
  }
}

/**
 * Helper function to get current tool position
 */
function getCurrentPosition() {
  return new Vector(xOutput.getCurrent(), yOutput.getCurrent(), zOutput.getCurrent());
}

/**
 * Helper function to get circular plane
 */
function getCircularPlane() {
  // Determine which plane the arc is in based on current section
  if (currentSection.getType() == TYPE_TURNING) {
    return PLANE_ZX;  // G18 - Turning plane
  } else {
    // For milling, check the actual arc plane
    var n = getCircularNormal();
    if (Vector.dot(n, new Vector(0, 0, 1)) > 0.9) {
      return PLANE_XY;  // G17 - XY plane
    } else if (Vector.dot(n, new Vector(1, 0, 0)) > 0.9) {
      return PLANE_YZ;  // G19 - YZ plane
    } else {
      return PLANE_ZX;  // G18 - ZX plane
    }
  }
}

/**
 * Helper function to linearize arcs (break into small linear moves)
 */
function linearize(tolerance) {
  // This function breaks an arc into small linear segments
  // Used when arc is too complex for G2/G3 (helical, full circle in radius mode, etc.)
  
  var startAngle = getCircularStartAngle();
  var endAngle = startAngle + getCircularSweep();
  var center = getCircularCenter();
  var radius = getCircularRadius();
  
  // Calculate number of segments based on tolerance
  var segments = Math.max(4, Math.ceil(Math.abs(getCircularSweep()) / (2 * Math.acos(1 - tolerance / radius))));
  
  // Generate linear segments
  for (var i = 1; i <= segments; i++) {
    var angle = startAngle + (endAngle - startAngle) * i / segments;
    var x = center.x + radius * Math.cos(angle);
    var y = center.y + radius * Math.sin(angle);
    var z = getCurrentPosition().z; // Assuming flat arc for now
    
    onLinear(x, y, z, getFeed(currentSection.getFeedrate()));
  }
}

/**
 * Helper function to get degrees from radians
 */
function toDeg(rad) {
  return rad * 180 / Math.PI;
}

/**
 * Helper function to convert to radians
 */
function toRad(deg) {
  return deg * Math.PI / 180;
}

/**
 * Helper function to force all axis outputs on next move
 */
function forceXYZ() {
  xOutput.reset();
  yOutput.reset();
  zOutput.reset();
}

/**
 * Helper function to force all rotary axis outputs on next move
 */
function forceABC() {
  aOutput.reset();
  bOutput.reset();
  cOutput.reset();
}

// ============================================================================
// END OF GRACE ENGINEERING INTEGREX 100-IV ST DUAL TURRET POST PROCESSOR
// ============================================================================

/**
 * NEXT DEVELOPMENT STEPS:
 * 
 * Phase 1 (Current): Foundation Setup
 * - [X] Create skeleton structure with heavy comments
 * - [ ] Implement onOpen() - program header and initialization
 * - [ ] Implement onClose() - program termination
 * - [ ] Test basic structure (no operations, just header/footer)
 * 
 * Phase 2: Matrix Control M-Codes
 * - [ ] Implement G109 L1/L2 turret selection
 * - [ ] Implement M901/M902 spindle selection
 * - [ ] Implement M200/M300/M202/M302 milling mode
 * - [ ] Implement waiting codes (M950-M997, P-codes)
 * 
 * Phase 3: Turret Axis Management
 * - [ ] Implement Y-axis output per turret
 * - [ ] Implement B-axis output (upper turret only)
 * - [ ] Implement C-axis positioning
 * - [ ] Implement cross machining control (G110/G111)
 * 
 * Phase 4: Operation Logic
 * - [ ] Implement turning operations
 * - [ ] Implement milling operations
 * - [ ] Implement sub-spindle operations
 * - [ ] Implement onLinear(), onRapid(), onCircular()
 * 
 * Phase 5: Compound Machining
 * - [ ] Implement separate operations (sequential turrets)
 * - [ ] Implement parallel operations (simultaneous turrets)
 * - [ ] Implement balanced cutting (M562/M563)
 * 
 * Phase 6: Tool Management
 * - [ ] Implement tool changes (T-codes)
 * - [ ] Implement tool offsets
 * - [ ] Implement turret-specific tool libraries
 * 
 * Phase 7: Work Coordinate Systems
 * - [ ] Implement G54-G59 work offsets
 * - [ ] Implement spindle-specific offsets
 * - [ ] Implement part transfer WCS handling
 * 
 * Phase 8: Testing & Validation
 * - [ ] Create test programs
 * - [ ] Dry run validation
 * - [ ] Documentation
 */

// ============================================================================
// SECTION 11: CYCLE FUNCTIONS (PHASE 4)
// ============================================================================

/**
 * Called when a cycle is being executed
 * Phase 4: Advanced Operations - Drilling, tapping, boring cycles
 */
function onCycle() {
  if (!getProperty("useCycles")) {
    // User has disabled canned cycles - will linearize instead
    return;
  }
  
  // Cycles are handled in onCyclePoint
  // This function can perform setup if needed
  
  writeComment("Cycle: " + cycleType);
}

/**
 * Called for each point in a cycle (drilling, tapping, etc.)
 * Phase 4: Drilling Cycles Implementation
 */
function onCyclePoint(x, y, z) {
  
  if (!getProperty("useCycles")) {
    // Linearize the cycle - expand into G0/G1 moves
    expandCyclePoint(x, y, z);
    return;
  }
  
  // Set plane before starting cycle
  if (machineState.isTurning) {
    writeBlock(gPlaneModal.format(18));  // G18 - ZX plane for turning
  } else {
    writeBlock(gPlaneModal.format(17));  // G17 - XY plane for milling
  }
  
  //--------------------------------------------------------------------------
  // CYCLE INITIALIZATION (first point only)
  //--------------------------------------------------------------------------
  if (isFirstCyclePoint()) {
    
    // Position to cycle clearance (R plane)
    repositionToCycleClearance(cycle, x, y, z);
    
    // Calculate dwell time in milliseconds (if needed)
    var P = !cycle.dwell ? 0 : clamp(1, cycle.dwell * 1000, 99999999);
    
    //------------------------------------------------------------------------
    // DRILLING CYCLES
    //------------------------------------------------------------------------
    switch (cycleType) {
    
    case "drilling":
      // G81 - Standard drilling cycle
      writeBlock(
        gRetractModal.format(98),      // G98 - Return to initial level
        gAbsIncModal.format(90),        // G90 - Absolute mode
        gCycleModal.format(81),         // G81 - Drill cycle
        getCommonCycle(x, y, z, cycle.retract),
        getFeed(cycle.feedrate)
      );
      break;
      
    case "counter-boring":
      // G82 - Counter boring cycle (drilling with dwell)
      writeBlock(
        gRetractModal.format(98),
        gAbsIncModal.format(90),
        gCycleModal.format(82),         // G82 - Counter bore
        getCommonCycle(x, y, z, cycle.retract),
        conditional(P > 0, "P" + milliFormat.format(P)),  // Dwell time
        getFeed(cycle.feedrate)
      );
      break;
      
    case "chip-breaking":
      // G73 - High-speed peck drilling (chip breaking)
      if (cycle.accumulatedDepth < cycle.depth) {
        // Not deep enough for chip breaking - linearize
        expandCyclePoint(x, y, z);
      } else {
        writeBlock(
          gRetractModal.format(98),
          gAbsIncModal.format(90),
          gCycleModal.format(73),       // G73 - High-speed peck
          getCommonCycle(x, y, z, cycle.retract),
          "Q" + spatialFormat.format(cycle.incrementalDepth),  // Peck depth
          conditional(P > 0, "P" + milliFormat.format(P)),
          getFeed(cycle.feedrate)
        );
      }
      break;
      
    case "deep-drilling":
      // G83 - Peck drilling cycle (full retract)
      if (cycle.incrementalDepthReduction > 0) {
        // Variable peck not supported - linearize
        expandCyclePoint(x, y, z);
        return;
      }
      writeBlock(
        gRetractModal.format(98),
        gAbsIncModal.format(90),
        gCycleModal.format(83),         // G83 - Peck drill
        getCommonCycle(x, y, z, cycle.retract),
        "Q" + spatialFormat.format(cycle.incrementalDepth),  // Peck depth
        conditional(P > 0, "P" + milliFormat.format(P)),
        getFeed(cycle.feedrate)
      );
      break;
      
    //------------------------------------------------------------------------
    // TAPPING CYCLES
    //------------------------------------------------------------------------
    case "tapping":
    case "right-tapping":
      // G84 (RH) or G74 (LH) - Tapping cycle
      var tapCode = (tool.type == TOOL_TAP_LEFT_HAND) ? 74 : 84;
      writeBlock(
        gRetractModal.format(98),
        gAbsIncModal.format(90),
        gCycleModal.format(tapCode),    // G84 RH or G74 LH
        getCommonCycle(x, y, z, cycle.retract),
        getFeed(cycle.feedrate)
      );
      forceFeed();
      break;
      
    case "left-tapping":
      // G74 - Left-hand tapping
      writeBlock(
        gRetractModal.format(98),
        gAbsIncModal.format(90),
        gCycleModal.format(74),         // G74 - LH tap
        getCommonCycle(x, y, z, cycle.retract),
        getFeed(cycle.feedrate)
      );
      forceFeed();
      break;
      
    case "tapping-with-chip-breaking":
      // Rigid tapping with chip breaking
      writeBlock(
        gRetractModal.format(98),
        gAbsIncModal.format(90),
        gCycleModal.format(84),
        getCommonCycle(x, y, z, cycle.retract),
        "Q" + spatialFormat.format(cycle.incrementalDepth),
        getFeed(cycle.feedrate)
      );
      forceFeed();
      break;
      
    //------------------------------------------------------------------------
    // BORING CYCLES
    //------------------------------------------------------------------------
    case "boring":
      // G85 - Boring cycle (feed in and out)
      writeBlock(
        gRetractModal.format(98),
        gAbsIncModal.format(90),
        gCycleModal.format(85),         // G85 - Bore
        getCommonCycle(x, y, z, cycle.retract),
        getFeed(cycle.feedrate)
      );
      break;
      
    case "reaming":
      // G85 - Reaming (same as boring)
      writeBlock(
        gRetractModal.format(98),
        gAbsIncModal.format(90),
        gCycleModal.format(85),
        getCommonCycle(x, y, z, cycle.retract),
        getFeed(cycle.feedrate)
      );
      break;
      
    case "stop-boring":
      // G86 - Boring with spindle stop and rapid retract
      writeBlock(
        gRetractModal.format(98),
        gAbsIncModal.format(90),
        gCycleModal.format(86),         // G86 - Bore with stop
        getCommonCycle(x, y, z, cycle.retract),
        conditional(P > 0, "P" + milliFormat.format(P)),
        getFeed(cycle.feedrate)
      );
      break;
      
    case "manual-boring":
      // G88 - Boring with manual retract
      writeBlock(
        gRetractModal.format(98),
        gAbsIncModal.format(90),
        gCycleModal.format(88),         // G88 - Manual bore
        getCommonCycle(x, y, z, cycle.retract),
        conditional(P > 0, "P" + milliFormat.format(P)),
        getFeed(cycle.feedrate)
      );
      break;
      
    case "boring-with-stop-dwell":
      // G89 - Boring with dwell
      writeBlock(
        gRetractModal.format(98),
        gAbsIncModal.format(90),
        gCycleModal.format(89),         // G89 - Bore with dwell
        getCommonCycle(x, y, z, cycle.retract),
        conditional(P > 0, "P" + milliFormat.format(P)),
        getFeed(cycle.feedrate)
      );
      break;
      
    //------------------------------------------------------------------------
    // THREADING CYCLES
    //------------------------------------------------------------------------
    case "thread-turning":
      // Threading cycle - G76 (multi-pass) or G92 (single-pass)
      
      // Check if we should use simple threading (G92) or compound threading (G76)
      var useSimpleThread = getProperty("useSimpleThread");
      
      if (useSimpleThread) {
        //--------------------------------------------------------------------
        // G92 - SIMPLE THREADING (Single Pass)
        //--------------------------------------------------------------------
        // Used for: simple threads, manual control, compatibility
        
        var r = -cycle.incrementalX; // Taper amount (positive if taper goes down)
        
        // Position to thread start
        moveToThreadStart(x, y, z);
        
        // Output G92 threading command
        writeBlock(
          gMotionModal.format(92),               // G92 - Thread cutting
          xOutput.format(x - cycle.incrementalX), // Final X (diameter)
          yOutput.format(y),
          zOutput.format(z),                      // Final Z
          conditional(zFormat.isSignificant(r), g92ROutput.format(r)), // Taper (if any)
          pitchOutput.format(cycle.pitch)         // Thread pitch (F)
        );
        
      } else {
        //--------------------------------------------------------------------
        // G76 - COMPOUND THREADING (Multiple Pass)
        //--------------------------------------------------------------------
        // Used for: automatic multiple passes, finish passes, optimal cutting
        
        if (isLastCyclePoint()) {
          // Only output G76 on last cycle point (after all passes calculated)
          
          // Calculate thread parameters
          var threadHeight = getParameter("operation:threadDepth");
          var repeatPass = hasParameter("operation:nullPass") ? getParameter("operation:nullPass") : 0;
          var chamferWidth = 10; // Pullout width in 1/10's of thread lead
          var materialAllowance = 0; // Material allowance for finishing pass
          var cuttingAngle = getParameter("operation:infeedAngle", 30) * 2; // Infeed angle
          
          // Calculate stepdowns from cycle points
          var stepdowns = [];
          for (var i = 0; i < getNumberOfCyclePoints() - 1; i++) {
            stepdowns.push(Math.abs(getCyclePoint(i).x - getCyclePoint(i + 1).x));
          }
          var minimumDepthOfCut = Math.min.apply(null, stepdowns.filter(Boolean));
          var firstDepthOfCut = cycle.firstPassDepth ? cycle.firstPassDepth : 
                                threadHeight - Math.abs(getCyclePoint(0).x - x);
          
          //------------------------------------------------------------------
          // FIRST G76 BLOCK - Cycle parameters
          //------------------------------------------------------------------
          // Format: G76 P(multi-digit) Q(min cut) R(finish allowance)
          // P format: AABBCC where AA=repeat passes, BB=chamfer, CC=angle
          var pcode = repeatPass * 10000 + chamferWidth * 100 + cuttingAngle;
          
          gCycleModal.reset();
          writeBlock(
            gCycleModal.format(76),                    // G76 - Threading cycle
            threadP1Output.format(pcode),               // P - Cycle parameters
            threadQOutput.format(minimumDepthOfCut),    // Q - Minimum depth of cut
            threadROutput.format(materialAllowance)     // R - Finish allowance
          );
          
          //------------------------------------------------------------------
          // SECOND G76 BLOCK - Thread geometry
          //------------------------------------------------------------------
          // Format: G76 X(final) Z(final) R(taper) P(depth) Q(first cut) F(pitch)
          var r = -cycle.incrementalX; // Taper (positive if taper goes down)
          
          gCycleModal.reset();
          writeBlock(
            gCycleModal.format(76),                     // G76 - Threading cycle
            xOutput.format(x),                          // X - Final diameter
            zOutput.format(z),                          // Z - Thread end position
            conditional(zFormat.isSignificant(r), threadROutput.format(r)), // R - Taper
            threadP2Output.format(threadHeight),        // P - Thread depth (radial)
            threadQOutput.format(firstDepthOfCut),      // Q - First pass depth
            pitchOutput.format(cycle.pitch)             // F - Thread pitch
          );
          
          forceFeed(); // Force feed output on next move
        }
      }
      return; // Threading handled, skip standard cycle point logic
      
    //------------------------------------------------------------------------
    // UNSUPPORTED CYCLES
    //------------------------------------------------------------------------
    default:
      // Cycle not supported - linearize into basic moves
      expandCyclePoint(x, y, z);
    }
    
  } else {
    // NOT FIRST POINT - just output coordinates
    // Cycle is modal, so we only need X Y (Z for some cycles)
    if (cycleExpanded) {
      expandCyclePoint(x, y, z);
    } else {
      var _x = xOutput.format(x);
      var _y = yOutput.format(y);
      if (_x || _y) {
        writeBlock(_x, _y);
      }
    }
  }
}

/**
 * Called at the end of a cycle
 * Phase 4: Cancel the active cycle
 */
function onCycleEnd() {
  if (!cycleExpanded) {
    writeBlock(gCycleModal.format(80));  // G80 - Cancel cycle
    gMotionModal.reset();
  }
}

/**
 * Helper function to position to cycle clearance plane
 */
function repositionToCycleClearance(cycle, x, y, z) {
  // Position to R plane (clearance height) before starting cycle
  writeBlock(gMotionModal.format(0), xOutput.format(x), yOutput.format(y));
  writeBlock(gMotionModal.format(0), zOutput.format(cycle.clearance));
}

/**
 * Helper function to get common cycle parameters
 */
function getCommonCycle(x, y, z, r) {
  // Build common cycle parameters: X Y Z R
  forceXYZ();
  return [
    xOutput.format(x),
    yOutput.format(y),
    zOutput.format(z),
    "R" + spatialFormat.format(r)
  ];
}

/**
 * Helper function for clamp
 */
function clamp(min, value, max) {
  return Math.max(min, Math.min(value, max));
}

/**
 * Helper function to check if this is the first cycle point
 */
function isFirstCyclePoint() {
  return cycleSubprogramIsActive ? false : (getCurrentPosition().x == 0 && getCurrentPosition().y == 0 && getCurrentPosition().z == 0) || !isSameDirection(getCurrentDirection(), cycleDirection) || isProbeOperation();
}

/**
 * Helper function to check current direction
 */
function getCurrentDirection() {
  // Returns current tool axis direction
  return currentSection.workPlane.forward;
}

/**
 * Helper function to check if operation is probing
 */
function isProbeOperation() {
  return currentSection.hasParameter("operation-strategy") && 
         (currentSection.getParameter("operation-strategy") == "probe");
}

/**
 * Helper function to move to thread start position
 * Positions tool at start of threading operation with proper clearance
 */
function moveToThreadStart(x, y, z) {
  // Position to thread start with clearance
  // For threading, we need to be at the start Z position before engaging
  var threadStart = z + cycle.incrementalZ; // Start position (clearance)
  
  // Rapid to thread start X/Y
  if (gotYAxis) {
    writeBlock(gMotionModal.format(0), xOutput.format(x), yOutput.format(y));
  } else {
    writeBlock(gMotionModal.format(0), xOutput.format(x));
  }
  
  // Rapid to thread start Z (with clearance)
  writeBlock(gMotionModal.format(0), zOutput.format(threadStart));
}

/**
 * Helper function to get number of cycle points
 */
function getNumberOfCyclePoints() {
  // Returns the total number of points in the current cycle
  return currentSection.getNumberOfCyclePoints();
}

/**
 * Helper function to get a specific cycle point
 */
function getCyclePoint(index) {
  // Returns the cycle point at the specified index
  return currentSection.getCyclePoint(index);
}

/**
 * Helper function to check if this is the last cycle point
 */
function isLastCyclePoint() {
  // For threading with multiple passes, only output G76 on last point
  return currentSection.getCyclePointId() == (getNumberOfCyclePoints() - 1);
}
