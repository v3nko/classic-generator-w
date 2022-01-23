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
    private var slideAnimator;
    private var shakeAnimator;
    private var applyAltColor = false;

    function initialize(centerX, centerY) {
        View.initialize();
        self.centerX = centerX;
        self.centerY = centerY;
        animationTimer = new Timer.Timer();
        slideAnimator = new SlideAnimator(animationTimer, method(:onFinishSlideAnimation));
        shakeAnimator = new ShakeAnimator(animationTimer);
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
        var offsetY = slideAnimator.getDrawablePositionOffsetY();
        switch (slideAnimator.getAnimation()) {
            case SLIDE_UP:
                positionY += offsetY;
                break;
            case SLIDE_DOWN:
                positionY -= offsetY;
                break;
        }
        currentDrawable.setLocation(centerX + shakeAnimator.getShakeOffsetX(), positionY);
        currentDrawable.draw(dc);
        dc.clearClip();
    }

    private function drawPrevDrawable(dc) {
        var positionY = currentDrawablePositionY;
        var offsetY = prevDrawable.height - slideAnimator.getDrawablePositionOffsetY();
        switch (slideAnimator.getAnimation()) {
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

    function onFinishSlideAnimation() {
        applyAltColor = false;
        currentDrawable.setColor(getCurrentDrawableColor());
    }

    function pushNewDrawable(newDrawable, animation as PushAnimation) {
        var prevDrawableBuffer = currentDrawable;
        currentDrawable = newDrawable;
        drawableHeight = currentDrawable.height;
        if (!slideAnimator.isAnimationActive()) {
            prevDrawable = prevDrawableBuffer;
            if (prevDrawable != null) {
                prevDrawable.setColor(primaryValueColor);
            }
            currentDrawablePositionY = centerY - (drawableHeight / 2);
            if (animation != SLIDE_NONE) {
                slideAnimator.start(animation, drawableHeight);
            } else {
                slideAnimator.reset();
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
        if (!slideAnimator.isAnimationActive()) {
            shakeAnimator.start();
        }
    }

    static enum PushAnimation {
        SLIDE_NONE, SLIDE_DOWN, SLIDE_UP
    }

    class SlideAnimator {
        private const ANIMATION_DURATION_MILLIS = 170;
        private const ANIMATION_FREQUENCY = 50;
        private var topTranslateTheshold;
        private var drawablePositionOffsetY;
        private var frameStep = null;
        private var animation as PushAnimation;
        private var animationActive = false;
        private var animationTimer;

        private var drawableHeight;

        private var finishCallback as Method();

        function initialize(animationTimer, finishCallback as Method()) {
            me.animationTimer = animationTimer;
            me.finishCallback = finishCallback;
        }

        function getAnimation() as PushAnimation {
            return animation;
        }

        function getDrawablePositionOffsetY() {
            return drawablePositionOffsetY;
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
            animationActive = false;
            if (finishCallback != null) {
                finishCallback.invoke();
            }
        }

        function isAnimationActive() as Boolean {
            return animationActive;
        }

        function start(animation, drawableHeight) {
            me.drawableHeight = drawableHeight;
            me.animation = animation;
            drawablePositionOffsetY = drawableHeight;
            animationTimer.start(method(:requestSlideFrameUpdate), ANIMATION_FREQUENCY, true);
            animationActive = true;
        }

        function reset() {
            animation = SLIDE_NONE;
            drawablePositionOffsetY = 0;
            Ui.requestUpdate();
        }
    }

    class ShakeAnimator {
        private const ANIMATION_DURATION_MILLIS = 170;
        private const ANIMATION_FREQUENCY = 50;
        private const ANIMATION_SHAKE_ITERATIONS = 4;
        private const ANIMATION_SHAKE_TRANSLATE = 9;
        private var shakeOffsetX = 0;
        private var shakeIteration = 0;
        private var animationTimer;

        function initialize(animationTimer) {
            me.animationTimer = animationTimer;
        }

        function getShakeOffsetX() {
            return shakeOffsetX;
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

        function start() {
            animationTimer.start(method(:requestShakeFrameUpdate), ANIMATION_FREQUENCY, true);
        }
    }
}
