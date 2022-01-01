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

    private var primaryValueColor = Gfx.COLOR_WHITE;
    private var altValueColor = Gfx.COLOR_WHITE;

    // Animation-related values

    private var animationTimer;
    private var isAnimationActive = false;

    // Slide animation
    private const ANIMATION_DURATION_MILLIS = 170;
    private const ANIMATION_FREQUENCY = 50;
    private var topTranslateTheshold;
    private var drawablePositionOffsetY;
    private var applyAltColor = false;
    private var frameStep = null;

    // Shake animation
    private const ANIMATION_SHAKE_ITERATIONS = 4;
    private const ANIMATION_SHAKE_TRANSLATE = 9;
    private var shakeOffsetX = 0;
    private var shakeIteration = 0;
    
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
            centerX + shakeOffsetX,
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

    private function evaluateSlideFrameStep() {
        if (frameStep == null || frameStep == 0) {
            var transitionLength = drawableHeight;
            frameStep = (transitionLength / (ANIMATION_DURATION_MILLIS / ANIMATION_FREQUENCY))
                .toNumber();
        }
    }

    function requestSlideFrameUpdate() {
        evaluateSlideFrameStep();
        if (drawablePositionOffsetY <= 0) {
            finishSlideAnimation();
        } else {
            drawablePositionOffsetY = drawablePositionOffsetY - frameStep;
            if (drawablePositionOffsetY <= 0) {
                drawablePositionOffsetY = 0;
                finishSlideAnimation();
            }
        }
        Ui.requestUpdate();
    }

    private function finishSlideAnimation() {
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
            animationTimer.start(method(:requestSlideFrameUpdate), ANIMATION_FREQUENCY, true);
            isAnimationActive = true;
        } else {
            applyAltColor = true;
        }
        currentDrawable.setColor(getCurrentDrawableColor());
    }

    function setPrimaryColor(color as Graphics.ColorType) {
        primaryValueColor = color;
        if (currentDrawable != null && !applyAltColor) {
            currentDrawable.setColor(color);
        }
        if (prevDrawable != null) {
            prevDrawable.setColor(color);
        }
    }    
    
    function setAltColor(color as Graphics.ColorType) {
        altValueColor = color;
        if (currentDrawable != null && applyAltColor) {
            currentDrawable.setColor(color);
        }
    }

    function shake() {
        if (!isAnimationActive) {
            animationTimer.start(method(:requestShakeFrameUpdate), ANIMATION_FREQUENCY, true);
        }
    }

    function requestShakeFrameUpdate() {
        if (shakeIteration >= ANIMATION_SHAKE_ITERATIONS) {
            animationTimer.stop();
            shakeOffsetX = 0;
            shakeIteration = 0;
        } else {
            shakeIteration++;
            if (shakeOffsetX < 0) {
                shakeOffsetX = ANIMATION_SHAKE_TRANSLATE;
            } else {
                shakeOffsetX = ANIMATION_SHAKE_TRANSLATE * -1;
            }
        }
        Ui.requestUpdate();
    }
}
