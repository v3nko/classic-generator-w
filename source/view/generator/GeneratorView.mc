using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as System;
using Generator as Gen;
using Di;

class GeneratorView extends BaseView {

    // General positioning values

	private var centerX;
	private var centerY;

    private var resultView as GeneratorResultView;
    private var modeView as GeneratorModeView;
    private var buttonIndicatorDrawer as ButtonIndicatorDrawer;
    private var recentResultView as GeneratorRecentResultView;

    private var serviceLocator;

    private var generatorController as GeneratorController;

    private var timeFormatter;
    
    private const BUTTON_INDICATOR_WIDTH = 12;
    private const BUTTON_INDICATOR_THIKNESS = 4;
    private const BUTTON_INDICATOR_ANGLE_START = 30;
    private const BUTTON_INDICATOR_ANGLE_UP = 180;
    private const BUTTON_INDICATOR_ANGLE_DOWN = 210;

    function initialize(serviceLocator) {
		BaseView.initialize(serviceLocator.getViewLifecycleHandler());
        me.serviceLocator = serviceLocator;
        me.generatorController = serviceLocator.getGeneratorController();
        me.timeFormatter = serviceLocator.getDateTimeFormatter();
	}

    function onLayout(dc) {
        View.setLayout(Rez.Layouts.generator(dc));
		centerX = dc.getWidth() / 2;
		centerY = dc.getHeight() / 2;
        resultView = View.findDrawableById("generator_result");
        modeView = View.findDrawableById("generator_mode");
        buttonIndicatorDrawer = new ButtonIndicatorDrawer(centerX, centerY);
        recentResultView = View.findDrawableById("generator_recent_result");
        generatorController.loadSettings();
        generatorController.setOnHistoryUpdate(method(:onHistoryUpdate));

        updateMode(generatorController.getCurrentMode(), SlidableView.SLIDE_NONE);
    }

    function generateNewValue() {
        generatorController.generate()
            .onError(method(:handleGenerationError));
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
        var alert = new Alert(serviceLocator,  {:text => Application.loadResource(messageId)});
        alert.pushView();
    }

    function onUpdate(dc) {
        View.onUpdate(dc);
        drawButtonIndicators(dc);
    }
    
    function onShow() {
        BaseView.onShow();
        generatorController.loadHistory();
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
        modeView.pushMode(generatorMode, animation);
    }

    function handleModeSwitchError(arg) {
        var argText = "null";
        if (arg != null) {
            argText = arg.toString();
        }
        System.println("Unable to swtich generator mode: " + argText);

        var alert = new Alert(
            serviceLocator,
            { :text => Application.loadResource(Rez.Strings.error_mode_switch_general) }
        );
        alert.pushView();
    }

    function onHistoryUpdate(resultHistory) {
        if (resultHistory.size() > 0) {
            resultView.pushResult(resultHistory[0]);
            if (resultHistory.size() > 1) {
                recentResultView.pushRecentResult(resultHistory[1]);
            } else {
                recentResultView.pushRecentResult(null);
            }
        } else {
            generateNewValue();
        }
    }


    function navigateToMenu() {
        var menu = new Ui.Menu2({ :title => Rez.Strings.menu_title_results_history });
        var history = generatorController.getHistory();
        for (var i = 0; i < history.size(); i++) {
            var record = history[i];
            menu.addItem(
                new Ui.MenuItem(
                    Lang.format("$1$ | $2$", [resolveTextIndicator(record.type), record.data]),
                    timeFormatter.formatDateTimeNumeric(record.time),
                    null,
                    null
                )
            );
        }
        BaseView.showMenu(menu, new HistoryMenuInputdelegate(serviceLocator), Ui.SLIDE_IMMEDIATE);
        return true;
    }

    private function resolveTextIndicator(generatorMode as Gen.GeneratorType) {
        var indicator;
        switch (generatorMode) {
            case Gen.GENERATOR_NUM:
                indicator = Rez.Strings.gen_title_num_short;
                break;
            case Gen.GENERATOR_RANGE:
                indicator = Rez.Strings.gen_title_num_range_short;
                break;
            case Gen.GENERATOR_NUM_FIXED:
                indicator = Rez.Strings.gen_title_num_fixed_short;
                break;
            case Gen.GENERATOR_ALPHANUM:
                indicator = Rez.Strings.gen_title_alphanum_short;
                break;
            case Gen.GENARATOR_HEX:
                indicator = Rez.Strings.gen_title_hex_short;
                break;
            default:
                indicator = Rez.Strings.gen_title_unknown_short;
        }
        return Application.loadResource(indicator);
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
