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
    private const FG_COLOR_DEFAULT = Gfx.COLOR_WHITE;
    private const BG_COLOR_DEFAULT = Gfx.COLOR_BLACK;
    private const VERTICAL_OFFSET = 35;
    private const BOTTOM_PADDING = 10;

    hidden var timer;
    hidden var timeout;
    hidden var text;
    hidden var font;
    hidden var fgcolor;
    hidden var bgcolor;

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

        fgcolor = params.get(:fgcolor);
        if (fgcolor == null) {
            fgcolor = FG_COLOR_DEFAULT;
        }

        bgcolor = params.get(:bgcolor);
        if (bgcolor == null) {
            bgcolor = BG_COLOR_DEFAULT;
        }

        timeout = params.get(:timeout);
        if (timeout == null) {
            timeout = TIMEOUT_DEFAULT;
        }

        timer = new Timer.Timer();
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
    }

    function onUpdate(dc) {
        var msgDc = msgLayer.getDc();
        msgDc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        var posY = textArea.writeLines(msgDc, text, font, VERTICAL_OFFSET);
        var settings = System.getDeviceSettings();
		var screenWidth = settings.screenWidth;
		var screenHeight = settings.screenHeight;

        var bgDc = bgLayer.getDc();
        var alertHeight = posY + BOTTOM_PADDING;
        bgDc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        bgDc.setPenWidth(1);
        bgDc.drawLine(0, alertHeight, screenWidth, alertHeight);
        bgDc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        bgDc.fillRectangle(0, 0, screenWidth, alertHeight);
    }

    function dismiss() {
        Ui.popView(SLIDE_IMMEDIATE);
    }

    function pushView(transition) {
        Ui.pushView(self, new AlertDelegate(self), transition);
    }
}
