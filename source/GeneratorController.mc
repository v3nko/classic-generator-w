class GeneratorController {
    
    private var generator;

    private var currentMode as GeneratorType;

    function initialize(generator as Generator) {
        me.generator = generator;
    }

    function loadSettings() {
        currentMode = GENERATOR_NUM_FIXED;
    }

    function generate() as Result<String> {
        // TODO: use loaded settings for generator options
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
        return new Success(currentMode);
    }
    
    function switchToPreviousMode() as Result {
        currentMode--;
        if (currentMode < 0) {
            currentMode = GENERATOR_TYPES_COUNT - 1;
        }
        return new Success(currentMode);
    }

    function getCurrentMode() as GeneratorType {
        return currentMode;
    }
}

class UnsupportedGenearatorType {

}
