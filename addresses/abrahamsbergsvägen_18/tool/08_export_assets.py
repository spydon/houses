import base64
import json

import numpy as np
from PIL import Image

surface = np.load('surface_final.npy')
ground = np.load('ground_final.npy')
meta = json.load(open('dsm_meta.json'))
E_MIN, N_MAX, W, H = meta['e_min'], meta['n_max'], meta['w'], meta['h']
surface_dm = np.round(surface * 10).astype('<i2')
GE0, GN0, GW, GH = 673440, 6570330, 85, 75
ground_crop = ground[N_MAX - GN0:N_MAX - GN0 + GH, GE0 - E_MIN:GE0 - E_MIN + GW]
ground_dm = np.round(ground_crop * 10).astype('<i2')
geo = json.load(open('img4_sim.json'))
out = {
    'latitude': 59.23597,
    'longitude': 18.04096,
    'gridBearingOfTrueNorth': round(meta['convergence'], 4),
    'surface': {'originEast': E_MIN, 'originNorth': N_MAX, 'width': W, 'height': H, 'cellSize': 1.0,
                'decimeters': base64.b64encode(surface_dm.tobytes()).decode()},
    'ground': {'originEast': GE0, 'originNorth': GN0, 'width': GW, 'height': GH, 'cellSize': 1.0,
               'decimeters': base64.b64encode(ground_dm.tobytes()).decode()},
    'image': {'width': 567, 'height': 497, 'a': geo['a'], 'b': geo['b'], 'eastOffset': geo['tx'], 'northOffset': geo['ty']},
    'spots': [
        {'name': 'Pool', 'east': 673472.5, 'north': 6570285.0},
        {'name': 'Terrace by the house', 'east': 673479.0, 'north': 6570288.5},
        {'name': 'West deck', 'east': 673468.0, 'north': 6570294.0},
    ],
}
json.dump(out, open('../assets/surface_model.json', 'w'), separators=(',', ':'))
Image.open('input/backyard.png').convert('RGB').save('../assets/backyard.jpg', quality=92)
Image.open('input/cover.png').convert('RGB').save('../assets/cover.jpg', quality=86)
