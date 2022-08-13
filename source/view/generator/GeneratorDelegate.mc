using Toybox.WatchUi as Ui;

class GeneratorDelegate extends Ui.BehaviorDelegate {

    var generatorView;

    function initialize(view) {
        generatorView = view;
        Ui.BehaviorDelegate.initialize();
    }

    function onSelect() {
        generatorView.generateNewValue();
        return true;
    }

    function onPreviousPage() {
        generatorView.switchToPreviousMode();
        return true;
    }

    function onNextPage() {
        generatorView.switchToNextMode();
        return true;
    }

    function onMenu() {
        generatorView.navigateToMenu();
        return true;
    }
}
