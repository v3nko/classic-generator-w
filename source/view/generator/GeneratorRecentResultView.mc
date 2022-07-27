using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Generator as Gen;
using Mathx;

class GeneratorRecentResultView extends SlidableView {
    
    private const RESULT_FONT = Gfx.FONT_TINY;
    private const TIME_FONT = Gfx.FONT_XTINY;

    private var dateTimeFormatter;

    private var resultHeight;
    private var timeHeight;

    function initialize(params as Dictionary) {
        var horizontalBias = params.get(:horizontalBias);
        var verticalBias = params.get(:verticalBias);
        var width = System.getDeviceSettings().screenWidth;
        var height = System.getDeviceSettings().screenHeight;
        SlidableView.initialize(
            params.get(:identifier),
            width * horizontalBias,
            height * verticalBias
        );
        resultHeight = Gfx.getFontHeight(RESULT_FONT);
        timeHeight = Gfx.getFontHeight(TIME_FONT);
        dateTimeFormatter = Di.provideServiceRegistry().getDateTimeFormatter();
    }

    function pushRecentResult(result as GeneratorResult) {
        if (result != null) {
            var resultText = new Ui.Text(
                {
                    :text => result.data,
                    :font => RESULT_FONT,
                    :justification => Gfx.TEXT_JUSTIFY_CENTER,
                    :height => resultHeight
                }
            );
            var timeText = new Ui.Text(
                {
                    :text => dateTimeFormatter.formatDateTimeNumeric(result.time),
                    :font => TIME_FONT,
                    :justification => Gfx.TEXT_JUSTIFY_CENTER,
                    :height => timeHeight
                }
            );

            var recentResult = new RecentResultDrawable();
            recentResult.setup(resultText, timeText, resolveIndicator(result.type));
        
            pushDrawable(recentResult, SlidableView.SLIDE_DOWN);
        } else {
            pushDrawable(null, SlidableView.SLIDE_DOWN);
        }
    }

    private function resolveIndicator(generatorMode as Gen.GeneratorType) {
        var resource;
        switch (generatorMode) {
            case Gen.GENERATOR_NUM:
                resource = Rez.Drawables.ic_num;
                break;
            case Gen.GENERATOR_RANGE:
                resource = Rez.Drawables.ic_range;
                break;
            case Gen.GENERATOR_NUM_FIXED:
                resource = Rez.Drawables.ic_num_fixed;
                break;
            case Gen.GENERATOR_ALPHANUM:
                resource = Rez.Drawables.ic_alphanum;
                break;
            case Gen.GENARATOR_HEX:
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

    class RecentResultDrawable extends Ui.Drawable {

        private var resultType as Drawable = null;
        private var resultText as Drawable = null;
        private var timeText as Drawable = null;
        private var vSpacing = 2;
        private var hSpacing = 7;
        private var padding = 5;
        private var headlineHeight;

        function initialize() {
            Drawable.initialize({});
        }

        function draw(dc) {
            resultText.setLocation(
                me.locX + (resultType.getWidth() / 2f) + (hSpacing / 2f),
                getHeadlineLocY(resultText.height)
            );
            resultText.draw(dc);
            timeText.setLocation(me.locX, resultText.locY + resultText.height + vSpacing);
            timeText.draw(dc);
            dc.drawBitmap(
                resultText.locX - resultType.getWidth() - (resultText.width / 2f) - hSpacing,
                getHeadlineLocY(resultType.getHeight()),
                resultType
            );
        }

        private function getHeadlineLocY(baseHeight) {
            return me.locY + ((headlineHeight - baseHeight) / 2f) + padding;
        }

        function setColor(color) {
            resultText.setColor(color);
        }
        
        function setup(text as Drawable, time as Drawable, icon as Ui.BitmapResource) {
            resultText = text;
            timeText = time;
            resultType = icon;
            headlineHeight = Mathx.max(resultText.height, icon.getHeight());
            setSize(
                width,
                headlineHeight + timeText.height + vSpacing + (padding * 2)
            );
        }
    }
}
