using Toybox.WatchUi as Ui;
using Toybox.Lang;
using Generator as Gen;

class GeneratorOptionsPicker extends Ui.Picker {
    private const valueSet = "0123456789";
    private const lenSet = "123456";
    private const sign = "-";

    private var serviceLocator;
    private var validator;

    private var genMode;
    private var title;

    public function initialize(serviceLocator, params) {
        me.serviceLocator = serviceLocator;
        validator = serviceLocator.getGeneratorOptionsValidator();
        genMode = params.get(:generatorMode);

        var title = new Ui.Text(
            {
                :text => "Gen options", 
                :locX => Ui.LAYOUT_HALIGN_CENTER,
                :locY => Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Graphics.COLOR_WHITE
            }
        );

        Picker.initialize(
            { 
                :title => title,
                :pattern => getPickerFactories()
            }
        );
    }

    private function getPickerFactories() {
        var factories = [];
        switch (genMode) {
            case Gen.GENERATOR_NUM:
                break;
            case Gen.GENERATOR_RANGE:
                for (var i = 0; i < validator.getMaxArgLength() + 1; i++) {
                    factories.add(new CharacterFactory(sign + valueSet));
                }
                break;
            case Gen.GENERATOR_NUM_FIXED:
            case Gen.GENERATOR_ALPHANUM:
            case Gen.GENARATOR_HEX:
                break;
            default:
                throw new Lang.UnexpectedTypeException("Unknown or unspecified generator mode");
        }
        return factories;
    }

    public function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        Picker.onUpdate(dc);
    }
}

class GeneratorOptionsPickerDelegate extends Ui.PickerDelegate {
    public function initialize() {
        PickerDelegate.initialize();
    }

    public function onCancel() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }

    public function onAccept(values as Array) as Boolean {
        var argValue = "";
        for (var i = 0; i < values.size(); i++) {
            argValue += values[i];
        }
        return true;
    }
}
