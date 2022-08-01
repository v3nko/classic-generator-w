using Toybox.Application as App;
using Di;

class CGApp extends App.AppBase {
    private var serviceLocator;
    private var lifecycleHandler;

    function initialize() {
        AppBase.initialize();
        serviceLocator = Di.provideServiceRegistry();
        lifecycleHandler = serviceLocator.getViewLifecycleHandler();
    }

    function onStop(state) {
        AppBase.onStop(state);
        lifecycleHandler.onAppExit();
    }

    function getInitialView() {
        var view = new GeneratorView(serviceLocator);
        return [view, new GeneratorDelegate(view)];
    }
}
