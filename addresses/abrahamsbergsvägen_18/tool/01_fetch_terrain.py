import math, os, requests, numpy as np
os.makedirs('tiles', exist_ok=True)
from PIL import Image
from pyproj import Transformer
z = 16; n = 2 ** z
lat, lon = 59.23597, 18.04096
tx = int((lon + 180) / 360 * n); ty = int((1 - math.asinh(math.tan(math.radians(lat))) / math.pi) / 2 * n)
s = requests.Session(); s.headers['User-Agent'] = 'sun-analysis-script/1.0'
R = 2; T = 512
mosaic = np.zeros(((2 * R + 1) * T, (2 * R + 1) * T))
for dx in range(-R, R + 1):
    for dy in range(-R, R + 1):
        fn = f'tiles/mh_{z}_{tx+dx}_{ty+dy}.webp'
        if not os.path.exists(fn):
            r = s.get(f'https://tiles.mapterhorn.com/{z}/{tx+dx}/{ty+dy}.webp', timeout=30); r.raise_for_status(); open(fn, 'wb').write(r.content)
        im = np.asarray(Image.open(fn).convert('RGB')).astype(np.float64)
        mosaic[(dy + R) * T:(dy + R + 1) * T, (dx + R) * T:(dx + R + 1) * T] = im[..., 0] * 256 + im[..., 1] + im[..., 2] / 256 - 32768
E0, N0 = 673474, 6570285; H = 600
es = np.arange(E0 - H, E0 + H + 1); ns = np.arange(N0 + H, N0 - H - 1, -1)
EE, NN = np.meshgrid(es, ns)
lo, la = Transformer.from_crs(3006, 4326, always_xy=True).transform(EE.ravel(), NN.ravel())
lo = np.array(lo); la = np.array(la)
gx = ((lo + 180) / 360 * n - (tx - R)) * T - 0.5
gy = ((1 - np.arcsinh(np.tan(np.radians(la))) / np.pi) / 2 * n - (ty - R)) * T - 0.5
x0 = np.floor(gx).astype(int); y0 = np.floor(gy).astype(int); fx = gx - x0; fy = gy - y0
ok = (x0 >= 0) & (y0 >= 0) & (x0 < mosaic.shape[1] - 1) & (y0 < mosaic.shape[0] - 1)
print('coverage', ok.mean())
x0c = np.clip(x0, 0, mosaic.shape[1] - 2); y0c = np.clip(y0, 0, mosaic.shape[0] - 2)
v = (mosaic[y0c, x0c] * (1 - fx) * (1 - fy) + mosaic[y0c, x0c + 1] * fx * (1 - fy) + mosaic[y0c + 1, x0c] * (1 - fx) * fy + mosaic[y0c + 1, x0c + 1] * fx * fy)
v[~ok] = np.nan
dtm = v.reshape(EE.shape).astype(np.float32)
np.save('dtm_sweref.npy', dtm)
print('grid', dtm.shape, 'origin E', E0 - H, 'N', N0 + H, 'center', dtm[H, H])
