using UniTimer;

class ViewLifecycleHandler {
    private const EXIT_TIMEOUT = 6100;
    private const TIMER_LIFECYCLE_HANDLER = "lifecycle_handler";
    
    private var viewRefCounter = 0;
    private var exitTimer = UniTimer.getTimer();
    private var exitTimerSuppressed = false;

    function onShow() {
        exitTimerSuppressed = false;
        viewRefCounter++;
        exitTimer.stop(TIMER_LIFECYCLE_HANDLER);
    }

    function onHide() {
        viewRefCounter--;
        if (viewRefCounter <= 0 && !exitTimerSuppressed) {
            exitTimer.start(TIMER_LIFECYCLE_HANDLER, method(:exitApp), EXIT_TIMEOUT, false);
        }
    }

    function suppressExitTimer() {
        exitTimerSuppressed = true;
        exitTimer.stop(TIMER_LIFECYCLE_HANDLER);
    }

    function onAppExit() {
        exitTimer.stop(TIMER_LIFECYCLE_HANDLER);
    }

    function exitApp() {
        System.exit();
    }
}
