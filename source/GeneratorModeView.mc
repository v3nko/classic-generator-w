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
        var textIndicator = new Ui.Text(
            {
                :text => Application.loadResource(Rez.Strings.gen_title_alphanum),
                :font => MODE_TITLE_FONT,
                :locX => WatchUi.LAYOUT_HALIGN_CENTER,
                :locY => WatchUi.LAYOUT_VALIGN_CENTER,
                :justification => Gfx.TEXT_JUSTIFY_CENTER,
                :height => modeTitleHeight
            }
        );

        var iconIndicator = Application.loadResource(Rez.Drawables.ic_alphanum);

        var indicatorGroup = new IndicatorDrawable();
        indicatorGroup.setIndicators(textIndicator, iconIndicator);
    
        pushNewDrawable(indicatorGroup);
    }

    class IndicatorDrawable extends Ui.Drawable {

        private var indicatorIcon as Drawable = null;
        private var indicatorText as Ui.BitmapResource = null;
        private var spacing = 2;
        private var padding = 5;

        function initialize() {
            Drawable.initialize({});
        }

        function draw(dc) {
            indicatorText.setLocation(
                me.locX,
                me.locY + indicatorIcon.getHeight() + spacing + padding
            );
            indicatorText.draw(dc);
            dc.drawBitmap(me.locX - indicatorIcon.getWidth() / 2, me.locY + padding, indicatorIcon);
        }

        function setColor(color) {
            indicatorText.setColor(color);
        }
        
        function setIndicators(text as Drawable, icon as Ui.BitmapResource) {
            indicatorText = text;
            indicatorIcon = icon;
            setSize(
                width,
                indicatorText.height + indicatorIcon.getHeight() + spacing + (padding * 2)
            );
        }
    }
}
