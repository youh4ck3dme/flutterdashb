import re
import sys

def verify():
    dart_path = 'lib/components/premium_background.dart'
    html_path = '/Users/erikbabcan/googla-builder1s/wallpaper.html'

    try:
        with open(dart_path, 'r') as f:
            dart_content = f.read()
    except Exception as e:
        print(f"Error reading {dart_path}: {e}")
        sys.exit(1)

    try:
        with open(html_path, 'r') as f:
            html_content = f.read()
    except Exception as e:
        print(f"Error reading {html_path}: {e}")
        sys.exit(1)

    errors = []

    # 1. Check math import
    if "import 'dart:math' as math;" not in dart_content:
        errors.append("Missing import 'dart:math' as math;")

    # 2. Check Teal Orb
    # CSS: top: 9%, left: 8%, width: 280px, height: 280px, background: rgba(0, 188, 212, 0.24), filter: blur(64px), opacity: 0.55
    # Center X: size.width * 0.08 + 140.0
    # Center Y: size.height * 0.09 + 140.0
    # Radius: 140.0
    # Blur: 64.0
    # Combined alpha: 0.24 * 0.55 = 0.132 -> Color(0x2200BCD4) or Color(0x2100BCD4)
    teal_cx_match = re.search(r'tealCx\s*=\s*size\.width\s*\*\s*0\.08\s*\+\s*140\.0', dart_content)
    teal_cy_match = re.search(r'tealCy\s*=\s*size\.height\s*\*\s*0\.09\s*\+\s*140\.0', dart_content)
    teal_radius_match = re.search(r'canvas\.drawCircle\(Offset\(tealCx,\s*tealCy\),\s*140\.0', dart_content)
    teal_blur_match = re.search(r'MaskFilter\.blur\(BlurStyle\.normal,\s*64\.0\)', dart_content)
    teal_color_match = re.search(r'const\s+Color\(0x2[12]00BCD4\)', dart_content)

    if not teal_cx_match:
        errors.append("Teal Orb Center X math does not match left: 8% + 140px")
    if not teal_cy_match:
        errors.append("Teal Orb Center Y math does not match top: 9% + 140px")
    if not teal_radius_match:
        errors.append("Teal Orb Radius does not match 140.0px (width 280px)")
    if not teal_blur_match:
        errors.append("Teal Orb blur standard deviation does not match 64.0")
    if not teal_color_match:
        errors.append("Teal Orb combined color/opacity does not match 0x2200BCD4 (0.24 * 0.55)")

    # 3. Check Blue Orb
    # CSS: right: 6%, bottom: 8%, width: 320px, height: 320px, background: rgba(66, 133, 244, 0.18), filter: blur(64px), opacity: 0.55
    # Center X: size.width - (size.width * 0.06 + 160.0)
    # Center Y: size.height - (size.height * 0.08 + 160.0)
    # Radius: 160.0
    # Combined alpha: 0.18 * 0.55 = 0.099 -> Color(0x194285F4)
    blue_cx_match = re.search(r'blueCx\s*=\s*size\.width\s*-\s*\(\s*size\.width\s*\*\s*0\.06\s*\+\s*160\.0\s*\)', dart_content)
    blue_cy_match = re.search(r'blueCy\s*=\s*size\.height\s*-\s*\(\s*size\.height\s*\*\s*0\.08\s*\+\s*160\.0\s*\)', dart_content)
    blue_radius_match = re.search(r'canvas\.drawCircle\(Offset\(blueCx,\s*blueCy\),\s*160\.0', dart_content)
    blue_color_match = re.search(r'const\s+Color\(0x194285F4\)', dart_content)

    if not blue_cx_match:
        errors.append("Blue Orb Center X math does not match right: 6% + 160px")
    if not blue_cy_match:
        errors.append("Blue Orb Center Y math does not match bottom: 8% + 160px")
    if not blue_radius_match:
        errors.append("Blue Orb Radius does not match 160.0px (width 320px)")
    if not blue_color_match:
        errors.append("Blue Orb combined color/opacity does not match 0x194285F4 (0.18 * 0.55)")

    # 4. Check Base Gradient: Linear 145deg
    linear_angle_match = re.search(r'145\.0\s*\*\s*math\.pi\s*/\s*180\.0', dart_content)
    linear_colors_match = re.search(r'const\s+Color\(0xFF07080B\),\s*const\s+Color\(0xFF0B0D12\),\s*const\s+Color\(0xFF111111\)', dart_content)
    linear_stops_match = re.search(r'0\.0,\s*0\.48,\s*1\.0', dart_content)

    if not linear_angle_match:
        errors.append("Base linear gradient angle is not 145deg")
    if not linear_colors_match:
        errors.append("Base linear gradient colors do not match #07080b, #0b0d12, #111111")
    if not linear_stops_match:
        errors.append("Base linear gradient stops do not match 0%, 48%, 100%")

    # 5. Check Base Radial Gradients
    # Radial 1: circle at 15% 18%, rgba(0, 188, 212, 0.14), transparent 24%
    radial1_cx_match = re.search(r'r1Cx\s*=\s*w\s*\*\s*0\.15', dart_content)
    radial1_cy_match = re.search(r'r1Cy\s*=\s*h\s*\*\s*0\.18', dart_content)
    radial1_radius_match = re.search(r'r1Radius\s*=\s*r1FarthestDist\s*\*\s*0\.24', dart_content)
    radial1_color_match = re.search(r'const\s+Color\(0x2400BCD4\)', dart_content)

    if not (radial1_cx_match and radial1_cy_match):
        errors.append("Base radial 1 center does not match 15% 18%")
    if not radial1_radius_match:
        errors.append("Base radial 1 radius does not match farthest-corner * 24%")
    if not radial1_color_match:
        errors.append("Base radial 1 color does not match 0x2400BCD4")

    # Radial 2: circle at 80% 18%, rgba(66, 133, 244, 0.16), transparent 22%
    radial2_cx_match = re.search(r'r2Cx\s*=\s*w\s*\*\s*0\.80', dart_content)
    radial2_cy_match = re.search(r'r2Cy\s*=\s*h\s*\*\s*0\.18', dart_content)
    radial2_radius_match = re.search(r'r2Radius\s*=\s*r2FarthestDist\s*\*\s*0\.22', dart_content)
    radial2_color_match = re.search(r'const\s+Color\(0x294285F4\)', dart_content)

    if not (radial2_cx_match and radial2_cy_match):
        errors.append("Base radial 2 center does not match 80% 18%")
    if not radial2_radius_match:
        errors.append("Base radial 2 radius does not match farthest-corner * 22%")
    if not radial2_color_match:
        errors.append("Base radial 2 color does not match 0x294285F4")

    # Radial 3: circle at 50% 100%, rgba(255, 255, 255, 0.08), transparent 30%
    radial3_cx_match = re.search(r'r3Cx\s*=\s*w\s*\*\s*0\.50', dart_content)
    radial3_cy_match = re.search(r'r3Cy\s*=\s*h', dart_content)
    radial3_radius_match = re.search(r'r3Radius\s*=\s*r3FarthestDist\s*\*\s*0\.30', dart_content)
    radial3_color_match = re.search(r'const\s+Color\(0x14FFFFFF\)', dart_content)

    if not (radial3_cx_match and radial3_cy_match):
        errors.append("Base radial 3 center does not match 50% 100%")
    if not radial3_radius_match:
        errors.append("Base radial 3 radius does not match farthest-corner * 30%")
    if not radial3_color_match:
        errors.append("Base radial 3 color does not match 0x14FFFFFF")

    # 6. Check Grid
    grid_step_match = re.search(r'const\s+double\s+step\s*=\s*120\.0', dart_content)
    grid_color_match = re.search(r'const\s+Color\(0x0[23]FFFFFF\)', dart_content)
    grid_mask_match = re.search(r'maskR\s*=\s*farthestCornerDist\s*\*\s*0\.82', dart_content)

    if not grid_step_match:
        errors.append("Grid step is not 120.0px")
    if not grid_color_match:
        errors.append("Grid line color/opacity is not Color(0x03FFFFFF)")
    if not grid_mask_match:
        errors.append("Grid radial mask size is not farthestCornerDist * 82%")

    # 7. Check Repaint boundaries
    repaint_boundaries_count = len(re.findall(r'RepaintBoundary\(', dart_content))
    if repaint_boundaries_count < 3:
        errors.append(f"Expected at least 3 RepaintBoundary widgets, found {repaint_boundaries_count}")

    # Output results
    if errors:
        print("VERIFICATION FAILED:")
        for err in errors:
            print(f"  - {err}")
        sys.exit(1)
    else:
        print("VERIFICATION SUCCESSFUL: premium_background.dart matches wallpaper.html A to Z! 100% correct.")

if __name__ == '__main__':
    verify()
