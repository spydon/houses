import pickle, numpy as np, imagecodecs
from address import E0 as CENTER_EAST
t = pickle.load(open('tiff_tags.pkl', 'rb'))
off = t[273][2]; cnt = t[279][2]
m = pickle.load(open('chm_rows_meta.pkl', 'rb'))
buf = open('chm_rows.bin', 'rb').read()
r0, r1 = m['r0'], m['r1']; base = m['need_start']
E0 = CENTER_EAST - 600; E1 = CENTER_EAST + 601
c0 = E0 - 620000; c1 = E1 - 620000
rows = []
for r in range(r0, r1 + 1):
    data = buf[off[r] - base: off[r] - base + cnt[r]]
    row = np.frombuffer(imagecodecs.lzw_decode(data), dtype='<i2')
    rows.append(row[c0:c1])
chm = np.array(rows)
print(chm.shape, chm.min(), chm.max(), np.unique(chm[chm < 0])[:10])
np.save('chm_raw.npy', chm)
print('row0 N top edge', 6700000 - r0, 'col0 E left edge', E0)
