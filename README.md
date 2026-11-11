# Houses

Sun and shade studies for houses, published to GitHub Pages at
https://spydon.github.io/houses/.

The site is a Flutter web app. The front page lists the addresses, and each
address is its own Flutter package in `addresses/`.

| Path                               | Contents                                     |
| ---------------------------------- | -------------------------------------------- |
| `lib/`                             | The front page and the routing between pages |
| `addresses/abrahamsbergsvägen_18/` | Sun model for Abrahamsbergsvägen 18          |
| `.github/workflows/deploy.yml`     | Builds and publishes the site                |

## Running locally

```sh
flutter pub get
flutter run -d chrome --wasm
```

## Adding an address

1. Create a Flutter package in `addresses/<street_and_number>/` with
   `resolution: workspace` in its `pubspec.yaml`.
2. Add it to `workspace` and `dependencies` in the root `pubspec.yaml`.
3. Add an `Address` entry in `lib/src/address.dart`.

## Deployment

Every push to `main` runs the tests, builds the web app with WebAssembly
(`flutter build web --wasm`) and publishes it to GitHub Pages. Browsers without
WebAssembly garbage collection support get the JavaScript build instead. Pull
requests run the same checks without publishing.
