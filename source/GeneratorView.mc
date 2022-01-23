using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as System;
using Toybox.Timer;
using Generator as Gen;

class GeneratorView extends Ui.View {

    // General positioning values

	private var centerX;
	private var centerY;

    private var generatorResultView as GeneratorResultView;
    private var generatorModeView as GeneratorModeView;

    private var generatorController as GeneratorController;
    
    private const MODE_POSITION_FACTOR = 0.16;

    function initialize() {
		View.initialize();
	}

    function onLayout(dc) {
		centerX = dc.getWidth() / 2;
		centerY = dc.getHeight() / 2;
        generatorResultView = new GeneratorResultView(centerX, centerY);
        var modePositionY = dc.getHeight() * MODE_POSITION_FACTOR;
        generatorModeView = new GeneratorModeView(centerX, modePositionY);

        var generator = new Gen.RandomGenerator(new GeneratorOptionsValidator());
        generatorController = new GeneratorController(generator, new SettingsStore());
        generatorController.loadSettings();

        updateMode(generatorController.getCurrentMode(), SlideableView.SLIDE_NONE);

        generateNewValue();
    }

    function generateNewValue() {
        generatorController.generate()
            .onSuccess(method(:updateResult))
            .onError(method(:handleGenerationError));
    }

    function updateResult(result) {
        generatorResultView.pushNewResult(result);
    }

    function handleGenerationError(arg) {
        generatorResultView.shake();
        if (arg instanceof Gen.InvalidArgumentError) {
            System.println("Generator error occured: " + arg.reason);
        } else {
            System.println("Unknown generator error occured");
        }
    }

    function onUpdate(dc) {
        dc.setColor(Gfx.COLOR_TRANSPARENT, Gfx.COLOR_BLACK);
        dc.clear();
        generatorResultView.onUpdate(dc);
        generatorModeView.onUpdate(dc);
    }

    function switchToPreviousMode() {
        generatorController.switchToPreviousMode()
            .onSuccess(method(:updateModePrevious))
            .onError(method(:handleModeSwitchError));
    }

    function switchToNextMode() {
        generatorController.switchToNextMode()
            .onSuccess(method(:updateModeNext))
            .onError(method(:handleModeSwitchError));
    }

    function updateModeNext(generatorMode as Gen.GeneratorType) {
        updateMode(generatorMode, SlideableView.SLIDE_UP);
    }

    function updateModePrevious(generatorMode as Gen.GeneratorType) {
        updateMode(generatorMode, SlideableView.SLIDE_DOWN);
    }

    private function updateMode(generatorMode as Gen.GeneratorType, animation as PushAnimation) {
        generatorModeView.pushNewMode(generatorMode, animation);
    }

    function handleModeSwitchError(arg) {
        generatorModeView.shake();
        var argText = "null";
        if (arg != null) {
            argText = arg.toString();
        }
        System.println("Unable to swtich generator mode: " + argText);
    }

	function onShow() {
        // no-op
	}

    function onHide() {
        // no-op
	}
}
