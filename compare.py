import sys
from PIL import Image, ImageChops

def main():
    img1_path = '/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/wallpaper_reference.png'
    img2_path = '/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/flutter_current.png'
    diff_path = '/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/diff.png'

    try:
        img1 = Image.open(img1_path).convert('RGB')
        img2 = Image.open(img2_path).convert('RGB')
    except Exception as e:
        print(f"Error opening images: {e}")
        return

    if img1.size != img2.size:
        print(f"Sizes differ: {img1.size} vs {img2.size}. Resizing second to match first.")
        img2 = img2.resize(img1.size)

    diff = ImageChops.difference(img1, img2)
    diff.save(diff_path)
    
    # Calculate difference percentage
    stat = diff.histogram()
    diff_pixels = sum(stat[1:])  # number of pixels with non-zero diff
    total_pixels = img1.size[0] * img1.size[1]
    pct = (diff_pixels / total_pixels) * 100
    print(f"Different pixels: {pct:.2f}%")
    
    # Also calculate mean error
    pixels1 = list(img1.getdata())
    pixels2 = list(img2.getdata())
    total_diff = 0
    for p1, p2 in zip(pixels1, pixels2):
        total_diff += abs(p1[0]-p2[0]) + abs(p1[1]-p2[1]) + abs(p1[2]-p2[2])
    mean_diff = total_diff / (total_pixels * 3)
    print(f"Mean RGB difference: {mean_diff:.2f}")

if __name__ == '__main__':
    main()
