using Toybox.WatchUi as Ui;

class HistoryMenuInputdelegate extends Ui.Menu2InputDelegate {

    private var serviceLocator;

    function initialize(serviceLocator) {
        Menu2InputDelegate.initialize();
        me.serviceLocator = serviceLocator;
    }

    function onSelect(item as Ui.MenuItem) {
        var dialog = new Ui.Confirmation(
            Application.loadResource(Rez.Strings.dialog_title_clear_history)
        );
        Ui.pushView(
            dialog,
            new ClearHistoryDialogDelegate(serviceLocator, method(:onClearHistory)),
            Ui.SLIDE_LEFT
        );
        return true;
    }

    function onClearHistory() {
        onBack();
    }

    function onBack() {
        Ui.popView(Ui.SLIDE_RIGHT);
    }

    function onDone() {
        onBack();
    }
}
