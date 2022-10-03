using Toybox.WatchUi as Ui;
using Toybox.Lang;
using Generator as Gen;

class GeneratorOptionsPicker extends Ui.Picker {
    private const VALUE_SET = "0123456789".toCharArray();
    private const LEN_SET = "123456".toCharArray();
    private const SIGN_POSITIVE = '+';
    private const SIGN_NEGATIVE = '-';
    private const SIGN_SET = [SIGN_POSITIVE, SIGN_NEGATIVE];

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
                :text => getTitle(), 
                :locX => Ui.LAYOUT_HALIGN_CENTER,
                :locY => Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Graphics.COLOR_WHITE
            }
        );

        Picker.initialize(
            { 
                :title => title,
                :pattern => getPickerFactories(),
                :defaults => getDefaultPickerValues()
            }
        );
    }

    private function getTitle() {
        switch (option) {
            case Gen.NUM_MAX:
                return Application.loadResource(Rez.Strings.settings_num_max);
            case Gen.RANGE_MIN:
                return Application.loadResource(Rez.Strings.settings_range_min);
            case Gen.RANGE_MAX:
                return Application.loadResource(Rez.Strings.settings_range_max);
            case Gen.NUM_FIXED_LEN:
                return Application.loadResource(Rez.Strings.settings_num_fixed_len);
            case Gen.ALPHANUM_LEN:
                return Application.loadResource(Rez.Strings.settings_alphanum_len);
            case Gen.HEX_LEN:
                return Application.loadResource(Rez.Strings.settings_hex_len);
            default:
                throw new Lang.UnexpectedTypeException("Unknown or unspecified generator mode");
        }
    }

    private function getPickerFactories() {
        var factories = [];
        switch (option) {
            case Gen.NUM_MAX:
                for (var i = 0; i < settingsController.getMaxArgLength(); i++) {
                    factories.add(new CharacterFactory(VALUE_SET));
                }
                break;
            case Gen.RANGE_MIN:
            case Gen.RANGE_MAX:
                factories.add(new CharacterFactory(SIGN_SET));
                for (var i = 0; i < settingsController.getMaxArgLength(); i++) {
                    factories.add(new CharacterFactory(VALUE_SET));
                }
                break;
            case Gen.NUM_FIXED_LEN:
            case Gen.ALPHANUM_LEN:
            case Gen.HEX_LEN:
                factories.add(new CharacterFactory(LEN_SET));
                break;
            default:
                throw new Lang.UnexpectedTypeException("Unknown or unspecified generator mode");
        }
        return factories;
    }

    private function getDefaultPickerValues() {
        var defaults = [];
        switch (option) {
            case Gen.NUM_MAX:
                defaults = decomposeMaxValue(settingsController.getNumMax());
                break;
            case Gen.RANGE_MIN:
                defaults = decomposeRangeValue(settingsController.getRangeMin());
                break;
            case Gen.RANGE_MAX:
                defaults = decomposeRangeValue(settingsController.getRangeMax());
                break;
            case Gen.NUM_FIXED_LEN:
                defaults = decomposeLenValue(settingsController.getNumFixedLen());
                break;
            case Gen.ALPHANUM_LEN:
                defaults = decomposeLenValue(settingsController.getAlphanumLen());
                break;
            case Gen.HEX_LEN:
                defaults = decomposeLenValue(settingsController.getHexLen());
                break;
            default:
                throw new Lang.UnexpectedTypeException("Unknown or unspecified generator mode");
        }
        return defaults;
    }

    private function decomposeRangeValue(rawValue as Number) as Array {
        var signIndex;
        if (rawValue < 0) {
            signIndex = SIGN_SET.indexOf(SIGN_NEGATIVE);
        } else {
            signIndex = SIGN_SET.indexOf(SIGN_POSITIVE);
        }
        var value = alignRangeValue(
            decomposeSettingsValue(rawValue.abs().toString(), VALUE_SET),
            signIndex
        );
        return value;
    }

    private function alignRangeValue(value as Array, signIndex as Number or Null) as Array {
        var gap = settingsController.getMaxArgLength() - value.size();
        var alignedValue;
        if (signIndex != null) {
            alignedValue = [signIndex];
        } else {
            alignedValue = [];
        }
        if (gap > 0) {
            for (var i = 0; i < gap; i++) {
                alignedValue.add(0);
            }
            alignedValue.addAll(value);
        } else if (gap < 0) {
            alignedValue.addAll(value.slice(0, settingsController.getMaxArgLength()));
        } else {
            alignedValue.addAll(value);
        }
        return alignedValue;
    }

    private function decomposeMaxValue(rawValue as Number) as Array {
        return alignRangeValue(decomposeSettingsValue(rawValue.toString(), VALUE_SET), null);
    }

    private function decomposeSettingsValue(value as String, charSet as Array) as Array {
        var valueArray = value.toCharArray();
        var result = [];
        for (var i = 0; i < value.length(); i++) {
            var index = charSet.indexOf(valueArray[i]);
            if (index < 0) {
                index = 0;
            }
            result.add(index);
        }
        return result;
    }

    private function decomposeLenValue(rawValue as String) as Array {
        return decomposeSettingsValue(rawValue.toString(), LEN_SET);
    }

    public function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        Picker.onUpdate(dc);
    }

    function onAccept(value) {
        switch (option) {
            case Gen.NUM_MAX:
                settingsController.saveNumMax(value);
                break;
            case Gen.RANGE_MIN:
                settingsController.saveRangeMin(value);
                break;
            case Gen.RANGE_MAX:
                settingsController.saveRangeMax(value);
                break;
            case Gen.NUM_FIXED_LEN:
                settingsController.saveNumFixedLen(value);
                break;
            case Gen.ALPHANUM_LEN:
                settingsController.saveAlphanumLen(value);
                break;
            case Gen.HEX_LEN:
                settingsController.saveHexLen(value);
                break;
        }
    }

    function getOption() {
        return option;
    }
}

class GeneratorOptionsPickerDelegate extends Ui.PickerDelegate {
    private var picker as GeneratorOptionsPicker;
    private var serviceLocator;
    private var onAcceptCallback;

    public function initialize(
        serviceLocator, 
        picker as GeneratorOptionsPicker, 
        onAcceptCallback as Method
    ) {
        PickerDelegate.initialize();
        me.picker = picker;
        me.serviceLocator = serviceLocator;
        me.onAcceptCallback = onAcceptCallback;
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
            onAcceptCallback.invoke(picker.getOption());
            Ui.popView(Ui.SLIDE_IMMEDIATE);
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
