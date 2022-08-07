using Toybox.WatchUi as Ui;
using Generator as Gen;

class MainMenuDelegate extends Ui.Menu2InputDelegate {

    private var serviceLocator;
    private var generatorController;
    private var timeFormatter;

    function initialize(serviceLocator) {
        Menu2InputDelegate.initialize();
        me.serviceLocator = serviceLocator;
        generatorController = serviceLocator.getGeneratorController();
        timeFormatter = serviceLocator.getDateTimeFormatter();
    }

    function onSelect(item as WatchUi.MenuItem) {
        switch (item.getId()) {
            case :history:
                navigateToHistory();
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
        Ui.pushView(menu, new HistoryMenuInputdelegate(serviceLocator), Ui.SLIDE_IMMEDIATE);
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

    private function navigateToAbout() {
        Ui.pushView(new AboutView(serviceLocator), null, Ui.SLIDE_IMMEDIATE);
    }
}
