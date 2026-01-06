# Contributing to Grace Integrex Post Processor

Thank you for your interest in contributing to this project! This post processor is custom-developed for a specific machine configuration, but contributions are welcome.

---

## 📋 Overview

This is a specialized post processor for:
- **Machine:** Mazak Integrex 100-IV ST (Serial 195369)
- **Owner:** Grace Engineering Corp
- **Status:** Active development (v0.4.0)

---

## 🤝 How to Contribute

### Reporting Issues

1. **Search existing issues** to avoid duplicates
2. **Provide complete information:**
   - Fusion 360 version
   - Post processor version
   - Generated G-code sample
   - Expected behavior
   - Actual behavior
   - Steps to reproduce

3. **Use the issue template:**
   ```markdown
   **Version:** v0.4.0
   **Fusion 360:** 2.0.XXXX
   **Operation Type:** Turning / Milling / Both
   
   **Description:**
   [Clear description of the issue]
   
   **G-Code Output:**
   ```gcode
   [Paste problematic G-code here]
   ```
   
   **Expected:**
   [What should happen]
   
   **Actual:**
   [What actually happens]
   ```

### Suggesting Features

1. **Check the development roadmap** in [DEVELOPMENT_STATUS.md](DEVELOPMENT_STATUS.md)
2. **Open an issue** with label `enhancement`
3. **Explain the use case** and benefits
4. **Provide examples** if possible

---

## 💻 Development Guidelines

### Code Style

1. **Heavy commenting is required**
   - Explain WHY, not just WHAT
   - Document all machine-specific decisions
   - Reference programming manual sections

2. **Follow existing structure**
   ```javascript
   /**
    * Function description
    * @param {type} name - Parameter description
    * @returns {type} - Return value description
    */
   function myFunction(param) {
     // Implementation
   }
   ```

3. **Use descriptive variable names**
   ```javascript
   // Good
   var upperTurretYAxisEnabled = true;
   
   // Bad
   var flag = true;
   ```

4. **Maintain compatibility**
   - Don't break existing functionality
   - Preserve machine-specific settings
   - Test thoroughly before submitting

### Commit Messages

Use conventional commit format:

```
type(scope): subject

body

footer
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `refactor`: Code restructuring
- `test`: Adding tests
- `chore`: Maintenance

**Examples:**
```
feat(motion): Add G83 peck drilling cycle

Implements standard G83 peck drilling cycle with:
- Peck depth (Q parameter)
- Retract distance (R parameter)
- Dwell at bottom (P parameter)

Closes #123

fix(diameter): Correct X-axis scaling for facing operations

X-axis was outputting radius instead of diameter in facing
operations when using G1 Z-axis only moves.

Fixes #456

docs(readme): Update installation instructions

Added macOS installation path and Fusion 360 version
requirements.
```

---

## 🔬 Testing Requirements

### Before Submitting

1. **Syntax Check**
   - Load post in Fusion 360
   - Generate test program
   - Check for errors

2. **Simulator Validation**
   - Run in Mazak simulator if available
   - Check for collision warnings
   - Verify tool paths

3. **Documentation**
   - Update CHANGELOG.md
   - Update README.md if needed
   - Add inline comments

### Test Cases

Create test cases for:
- Simple turning operation
- Simple milling operation
- Dual turret operation
- Edge cases (full circles, helical arcs, etc.)

---

## 🔄 Pull Request Process

### 1. Fork & Branch

```bash
# Fork the repository on GitHub
git clone https://github.com/your-username/grace-integrex-post.git
cd grace-integrex-post

# Create feature branch
git checkout -b feature/my-improvement
```

### 2. Make Changes

- Follow code style guidelines
- Add/update tests
- Update documentation
- Test thoroughly

### 3. Commit

```bash
# Stage changes
git add .

# Commit with descriptive message
git commit -m "feat(cycles): Add G83 peck drilling cycle"
```

### 4. Push & Create PR

```bash
# Push to your fork
git push origin feature/my-improvement

# Create Pull Request on GitHub
```

### 5. PR Template

```markdown
## Description
[Clear description of changes]

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [x] Loaded in Fusion 360 without errors
- [x] Generated test program successfully
- [ ] Tested in simulator
- [ ] Dry run on machine

## Checklist
- [x] Code follows style guidelines
- [x] Comments added for complex logic
- [x] Documentation updated
- [x] CHANGELOG.md updated
- [x] No breaking changes to existing functionality

## Related Issues
Closes #123
```

---

## 🚫 What NOT to Change

### Machine-Specific Settings

**DO NOT modify** these without approval:
- Machine serial number (195369)
- Spindle speed limits (5060/6000/12000)
- Axis travel limits
- Turret configuration
- Control type (Matrix)

### Critical Format Definitions

**DO NOT change** without testing:
- `xFormat` (diameter mode scale:2)
- Modal output variables
- M-code definitions

### File Structure

**DO NOT reorganize** without discussion:
- Keep all definitions in single .cps file
- Maintain section order
- Preserve header comments

---

## 📚 Resources

### Required Reading

1. [Mazak Programming Manual](docs/Programming_Manual_2.pdf)
2. [DEVELOPMENT_STATUS.md](DEVELOPMENT_STATUS.md)
3. [TECHNICAL_NOTES.md](TECHNICAL_NOTES.md)
4. [Autodesk Post Processor Reference](https://cam.autodesk.com/posts/)

### Helpful Links

- [Fusion 360 CAM Documentation](https://help.autodesk.com/view/fusion360/ENU/)
- [G-Code Reference](https://www.mazak.com)
- [Mill-Turn Programming Guide](https://www.mazak.com)

---

## ⚖️ License

By contributing, you agree that your contributions will be licensed under the same license as the project (Proprietary - Grace Engineering Corp).

---

## 🆘 Getting Help

- **Questions:** Open an issue with label `question`
- **Discussion:** Use GitHub Discussions
- **Urgent:** Contact Grace Engineering directly

---

## 🎯 Development Priorities

See [DEVELOPMENT_STATUS.md](DEVELOPMENT_STATUS.md) for current priorities:

**High Priority:**
1. Phase 4: Drilling cycles
2. Phase 4: Threading
3. Phase 4: B-axis output
4. Phase 5: Balanced cutting

**Medium Priority:**
1. Phase 6: Tool management
2. Phase 7: Advanced WCS

**Nice to Have:**
- Code optimization
- Additional error checking
- Enhanced documentation

---

## ✅ Code Review Criteria

Pull requests will be reviewed for:

1. **Functionality**
   - Works as intended
   - No regressions
   - Handles edge cases

2. **Code Quality**
   - Follows style guide
   - Well commented
   - Maintainable

3. **Testing**
   - Test cases included
   - Simulator validated
   - Documentation updated

4. **Compatibility**
   - Fusion 360 compatible
   - Machine compatible
   - No breaking changes

---

## 🙏 Thank You!

Your contributions help improve this post processor for the manufacturing community. Every bug fix, feature, and documentation improvement is valued!

---

**Questions?** Open an issue or contact Grace Engineering.

**Last Updated:** January 6, 2026
