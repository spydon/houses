import requests, inflate64, pickle, time, sys
URL = 'https://geodpags.skogsstyrelsen.se/geodataport/data/sksTradhojd01.zip'
t = pickle.load(open('tiff_tags.pkl', 'rb'))
off = t[273][2]; cnt = t[279][2]
r0 = 6700000 - 6570285 - 400; r1 = 6700000 - 6570285 + 400
need_start = off[r0]; need_end = off[r1] + cnt[r1]
s = requests.Session(); s.headers['User-Agent'] = 'sun-analysis-script/1.0'
inf = inflate64.Inflater()
upos = 0; cpos = 141; captured = bytearray(); t0 = time.time(); last = 0
with s.get(URL, headers={'Range': f'bytes={cpos}-'}, stream=True, timeout=60) as r:
    for chunk in r.iter_content(chunk_size=1 << 20):
        out = inf.inflate(chunk)
        a, b = upos, upos + len(out)
        if b > need_start and a < need_end:
            captured += out[max(0, need_start - a):min(len(out), need_end - a)]
        upos = b; cpos += len(chunk)
        if time.time() - last > 15:
            last = time.time()
            print(f'{time.time()-t0:6.0f}s uncompressed {upos/1e9:.2f} GB of {need_end/1e9:.2f} GB', flush=True)
        if upos >= need_end:
            break
open('chm_rows.bin', 'wb').write(captured)
pickle.dump({'r0': r0, 'r1': r1, 'need_start': need_start}, open('chm_rows_meta.pkl', 'wb'))
print('done', len(captured), 'bytes in', round(time.time() - t0), 's', flush=True)
