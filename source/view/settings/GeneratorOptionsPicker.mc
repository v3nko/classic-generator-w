using Toybox.WatchUi as Ui;
using Toybox.Lang;
using Generator as Gen;

class GeneratorOptionsPicker extends Ui.Picker {
    private const valueSet = "0123456789";
    private const lenSet = "123456";
    private const sign = "+-";

    private var serviceLocator;
    private var settingsController;

    hidden var option;
    hidden var title;

    public function initialize(serviceLocator, params) {
        me.serviceLocator = serviceLocator;
        settingsController = serviceLocator.getSettingsController();
        option = params.get(:option);

        title = new Ui.Text(
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
        switch (option) {
            case Gen.NUM_MAX:
                break;
            case Gen.RANGE_MIN:
            case Gen.RANGE_MAX:
                factories.add(new CharacterFactory(sign));
                for (var i = 0; i < settingsController.getMaxArgLength(); i++) {
                    factories.add(new CharacterFactory(valueSet));
                }
                break;
            case Gen.NUM_FIXED_LEN:
            case Gen.ALPHANUM_LEN:
            case Gen.HEX_LEN:
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

    public function setTitle(titleText) {
        title.setText(titleText);
    }

    function onAccept(value) {
        switch (option) {
            case Gen.NUM_MAX:
                break;
            case Gen.RANGE_MIN:
                settingsController.saveRangeMin(value);
                break;
            case Gen.RANGE_MAX:
                settingsController.saveRangeMax(value);
                break;
            case Gen.NUM_FIXED_LEN:
            case Gen.ALPHANUM_LEN:
            case Gen.HEX_LEN:
                break;
        }
        Ui.popView(Ui.SLIDE_IMMEDIATE);
    }
}

class GeneratorOptionsPickerDelegate extends Ui.PickerDelegate {
    private var picker as GeneratorOptionsPicker;
    private var serviceLocator;

    public function initialize(serviceLocator, picker as GeneratorOptionsPicker) {
        PickerDelegate.initialize();
        me.picker = picker;
        me.serviceLocator = serviceLocator;
    }

    public function onCancel() as Boolean {
        Ui.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }

    public function onAccept(values as Array) as Boolean {
        var argValue = "";
        for (var i = 0; i < values.size(); i++) {
            argValue += values[i];
        }
        var value = null;
        try {
            value = argValue.toNumber();
        } catch(e) {
            System.println("Unable to parse picker value: " + e);
        }
        if (value != null) {
            picker.onAccept(value);
            return true;
        } else {
            var alert = new Alert(
                serviceLocator,  
                { :text => Application.loadResource(Rez.Strings.error_invalid_generator_arguments) }
            );
            alert.pushView();
            return false;
        }
    }
}
