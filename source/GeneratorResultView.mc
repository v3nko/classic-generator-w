using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as System;
using Toybox.Timer;

class GeneratorResultView extends SlideableView {

    private const COLOR_PRIMARY = Gfx.COLOR_YELLOW;
    private const COLOR_ALT = Gfx.COLOR_DK_RED;

    private var generatorValueFont;
    private var valueHeight;

    function initialize(centerX, centerY) {
        SlideableView.initialize(centerX, centerY);
        setPrimaryColor(COLOR_PRIMARY);
        setAltColor(COLOR_ALT);
        generatorValueFont = Ui.loadResource(Rez.Fonts.rajdhani_bold_104);
        valueHeight = Gfx.getFontHeight(generatorValueFont);
    }

    function pushNewResult(resultValue as String) {
        pushNewDrawable(
            new Ui.Text(
                {
                    :text => resultValue,
                    :font => generatorValueFont,
                    :locX => WatchUi.LAYOUT_HALIGN_CENTER,
                    :locY => WatchUi.LAYOUT_VALIGN_CENTER,
                    :justification => Gfx.TEXT_JUSTIFY_CENTER,
                    :height => valueHeight
                }
            )
        );
    }
}
