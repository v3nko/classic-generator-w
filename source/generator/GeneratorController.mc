using Generator as Gen;
using Toybox.Time;

class GeneratorController {

    private var generator;
    private var generatorMode as GeneratorMode;
    private var settings;
    private var generatorStore;

    // Consumer-configured fields
    private var recentResultCallback = null;

    function initialize(
        generator as Gen.Generator, 
        settings as SettingsStore, 
        generatorStore as GeneratorStore
    ) {
        me.generator = generator;
        generatorMode = new GeneratorMode();
        me.settings = settings;
        me.generatorStore = generatorStore;
    }

    function loadSettings() {
        generatorMode.setCurrentMode(settings.getGeneratorMode());
    }

    function generate() as Result<String> {
        var result;
        var mode = generatorMode.getCurrentMode();
        switch (mode) {
            case Gen.GENERATOR_NUM:
                result = generator.generateNum(settings.getNumMax());
                break;
            case Gen.GENERATOR_RANGE:
                result = generator.generateRange(settings.getRangeMin(), settings.getRangeMax());
                break;
            case Gen.GENERATOR_NUM_FIXED:
                result = generator.generateNumFixed(settings.getNumFixedLen());
                break;
            case Gen.GENERATOR_ALPHANUM:
                result = generator.generateAlphanum(settings.getAlphanumLen());
                break;
            case Gen.GENARATOR_HEX:
                result = generator.generateHex(settings.getHexLen());
                break;
            default:
                result = new Error(new UnsupportedGeneratorType());
        }
        if (result instanceof Success) {
            generatorStore.appenHistoryRecord(result.data, mode, Time.now().value());

            if (recentResultCallback != null) {
                var history = generatorStore.getGeneratorHistory();
                var recentResult = null;
                if (history.size() >= 2) {
                    recentResult = generatorStore.parseHistoryRecord(history[history.size() - 2]);
                }
                recentResultCallback.invoke(recentResult);
            }
        }
        return result;
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

    function setOnRecentResultUpdate(callback as Method(result)) {
        recentResultCallback = callback;
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
