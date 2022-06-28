using Toybox.Application as App;
using Di;

class CGApp extends App.AppBase {
    private var registry;
    private var lifecycleHandler;

    function initialize() {
        AppBase.initialize();
        registry = Di.provideServiceRegistry();
        lifecycleHandler = registry.getViewLifecycleHandler();
    }

    function onStop(state) {
        AppBase.onStop(state);
        lifecycleHandler.onAppExit();
    }

    function getInitialView() {
        var view = new GeneratorView(
            registry.getGeneratorController(), 
            registry.getViewLifecycleHandler()
        );
        return [view, new GeneratorDelegate(view)];
    }
}
