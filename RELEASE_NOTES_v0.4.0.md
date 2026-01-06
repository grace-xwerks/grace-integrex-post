# Release v0.4.0 - Motion Implementation Complete

**Release Date:** January 6, 2026  
**Status:** Development Release - Not Production Ready

---

## 🎉 What's New

### Phase 3: Motion Implementation ✅

This release implements complete basic motion control for the Grace Engineering Mazak Integrex 100-IV ST dual turret mill-turn machine.

**New Features:**
- ✅ **G0 Rapid Positioning** - Full rapid movement support
- ✅ **G1 Linear Interpolation** - Linear cutting moves with feed control
- ✅ **G2/G3 Arc Interpolation** - Circular moves in radius or IJK mode
- ✅ **Automatic Plane Selection** - G17/G18/G19 based on operation
- ✅ **Feed Rate Management** - G94 (per minute) and G95 (per revolution)
- ✅ **Y-Axis Per Turret** - Automatic enable/disable based on turret
- ✅ **Diameter Mode Fix** - Critical fix for X-axis output (v0.3.1)

---

## 📦 What's Included

### Post Processor Files

**Main File:**
- `grace_integrex_100iv_dual_turret.cps` - Current version (v0.4.0)

**Versioned:**
- `versions/grace_integrex_100iv_dual_turret_v0.4.0.cps` - Tagged version

### Documentation

**Getting Started:**
- `README.md` - Project overview and installation
- `CHANGELOG.md` - Complete version history
- `LICENSE` - Proprietary license terms

**Development:**
- `DEVELOPMENT_STATUS.md` - Detailed phase progress
- `CONTRIBUTING.md` - Contribution guidelines
- `TECHNICAL_NOTES.md` - Implementation details

**Technical Documentation:**
- `docs/xformat_fix_documentation.md` - Diameter mode fix explanation
- `docs/Phase_3_Summary.md` - Phase 3 completion summary
- `docs/sanity_check_report.md` - Code quality review

**Version Control:**
- `versions/VERSION_HISTORY.txt` - Version compatibility matrix
- `.gitignore` - Git ignore file

---

## ✨ Highlights

### Complete Basic Motion

The post processor can now generate functional G-code for:

**Turning Operations:**
```gcode
G0 X52.0 Z5.0           ← Rapid positioning
G1 Z-25.0 F0.25        ← Face cut
X50.0                   ← Turn to diameter (diameter mode!)
G2 X46.0 Z-27.0 R2.0   ← Corner radius
```

**Milling Operations:**
```gcode
G17                     ← XY plane
G0 X25.0 Y0.0 Z5.0     ← Rapid approach
G1 Z-5.0 F500          ← Plunge
G3 X25.0 Y0.0 I-25.0 J0.0 F800  ← Full circle
```

### Diameter Mode Fixed

**Critical Fix (v0.3.1):**
- X-axis now correctly outputs diameter values
- Added `scale:2` to xFormat
- **Example:** 25mm radius → X50.0 output ✅
- **Before fix:** Would output X25.0 → 50% undersized parts ❌

---

## 📊 Completion Status

### Completed Phases (3 of 8)

| Phase | Status | Features |
|-------|--------|----------|
| **Phase 1** | ✅ Complete | Foundation, program structure |
| **Phase 2** | ✅ Complete | Matrix M-codes, turret selection |
| **Phase 3** | ✅ Complete | Motion control (G0/G1/G2/G3) |
| Phase 4 | 🔄 Next | Drilling cycles, threading, B-axis |
| Phase 5 | ⏳ Planned | Compound machining, balanced cutting |
| Phase 6 | ⏳ Planned | Advanced tool management |
| Phase 7 | ⏳ Planned | Extended work coordinates |
| Phase 8 | ⏳ Planned | Testing & validation |

**Overall Progress:** 37.5% (3 of 8 phases complete)

---

## ⚠️ Important Warnings

### NOT Production Ready

**This release is for DEVELOPMENT and TESTING only.**

**Known Limitations:**
- ❌ No drilling/tapping cycles (will linearize)
- ❌ No threading support (G76/G92)
- ❌ No B-axis output (upper turret B not implemented)
- ❌ No C-axis indexing for live tools
- ❌ No balanced cutting (M562/M563)
- ❌ No sub-spindle part transfer
- ❌ Not tested on actual machine

### Safety Requirements

**Before using on any machine:**

1. ✅ Validate ALL G-code in Mazak simulator
2. ✅ Perform dry run with no part/tools
3. ✅ Verify all work offsets and tool offsets
4. ✅ Check spindle speed limits
5. ✅ Verify turret clearances
6. ✅ Test with single-block execution

**⚠️ The developers assume NO LIABILITY for machine damage, tool breakage, or scrap parts.**

---

## 🚀 Installation

### Quick Start

1. **Download the release**
   ```bash
   unzip grace_integrex_post_v0.4.0_release.zip
   cd grace_integrex_post_release
   ```

2. **Copy to Fusion 360**
   
   **Windows:**
   ```
   %LOCALAPPDATA%\Autodesk\webdeploy\production\<version>\Fusion\Server\CAM\cache\posts\
   ```
   
   **macOS:**
   ```
   ~/Library/Application Support/Autodesk/webdeploy/production/<version>/Fusion360.app/Contents/Libraries/Applications/CAM/cache/posts/
   ```

3. **Select in Fusion 360**
   - CAM workspace → Post Process
   - Select "grace_integrex_100iv_dual_turret"
   - Configure properties
   - Generate G-code

### Detailed Instructions

See [README.md](README.md) for complete installation and usage instructions.

---

## 📝 What Works

### Verified Functionality

✅ **Program Structure:**
- Header with machine identification
- Proper initialization (G21, G18, G90, G94)
- Safe termination sequence
- Return to home position

✅ **Turret Management:**
- G109 L1/L2 turret selection
- Automatic turret switching
- Y-axis enable/disable per turret
- Section synchronization (M950)

✅ **Spindle Control:**
- M901/M902 spindle selection
- M200/M300 milling mode
- M203 milling spindle rotation
- Spindle speed validation

✅ **Tool Management:**
- T-code tool changes
- D-code tool ID support
- Work offset selection (G54-G59)
- Coolant control (M8/M9)

✅ **Motion Control:**
- G0 rapid positioning
- G1 linear interpolation
- G2/G3 circular interpolation
- Radius and IJK arc formats
- Plane selection (G17/G18/G19)
- Feed rate control (G94/G95)

✅ **Coordinate Systems:**
- Diameter mode for turning (X-axis)
- Radius mode for milling (Y-axis)
- Automatic coordinate conversion

---

## 🐛 Known Issues

No bugs currently reported for v0.4.0.

**Limitations** (not bugs):
- See "NOT Production Ready" section above

---

## 📈 Metrics

### Code Statistics

| Metric | Value |
|--------|-------|
| Lines of Code | 2,026 |
| Functions | 35 |
| Comments | ~800 lines (40%) |
| File Size | 66 KB |

### Development Progress

| Category | Complete |
|----------|----------|
| Basic Motion | 100% ✅ |
| Structure | 100% ✅ |
| Matrix M-Codes | 100% ✅ |
| Cycles | 0% ⏳ |
| Multi-Axis | 33% 🔄 |
| Compound | 0% ⏳ |

---

## 🔮 What's Next

### Phase 4 Roadmap (v0.5.0)

**Target:** Q1 2026

**Planned Features:**
- Drilling cycles (G81-G89)
- Peck drilling (G83)
- Tapping (G84, G74)
- Threading (G76, G92)
- B-axis output (upper turret)
- C-axis positioning
- Sub-spindle operations

---

## 📚 Documentation

### Must Read

1. **[README.md](README.md)** - Start here!
2. **[CHANGELOG.md](CHANGELOG.md)** - Version history
3. **[DEVELOPMENT_STATUS.md](DEVELOPMENT_STATUS.md)** - Current progress

### Technical Deep-Dive

1. **[TECHNICAL_NOTES.md](TECHNICAL_NOTES.md)** - Implementation details
2. **[docs/xformat_fix_documentation.md](docs/xformat_fix_documentation.md)** - Diameter mode
3. **[docs/Phase_3_Summary.md](docs/Phase_3_Summary.md)** - Phase 3 details

### Contributing

1. **[CONTRIBUTING.md](CONTRIBUTING.md)** - How to contribute
2. **[LICENSE](LICENSE)** - License terms

---

## 🙏 Acknowledgments

**Developed By:**
- Grace Engineering Corp
- Claude AI (Anthropic)

**Based On:**
- Autodesk Fusion 360 `mazak_integrex_i-100s.cps`
- Mazak Matrix Programming Manual
- Grace Engineering Machine Parameters (Serial 195369)

**Special Thanks:**
- Mazak for comprehensive programming documentation
- Autodesk for Fusion 360 CAM platform
- Mill-turn programming community

---

## 🔗 Links

- **GitHub Repository:** [Link to your repo]
- **Issue Tracker:** [Link to issues]
- **Discussions:** [Link to discussions]
- **Documentation:** [Link to wiki/docs]

---

## 📞 Support

**For Issues:**
- Open an issue on GitHub
- Include Fusion 360 version
- Attach G-code sample
- Describe expected vs actual

**For Questions:**
- Check documentation first
- Search existing issues
- Open discussion or question issue

**For Machine-Specific:**
- Contact Grace Engineering
- Refer to Mazak programming manual
- Consult Mazak technical support

---

## ⬇️ Download

**Full Package (Recommended):**
- `grace_integrex_post_v0.4.0_release.zip` (70 KB)
  - Includes all documentation
  - Versioned .cps files
  - Complete project structure

**Individual Files:**
- `grace_integrex_100iv_dual_turret.cps` - Post processor only

---

## 🔐 Checksums

```
MD5:    [Generate after zip creation]
SHA256: [Generate after zip creation]
```

---

## 📅 Release Timeline

- **v0.1.0** - January 5, 2026 - Skeleton
- **v0.2.0** - January 5, 2026 - Foundation
- **v0.3.0** - January 5, 2026 - Matrix M-codes
- **v0.3.1** - January 6, 2026 - Critical fix
- **v0.4.0** - January 6, 2026 - Motion (current)
- **v0.5.0** - Q1 2026 - Advanced operations (planned)
- **v1.0.0** - Q3 2026 - Production release (planned)

---

**Released:** January 6, 2026  
**Version:** 0.4.0  
**Status:** Development  
**License:** Proprietary - Grace Engineering Corp.

---

*This release represents significant progress toward a production-ready post processor for the Grace Engineering Mazak Integrex 100-IV ST. However, extensive testing is still required before use in production environment.*
