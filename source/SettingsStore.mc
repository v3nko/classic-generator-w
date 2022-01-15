using Toybox.Application.Storage as Storage;

class SettingsStore {

    private static const KEY_GENERATOR_MODE = "generator_mode";

    function getGeneratorMode() as Integer {
        return Storage.getValue(KEY_GENERATOR_MODE);
    }

    function saveGeneratorMode(value as Integer) {
        Storage.setValue(KEY_GENERATOR_MODE, value);
    }
}
