using Toybox.Timer;

class ViewLifecycleHandler {
    private const EXIT_TIMEOUT = 6100;
    
    private var viewRefCounter = 0;
    private var exitTimer = new Timer.Timer();

    function onShow() {
        viewRefCounter++;
        exitTimer.stop();
    }

    function onHide() {
        viewRefCounter--;
        if (viewRefCounter <= 0) {
            exitTimer.start(method(:exitApp), EXIT_TIMEOUT, false);
        }
    }

    function onAppExit() {
        exitTimer.stop();
    }

    function exitApp() {
        System.exit();
    }
}
