using Generator as Gen;
using Toybox.Time;

class SettingsController {
    private var settings;
    private var validator;

    function initialize(settings as SettingsStore, validator as GeneratorOptionsValidator) {
        me.settings = settings;
        me.validator = validator;
    }

    function getStartupGenEnabled() as Boolean {
        return settings.getStartupGenEnabled();
    }

    function saveStartupGenEnabled(value as Boolean) as Boolean {
        return settings.saveStartupGenEnabled(value);
    }

    function getMaxArgLength() {
        return validator.getMaxArgLength();
    }

    function getNumMax() as Number {
        return settings.getNumMax();
    }

    function getRangeMin() as Number {
        return settings.getRangeMin();
    }

    function getRangeMax() as Number {
        return settings.getRangeMax();
    }

    function getNumFixedLen() as Number {
        return settings.getNumFixedLen();
    }

    function getAlphanumLen() as Number {
        return settings.getAlphanumLen();
    }

    function getHexLen() as Number {
        return settings.getHexLen();
    }

    function saveNumMax(value as Number) as Number {
        return settings.saveNumMax(value);
    }

    function saveRangeMin(value as Number) as Number {
        return settings.saveRangeMin(value);
    }

    function saveRangeMax(value as Number) as Number {
        return settings.saveRangeMax(value);
    }

    function saveNumFixedLen(value as Number) as Number {
        return settings.saveNumFixedLen(value);
    }

    function saveAlphanumLen(value as Number) as Number {
        return settings.saveAlphanumLen(value);
    }

    function saveHexLen(value as Number) as Number {
        return settings.saveHexLen(value);
    }

    function getGeneratorOptionValue(option as GeneratorOption) {
        var value;
        switch (option) {
            case Gen.NUM_MAX:
                value = getNumMax();
                break;
            case Gen.RANGE_MIN:
                value = getRangeMin();
                break;
            case Gen.RANGE_MAX:
                value = getRangeMax();
                break;
            case Gen.NUM_FIXED_LEN:
                value = getNumFixedLen();
                break;
            case Gen.ALPHANUM_LEN:
                value = getAlphanumLen();
                break;
            case Gen.HEX_LEN:
                value = getHexLen();
                break;
        }
        return  value;
    }
}
