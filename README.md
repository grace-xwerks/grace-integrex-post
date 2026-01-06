# Grace Engineering - Mazak Integrex 100-IV ST Dual Turret Post Processor

[![License](https://img.shields.io/badge/License-Proprietary-red.svg)](LICENSE)
[![Version](https://img.shields.io/badge/Version-0.4.0-blue.svg)](CHANGELOG.md)
[![Status](https://img.shields.io/badge/Status-Development-yellow.svg)](DEVELOPMENT_STATUS.md)

A custom Autodesk Fusion 360 post processor for the Mazak Integrex 100-IV ST dual turret mill-turn machine with Matrix (Nexus) control.

---

## 🎯 Overview

This post processor is specifically designed for:

- **Machine:** Mazak Integrex 100-IV ST (Model IN1004ST)
- **Serial Number:** 195369
- **Control:** Mazak Matrix (Matrix Nexus)
- **Owner:** Grace Engineering Corp
- **Configuration:** Dual turret, Y-axes on both turrets, B-axis on upper turret, sub-spindle

### Key Features

- ✅ Dual turret support with G109 L1/L2 turret selection
- ✅ Matrix control M-codes (M901/M902, M200/M300, M950, M562/M563)
- ✅ Y-axis on both upper and lower turrets (±105mm travel)
- ✅ B-axis on upper turret (0-90°, programmable)
- ✅ Sub-spindle support
- ✅ Diameter mode for turning operations
- ✅ Complete motion control (G0, G1, G2, G3)
- ✅ Milling and turning operations
- ✅ Work offset management (G54-G59)
- ✅ Spindle speed limiting per spindle type

---

## 📋 Machine Specifications

### Axis Configuration

| Axis | Travel | Notes |
|------|--------|-------|
| X-axis | -50mm min (radius) | No maximum limit check |
| Y-axis | ±105mm | Both turrets |
| Z-axis | Software limits | ±100,000mm for calculations |
| B-axis | 0° to 90° | Upper turret only, programmable |
| C-axis | 0° to 360° | Both spindles, cyclic |

### Spindle Specifications

| Spindle | Max RPM | Notes |
|---------|---------|-------|
| Main | 5,060 | Kitagawa 6" 3-jaw chuck limitation |
| Sub | 6,000 | Standard chuck |
| Live Tooling | 12,000 | Both turrets |

### Turret Configuration

| Turret | Y-Axis | B-Axis | C-Axis | Live Tools |
|--------|--------|--------|--------|------------|
| Upper (TR1/HD1) | ✅ ±105mm | ✅ 0-90° | ✅ | ✅ 12k RPM |
| Lower (TR2/HD2) | ✅ ±105mm | ❌ | ✅ | ✅ 12k RPM |

---

## 🚀 Installation

### Prerequisites

- Autodesk Fusion 360 (2020 or newer recommended)
- Access to Fusion 360 CAM workspace
- Basic understanding of mill-turn programming

### Installation Steps

1. **Download the Post Processor:**
   ```bash
   git clone https://github.com/your-username/grace-integrex-post.git
   cd grace-integrex-post
   ```

2. **Copy to Fusion 360 Post Library:**
   
   **Windows:**
   ```
   Copy grace_integrex_100iv_dual_turret.cps to:
   %LOCALAPPDATA%\Autodesk\webdeploy\production\<version>\Fusion\Server\CAM\cache\posts\
   ```
   
   **macOS:**
   ```
   Copy grace_integrex_100iv_dual_turret.cps to:
   ~/Library/Application Support/Autodesk/webdeploy/production/<version>/Fusion360.app/Contents/Libraries/Applications/CAM/cache/posts/
   ```

3. **Select in Fusion 360:**
   - Open CAM workspace
   - Right-click on Setup → Post Process
   - Click "Select" next to "Post Configuration"
   - Choose "grace_integrex_100iv_dual_turret" from library
   - Click "Post"

---

## 📖 Usage

### Basic Workflow

1. **Setup Your Part in Fusion 360**
   - Create manufacturing setup for mill-turn
   - Assign operations to correct turret (1=Upper, 2=Lower)
   - Set spindle (Primary=Main, Secondary=Sub)
   - Define work coordinate system (G54-G59)

2. **Tool Assignment**
   - Turret 1 (Upper): Tools with Y-axis and B-axis capability
   - Turret 2 (Lower): Tools with Y-axis, no B-axis
   - Enter Tool ID Code in Product ID field if required

3. **Post Process**
   - Select this post processor
   - Configure properties (see below)
   - Generate G-code
   - Review output for correctness

### Post Processor Properties

| Property | Default | Options | Description |
|----------|---------|---------|-------------|
| Controller Type | Matrix | Matrix, Smooth | Control type |
| Max Spindle Speed (Main) | 5060 | 0-10000 | Main spindle RPM limit |
| Max Spindle Speed (Sub) | 6000 | 0-10000 | Sub-spindle RPM limit |
| Max Spindle Speed (Live) | 12000 | 0-20000 | Live tooling RPM limit |
| Use Sequence Numbers | Tool Change | Yes, No, Tool Change | N-code output |
| Use Radius Arcs | true | true, false | R vs IJK for arcs |
| Use Canned Cycles | true | true, false | Drilling cycles |
| Optional Stop | true | true, false | M01 output |

### Example Program Structure

```gcode
%
(PROGRAM: SAMPLE-PART)
(Grace Engineering - Integrex 100-IV ST)
(Serial: 195369)

G21 G18 G90 G94 G49 G54

(======================================)
(UPPER TURRET - MAIN SPINDLE TURNING)
(======================================)
G109 L1
M901
M202
T0101
M3 S1200
G0 X52.0 Z5.0
G1 Z-25.0 F0.25
X50.0
G0 X100.0 Z50.0
M9 M5
M950
M30

(======================================)
(LOWER TURRET - MAIN SPINDLE TURNING)
(======================================)
G109 L2
M901
M202
T0201
M3 S1200
G0 X52.0 Z5.0
G1 Z-25.0 F0.25
X50.0
G0 X100.0 Z50.0
M9 M5
M950
M30

M30
%
```

---

## 📊 Development Status

**Current Version:** 0.4.0  
**Status:** Development - Not Production Ready

### Completed Phases (✅)

- **Phase 1:** Foundation Setup
  - Machine configuration
  - Program structure
  - Header/footer generation

- **Phase 2:** Matrix Control M-Codes
  - G109 turret selection
  - M901/M902 spindle selection
  - M200/M300 milling mode
  - M950 synchronization
  - Tool management

- **Phase 3:** Motion Implementation
  - G0 rapid positioning
  - G1 linear interpolation
  - G2/G3 circular interpolation
  - Feed rate management
  - Y-axis per turret

### Pending Phases (🔄)

- **Phase 4:** Advanced Operations
  - Drilling cycles (G83, G73, etc.)
  - Threading (G76, G92)
  - B-axis output
  - C-axis positioning
  - Sub-spindle operations

- **Phase 5:** Compound Machining
  - Balanced cutting (M562/M563)
  - Parallel operations
  - Cross-machining (G110/G111)

- **Phase 6-8:** Tool Management, Advanced WCS, Testing

**See [DEVELOPMENT_STATUS.md](DEVELOPMENT_STATUS.md) for detailed progress.**

---

## ⚠️ Important Notes

### Current Limitations

- ❌ No drilling/tapping cycles (will linearize)
- ❌ No threading support
- ❌ No B-axis output (upper turret B not implemented)
- ❌ No C-axis indexing for live tools
- ❌ No balanced cutting (M562/M563)
- ❌ No sub-spindle part transfer
- ❌ Not tested on actual machine yet

### Safety Warnings

**⚠️ DO NOT USE IN PRODUCTION**

This post processor is under active development. Before using on the actual machine:

1. ✅ Validate all G-code in Mazak simulator
2. ✅ Perform dry run with no part/tools
3. ✅ Verify all work offsets and tool offsets
4. ✅ Check spindle speed limits
5. ✅ Verify turret clearances
6. ✅ Test with single-block execution first

**The developers assume no liability for machine damage, tool breakage, or scrap parts.**

---

## 🔧 Technical Details

### Architecture

This is a **standalone, definitive post processor**:
- All machine definitions contained in single file
- No external machine definition files required
- Single source of truth for this specific machine
- Based on Mazak Integrex i-100S reference post

### Key Technical Decisions

1. **Diameter Mode:** X-axis uses `scale:2` to output diameter values
2. **G109 Structure:** Each turret section ends with M30
3. **M950 Synchronization:** Automatic insertion between turret changes
4. **Modal Output:** Efficient G-code with modal suppression

### Code Structure

```
grace_integrex_100iv_dual_turret.cps
├── Header (Machine info, version, changelog)
├── Properties (User-configurable settings)
├── Format Definitions (Number formatting)
├── Global Variables (Machine state, flags)
├── M-Code Definitions (getCode function)
├── Machine Configuration (defineMachine)
├── Turret Activation (activateMachine)
├── Utility Functions (Helpers)
└── Main Callbacks (onOpen, onSection, onLinear, etc.)
```

---

## 📚 Documentation

- [CHANGELOG.md](CHANGELOG.md) - Version history and changes
- [DEVELOPMENT_STATUS.md](DEVELOPMENT_STATUS.md) - Current development progress
- [TECHNICAL_NOTES.md](TECHNICAL_NOTES.md) - Implementation details
- [CONTRIBUTING.md](CONTRIBUTING.md) - How to contribute
- [xformat_fix_documentation.md](docs/xformat_fix_documentation.md) - Critical diameter mode fix

---

## 🤝 Contributing

This is a custom post processor for a specific machine. Contributions are welcome but should maintain compatibility with the Grace Engineering Integrex 100-IV ST configuration.

### How to Contribute

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Make your changes
4. Test thoroughly (simulator + dry run)
5. Commit with clear messages (`git commit -m 'Add feature: ...'`)
6. Push to branch (`git push origin feature/improvement`)
7. Create Pull Request

### Coding Standards

- Heavy commenting for clarity
- Maintain existing code structure
- Test all changes in simulator
- Update documentation
- Follow Autodesk post processor best practices

---

## 📝 License

**Proprietary - Grace Engineering Corp**

This post processor is custom-developed for Grace Engineering's specific machine configuration. Use on other machines may require modifications.

---

## 👥 Authors & Acknowledgments

**Developed By:**
- Grace Engineering Corp
- Claude AI (Anthropic)

**Based On:**
- Autodesk Fusion 360 `mazak_integrex_i-100s.cps` reference post
- Mazak Matrix programming manual specifications
- Grace Engineering machine parameters (Serial 195369)

**Special Thanks:**
- Mazak for programming documentation
- Autodesk for Fusion 360 CAM platform
- Mill-turn programming community

---

## 📞 Support

**For Issues:**
- Open an issue on GitHub
- Include Fusion 360 version
- Attach generated G-code sample
- Describe expected vs actual behavior

**For Machine-Specific Questions:**
- Contact Grace Engineering directly
- Refer to Mazak programming manual
- Consult Mazak technical support

---

## 🔗 Resources

- [Mazak Programming Manual](docs/Programming_Manual_2.pdf)
- [Autodesk Post Processor Training](https://cam.autodesk.com/posts/)
- [Fusion 360 CAM Documentation](https://help.autodesk.com/view/fusion360/ENU/)
- [Matrix Control Documentation](https://www.mazak.com)

---

## 📅 Roadmap

### Q1 2026
- ✅ Phase 1-3 completion
- 🔄 Phase 4: Advanced operations
- 🔄 Simulator testing

### Q2 2026
- Phase 5: Compound machining
- First machine dry run
- Documentation completion

### Q3 2026
- Phase 6-8: Final features
- Production validation
- v1.0 release

---

**Last Updated:** January 2026  
**Current Version:** 0.4.0  
**Status:** Active Development

---

