using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as System;

class GeneratorView extends Ui.View {

    hidden var generatorValue;

	hidden var centerX;
	hidden var centerY;
    hidden var valueOffset;
    
    function initialize() {
		View.initialize();
	}

    function onLayout(dc) {
		centerX = dc.getWidth() / 2;
		centerY = dc.getHeight() / 2;
        me.valueOffset = me.centerY - (Gfx.getFontHeight(Gfx.FONT_LARGE) / 2);

        generateNewValue();
    }

    hidden function generateNewValue() {
        generatorValue = Math.rand() % 100;
    }

    function onUpdate(dc) {
        dc.setColor(Gfx.COLOR_TRANSPARENT, Gfx.COLOR_BLACK);
        dc.clear();
        drawRecentValue(dc);
    }

    hidden function drawRecentValue(dc) {
        dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT);
        dc.drawText(
            me.centerX, 
            me.valueOffset, 
            Gfx.FONT_LARGE, 
            me.generatorValue, 
            Gfx.TEXT_JUSTIFY_CENTER
        );
    }

	function onShow() {
        // no-op
	}

    function onHide() {
        // no-op
	}
}