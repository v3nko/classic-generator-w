using Toybox.WatchUi as Ui;

class BaseView extends Ui.View {
    var lifecycleHandler;

    function initialize(lifecycleHandler as ViewLifecycleHandler) {
        View.initialize();
        me.lifecycleHandler = lifecycleHandler;
    }

    function onShow() {
        View.onShow();
        lifecycleHandler.onShow();
    }

    function onHide() {
        View.onHide();
        lifecycleHandler.onHide();
    }
}
