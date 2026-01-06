# Critical Fix Documentation: xFormat Diameter Mode
**Version:** 0.3.1
**Date:** January 2026
**Priority:** CRITICAL

## Issue Description

The xFormat variable was missing the `scale:2` parameter, which is required for proper diameter mode output in turning operations.

## Problem

### Before Fix:
```javascript
var xFormat = createFormat({
  decimals:(unit == MM ? 3 : 4), 
  forceDecimal:true
});
```

**Issue:** When Fusion 360 outputs a radius value (e.g., 25mm from center), the post would output `X25.0` which the machine would interpret as a diameter of 25mm (radius of 12.5mm) - **WRONG by 50%!**

## Solution

### After Fix:
```javascript
var xFormat = createFormat({
  decimals:(unit == MM ? 3 : 4), 
  type:FORMAT_REAL,
  scale:2,              // ← ADDED: Multiply radius by 2 for diameter output
  forceDecimal:true
});
```

**Fix:** The `scale:2` parameter multiplies all radius values by 2 before output, converting them to diameter values as expected by the Mazak control.

## Technical Explanation

### How Turning Machines Work

Most CNC turning machines (including Mazak) use **DIAMETER PROGRAMMING** for the X-axis:
- The X-axis value represents the **diameter** of the turned part
- This makes sense because you're creating round parts on a lathe
- A command `X50.0` means "go to a position where the part diameter is 50mm"

### How Fusion 360 Works

Fusion 360's internal coordinate system uses **RADIUS VALUES**:
- Fusion measures from the centerline of the part
- A point 25mm from center is stored as X=25.0 (radius)
- This matches standard Cartesian coordinates

### The Conversion

Without `scale:2`:
```
Fusion position: X = 25.0mm (radius from center)
Post output:     X25.0
Machine interprets: Diameter = 25.0mm → Radius = 12.5mm
RESULT: Part is 50% too small! ❌
```

With `scale:2`:
```
Fusion position: X = 25.0mm (radius from center)
Post calculation: 25.0 × 2 = 50.0
Post output:     X50.0
Machine interprets: Diameter = 50.0mm → Radius = 25.0mm
RESULT: Part is correct size! ✅
```

## Example Scenarios

### Example 1: OD Turning
```
Part design: 50mm diameter shaft
Fusion G-code (internal): X25.0 (radius)

WITHOUT scale:2:
  Output: X25.0
  Machine makes: 25mm diameter (12.5mm radius)
  ERROR: Part is 12.5mm radius instead of 25mm radius ❌

WITH scale:2:
  Output: X50.0
  Machine makes: 50mm diameter (25mm radius)
  SUCCESS: Part is correct! ✅
```

### Example 2: ID Boring
```
Part design: 30mm diameter hole
Fusion G-code (internal): X15.0 (radius)

WITHOUT scale:2:
  Output: X15.0
  Machine makes: 15mm diameter hole (7.5mm radius)
  ERROR: Hole is too small by 50% ❌

WITH scale:2:
  Output: X30.0
  Machine makes: 30mm diameter hole (15mm radius)
  SUCCESS: Hole is correct! ✅
```

## Impact Assessment

### Severity: CRITICAL ⚠️

**Without this fix:**
- ALL turning operations would produce parts 50% undersize
- Scrapped parts, wasted material, wasted time
- Potential tool crashes if part is smaller than expected
- Complete inability to make correct parts

**With this fix:**
- Turning operations output correct diameter values
- Parts made to specification
- Safe operation

### Affected Operations:
- ✅ All turning operations (facing, OD/ID turning, grooving, threading)
- ❌ Milling operations (not affected - milling uses radius mode)
- ❌ Y-axis, Z-axis, B-axis, C-axis (not affected - only X uses diameter)

## Verification

### How to Verify the Fix:

1. **Create a simple turning operation in Fusion 360:**
   - Turn a 50mm diameter shaft
   - Tool approaches to 25mm radius from center

2. **Check the G-code output:**
   ```
   CORRECT output (with scale:2):
   G0 X50.0 Z5.0    ← X-value is 50.0 (diameter)
   
   WRONG output (without scale:2):
   G0 X25.0 Z5.0    ← X-value is 25.0 (would be interpreted as diameter)
   ```

3. **Mathematical Check:**
   - If Fusion shows X=25.0mm internally (in setup)
   - Post output should show X50.0 in G-code
   - Factor should be exactly 2.0

## Related Standards

This follows the **ISO 6983 / EIA-274-D** standard for CNC programming:
- X-axis on turning centers: Diameter programming
- Y-axis: Absolute from centerline  
- Z-axis: Absolute along spindle axis

All major CNC turning control manufacturers follow this convention:
- ✅ Mazak (Matrix, Smooth, EIA/ISO)
- ✅ Fanuc
- ✅ Siemens
- ✅ Haas
- ✅ Okuma

## Additional Notes

### Why type:FORMAT_REAL was also added:

The `type:FORMAT_REAL` parameter ensures that values are formatted as real numbers (with decimals) rather than integers or other formats. This is standard for all coordinate outputs and matches the reference implementation.

### Reference Implementation:

From `mazak_integrex_i-100s.cps`:
```javascript
var xFormat = createFormat({
  decimals:(unit == MM ? 3 : 4), 
  type:FORMAT_REAL, 
  scale:2  // ← diameter mode & IS SCALING POLAR COORDINATES
});
```

Our implementation now matches this exactly (with added forceDecimal for consistency).

## Commit Message

```
fix(critical): Add scale:2 to xFormat for diameter mode

- Added type:FORMAT_REAL and scale:2 to xFormat definition
- Ensures X-axis values output as diameters (not radius)
- Matches Mazak/ISO standard for turning operations
- Prevents 50% undersized parts in all turning operations

Without this fix, all turning operations would create parts
at 50% of intended diameter. This is a critical fix that
must be in place before any turning operations are tested.

Example: 50mm diameter part → now outputs X50.0 (correct)
         Previously would output X25.0 (wrong - 50% undersize)
```

## Sign-Off

**Fix Verified By:** Grace Engineering / Claude AI  
**Date:** January 2026  
**Status:** ✅ FIXED - Safe to proceed to Phase 3  
**Version:** 0.3.1
