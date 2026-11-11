import requests, struct, inflate64, pickle
URL = 'https://geodpags.skogsstyrelsen.se/geodataport/data/sksTradhojd01.zip'
s = requests.Session(); s.headers['User-Agent'] = 'sun-analysis-script/1.0'
head = s.get(URL, headers={'Range': 'bytes=141-3000141'}).content
raw = inflate64.Inflater().inflate(head)
E = '<' if raw[:2] == b'II' else '>'
ifd = struct.unpack(E + 'Q', raw[8:16])[0]
print('ifd at', ifd, 'have', len(raw))
n = struct.unpack(E + 'Q', raw[ifd:ifd + 8])[0]
sizes = {1: 1, 2: 1, 3: 2, 4: 4, 5: 8, 11: 4, 12: 8, 16: 8, 17: 8, 18: 8}
fmts = {1: 'B', 3: 'H', 4: 'I', 12: 'd', 16: 'Q', 17: 'q', 18: 'Q', 11: 'f'}
tags = {}
for i in range(n):
    e = raw[ifd + 8 + 20 * i: ifd + 8 + 20 * (i + 1)]
    tag, typ, cnt = struct.unpack(E + 'HHQ', e[:12])
    sz = sizes.get(typ, 1) * cnt
    if sz <= 8:
        v = struct.unpack(E + fmts[typ] * cnt, e[12:12 + sz]) if typ in fmts else e[12:12 + sz]
    else:
        off = struct.unpack(E + 'Q', e[12:20])[0]
        if off + sz <= len(raw):
            v = struct.unpack(E + fmts[typ] * cnt, raw[off:off + sz]) if typ in fmts else raw[off:off + sz]
        else:
            v = ('@', off, cnt)
    tags[tag] = (typ, cnt, v)
    show = v if (not isinstance(v, tuple) or len(v) < 12) else (v[:6], '...', len(v))
    print(tag, typ, cnt, show)
pickle.dump(tags, open('tiff_tags.pkl', 'wb'))
