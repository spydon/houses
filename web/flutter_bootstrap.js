{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  config: {
    suppressMultithreadingWarning: true,
  },
  onEntrypointLoaded: async function (engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    document.getElementById("loading")?.remove();
    await appRunner.runApp();
  },
});
