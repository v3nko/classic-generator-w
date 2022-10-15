using Toybox.WatchUi as Ui;
using Generator as Gen;

class MainMenuDelegate extends Ui.Menu2InputDelegate {

    private var serviceLocator;
    private var generatorController;
    private var settingsController;
    private var timeFormatter;

    function initialize(serviceLocator) {
        Menu2InputDelegate.initialize();
        me.serviceLocator = serviceLocator;
        generatorController = serviceLocator.getGeneratorController();
        settingsController = serviceLocator.getSettingsController();
        timeFormatter = serviceLocator.getDateTimeFormatter();
    }

    function onSelect(item as WatchUi.MenuItem) {
        switch (item.getId()) {
            case :history:
                navigateToHistory();
                break;
            case :settings:
                navigateToSettings();
                break;
            case :about:
                navigateToAbout();
                break;
        }
        return true;
    }

    private function navigateToHistory() {
        var menu = new Ui.Menu2({ :title => Rez.Strings.menu_title_results_history });
        var history = generatorController.getHistory();
        if (history.size() != 0) {
            for (var i = 0; i < history.size(); i++) {
                var record = history[i];
                menu.addItem(
                    new Ui.MenuItem(
                        Lang.format("$1$ | $2$", [resolveTextIndicator(record.type), record.data]),
                        timeFormatter.formatDateTimeNumeric(record.time),
                        null,
                        null
                    )
                );
            }
            Ui.pushView(menu, new HistoryMenuInputdelegate(serviceLocator), Ui.SLIDE_LEFT);
        }
    }

    private function resolveTextIndicator(generatorMode as Gen.GeneratorType) {
        var indicator;
        switch (generatorMode) {
            case Gen.GENERATOR_NUM:
                indicator = Rez.Strings.gen_title_num_short;
                break;
            case Gen.GENERATOR_RANGE:
                indicator = Rez.Strings.gen_title_num_range_short;
                break;
            case Gen.GENERATOR_NUM_FIXED:
                indicator = Rez.Strings.gen_title_num_fixed_short;
                break;
            case Gen.GENERATOR_ALPHANUM:
                indicator = Rez.Strings.gen_title_alphanum_short;
                break;
            case Gen.GENARATOR_HEX:
                indicator = Rez.Strings.gen_title_hex_short;
                break;
            default:
                indicator = Rez.Strings.gen_title_unknown_short;
        }
        return Application.loadResource(indicator);
    }

    private function navigateToSettings() {
        var menu = new Ui.Menu2({ :title => Rez.Strings.menu_title_settings });
        addToggleSettingsItem(
            menu,
            Rez.Strings.settings_startup_gen,
            settingsController.getStartupGenEnabled(),
            :startupGenEnabled
        );
        addGeneratorSettingsItem(menu, Gen.NUM_MAX);
        addGeneratorSettingsItem(menu, Gen.RANGE_MIN);
        addGeneratorSettingsItem(menu, Gen.RANGE_MAX);
        addGeneratorSettingsItem(menu, Gen.NUM_FIXED_LEN);
        addGeneratorSettingsItem(menu, Gen.ALPHANUM_LEN);
        addGeneratorSettingsItem(menu, Gen.HEX_LEN);
        Ui.pushView(menu, new SettingsMenuDelegate(serviceLocator, menu), Ui.SLIDE_LEFT);
    }

    private function addToggleSettingsItem(menu, titleId, value as Boolean, itemId) {
        menu.addItem(
            new Ui.ToggleMenuItem(Application.loadResource(titleId), null, itemId, value, null)
        );
    }

    private function addGeneratorSettingsItem(menu, option as Generatoroption) {
        menu.addItem(
            new Ui.MenuItem(
                resolveGeneratorOptionTitle(option),
                resolveGeneratorOptionValue(option),
                option,
                null
            )
        );
    }

    private function resolveGeneratorOptionTitle(option as GeneratorOption) {
        var titleId;
        switch (option) {
            case Gen.NUM_MAX:
                titleId = Rez.Strings.settings_num_max;
                break;
            case Gen.RANGE_MIN:
                titleId = Rez.Strings.settings_range_min;
                break;
            case Gen.RANGE_MAX:
                titleId = Rez.Strings.settings_range_max;
                break;
            case Gen.NUM_FIXED_LEN:
                titleId = Rez.Strings.settings_num_fixed_len;
                break;
            case Gen.ALPHANUM_LEN:
                titleId = Rez.Strings.settings_alphanum_len;
                break;
            case Gen.HEX_LEN:
                titleId = Rez.Strings.settings_hex_len;
                break;
        }
        return Application.loadResource(titleId);
    }

    private function resolveGeneratorOptionValue(option as GeneratorOption) {
        return settingsController.getGeneratorOptionValue(option).toString();
    }

    private function navigateToAbout() {
        Ui.pushView(new AboutView(serviceLocator), null, Ui.SLIDE_LEFT);
    }

    function onBack() {
        Ui.popView(Ui.SLIDE_RIGHT);
    }

    function onDone() {
        onBack();
    }
}
