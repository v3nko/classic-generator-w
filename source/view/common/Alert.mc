using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;
using Toybox.Timer as Timer;

class AlertDelegate extends Ui.InputDelegate {
    hidden var view;

    function initialize(view) {
        InputDelegate.initialize();
        self.view = view;
    }

    function onKey(evt) {
        switch(evt.getKey()) {
            case Ui.KEY_UP:
                view.scrollUp();
                break;
            case Ui.KEY_DOWN:
                view.scrollDown();
                break;
            default:
                view.dismiss();
        }
        return true;
    }

    function onTap(evt) {
        view.dismiss();
        return true;
    }
}

class Alert extends Ui.View {
    
    private const TEXT_DEFAULT = "Something went wrong";
    private const FONT_DEFAULT = Gfx.FONT_SYSTEM_TINY;
    private const TIMEOUT_DEFAULT = 5800;
    private const TEXT_COLOR_DEFAULT = Gfx.COLOR_WHITE;
    private const BG_COLOR_DEFAULT = Gfx.COLOR_BLACK;
    private const STROKE_COLOR_DEFAULT = TEXT_COLOR_DEFAULT;
    private const VERTICAL_OFFSET_PERCENT = 0.12;
    private const PADDING_BOTTOM = 10;

    hidden var paddingTop;

    hidden var timer;
    hidden var timeout;
    hidden var text;
    hidden var font;
    hidden var textColor;
    hidden var backgroundColor;
    hidden var strokeColor;

    hidden var textArea;

    hidden var width;
    hidden var height;

    function initialize(params) {
        View.initialize();

        text = params.get(:text);
        if (text == null) {
            text = TEXT_DEFAULT;
        }

        font = params.get(:font);
        if (font == null) {
            font = FONT_DEFAULT;
        }

        textColor = params.get(:textColor);
        if (textColor == null) {
            textColor = TEXT_COLOR_DEFAULT;
        }

        backgroundColor = params.get(:backgroundColor);
        if (backgroundColor == null) {
            backgroundColor = BG_COLOR_DEFAULT;
        }

        strokeColor = params.get(:strokeColor);
        if (strokeColor == null) {
            strokeColor = STROKE_COLOR_DEFAULT;
        }

        timeout = params.get(:timeout);
        if (timeout == null) {
            timeout = TIMEOUT_DEFAULT;
            timer = new Timer.Timer();
        }
    }

    function onShow() {
        // timer.start(method(:scrollOrDismiss), timeout, false);
    }

    function onHide() {
        timer.stop();
        textArea.reset();
    }

    function onLayout(dc) {
        paddingTop = dc.getHeight() * VERTICAL_OFFSET_PERCENT;

        textArea = new WrapText(
            {
                :backgroundColor => backgroundColor,
                :textColor => textColor,
                :paddingTop => paddingTop,
                :paddingBottom => PADDING_BOTTOM,
                :font => font
            }
        );
        textArea.setLocation(0, 0);
        textArea.setText(text);
        var settings = System.getDeviceSettings();
		me.width = settings.screenWidth;
		me.height = settings.screenHeight;
        textArea.width = me.width;
    }

    function scrollOrDismiss() {
        // TODO: dismiss if nothing to scroll or schedule dismiss after scrolling
        textArea.requestAutoScroll();
    }

    function onUpdate(dc) {
        textArea.draw(dc);
        var textHeight = textArea.height;

        // Draw bottom border line
        dc.setColor(strokeColor, backgroundColor);
        dc.setPenWidth(1);
        dc.drawLine(0, textHeight, width, textHeight);
    }

    function dismiss() {
        Ui.popView(Ui.SLIDE_UP);
    }

    function pushView() {
        Ui.pushView(self, new AlertDelegate(self), Ui.SLIDE_DOWN);
    }

    public function scrollDown() {
        textArea.scrollDown();
	}

	public function scrollUp() {
		textArea.scrollUp();
	}
}
