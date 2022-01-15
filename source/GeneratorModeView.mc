using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

class GeneratorModeView extends SlideableView {

    private const MODE_TITLE_FONT = Gfx.FONT_TINY;

    private var modeTitleHeight;

    function initialize(centerX, centerY) {
        SlideableView.initialize(centerX, centerY);
        modeTitleHeight = Gfx.getFontHeight(MODE_TITLE_FONT);
    }
    
    function pushNewMode(generatorMode as GeneratorType, animation as PushAimation) {
        var textIndicator = new Ui.Text(
            {
                :text => resolveTitle(generatorMode),
                :font => MODE_TITLE_FONT,
                :locX => WatchUi.LAYOUT_HALIGN_CENTER,
                :locY => WatchUi.LAYOUT_VALIGN_CENTER,
                :justification => Gfx.TEXT_JUSTIFY_CENTER,
                :height => modeTitleHeight
            }
        );

        var iconIndicator = resolveIndicator(generatorMode);

        var indicatorGroup = new IndicatorDrawable();
        indicatorGroup.setIndicators(textIndicator, iconIndicator);
    
        pushNewDrawable(indicatorGroup, animation);
    }

    private function resolveIndicator(generatorMode as GeneratorType) {
        var resource;
        switch (generatorMode) {
            case GENERATOR_NUM:
                resource = Rez.Drawables.ic_num;
                break;
            case GENERATOR_RANGE:
                resource = Rez.Drawables.ic_range;
                break;
            case GENERATOR_NUM_FIXED:
                resource = Rez.Drawables.ic_num_fixed;
                break;
            case GENERATOR_ALPHANUM:
                resource = Rez.Drawables.ic_alphanum;
                break;
            case GENARATOR_HEX:
                resource = Rez.Drawables.ic_hex;
                break;
            default:
                resource = null;
        }
        if (resource != null) {
            return Application.loadResource(resource);
        } else {
            return null;
        }
    }

    private function resolveTitle(generatorMode as GeneratorType) {
        var resource;
        switch (generatorMode) {
            case GENERATOR_NUM:
                resource = Rez.Strings.gen_title_num;
                break;
            case GENERATOR_RANGE:
                resource = Rez.Strings.gen_title_num_range;
                break;
            case GENERATOR_NUM_FIXED:
                resource = Rez.Strings.gen_title_num_fixed;
                break;
            case GENERATOR_ALPHANUM:
                resource = Rez.Strings.gen_title_alphanum;
                break;
            case GENARATOR_HEX:
                resource = Rez.Strings.gen_title_hex;
                break;
            default:
                resource = null;
        }
        if (resource != null) {
            return Application.loadResource(resource);
        } else {
            return null;
        }
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
