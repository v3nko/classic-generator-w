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
    private var buttonIndicatorDrawer as ButtonIndicatorDrawer;

    private var generatorController as GeneratorController;
    
    private const BUTTON_INDICATOR_WIDTH = 12;
    private const BUTTON_INDICATOR_THIKNESS = 4;
    private const BUTTON_INDICATOR_ANGLE_START = 30;
    private const BUTTON_INDICATOR_ANGLE_UP = 180;
    private const BUTTON_INDICATOR_ANGLE_DOWN = 210;

    function initialize(generatorController) {
		View.initialize();
        me.generatorController = generatorController;
	}

    function onLayout(dc) {
        View.setLayout(Rez.Layouts.generator(dc));
		centerX = dc.getWidth() / 2;
		centerY = dc.getHeight() / 2;
        generatorResultView = View.findDrawableById("generator_result");
        generatorModeView = View.findDrawableById("generator_mode");
        buttonIndicatorDrawer = new ButtonIndicatorDrawer(centerX, centerY);
        generatorController.loadSettings();

        updateMode(generatorController.getCurrentMode(), SlidableView.SLIDE_NONE);

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
        var messageId;
        if (arg instanceof Gen.InvalidArgumentError) {
            System.println("Generator error occured: " + arg.reason);
            messageId = Rez.Strings.error_invalid_generator_arguments;
        } else {
            System.println("Unknown generator error occured");
            messageId = Rez.Strings.error_generator_general;
        }
        var alert = new Alert({:text => Application.loadResource(messageId)});
        alert.pushView(Ui.SLIDE_IMMEDIATE);
    }

    function onUpdate(dc) {
        View.onUpdate(dc);
        drawButtonIndicators(dc);
    }

    private function drawButtonIndicators(dc) {
        buttonIndicatorDrawer.drawIndicator(
            dc,
            BUTTON_INDICATOR_ANGLE_START,
            Gfx.COLOR_YELLOW,
            BUTTON_INDICATOR_THIKNESS,
            BUTTON_INDICATOR_WIDTH
        );
        buttonIndicatorDrawer.drawIndicator(
            dc,
            BUTTON_INDICATOR_ANGLE_UP,
            Gfx.COLOR_WHITE,
            BUTTON_INDICATOR_THIKNESS,
            BUTTON_INDICATOR_WIDTH
        );
        buttonIndicatorDrawer.drawIndicator(
            dc,
            BUTTON_INDICATOR_ANGLE_DOWN,
            Gfx.COLOR_WHITE,
            BUTTON_INDICATOR_THIKNESS,
            BUTTON_INDICATOR_WIDTH
        );
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
        updateMode(generatorMode, SlidableView.SLIDE_UP);
    }

    function updateModePrevious(generatorMode as Gen.GeneratorType) {
        updateMode(generatorMode, SlidableView.SLIDE_DOWN);
    }

    private function updateMode(generatorMode as Gen.GeneratorType, animation as PushAnimation) {
        generatorModeView.pushNewMode(generatorMode, animation);
    }

    function handleModeSwitchError(arg) {
        var argText = "null";
        if (arg != null) {
            argText = arg.toString();
        }
        System.println("Unable to swtich generator mode: " + argText);

        var alert = new Alert(
            {:text => Application.loadResource(Rez.Strings.error_mode_switch_general)}
        );
        alert.pushView(Ui.SLIDE_IMMEDIATE);
    }

	function onShow() {
        // no-op
	}

    function onHide() {
        // no-op
	}

    class ButtonIndicatorDrawer {
        private var centerX;
	    private var centerY;

        function initialize(centerX, centerY) {
            me.centerX = centerX;
            me.centerY = centerY;
        }

        function drawIndicator(dc, angle, color, thikness, width) {
            dc.setColor(color, Gfx.COLOR_BLACK);
            dc.setPenWidth(thikness);
            var halfWidth = width / 2;
            dc.drawArc(
                centerX,
                centerY,
                (dc.getWidth() / 2) - thikness,
                Gfx.ARC_COUNTER_CLOCKWISE,
                angle - halfWidth,
                angle + halfWidth
            );
        }
    }
}
