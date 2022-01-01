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

    private var generator as Generator;

    function initialize() {
		View.initialize();
	}

    function onLayout(dc) {
		centerX = dc.getWidth() / 2;
		centerY = dc.getHeight() / 2;
        generatorResultView = new GeneratorResultView(centerX, centerY);
        var modePositionY = dc.getHeight() * 0.25;
        generatorModeView = new GeneratorModeView(centerX, modePositionY);

        generator = new RandomGenerator(new GeneratorOptionsValidator());

        generateNewValue();
    }

    function generateNewValue() {
        generator.generateHex(6)
            .onSuccess(method(:updateResult))
            .onError(method(:handleError));
    }

    function updateResult(result) {
        generatorResultView.pushNewResult(result);
    }

    function handleError(arg) {
        // TODO: indicate error on UI
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

    function switchMode() {
        // TODO: switch actual generator mode
        generatorModeView.pushNewMode();
    }

	function onShow() {
        // no-op
	}

    function onHide() {
        // no-op
	}
}
