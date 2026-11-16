import math
from datetime import datetime, timedelta, timezone
from zoneinfo import ZoneInfo
STHLM = ZoneInfo('Europe/Stockholm')
def julian_day(dt):
    return dt.timestamp() / 86400.0 + 2440587.5
def sun_position(dt, lat, lon):
    jd = julian_day(dt)
    t = (jd - 2451545.0) / 36525.0
    L0 = (280.46646 + t * (36000.76983 + t * 0.0003032)) % 360
    M = 357.52911 + t * (35999.05029 - 0.0001537 * t)
    e = 0.016708634 - t * (0.000042037 + 0.0000001267 * t)
    Mr = math.radians(M)
    C = math.sin(Mr) * (1.914602 - t * (0.004817 + 0.000014 * t)) + math.sin(2 * Mr) * (0.019993 - 0.000101 * t) + math.sin(3 * Mr) * 0.000289
    true_long = L0 + C
    omega = 125.04 - 1934.136 * t
    app_long = true_long - 0.00569 - 0.00478 * math.sin(math.radians(omega))
    eps0 = 23 + (26 + (21.448 - t * (46.815 + t * (0.00059 - t * 0.001813))) / 60) / 60
    eps = eps0 + 0.00256 * math.cos(math.radians(omega))
    decl = math.asin(math.sin(math.radians(eps)) * math.sin(math.radians(app_long)))
    y = math.tan(math.radians(eps / 2)) ** 2
    L0r = math.radians(L0)
    eqt = 4 * math.degrees(y * math.sin(2 * L0r) - 2 * e * math.sin(Mr) + 4 * e * y * math.sin(Mr) * math.cos(2 * L0r) - 0.5 * y * y * math.sin(4 * L0r) - 1.25 * e * e * math.sin(2 * Mr))
    u = dt.astimezone(timezone.utc)
    minutes = u.hour * 60 + u.minute + u.second / 60 + u.microsecond / 6e7
    tst = (minutes + eqt + 4 * lon) % 1440
    ha = math.radians(tst / 4 - 180)
    la = math.radians(lat)
    cz = math.sin(la) * math.sin(decl) + math.cos(la) * math.cos(decl) * math.cos(ha)
    zen = math.degrees(math.acos(max(-1, min(1, cz))))
    elev = 90 - zen
    az = (math.degrees(math.atan2(math.sin(ha), math.cos(ha) * math.sin(la) - math.tan(decl) * math.cos(la))) + 180) % 360
    if elev > 85: r = 0
    elif elev > 5: te = math.tan(math.radians(elev)); r = 58.1 / te - 0.07 / te ** 3 + 0.000086 / te ** 5
    elif elev > -0.575: r = 1735 + elev * (-518.2 + elev * (103.4 + elev * (-12.79 + elev * 0.711)))
    else: r = -20.774 / math.tan(math.radians(elev))
    return elev + r / 3600, az
def day_series(date, lat, lon, step_min=1):
    start = datetime(date.year, date.month, date.day, 0, 0, tzinfo=STHLM)
    out = []
    for k in range(0, 24 * 60, step_min):
        dt = start + timedelta(minutes=k)
        el, az = sun_position(dt, lat, lon)
        out.append((dt, el, az))
    return out
if __name__ == '__main__':
    from datetime import date
    lat, lon = 59.23597, 18.04096
    for d in [date(2026, 6, 21), date(2026, 12, 21), date(2026, 3, 20)]:
        s = day_series(d, lat, lon)
        up = [x for x in s if x[1] > -0.833 + 0.833]  # refraction already applied: sunrise when upper limb at horizon ~ elev > -0.27 with refraction; use center > -0.27
        up = [x for x in s if x[1] > -0.267]
        noon = max(s, key=lambda x: x[1])
        print(d, 'rise', up[0][0].strftime('%H:%M'), 'set', up[-1][0].strftime('%H:%M'), 'noon', noon[0].strftime('%H:%M'), 'max elev %.1f az %.1f' % (noon[1], noon[2]), 'rise az %.0f set az %.0f' % (up[0][2], up[-1][2]))
