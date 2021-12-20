using Toybox.Application as App;
using Toybox.Timer as Timer;

class CGApp extends App.AppBase {
    function initialize() {
        AppBase.initialize();
    }
    
    function onStart(state) {
        
    }

    function onStop(state) {

    }

    function getInitialView() {
        var view = new GeneratorView();
        return [view, new GeneratorDelegate(view)];
    }
}
