using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

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

    function pushRecentResult(type as GeneratorType, time as Moment, result) {
        var resultText = new Ui.Text(
            {
                :text => result,
                :font => RESULT_FONT,
                :locX => WatchUi.LAYOUT_HALIGN_CENTER,
                :locY => WatchUi.LAYOUT_VALIGN_CENTER,
                :justification => Gfx.TEXT_JUSTIFY_CENTER,
                :height => resultHeight
            }
        );
        var timeText = new Ui.Text(
            {
                :text => dateTimeFormatter.formatDateTimeNumeric(time),
                :font => TIME_FONT,
                :locX => WatchUi.LAYOUT_HALIGN_CENTER,
                :locY => WatchUi.LAYOUT_VALIGN_CENTER,
                :justification => Gfx.TEXT_JUSTIFY_CENTER,
                :height => timeHeight
            }
        );

        var recentResult = new RecentResultDrawable();
        recentResult.setup(resultText, timeText, null);
    
        pushNewDrawable(recentResult, SlidableView.SLIDE_DOWN);
    }

    class RecentResultDrawable extends Ui.Drawable {

        private var resultType as Drawable = null;
        private var resultText as Drawable = null;
        private var timeText as Drawable = null;
        private var spacing = 2;
        private var padding = 5;

        function initialize() {
            Drawable.initialize({});
        }

        function draw(dc) {
            resultText.setLocation(me.locX, me.locY + padding);
            resultText.draw(dc);
            timeText.setLocation(me.locX, me.locY + resultText.height + spacing);
            timeText.draw(dc);
            // dc.drawBitmap(me.locX - resultType.getWidth() / 2, me.locY + padding, resultType);
        }

        function setColor(color) {
            resultText.setColor(color);
        }
        
        function setup(text as Drawable, time as Drawable, icon as Ui.BitmapResource) {
            resultText = text;
            timeText = time;
            resultType = icon;
            setSize(
                width,
                resultText.height + timeText.height + spacing + (padding * 2)
            );
        }
    }
}
