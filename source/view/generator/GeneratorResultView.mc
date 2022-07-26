using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

class GeneratorResultView extends SlidableView {

    private const COLOR_PRIMARY = Gfx.COLOR_YELLOW;
    private const COLOR_ALT = Gfx.COLOR_DK_RED;

    private var generatorValueFont;
    private var valueHeight;

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
        setPrimaryColor(COLOR_PRIMARY);
        setAltColor(COLOR_ALT);
        generatorValueFont = Ui.loadResource(Rez.Fonts.rajdhani_bold_104);
        valueHeight = Gfx.getFontHeight(generatorValueFont);
    }

    function pushResult(resultValue as String) {
        pushDrawable(
            new Ui.Text(
                {
                    :text => resultValue,
                    :font => generatorValueFont,
                    :locX => WatchUi.LAYOUT_HALIGN_CENTER,
                    :locY => WatchUi.LAYOUT_VALIGN_CENTER,
                    :justification => Gfx.TEXT_JUSTIFY_CENTER,
                    :height => valueHeight
                }
            ),
            SlidableView.SLIDE_DOWN
        );
    }
}
