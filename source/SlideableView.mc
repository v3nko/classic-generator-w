using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Timer;

class SlideableView extends Ui.View {
    
    // Slideable drawables
    
    private var prevDrawable as Drawable = null;
    private var currentDrawable as Drawable = null;

    // General positioning values

	private var centerX;
	private var centerY;
    private var currentDrawablePositionY;
    private var drawableHeight;

    // General color scheme

    private var primaryValueColor = Gfx.COLOR_YELLOW;
    private var altValueColor = Gfx.COLOR_DK_RED;

    // Animation-related values

    private const ANIMATION_DURATION_MILLIS = 170;
    private const ANIMATION_FREQUENCY = 50;
    private var topTranslateTheshold;
    private var animationTimer;
    private var isAnimationActive = false;
    private var drawablePositionOffsetY;
    private var applyAltColor = false;
    private var frameStep = null;

    
    function initialize(centerX, centerY) {
        View.initialize();
        self.centerX = centerX;
        self.centerY = centerY;
        animationTimer = new Timer.Timer();
    }

    function onUpdate(dc) {
        if (currentDrawable != null) {
            drawCurrentDrawable(dc);
        }
        if (prevDrawable != null) {
            drawPrevDrawable(dc);
        }
    }

    private function drawCurrentDrawable(dc) {
        dc.setClip(0, currentDrawablePositionY, dc.getWidth(), currentDrawable.height);
        currentDrawable.setLocation(
            centerX,
            currentDrawablePositionY + drawablePositionOffsetY
        );
        currentDrawable.draw(dc);
        dc.clearClip();
    }

    private function drawPrevDrawable(dc) {
        dc.setClip(0, currentDrawablePositionY, dc.getWidth(), prevDrawable.height);
        prevDrawable.setLocation(
            centerX,
            currentDrawablePositionY - (prevDrawable.height - drawablePositionOffsetY)
        );
        prevDrawable.draw(dc);
        dc.clearClip();
    }

    private function getCurrentDrawableColor() {
        if (applyAltColor) {
            return altValueColor;
        } else {
            return primaryValueColor;
        }
    }

    private function evaluateFrameStep() {
        if (frameStep == null || frameStep == 0) {
            var transitionLength = drawableHeight;
            frameStep = (transitionLength / (ANIMATION_DURATION_MILLIS / ANIMATION_FREQUENCY))
                .toNumber();
        }
    }

    function requestFrameUpdate() {
        evaluateFrameStep();
        if (drawablePositionOffsetY <= 0) {
            finishAnimation();
        } else {
            drawablePositionOffsetY = drawablePositionOffsetY - frameStep;
            if (drawablePositionOffsetY <= 0) {
                drawablePositionOffsetY = 0;
                finishAnimation();
            }
        }
        Ui.requestUpdate();
    }

    private function finishAnimation() {
        animationTimer.stop();
        isAnimationActive = false;
        applyAltColor = false;
        currentDrawable.setColor(getCurrentDrawableColor());
    }

    function pushNewDrawable(newDrawable) {
        var prevDrawableBuffer = currentDrawable;
        currentDrawable = newDrawable;
        drawableHeight = currentDrawable.height;
        if (!isAnimationActive) {
            prevDrawable = prevDrawableBuffer;
            if (prevDrawable != null) {
                prevDrawable.setColor(primaryValueColor);
            }
            currentDrawablePositionY = centerY - (drawableHeight / 2);
            drawablePositionOffsetY = drawableHeight;
            animationTimer.start(method(:requestFrameUpdate), ANIMATION_FREQUENCY, true);
            isAnimationActive = true;
        } else {
            applyAltColor = true;
        }
        currentDrawable.setColor(getCurrentDrawableColor());
    }
}
