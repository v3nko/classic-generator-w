using Toybox.WatchUi as Ui;

class ClearHistoryDialogDelegate extends Ui.ConfirmationDelegate {

    private var callback;
    private var generatorController;
    
    function initialize(serviceLocator, callback as Method) {
        ConfirmationDelegate.initialize();
        generatorController = serviceLocator.getGeneratorController();
        me.callback = callback;
    }

    function onResponse(response as Confirm) as Boolean {
        if (response == Ui.CONFIRM_YES) {
            generatorController.clearHistory();
            callback.invoke();
        }
        return true;
    }
}
