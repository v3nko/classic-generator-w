class GeneratorController {

    private static const DEFAULT_GENERATOR_MODE = GENERATOR_NUM_FIXED;
    
    private var generator;
    private var settings;

    private var currentMode as GeneratorType;

    function initialize(generator as Generator, settings as SettingsStore) {
        me.generator = generator;
        me.settings = settings;
    }

    function loadSettings() {
        currentMode = settings.getGeneratorMode();
        if (currentMode == null) {
            currentMode = DEFAULT_GENERATOR_MODE;
        }
    }

    function generate() as Result<String> {
        switch (currentMode) {
            case GENERATOR_NUM:
                return generator.generateNum(5);
            case GENERATOR_RANGE:
                return generator.generateRange(99, 195);
            case GENERATOR_NUM_FIXED:
                return generator.generateNumFixed(5);
            case GENERATOR_ALPHANUM:
                return generator.generateAlphanum(1);
            case GENARATOR_HEX:
                return generator.generateHex(1);
            default:
                return new Error(new UnsupportedGenearatorType());
        }
    }

    function switchToNextMode() as Result {
        currentMode++;
        if (currentMode >= GENERATOR_TYPES_COUNT) {
            currentMode = 0;
        }
        settings.saveGeneratorMode(currentMode);
        return new Success(currentMode);
    }
    
    function switchToPreviousMode() as Result {
        currentMode--;
        if (currentMode < 0) {
            currentMode = GENERATOR_TYPES_COUNT - 1;
        }
        settings.saveGeneratorMode(currentMode);
        return new Success(currentMode);
    }

    function getCurrentMode() as GeneratorType {
        return currentMode;
    }
}

class UnsupportedGenearatorType {

}
