using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as System;
using Toybox.Timer;

class GeneratorResultView extends Ui.View {

    // Generated value

    private var prevValue = null;
    private var generatorValue = null;

    // General positioning values

	private var centerX;
	private var centerY;
    private var valuePositionY;
    private var valueHeight;

    // General color scheme

    private var primaryValueColor = Gfx.COLOR_YELLOW;
    private var altValueColor = Gfx.COLOR_DK_RED;

    // Animation-related values

    private const ANIMATION_DURATION_MILLIS = 170;
    private const ANIMATION_FREQUENCY = 50;
    private var topTranslateTheshold;
    private var animationTimer;
    private var isAnimationActive = false;
    private var valuePositionOffsetY;
    private var applyAltColor = false;
    private var frameStep = null;

    function initialize(centerX, centerY) {
        View.initialize();
        self.centerX = centerX;
        self.centerY = centerY;
        animationTimer = new Timer.Timer();

        valueHeight = Gfx.getFontHeight(Gfx.FONT_NUMBER_THAI_HOT);
        valuePositionY = centerY - (valueHeight / 2);

        topTranslateTheshold = valuePositionY;
    }

    function onUpdate(dc) {
        drawRecentValue(dc);
        if (prevValue != null) {
            drawPrevValue(dc);
        }
    }

    private function drawRecentValue(dc) {
        dc.setClip(0, valuePositionY, dc.getWidth(), valueHeight);
        dc.setColor(getValueColor(), Gfx.COLOR_TRANSPARENT);
        dc.drawText(
            centerX, 
            valuePositionY + valuePositionOffsetY,
            Gfx.FONT_NUMBER_THAI_HOT, 
            generatorValue,
            Gfx.TEXT_JUSTIFY_CENTER
        );
        dc.clearClip();
    }    
    
    private function drawPrevValue(dc) {
        dc.setClip(0, valuePositionY, dc.getWidth(), valueHeight);
        dc.setColor(primaryValueColor, Gfx.COLOR_TRANSPARENT);
        dc.drawText(
            centerX, 
            valuePositionY - (valueHeight - valuePositionOffsetY), 
            Gfx.FONT_NUMBER_THAI_HOT, 
            prevValue,
            Gfx.TEXT_JUSTIFY_CENTER
        );
        dc.clearClip();
    }

    private function getValueColor() {
        if (applyAltColor) {
            return altValueColor;
        } else {
            return primaryValueColor;
        }
    }

    private function evaluateFrameStep() {
        if (frameStep == null) {
            var transitionLength = valueHeight;
            frameStep = (transitionLength / (ANIMATION_DURATION_MILLIS / ANIMATION_FREQUENCY))
                .toNumber();
        }
    }

    function requestFrameUpdate() {
        evaluateFrameStep();
        if (valuePositionOffsetY == 0) {
            finishAnimation();
        } else {
            valuePositionOffsetY = valuePositionOffsetY - frameStep;
            if (valuePositionOffsetY <= 0) {
                valuePositionOffsetY = 0;
                finishAnimation();
            }
        }
        Ui.requestUpdate();
    }

    private function finishAnimation() {
        animationTimer.stop();
        isAnimationActive = false;
        applyAltColor = false;
    }

    function pushNewResult(resultValue) {
        var prevValueBuffer = generatorValue;
        generatorValue = resultValue;
        if (!isAnimationActive) {
            prevValue = prevValueBuffer;
            valuePositionOffsetY = valueHeight;
            animationTimer.start(method(:requestFrameUpdate), ANIMATION_FREQUENCY, true);
            isAnimationActive = true;
        } else {
            applyAltColor = true;
        }
    }
}
