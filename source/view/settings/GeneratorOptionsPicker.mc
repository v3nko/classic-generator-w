using Toybox.WatchUi as Ui;
using Toybox.Lang;
using Generator as Gen;

class GeneratorOptionsPicker extends Ui.Picker {
    private const valueSet = "0123456789";
    private const lenSet = "123456";
    private const sign = "-";

    private var serviceLocator;
    private var validator;

    hidden var option;
    hidden var title;

    public function initialize(serviceLocator, params) {
        me.serviceLocator = serviceLocator;
        validator = serviceLocator.getGeneratorOptionsValidator();
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
                for (var i = 0; i < validator.getMaxArgLength() + 1; i++) {
                    factories.add(new CharacterFactory(valueSet + sign));
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
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
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
            System.println("Unable to parse picke value: " + e);
        }
        if (value != null) {
            picker.setTitle(value.toString());
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
