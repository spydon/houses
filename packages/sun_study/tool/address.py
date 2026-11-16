import json
import os
import sys
from pathlib import Path

if len(sys.argv) != 2:
    sys.exit(f'Usage: python {Path(sys.argv[0]).name} <address directory>')
os.chdir(Path(sys.argv[1]).resolve() / 'tool')
site = json.load(open('site.json'))
LAT, LON = site['latitude'], site['longitude']
E0, N0 = site['east'], site['north']
