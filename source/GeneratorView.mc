using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as System;
using Toybox.Timer;

class GeneratorView extends Ui.View {

    // General positioning values

	private var centerX;
	private var centerY;

    private var generatorResultView;

    function initialize() {
		View.initialize();
	}

    function onLayout(dc) {
		centerX = dc.getWidth() / 2;
		centerY = dc.getHeight() / 2;
        generatorResultView = new GeneratorResultView(centerX, centerY);
        generateNewValue();
    }

    function generateNewValue() {
        generatorResultView.pushNewResult(Math.rand() % 100);
    }

    function onUpdate(dc) {
        dc.setColor(Gfx.COLOR_TRANSPARENT, Gfx.COLOR_BLACK);
        dc.clear();
        generatorResultView.onUpdate(dc);
    }

	function onShow() {
        // no-op
	}

    function onHide() {
        // no-op
	}

    class GeneratorDelegate extends Ui.BehaviorDelegate {

        var generatorView;

        function initialize(view) {
            generatorView = view;
            Ui.BehaviorDelegate.initialize();
        }

        function onKey(keyEvent) {
            if (keyEvent.getKey() == Ui.KEY_ENTER) {
                generatorView.generateNewValue();
                Ui.requestUpdate();
            }
        }
    }
}