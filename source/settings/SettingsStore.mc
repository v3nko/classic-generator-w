using Toybox.Application.Storage as Storage;
using Toybox.Application.Properties as Properties;

class SettingsStore {

    private static const KEY_STARTUP_GEN = "startup_gen";
    private static const KEY_GENERATOR_MODE = "generator_mode";
    private static const KEY_NUM_MAX = "num_max";
    private static const KEY_RANGE_MIN = "range_min";
    private static const KEY_RANGE_MAX = "range_max";
    private static const KEY_NUM_FIXED_LEN = "num_fixed_len";
    private static const KEY_ALPHANUM_LEN = "alphanum_len";
    private static const KEY_HEX_LEN = "hex_len";

    function getStartupGen() as Boolean {
        return Properties.getValue(KEY_STARTUP_GEN);
    }

    function saveStartupGen(value as Boolean) {
        Properties.setValue(KEY_STARTUP_GEN, value);
    }

    function getGeneratorMode() as Number {
        return Storage.getValue(KEY_GENERATOR_MODE);
    }

    function saveGeneratorMode(value as Number) {
        Storage.setValue(KEY_GENERATOR_MODE, value);
    }

    function getNumMax() as Number {
        return Properties.getValue(KEY_NUM_MAX);
    }

    function getRangeMin() as Number {
        return Properties.getValue(KEY_RANGE_MIN);
    }

    function getRangeMax() as Number {
        return Properties.getValue(KEY_RANGE_MAX);
    }

    function getNumFixedLen() as Number {
        return Properties.getValue(KEY_NUM_FIXED_LEN);
    }

    function getAlphanumLen() as Number {
        return Properties.getValue(KEY_ALPHANUM_LEN);
    }

    function getHexLen() as Number {
        return Properties.getValue(KEY_HEX_LEN);
    }

    function saveNumMax(value as Number) as Number {
        return Properties.setValue(KEY_NUM_MAX, value);
    }

    function saveRangeMin(value as Number) as Number {
        return Properties.setValue(KEY_RANGE_MIN, value);
    }

    function saveRangeMax(value as Number) as Number {
        return Properties.setValue(KEY_RANGE_MAX, value);
    }

    function saveNumFixedLen(value as Number) as Number {
        return Properties.setValue(KEY_NUM_FIXED_LEN, value);
    }

    function saveAlphanumLen(value as Number) as Number {
        return Properties.setValue(KEY_ALPHANUM_LEN, value);
    }

    function saveHexLen(value as Number) as Number {
        return Properties.setValue(KEY_HEX_LEN, value);
    }
}
