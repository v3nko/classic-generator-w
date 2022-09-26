using Generator as Gen;
using Toybox.Time;

class SettingsController {
    private var settings;
    private var validator;

    function initialize(settings as SettingsStore, validator as GeneratorOptionsValidator) {
        me.settings = settings;
        me.validator = validator;
    }

    function getMaxArgLength() {
        return validator.getMaxArgLength();
    }

    function getNumMax() as Integer {
        return settings.getNumMax();
    }

    function getRangeMin() as Integer {
        return settings.getRangeMin();
    }

    function getRangeMax() as Integer {
        return settings.getRangeMax();
    }

    function getNumFixedLen() as Integer {
        return settings.getNumFixedLen();
    }

    function getAlphanumLen() as Integer {
        return settings.getAlphanumLen();
    }

    function getHexLen() as Integer {
        return settings.getHexLen();
    }

    function saveNumMax(value as Integer) as Integer {
        return settings.saveNumMax(value);
    }

    function saveRangeMin(value as Integer) as Integer {
        return settings.saveRangeMin(value);
    }

    function saveRangeMax(value as Integer) as Integer {
        return settings.saveRangeMax(value);
    }

    function saveNumFixedLen(value as Integer) as Integer {
        return settings.saveNumFixedLen(value);
    }

    function saveAlphanumLen(value as Integer) as Integer {
        return settings.saveAlphanumLen(value);
    }

    function saveHexLen(value as Integer) as Integer {
        return settings.saveHexLen(value);
    }
}