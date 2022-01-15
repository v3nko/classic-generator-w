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
    private var pushAnimation as PushAnimation;

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
        var positionY = currentDrawablePositionY;
        switch (pushAnimation) {
            case SLIDE_UP:
                positionY += drawablePositionOffsetY;
                break;
            case SLIDE_DOWN:
                positionY -= drawablePositionOffsetY;
                break;
        }
        currentDrawable.setLocation(centerX + shakeOffsetX, positionY);
        currentDrawable.draw(dc);
        dc.clearClip();
    }

    private function drawPrevDrawable(dc) {
        var positionY = currentDrawablePositionY;
        var offsetY = prevDrawable.height - drawablePositionOffsetY;
        switch (pushAnimation) {
            case SLIDE_UP:
                positionY -= offsetY;
                break;
            case SLIDE_DOWN:
                positionY += offsetY;
                break;
            default:
                return;
        }
        dc.setClip(0, currentDrawablePositionY, dc.getWidth(), prevDrawable.height);
        prevDrawable.setLocation(centerX, positionY);
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

    function pushNewDrawable(newDrawable, animation as PushAnimation) {
        var prevDrawableBuffer = currentDrawable;
        currentDrawable = newDrawable;
        drawableHeight = currentDrawable.height;
        if (!isAnimationActive) {
            pushAnimation = animation;
            prevDrawable = prevDrawableBuffer;
            if (prevDrawable != null) {
                prevDrawable.setColor(primaryValueColor);
            }
            currentDrawablePositionY = centerY - (drawableHeight / 2);
            if (animation != SLIDE_NONE) {
                drawablePositionOffsetY = drawableHeight;
                animationTimer.start(method(:requestSlideFrameUpdate), ANIMATION_FREQUENCY, true);
                isAnimationActive = true;
            } else {
                drawablePositionOffsetY = 0;
                Ui.requestUpdate();
            }
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

    enum PushAnimation {
        SLIDE_NONE, SLIDE_DOWN, SLIDE_UP
    }
}
