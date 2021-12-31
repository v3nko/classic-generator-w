using Toybox.WatchUi as Ui;

class GeneratorDelegate extends Ui.BehaviorDelegate {

    var generatorView;

    function initialize(view) {
        generatorView = view;
        Ui.BehaviorDelegate.initialize();
    }

    function onKey(keyEvent) {
        switch(keyEvent.getKey()) {
            case Ui.KEY_ENTER:
                generatorView.generateNewValue();
                Ui.requestUpdate();
                break;
            case Ui.KEY_DOWN:
                generatorView.switchMode();
                Ui.requestUpdate();
                break;
        }
    }
}
