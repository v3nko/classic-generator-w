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

    function initialize() {
		View.initialize();
	}

    function onLayout(dc) {
		centerX = dc.getWidth() / 2;
		centerY = dc.getHeight() / 2;
        generatorResultView = new GeneratorResultView(centerX, centerY);
        var modePositionY = dc.getHeight() * 0.25;
        generatorModeView = new GeneratorModeView(centerX, modePositionY);
        generateNewValue();
    }

    function generateNewValue() {
        generatorResultView.pushNewResult((Math.rand() % 100).toString());
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
