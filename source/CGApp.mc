using Toybox.Application as App;
using Toybox.Timer as Timer;
using Di;

class CGApp extends App.AppBase {
    function initialize() {
        AppBase.initialize();
    }
    
    function onStart(state) {
        
    }

    function onStop(state) {

    }

    function getInitialView() {
        var registry = Di.provideServiceRegistry();

        var view = new GeneratorView(registry.getGeneratorController());
        return [view, new GeneratorDelegate(view)];
    }
}
