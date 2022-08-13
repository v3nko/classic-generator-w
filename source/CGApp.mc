using Toybox.Application as App;
using Di;

class CGApp extends App.AppBase {
    private var serviceLocator;

    function initialize() {
        AppBase.initialize();
        serviceLocator = Di.provideServiceRegistry();
    }

    function getInitialView() {
        var view = new GeneratorView(serviceLocator);
        return [view, new GeneratorDelegate(view)];
    }
}
