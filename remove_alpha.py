#!/usr/bin/env python3
import sys
try:
    from PIL import Image
except ImportError:
    print("PIL not available, trying alternative method...")
    import subprocess
    # Use sips to flatten
    subprocess.run([
        'sips', '-s', 'format', 'jpeg',
        'assets/icon/icon_original.png',
        '--out', 'assets/icon/icon_temp.jpg'
    ])
    subprocess.run([
        'sips', '-s', 'format', 'png',
        'assets/icon/icon_temp.jpg',
        '--out', 'assets/icon/icon.png'
    ])
    subprocess.run(['rm', 'assets/icon/icon_temp.jpg'])
    sys.exit(0)

# Open the original icon with alpha
img = Image.open('assets/icon/icon_original.png')

# Create a white background
background = Image.new('RGB', img.size, (255, 255, 255))

# Paste the image on white background
if img.mode in ('RGBA', 'LA'):
    background.paste(img, mask=img.split()[-1])  # Use alpha as mask
else:
    background.paste(img)

# Save without alpha
background.save('assets/icon/icon.png', 'PNG')
print("✓ Removed alpha channel from icon.png")
