using Toybox.WatchUi as Ui;

class HistoryMenuInputdelegate extends Ui.Menu2InputDelegate {

    private var serviceLocator;

    function initialize(serviceLocator) {
        Menu2InputDelegate.initialize();
        me.serviceLocator = serviceLocator;
    }

    function onSelect(item as WatchUi.MenuItem) {
        var dialog = new Ui.Confirmation(
            Application.loadResource(Rez.Strings.dialog_title_clear_history)
        );
        Ui.pushView(
            dialog,
            new ClearHistoryDialogDelegate(serviceLocator, method(:onClearHistory)),
            Ui.SLIDE_IMMEDIATE
        );
        return true;
    }

    function onClearHistory() {
        Ui.popView(Ui.SLIDE_IMMEDIATE);
    }
}