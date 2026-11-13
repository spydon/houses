import numpy as np, json, math
from pyproj import Transformer
from matplotlib.path import Path

dtm = np.load('dtm_sweref.npy')
DTM_E0, DTM_N0 = 681766, 6570370
chm = np.load('chm_raw.npy').astype(np.float32) / 10
CHM_E0, CHM_N0 = 681766, 6570170

R = 400
E_MIN, N_MAX = 682366 - R, 6569770 + R
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

buildings_in = json.load(open('buildings.json'))
pts = np.column_stack([EE.ravel(), NN.ravel()])

def grown(poly, margin=0.7):
    p = np.array(poly, float); c = p.mean(axis=0); v = p - c
    return [tuple(map(float, q)) for q in c + v * (1 + margin / np.linalg.norm(v, axis=1, keepdims=True))]

cleared = [grown(b['poly']) for b in buildings_in]
mask = np.zeros(EE.shape, bool)
for area in cleared:
    mask |= Path(area).contains_points(pts).reshape(EE.shape)
trees = np.where(mask, 0, trees)
GROWTH = 1.5
trees = np.where(trees > 5, trees + GROWTH, trees)

# A gabled roof with its ridge parallel to the first edge, as nested blocks that step up towards the ridge.
def gable(points, eave, ridge, steps=4):
    a, b, c, d = (np.array(p, float) for p in points)
    start, end = (a + d) / 2, (b + c) / 2
    blocks = []
    for k in range(1, steps + 1):
        f = 0.5 * (1 - (k - 1) / steps)
        poly = [start + (a - d) * f, end + (b - c) * f, end - (b - c) * f, start - (a - d) * f]
        blocks.append(([tuple(map(float, p)) for p in poly], eave + (ridge - eave) * (k - 0.5) / steps))
    return blocks

buildings = []
objects = np.zeros_like(ground)
for b in buildings_in:
    m = Path(b['poly']).contains_points(pts).reshape(EE.shape)
    base = float(np.median(ground[m]))
    parts = gable(b['poly'], b['eave'], b['ridge']) if 'ridge' in b else [(b['poly'], b['height'])]
    for poly, height in parts:
        pm = Path(poly).contains_points(pts).reshape(EE.shape)
        buildings.append({'name': b['name'], 'roof': base + height, 'poly': poly})
        objects = np.where(pm, np.maximum(objects, base + height - ground), objects)
surface = ground + np.maximum(trees, objects)
np.save('surface_without_buildings.npy', ground + trees)

tr = Transformer.from_crs(4326, 3006, always_xy=True)
lat, lon = 59.22762, 18.19612
a = tr.transform(lon, lat); b = tr.transform(lon, lat + 0.001)
convergence = math.degrees(math.atan2(b[0] - a[0], b[1] - a[1]))
print('grid bearing of true north', convergence)

np.save('ground_final.npy', ground); np.save('surface_final.npy', surface)
json.dump({'e_min': E_MIN, 'n_max': N_MAX, 'w': W, 'h': H, 'convergence': convergence,
           'buildings': buildings, 'cleared': cleared, 'growth': GROWTH}, open('dsm_meta.json', 'w'))
print('surface range', float(surface.min()), float(surface.max()), 'ground at pool', float(ground[R, R]))
