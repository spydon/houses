import numpy as np, math, json
from datetime import date
from sun import day_series
surface = np.load('surface_without_buildings.npy'); ground = np.load('ground_final.npy')
meta = json.load(open('dsm_meta.json'))
E_MIN, N_MAX, W, H, CONV = meta['e_min'], meta['n_max'], meta['w'], meta['h'], meta['convergence']
LAT, LON = 59.23597, 18.04096
def cell(e, n): return int(math.floor(N_MAX - n)), int(math.floor(e - E_MIN))
def steps():
    d = 0.75
    while d < 400:
        yield d
        d += 0.5 if d < 30 else (1.0 if d < 100 else 2.0)
STEPS = list(steps())
BUILDINGS = [(b['roof'], b['poly']) for b in meta['buildings']]
def inside(poly, x, y):
    result = False
    for i in range(len(poly)):
        (xi, yi), (xj, yj) = poly[i], poly[i - 1]
        if (yi > y) != (yj > y) and x < (xj - xi) * (y - yi) / (yj - yi) + xi:
            result = not result
    return result
def entry(poly, x, y, dx, dy):
    best = math.inf
    for i in range(len(poly)):
        (ax, ay), (bx, by) = poly[i], poly[(i + 1) % len(poly)]
        ex, ey = bx - ax, by - ay
        den = dx * ey - dy * ex
        if abs(den) < 1e-12: continue
        wx, wy = ax - x, ay - y
        t = (wx * ey - wy * ex) / den; u = (wx * dy - wy * dx) / den
        if t > 0 and 0 <= u <= 1: best = min(best, t)
    return best
def horizon(e, n, obs=1.0, bins=720):
    r, c = cell(e, n)
    base = max(ground[r, c] + obs, surface[r, c] + 0.1)
    for roof, poly in BUILDINGS:
        if inside(poly, e, n): base = max(base, roof + 0.1)
    out = np.zeros(bins)
    for i in range(bins):
        g = math.radians(i * 360 / bins + CONV); sx, sy = math.sin(g), math.cos(g)
        best = -90.0
        for d in STEPS:
            rr, cc = cell(e + d * sx, n + d * sy)
            if rr < 0 or cc < 0 or rr >= H or cc >= W: break
            dz = surface[rr, cc] - base
            if dz > 0:
                a = math.degrees(math.atan2(dz, d))
                if a > best: best = a
        for roof, poly in BUILDINGS:
            if roof <= base: continue
            t = entry(poly, e, n, sx, sy)
            if math.isfinite(t): best = max(best, math.degrees(math.atan2(roof - base, t)))
        out[i] = best
    return out, base
def windows(hz, day, step=1):
    s = day_series(day, LAT, LON, step)
    res = []; cur = None; total = 0
    for dt, el, az in s:
        i = az / 360 * len(hz); i0 = int(i) % len(hz); i1 = (i0 + 1) % len(hz); f = i - int(i)
        h = hz[i0] * (1 - f) + hz[i1] * f
        lit = el > 0 and el > h
        if lit:
            total += step
            if cur is None: cur = [dt, dt]
            else: cur[1] = dt
        elif cur is not None:
            res.append(cur); cur = None
    if cur: res.append(cur)
    res = [w for w in res if (w[1] - w[0]).seconds >= 10 * 60]
    return res, total
if __name__ == '__main__':
    spots = {'Pool': (673472.5, 6570285.0), 'Terrace by the house': (673479.0, 6570288.5), 'West deck': (673468.0, 6570294.0)}
    months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
    allres = {}
    for name, (e, n) in spots.items():
        hz, base = horizon(e, n)
        np.save(f'hz_{name.split()[0].lower()}.npy', hz)
        print(f'== {name} (observer {base:.1f} m)  horizon S={hz[360]:.0f} SW={hz[450]:.0f} W={hz[540]:.0f} SE={hz[270]:.0f} E={hz[180]:.0f}')
        for m in range(1, 13):
            d = date(2026, m, 15)
            res, total = windows(hz, d)
            s = day_series(d, LAT, LON)
            up = [x for x in s if x[1] > -0.267]
            ws = ', '.join(f"{w[0].strftime('%H:%M')} to {(w[1]).strftime('%H:%M')}" for w in res) or 'none'
            print(f"{months[m-1]:10s} sunrise {up[0][0].strftime('%H:%M')} sunset {up[-1][0].strftime('%H:%M')} | sun: {ws} | {total//60} h {total%60:02d} min")
