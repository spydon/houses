# Houses

Sun and shade studies for houses, published to GitHub Pages at
https://spydon.github.io/houses/.

The site is a Flutter web app. The front page lists the addresses, and each
address is its own Flutter package in `addresses/` with its data, tests and
its configuration for the data scripts. The sun model, the page, the widgets
and the data scripts are shared by all addresses in `packages/sun_study/`.

| Path                               | Contents                                     |
| ---------------------------------- | -------------------------------------------- |
| `lib/`                             | The front page and the routing between pages |
| `packages/sun_study/`              | Sun model, page and widgets for every study  |
| `packages/sun_study/tool/`         | Scripts that build the data for an address   |
| `addresses/abrahamsbergsvägen_18/` | Data and tests for Abrahamsbergsvägen 18     |
| `addresses/berganäsvägen_18b/`     | Data and tests for Berganäsvägen 18B         |
| `addresses/kästavägen_6/`          | Data and tests for Kästavägen 6              |
| `.github/workflows/deploy.yml`     | Builds and publishes the site                |

## Running locally

```sh
flutter pub get
flutter run -d chrome --wasm
```

## Adding an address

1. Create a Flutter package in `addresses/<street_and_number>/` with
   `resolution: workspace` and a dependency on `sun_study` in its
   `pubspec.yaml`.
2. Describe the address in `tool/site.json`, `tool/buildings.json` and
   `tool/spots.json`, starting from the ones for an existing address, and
   build `assets/surface_model.json`, `assets/backyard.jpg` and
   `assets/cover.jpg` with the scripts in `packages/sun_study/tool/`.
3. Describe the study with a `SunStudy` constant in the package library.
4. Add the package to `workspace` and `dependencies` in the root
   `pubspec.yaml`, add an `Address` entry in `lib/src/address.dart` and add a
   test step for it in `.github/workflows/deploy.yml`.

## Regenerating the data

The scripts in `packages/sun_study/tool/` need Python 3.12 with numpy,
rasterio, pyproj, pillow, requests, matplotlib, inflate64 and imagecodecs. Each
takes the address directory as its only argument, and they run in order:

```sh
for step in packages/sun_study/tool/0*.py; do
  python "$step" addresses/kästavägen_6
done
```

Step 3 streams the 6.5 gigabyte tree height file for Stockholm county and keeps
only the rows around the house, which takes about eight minutes. Downloads and
intermediate files are kept in the address's `tool` folder and are ignored by
git.

`tool/site.json` holds the settings for an address:

| Key                               | Contents                                                                     |
| --------------------------------- | ---------------------------------------------------------------------------- |
| `latitude`, `longitude`           | The position used for the sun                                                |
| `east`, `north`                   | The center of the 800 by 800 meter model, in SWEREF 99 TM                    |
| `photo`                           | West, south, east and north edges of the aerial photo, in SWEREF 99 TM       |
| `ground`                          | West edge, north edge, width and height of the detailed ground heights       |
| `cover`                           | Either `crop`, a pixel box of the aerial photo, or `file`, an image to use   |
| `cleared` (optional)              | Additional areas where trees are removed, such as demolished buildings       |
| `clearAroundBuildings` (optional) | `false` to keep the trees around the building outlines                       |
| `buildingBase` (optional)         | `lowest` to measure buildings from the lowest ground point instead of median |
| `extra` (optional)                | Additional fields for `surface_model.json`                                   |

## Deployment

Every push to `main` runs the tests, builds the web app with WebAssembly
(`flutter build web --wasm`) and publishes it to GitHub Pages. Browsers without
WebAssembly garbage collection support get the JavaScript build instead. Pull
requests run the same checks without publishing.
