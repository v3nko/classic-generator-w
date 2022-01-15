using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as System;
using Toybox.Timer;

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

        var generator = new RandomGenerator(new GeneratorOptionsValidator());
        generatorController = new GeneratorController(generator);
        generatorController.loadSettings();

        updateMode(generatorController.getCurrentMode());

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
        if (arg instanceof InvalidArgumentError) {
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
            .onSuccess(method(:updateMode))
            .onError(method(:handleModeSwitchError));
    }

    function switchToNextMode() {
        generatorController.switchToNextMode()
            .onSuccess(method(:updateMode))
            .onError(method(:handleModeSwitchError));
    }

    function updateMode(generatorMode as GeneratorType) {
        generatorModeView.pushNewMode(generatorMode);
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
