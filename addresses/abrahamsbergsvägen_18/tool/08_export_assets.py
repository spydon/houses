import base64
import json

import numpy as np
from PIL import Image

surface = np.load('surface_without_buildings.npy')
ground = np.load('ground_final.npy')
meta = json.load(open('dsm_meta.json'))
E_MIN, N_MAX, W, H = meta['e_min'], meta['n_max'], meta['w'], meta['h']
surface_dm = np.round(surface * 10).astype('<i2')
GE0, GN0, GW, GH = 673425, 6570325, 100, 85
ground_crop = ground[N_MAX - GN0:N_MAX - GN0 + GH, GE0 - E_MIN:GE0 - E_MIN + GW]
ground_dm = np.round(ground_crop * 10).astype('<i2')
out = {
    'latitude': 59.23597,
    'longitude': 18.04096,
    'gridBearingOfTrueNorth': round(meta['convergence'], 4),
    'surface': {'originEast': E_MIN, 'originNorth': N_MAX, 'width': W, 'height': H, 'cellSize': 1.0,
                'decimeters': base64.b64encode(surface_dm.tobytes()).decode()},
    'ground': {'originEast': GE0, 'originNorth': GN0, 'width': GW, 'height': GH, 'cellSize': 1.0,
               'decimeters': base64.b64encode(ground_dm.tobytes()).decode()},
    'image': {'width': 1125, 'height': 938, 'a': 0.08, 'b': 0.0, 'eastOffset': 673430.0, 'northOffset': 6570320.0},
    'buildings': [
        {'name': b['name'], 'roof': round(b['roof'], 2), 'points': [[round(e, 2), round(n, 2)] for e, n in b['poly']]}
        for b in meta['buildings']
    ],
    'spots': [
        {'name': 'Pool', 'east': 673472.5, 'north': 6570285.0},
        {'name': 'Terrace by the house', 'east': 673479.0, 'north': 6570288.5},
        {'name': 'West deck', 'east': 673468.0, 'north': 6570294.0},
    ],
}
json.dump(out, open('../assets/surface_model.json', 'w'), separators=(',', ':'))
Image.open('input/cover.png').convert('RGB').save('../assets/cover.jpg', quality=86)
