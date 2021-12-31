using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

class GeneratorModeView extends SlideableView {

    private const MODE_TITLE_FONT = Gfx.FONT_TINY;

    private var modeTitleHeight;

    function initialize(centerX, centerY) {
        SlideableView.initialize(centerX, centerY);
        modeTitleHeight = Gfx.getFontHeight(MODE_TITLE_FONT);
    }
    
    // TODO: pass generator mode
    function pushNewMode() {
        pushNewDrawable(
            new Ui.Text(
                {
                    :text => "Fixed numeric",
                    :font => MODE_TITLE_FONT,
                    :locX => WatchUi.LAYOUT_HALIGN_CENTER,
                    :locY => WatchUi.LAYOUT_VALIGN_CENTER,
                    :justification => Gfx.TEXT_JUSTIFY_CENTER,
                    :height => modeTitleHeight
                }
            )
        );
    }
}
