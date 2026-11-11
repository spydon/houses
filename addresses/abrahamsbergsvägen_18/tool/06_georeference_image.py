import numpy as np, json, cv2
def lm(X, Y): return (673450 + X / 16, 6570319 - Y / 16)
pairs = [
    ('shed', lm(315, 150), (178.5, 47.5)),
    ('nw small roof', lm(215, 310), (110, 150)),
    ('pool enclosure', lm(365, 555), (180, 312.5)),
    ('house roof', lm(550, 445), (320, 235)),
    ('se neighbor', lm(830, 660), (495, 395)),
    ('garage', lm(760, 420), (462, 250)),
]
P = np.array([p[2] for p in pairs], float); G = np.array([p[1] for p in pairs], float)
A = []; b = []
for (x, y), (e, n) in zip(P, G):
    A.append([x, y, 1, 0]); b.append(e)
    A.append([-y, x, 0, 1]); b.append(n)
sol, *_ = np.linalg.lstsq(np.array(A), np.array(b), rcond=None)
a, bb, tx, ty = sol
def f(x, y): return (a * x + bb * y + tx, bb * x - a * y + ty)
for name, g, p in pairs:
    e, n = f(*p); print(f'{name:16s} residual {e-g[0]:6.2f} {n-g[1]:6.2f}')
scale = np.hypot(a, bb); rot = np.degrees(np.arctan2(bb, a))
print('meters per px', scale, 'px per m', 1 / scale, 'rotation', rot)
json.dump({'a': a, 'b': bb, 'tx': tx, 'ty': ty}, open('img4_sim.json', 'w'))
img = cv2.imread('input/backyard.png'); h, w = img.shape[:2]
lmimg = cv2.imread('lm_ortho_hi.jpg')
out = np.zeros_like(img)
xs, ys = np.meshgrid(np.arange(w), np.arange(h))
E = a * xs + bb * ys + tx; N = bb * xs - a * ys + ty
mx = ((E - 673430) * 10).astype(np.float32); my = ((6570340 - N) * 10).astype(np.float32)
warped = cv2.remap(lmimg, mx, my, cv2.INTER_LINEAR)
edges = cv2.Canny(cv2.cvtColor(warped, cv2.COLOR_BGR2GRAY), 60, 150)
blend = cv2.addWeighted(img[..., :3], 0.6, warped, 0.4, 0)
blend[edges > 0] = (0, 255, 255)
cv2.imwrite('georeference_check.jpg', cv2.resize(blend, (w * 2, h * 2)))
