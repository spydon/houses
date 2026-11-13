import io

import numpy as np
import requests
from PIL import Image, ImageEnhance

EAST_MIN, EAST_MAX, NORTH_MIN, NORTH_MAX = 682325, 682415, 6569738, 6569813
METERS_PER_PIXEL = 0.08
width = round((EAST_MAX - EAST_MIN) / METERS_PER_PIXEL)
height = round((NORTH_MAX - NORTH_MIN) / METERS_PER_PIXEL)
response = requests.get(
    'https://minkarta.lantmateriet.se/map/ortofoto/',
    params={
        'service': 'WMS', 'version': '1.1.1', 'request': 'GetMap', 'layers': 'Ortofoto_0.16',
        'styles': '', 'srs': 'EPSG:3006', 'bbox': f'{EAST_MIN},{NORTH_MIN},{EAST_MAX},{NORTH_MAX}',
        'width': width, 'height': height, 'format': 'image/jpeg',
    },
    headers={'User-Agent': 'houses-sun-study/1.0'},
    timeout=90,
)
response.raise_for_status()
raw = np.asarray(Image.open(io.BytesIO(response.content)).convert('RGB')).astype(np.float32) / 255
black, white, gamma = 0.08, 0.80, 0.62
light = np.clip((raw - black) / (white - black), 0, 1) ** gamma
image = Image.fromarray((light * 255).round().astype(np.uint8))
image = ImageEnhance.Contrast(image).enhance(1.08)
image = ImageEnhance.Color(image).enhance(1.12)
image = ImageEnhance.Sharpness(image).enhance(1.15)
image.save('../assets/backyard.jpg', quality=88)
print(width, height)
