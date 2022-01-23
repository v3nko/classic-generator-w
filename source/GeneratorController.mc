using Generator as Gen;

class GeneratorController {

    private var generator;
    private var generatorMode as GeneratorMode;
    private var settings;

    function initialize(generator as Gen.Generator, settings as SettingsStore) {
        me.generator = generator;
        generatorMode = new GeneratorMode();
        me.settings = settings;
    }

    function loadSettings() {
        generatorMode.setCurrentMode(settings.getGeneratorMode());
    }

    function generate() as Result<String> {
        switch (generatorMode.getCurrentMode()) {
            case Gen.GENERATOR_NUM:
                return generator.generateNum(5);
            case Gen.GENERATOR_RANGE:
                return generator.generateRange(99, 195);
            case Gen.GENERATOR_NUM_FIXED:
                return generator.generateNumFixed(5);
            case Gen.GENERATOR_ALPHANUM:
                return generator.generateAlphanum(1);
            case Gen.GENARATOR_HEX:
                return generator.generateHex(1);
            default:
                return new Error(new UnsupportedGeneratorType());
        }
    }

    function switchToNextMode() as Result {
        var newMode = generatorMode.switchToNextMode();
        settings.saveGeneratorMode(newMode);
        return new Success(newMode);
    }
    
    function switchToPreviousMode() as Result {
        var newMode = generatorMode.switchToPreviousMode();
        settings.saveGeneratorMode(newMode);
        return new Success(newMode);
    }

    function getCurrentMode() as Gen.GeneratorType {
        return generatorMode.getCurrentMode();
    }
    
    class GeneratorMode {
        private const DEFAULT_GENERATOR_MODE = Gen.GENERATOR_NUM_FIXED;
        private var generatorModes = [
           Gen.GENERATOR_NUM,
           Gen.GENERATOR_RANGE,
           Gen.GENERATOR_NUM_FIXED,
           Gen.GENERATOR_ALPHANUM,
           Gen.GENARATOR_HEX
        ];
        private var currentMode as Gen.GeneratorType;
        private var currentModeIndex as Integer;

        function getCurrentMode() as GeneratorType {
            ensureModeSet();
            return currentMode;
        }

        private function ensureModeSet() {
            if (currentMode == null || currentModeIndex == null) {
                setCurrentMode(DEFAULT_GENERATOR_MODE);
            }
        }

        function setCurrentMode(mode as Gen.GeneratorType) {
            var modeIndex = generatorModes.indexOf(mode);
            if (modeIndex != -1) {
                currentMode = mode;
                currentModeIndex = modeIndex;
            } else {
                currentMode = DEFAULT_GENERATOR_MODE;
                currentModeIndex = generatorModes.indexOf(currentMode);
            }
        }

        function switchToNextMode() as Gen.GeneratorType {
            ensureModeSet();
            currentModeIndex++;
            if (currentModeIndex >= generatorModes.size()) {
                currentModeIndex = 0;
            }
            currentMode = generatorModes[currentModeIndex];
            return currentMode;
        }

        function switchToPreviousMode() as Gen.GeneratorType {
            ensureModeSet();
            currentModeIndex--;
            if (currentModeIndex < 0) {
                currentModeIndex = generatorModes.size() - 1;
            }
            currentMode = generatorModes[currentModeIndex];
            return currentMode;
        }
    }
}

class UnsupportedGeneratorType { }
