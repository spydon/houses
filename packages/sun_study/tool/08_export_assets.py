import base64
import json

import numpy as np
from PIL import Image

from address import LAT, LON, site

surface = np.load('surface_without_buildings.npy')
ground = np.load('ground_final.npy')
meta = json.load(open('dsm_meta.json'))
E_MIN, N_MAX, W, H = meta['e_min'], meta['n_max'], meta['w'], meta['h']
surface_dm = np.round(surface * 10).astype('<i2')
GE0, GN0, GW, GH = site['ground']
EAST_MIN, NORTH_MIN, EAST_MAX, NORTH_MAX = site['photo']
METERS_PER_PIXEL = 0.08
ground_crop = ground[N_MAX - GN0:N_MAX - GN0 + GH, GE0 - E_MIN:GE0 - E_MIN + GW]
ground_dm = np.round(ground_crop * 10).astype('<i2')
out = {
    'latitude': LAT,
    'longitude': LON,
    'gridBearingOfTrueNorth': round(meta['convergence'], 4),
    'surface': {'originEast': E_MIN, 'originNorth': N_MAX, 'width': W, 'height': H, 'cellSize': 1.0,
                'decimeters': base64.b64encode(surface_dm.tobytes()).decode()},
    'ground': {'originEast': GE0, 'originNorth': GN0, 'width': GW, 'height': GH, 'cellSize': 1.0,
               'decimeters': base64.b64encode(ground_dm.tobytes()).decode()},
    'image': {'width': round((EAST_MAX - EAST_MIN) / METERS_PER_PIXEL), 'height': round((NORTH_MAX - NORTH_MIN) / METERS_PER_PIXEL),
              'a': METERS_PER_PIXEL, 'b': 0.0, 'eastOffset': float(EAST_MIN), 'northOffset': float(NORTH_MAX)},
    'buildings': [
        {'name': b['name'], 'roof': round(b['roof'], 2), 'points': [[round(e, 2), round(n, 2)] for e, n in b['poly']]}
        for b in meta['buildings']
    ],
    'spots': json.load(open('spots.json')),
    **site.get('extra', {}),
}
json.dump(out, open('../assets/surface_model.json', 'w'), separators=(',', ':'))
cover = site['cover']
if 'file' in cover:
    Image.open(cover['file']).convert('RGB').save('../assets/cover.jpg', quality=86)
else:
    photo = Image.open('../assets/backyard.jpg')
    photo.crop(cover['crop']).resize((1440, 958), Image.LANCZOS).save('../assets/cover.jpg', quality=86)
