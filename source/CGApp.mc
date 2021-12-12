using Toybox.Application as App;
using Toybox.Timer as Timer;

class CGApp extends App.AppBase {
    function initialize() {
        AppBase.initialize();
    }
    
    function onStart(state) {
        
    }

    function onStop() {

    }

    function getInitialView() {
        return [new GeneratorView()];
    }
}