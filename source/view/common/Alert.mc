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
        view.dismiss();
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
    private const TIMEOUT_DEFAULT = 2000;
    private const TEXT_COLOR_DEFAULT = Gfx.COLOR_WHITE;
    private const BG_COLOR_DEFAULT = Gfx.COLOR_BLACK;
    private const STROKE_COLOR_DEFAULT = TEXT_COLOR_DEFAULT;
    private const VERTICAL_OFFSET_PERCENT = 0.12;
    private const BOTTOM_PADDING = 10;

    private var verticalOffset;

    hidden var timer;
    hidden var timeout;
    hidden var text;
    hidden var font;
    hidden var textColor;
    hidden var backgroundColor;
    hidden var strokeColor;

    hidden var textArea;

    hidden var bgLayer;
    hidden var msgLayer;

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
        timer.start(method(:dismiss), timeout, false);
    }

    function onHide() {
        timer.stop();
    }

    function onLayout(dc) {
        bgLayer = new Ui.Layer({});
        addLayer(bgLayer);
        msgLayer = new Ui.Layer({});
        addLayer(msgLayer);
        textArea = new WrapText();

        verticalOffset = dc.getHeight() * VERTICAL_OFFSET_PERCENT;
    }

    function onUpdate(dc) {
        var msgDc = msgLayer.getDc();
        msgDc.setColor(textColor, backgroundColor);
        var posY = textArea.writeLines(msgDc, text, font, verticalOffset);
        var settings = System.getDeviceSettings();
		var screenWidth = settings.screenWidth;
		var screenHeight = settings.screenHeight;

        var bgDc = bgLayer.getDc();
        var alertHeight = posY + BOTTOM_PADDING;
        bgDc.setColor(strokeColor, Graphics.COLOR_TRANSPARENT);
        bgDc.setPenWidth(1);
        bgDc.drawLine(0, alertHeight, screenWidth, alertHeight);
        bgDc.setColor(backgroundColor, Graphics.COLOR_TRANSPARENT);
        bgDc.fillRectangle(0, 0, screenWidth, alertHeight);
    }

    function dismiss() {
        Ui.popView(SLIDE_IMMEDIATE);
    }

    function pushView(transition) {
        Ui.pushView(self, new AlertDelegate(self), transition);
    }
}
