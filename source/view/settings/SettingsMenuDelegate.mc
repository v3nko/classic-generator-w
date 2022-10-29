using Toybox.WatchUi as Ui;
using Generator as Gen;

class SettingsMenuDelegate extends Ui.Menu2InputDelegate {

    private var serviceLocator;
    private var settingsController;
    private var menu;

    function initialize(serviceLocator, menu) {
        Menu2InputDelegate.initialize();
        me.serviceLocator = serviceLocator;
        me.settingsController = serviceLocator.getSettingsController();
        me.menu = menu;
    }

    function onSelect(item as Ui.MenuItem) {
        if (item.getId() == :startupGenEnabled) {
            settingsController.saveStartupGenEnabled(item.isEnabled());
        } else {
            var picker = new GeneratorOptionsPicker(serviceLocator, { :option => item.getId() });
            Ui.pushView(
                picker, 
                new GeneratorOptionsPickerDelegate(serviceLocator, picker, method(:onPickerAccept)),
                Ui.SLIDE_LEFT
            );
        }
    }

    function onPickerAccept(itemId) {
        var itemIndex = menu.findItemById(itemId);
        if (itemIndex >= 0) {
            menu.getItem(itemIndex).setSubLabel(resolveGeneratorOptionValue(itemId));
        }
    }

    private function resolveGeneratorOptionValue(option as GeneratorOption) {
        return settingsController.getGeneratorOptionValue(option).toString();
    }

    function onBack() {
        Ui.popView(Ui.SLIDE_RIGHT);
    }

    function onDone() {
        onBack();
    }
}
