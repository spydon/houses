import numpy as np, json, math, base64
from pyproj import Transformer
from matplotlib.path import Path

dtm = np.load('dtm_sweref.npy')
DTM_E0, DTM_N0 = 672874, 6570885
chm = np.load('chm_raw.npy').astype(np.float32) / 10
CHM_E0, CHM_N0 = 672874, 6570685

R = 400
E_MIN, N_MAX = 673474 - R, 6570285 + R
W = H = 2 * R
ce = E_MIN + 0.5 + np.arange(W)
cn = N_MAX - 0.5 - np.arange(H)
EE, NN = np.meshgrid(ce, cn)

def dtm_at(e, n):
    c = e - DTM_E0; r = DTM_N0 - n
    c0 = np.floor(c).astype(int); r0 = np.floor(r).astype(int); fx = c - c0; fy = r - r0
    return dtm[r0, c0] * (1 - fx) * (1 - fy) + dtm[r0, c0 + 1] * fx * (1 - fy) + dtm[r0 + 1, c0] * (1 - fx) * fy + dtm[r0 + 1, c0 + 1] * fx * fy

ground = dtm_at(EE, NN).astype(np.float32)
cc = (EE - 0.5 - CHM_E0).astype(int); cr = (CHM_N0 - (NN + 0.5)).astype(int)
trees = chm[cr, cc]

cleared = [(673458, 6570300), (673478, 6570312), (673488, 6570320), (673500, 6570310), (673521, 6570280),
           (673512, 6570270), (673497, 6570266), (673482, 6570267), (673477.2, 6570270.5), (673468.3, 6570276.6),
           (673463.9, 6570284.9), (673460, 6570292.7)]
pts = np.column_stack([EE.ravel(), NN.ravel()])
mask = Path(cleared).contains_points(pts).reshape(EE.shape)
trees = np.where(mask, 0, trees)
GROWTH = 1.5
trees = np.where(trees > 5, trees + GROWTH, trees)

def rect(cx, cy, length, width, bearing):
    a = math.radians(bearing); u = (math.sin(a), math.cos(a)); v = (math.cos(a), -math.sin(a))
    return [(cx + sx * length / 2 * u[0] + sy * width / 2 * v[0], cy + sx * length / 2 * u[1] + sy * width / 2 * v[1]) for sx, sy in ((1, 1), (1, -1), (-1, -1), (-1, 1))]

buildings = [
    {'name': 'House', 'height': 7.5, 'poly': [(673476.9, 6570295.4), (673486.1, 6570300.9), (673494.7, 6570290.4), (673485.4, 6570283.9)]},
    {'name': 'Neighbor to the southeast', 'height': 7.5, 'poly': rect(673503, 6570278.5, 15, 12, 140)},
    {'name': 'Neighbor to the northwest', 'height': 6.5, 'poly': rect(673460, 6570306.5, 13, 10, 140)},
    {'name': 'Roofed patio south of the pool', 'height': 2.8, 'poly': [(673477.0, 6570284.5), (673484.5, 6570283.5), (673484.0, 6570275.5), (673478.0, 6570275.0)]},
]
objects = np.zeros_like(ground)
for b in buildings:
    m = Path(b['poly']).contains_points(pts).reshape(EE.shape)
    base = ground[m].min() if m.any() else 0
    b['roof'] = float(base + b['height'])
    objects = np.where(m, np.maximum(objects, base + b['height'] - ground), objects)
surface = ground + np.maximum(trees, objects)
np.save('surface_without_buildings.npy', ground + trees)

tr = Transformer.from_crs(4326, 3006, always_xy=True)
lat, lon = 59.23597, 18.04096
a = tr.transform(lon, lat); b = tr.transform(lon, lat + 0.001)
convergence = math.degrees(math.atan2(b[0] - a[0], b[1] - a[1]))
print('grid bearing of true north', convergence)

np.save('ground_final.npy', ground); np.save('surface_final.npy', surface)
json.dump({'e_min': E_MIN, 'n_max': N_MAX, 'w': W, 'h': H, 'convergence': convergence,
           'buildings': buildings, 'cleared': cleared, 'growth': GROWTH}, open('dsm_meta.json', 'w'))
print('surface range', float(surface.min()), float(surface.max()), 'ground at pool', float(ground[R, R]))
