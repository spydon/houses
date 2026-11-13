# Houses

Sun and shade studies for houses, published to GitHub Pages at
https://spydon.github.io/houses/.

The site is a Flutter web app. The front page lists the addresses, and each
address is its own Flutter package in `addresses/` with its data, tests and
the scripts that build its data. The sun model, the page and the widgets are
shared by all addresses in `packages/sun_study/`.

| Path                               | Contents                                     |
| ---------------------------------- | -------------------------------------------- |
| `lib/`                             | The front page and the routing between pages |
| `packages/sun_study/`              | Sun model, page and widgets for every study  |
| `addresses/abrahamsbergsvägen_18/` | Data and tests for Abrahamsbergsvägen 18     |
| `addresses/berganäsvägen_18b/`     | Data and tests for Berganäsvägen 18B         |
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
2. Build `assets/surface_model.json`, `assets/backyard.jpg` and
   `assets/cover.jpg` with scripts in its `tool` folder, starting from the
   ones for an existing address.
3. Describe the study with a `SunStudy` constant in the package library.
4. Add the package to `workspace` and `dependencies` in the root
   `pubspec.yaml`, add an `Address` entry in `lib/src/address.dart` and add a
   test step for it in `.github/workflows/deploy.yml`.

## Deployment

Every push to `main` runs the tests, builds the web app with WebAssembly
(`flutter build web --wasm`) and publishes it to GitHub Pages. Browsers without
WebAssembly garbage collection support get the JavaScript build instead. Pull
requests run the same checks without publishing.
