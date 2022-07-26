using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as System;
using Generator as Gen;

class GeneratorView extends BaseView {

    // General positioning values

	private var centerX;
	private var centerY;

    private var generatorResultView as GeneratorResultView;
    private var generatorModeView as GeneratorModeView;
    private var buttonIndicatorDrawer as ButtonIndicatorDrawer;
    private var recentResultView as GeneratorRecentResultView;

    private var generatorController as GeneratorController;
    
    private const BUTTON_INDICATOR_WIDTH = 12;
    private const BUTTON_INDICATOR_THIKNESS = 4;
    private const BUTTON_INDICATOR_ANGLE_START = 30;
    private const BUTTON_INDICATOR_ANGLE_UP = 180;
    private const BUTTON_INDICATOR_ANGLE_DOWN = 210;

    function initialize(generatorController, lifecycleHandler) {
		BaseView.initialize(lifecycleHandler);
        me.generatorController = generatorController;
	}

    function onLayout(dc) {
        View.setLayout(Rez.Layouts.generator(dc));
		centerX = dc.getWidth() / 2;
		centerY = dc.getHeight() / 2;
        generatorResultView = View.findDrawableById("generator_result");
        generatorModeView = View.findDrawableById("generator_mode");
        buttonIndicatorDrawer = new ButtonIndicatorDrawer(centerX, centerY);
        recentResultView = View.findDrawableById("generator_recent_result");
        generatorController.loadSettings();
        generatorController.setOnRecentResultUpdate(method(:onRecentResultUpdate));

        updateMode(generatorController.getCurrentMode(), SlidableView.SLIDE_NONE);

        generateNewValue();
    }

    function generateNewValue() {
        generatorController.generate()
            .onSuccess(method(:updateResult))
            .onError(method(:handleGenerationError));
    }

    function updateResult(result) {
        generatorResultView.pushResult(result);
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
        var alert = new Alert(lifecycleHandler,  {:text => Application.loadResource(messageId)});
        alert.pushView();
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
        generatorModeView.pushMode(generatorMode, animation);
    }

    function handleModeSwitchError(arg) {
        var argText = "null";
        if (arg != null) {
            argText = arg.toString();
        }
        System.println("Unable to swtich generator mode: " + argText);

        var alert = new Alert(
            lifecycleHandler,
            {:text => Application.loadResource(Rez.Strings.error_mode_switch_general)}
        );
        alert.pushView();
    }

    function onRecentResultUpdate(result) {
        System.println("Recent result update: " + result);
        if (result != null) {
            recentResultView.pushRecentResult(result.type, result.time, result.data);
        }
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
