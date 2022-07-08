// Copyright 2017 by HarryOnline
// https://creativecommons.org/licenses/by/4.0/
//
// Wrap text so lines will fit on the screen
// https://gitlab.com/harryonline/fortune-quote

using Toybox.WatchUi as Ui;
using Toybox.System;
using Toybox.Graphics as Gfx;
using Toybox.Math;
using Mathx;
using UniTimer;

class WrapText extends Ui.Drawable {
	private const TEXT_COLOR_DEFAULT = Graphics.COLOR_WHITE;
	private const BACKGROUND_COLOR_DEFAULT = Graphics.COLOR_TRANSPARENT;
	private const FONT_DEFAULT = Graphics.FONT_SYSTEM_TINY;
	private const PADDING_TOP_DEFAULT = 0;
	private const PADDING_BOTTOM_DEFAULT = 0;
	
	/* Single scroll distance in percents relative to screen height */
	private const SCROLL_PAGE_RATIO = 0.45;

	hidden var screenWidth;
	hidden var screenHeight;
	hidden var screenShape;
	private var linePadding = 1; // Padding between lines
	private var sidePadding = 5; // Padding on the sides of the screen;
	private var roundMargin = 15; // Minimal margin at the top of round screens;
	private var rectangleAlignment = Gfx.TEXT_JUSTIFY_LEFT;

	hidden var textColor = Graphics.COLOR_WHITE;
	hidden var backgroundColor = Graphics.COLOR_TRANSPARENT;
	hidden var font;

	hidden var paddingTop;
	hidden var paddingBottom;

	hidden var textDrawingSpec;

	hidden var scrollAnimSpec = new ScrollAnimationSpec();

	hidden var onScrollEnd;

	hidden var text;

	function initialize(params) {
		Drawable.initialize(params);
		var settings = System.getDeviceSettings();
		screenWidth = settings.screenWidth;
		screenHeight = settings.screenHeight;
		screenShape = settings.screenShape;

        textColor = params.get(:textColor);
        if (textColor == null) {
            textColor = TEXT_COLOR_DEFAULT;
        }

        backgroundColor = params.get(:backgroundColor);
        if (backgroundColor == null) {
            backgroundColor = BACKGROUND_COLOR_DEFAULT;
        }
		
		paddingTop = params.get(:paddingTop);
        if (paddingTop == null) {
            paddingTop = PADDING_TOP_DEFAULT;
        }		
		
		paddingBottom = params.get(:paddingBottom);
        if (paddingBottom == null) {
            paddingBottom = PADDING_BOTTOM_DEFAULT;
        }

		font = params.get(:font);
		if (font == null) {
			font = FONT_DEFAULT;
		}

		scrollAnimSpec.reset();
		scrollAnimSpec.setInterpolationDistance(getPageScrollDistance());
		scrollAnimSpec.setCallback(method(:proceedScroll));
	}

	function setText(text) {
		me.text = text;
		scrollAnimSpec.reset();
		textDrawingSpec = null;
	}

	function draw(dc) {
		var posY = locY;
		if (posY >= screenHeight) {
			return;
		}

		// Top padding handling
		if (paddingTop >= 0) {
			dc.setColor(backgroundColor, backgroundColor);
			var verticalInset = posY + paddingTop + linePadding;
			dc.fillRectangle(0, posY, screenWidth, verticalInset);
			posY += verticalInset;
		} else {
			// Should have some space above
			posY += linePadding;	
		}

		// On round screens, needs more space from top, otherwise always zero width
		if (screenShape == System.SCREEN_SHAPE_ROUND && posY < roundMargin) {
			posY = roundMargin;
		}

		if (textDrawingSpec == null) {
			posY = createSpecAndDraw(dc, posY);
		} else {
			posY = drawTextSpec(dc, posY - scrollAnimSpec.getOffset());
		}

		// Bottom padding handling
		if (paddingBottom >= 0) {
			dc.setColor(backgroundColor, backgroundColor);
			var posYDelta = textDrawingSpec.getTextAreaHeight() - posY;
			dc.fillRectangle(0, posY, screenWidth, paddingBottom + posYDelta);
			posY += paddingBottom;
		}

		me.height = textDrawingSpec.getTextAreaHeight() + paddingBottom;
	}

	function setOnScrollEnd(callback) {
		me.onScrollEnd = callback;
	}

	hidden function createSpecAndDraw(dc, posY) {
		var height = dc.getFontHeight(font);
		var textPartsBuffer = ["", text];
		var textParts = [];
		var prevLineWidth = 0;
		var skipBeforeFixWidth = 2;
		var scrollTreshold = 0;
		while (textPartsBuffer.size() == 2) {
			var width = getWidthForLine(posY, height);
			if (prevLineWidth > width) {
				if (skipBeforeFixWidth == 0) {
					// Fix line width on the second line after the widest one to make even width for 
					// the remaining text as it can be scrolled
					width = prevLineWidth;
					if (scrollTreshold == 0) {
						scrollTreshold = posY;
					}
				} else {
					prevLineWidth = width;
					skipBeforeFixWidth--;
				}
			} else {
				prevLineWidth = width;
			}
			// Now calculate how much fits on the line
			textPartsBuffer = lineSplit(dc, textPartsBuffer[1], font, width);
			textParts.add(new TextLine(textPartsBuffer[0], width));
			drawTextLine(dc, width, height, posY, textPartsBuffer[0]);
			posY += height + linePadding;
		}

		textDrawingSpec = new TextDrawingSpec(textParts, height, posY, scrollTreshold);
		return posY;
	}

	hidden function drawTextSpec(dc, posY) {
		var textParts = textDrawingSpec.getTextParts();
		var height = textDrawingSpec.getlineHeight();
		for (var i = 0; i < textParts.size(); i++) {
			var line = textParts[i];
			drawTextLine(dc, line.getWidth(), height, posY, line.getText());
			posY += height + linePadding;
		}
		return posY;
	}

	hidden function drawTextLine(dc, width, height, posY, text) {
		if (posY < screenHeight && posY + height > 0) {
			dc.setColor(backgroundColor, backgroundColor);
			dc.fillRectangle(0, posY, screenWidth, height + linePadding);
			dc.setColor(textColor, backgroundColor);
			drawText(dc, width, posY, font, text);
		}
	}

	// Splits the text into a part that fits on the line, and the remaining text
	private function lineSplit(dc, text, font, width) {
		var os = 0;
		var textPartsBuffer = wordSplit(text, os);
		var count = 0;
		while (textPartsBuffer.size() == 2 && count < 10) {
			var newParts = wordSplit(text, textPartsBuffer[0].length() + 1);
			if (dc.getTextWidthInPixels(newParts[0], font) > width) {
                break;
			}
			count++;
			textPartsBuffer = newParts;
		}
		return textPartsBuffer;
	}

	// Splits the subject into first word and remaining text (if exists)
	private function wordSplit(subject, start) {
		var len = subject.length();
		var substr = subject.substring(start, len);
		var ptr = substr.find(" ");
		return ptr == null ? 
            [subject] : 
            [subject.substring(0, ptr + start), subject.substring(ptr + start + 1, len)];
	}

	// Find alignment, draw the text
	hidden function drawText(dc, width, posY, font, text) {
		if (
            screenShape != System.SCREEN_SHAPE_RECTANGLE || 
                rectangleAlignment == Gfx.TEXT_JUSTIFY_CENTER
        ) {
			dc.drawText(screenWidth/2, posY, font, text, Gfx.TEXT_JUSTIFY_CENTER);
		} else if (rectangleAlignment == Gfx.TEXT_JUSTIFY_LEFT) {
			dc.drawText(screenWidth / 2 - width / 2, posY, font, text, Gfx.TEXT_JUSTIFY_LEFT);
		} else {
			dc.drawText(screenWidth / 2 + width / 2, posY, font, text, Gfx.TEXT_JUSTIFY_RIGHT);
		}
	}

	// Return the width for a line at certain Y poistion and with height
	private function getWidthForLine(posY, height) {
		// Middle of the line should have some distance from border (sidePadding)
		var avgY = posY + height / 2;
		var w1 = getWidthAt(avgY) - 2 * sidePadding;
		// Corner should not get outside visible space
		var upperHalf = avgY < screenHeight/2;
		var cornerY = upperHalf ? posY : posY + height;
		var w2 = getWidthAt(cornerY);
		// Take minimum of both widths
		var width = w1 < w2 ? w1 : w2;
		return width;
	}

	// Return the width at certain Y position
	private function getWidthAt(posY) {
		if (screenShape == System.SCREEN_SHAPE_RECTANGLE) {
			return screenWidth;
		}
		var r = screenWidth / 2;
		var dY = posY - screenHeight / 2;

		if (dY.abs() >= r) {
            return 0;
		}
		var a = Math.asin(dY.toFloat() / r);
		var w = 2 * (r * Math.cos(a));
		return w.toNumber();
	}

	function reset() {
		scrollAnimSpec.reset();
	}

	private function invalidateAnimation() {
		var animationActive = textDrawingSpec != null && 
			textDrawingSpec.getScrollTreshold() != 0 &&
			scrollAnimSpec.getScrollDistance() > 0;
		scrollAnimSpec.updateAnimationState(animationActive);
		return animationActive;
	}

	private function getPageScrollDistance() {
		return screenHeight * SCROLL_PAGE_RATIO;
	}

	function proceedScroll() {
		if (invalidateAnimation()) {
			Ui.requestUpdate();
			return true;
		} else {
			if (onScrollEnd != null) {
				onScrollEnd.invoke();
			}
			return false;
		}
	}

	public function requestAutoScroll() {
		scrollAnimSpec.setScrollDistance(me.height - textDrawingSpec.getScrollTreshold());
		scrollAnimSpec.setScrollStep(scrollAnimSpec.SCROLL_STEP_MEDIUM);
		return proceedScroll();
	}

	public function scrollDown() {
		return scrollPage(ScrollAnimationSpec.DIRECTION_DOWN);
	}

	public function scrollUp() {
		return scrollPage(ScrollAnimationSpec.DIRECTION_UP);
	}

	private function scrollPage(direction) {
		var pageDistance = getPageScrollDistance();

		// Prevent stacking manaul scroll requests for distance larger than two pages
		var targetDistance = 
			pageDistance + Mathx.min(scrollAnimSpec.getScrollDistance(), pageDistance);
		var distance = validateScrollDistance(targetDistance, direction);
		if (distance > 0) {
			scrollAnimSpec.setScrollDistance(distance);
			scrollAnimSpec.setScrollDirection(direction);
			scrollAnimSpec.setScrollStep(scrollAnimSpec.SCROLL_STEP_LARGE);
			return proceedScroll();
		} else {
			return false;
		}
	}

	private function validateScrollDistance(distance, direction) {
		if (me.height < screenHeight) {
			return 0;
		}
		var scrollEndPosition = (distance * direction) + scrollAnimSpec.getOffset();
		var heightLimit = me.height - textDrawingSpec.getScrollTreshold();
		if (scrollEndPosition > heightLimit) {
			var availableDistance = Mathx.max(distance - (scrollEndPosition - heightLimit), 0);
			return availableDistance;
		}
		if (scrollEndPosition < 0) {
			var availableDistance = Mathx.max(distance + scrollEndPosition, 0);
			return availableDistance;
		} else {
			return distance;
		}
	}

	class TextDrawingSpec {
		private var textParts = [];
		private var lineHeight;
		private var scrollTreshold;
		private var textAreaHeight;

		function initialize(textParts, lineHeight, textAreaHeight, scrollTreshold) {
			me.textParts = textParts;
			me.lineHeight = lineHeight;
			me.textAreaHeight = textAreaHeight;
			me.scrollTreshold = scrollTreshold;
		}

		function getTextParts() {
			return textParts;
		}

		function getlineHeight() {
			return lineHeight;
		}

		function getTextAreaHeight() {
			return textAreaHeight;
		}

		function getScrollTreshold() {
			return scrollTreshold;
		}
	}

	class ScrollAnimationSpec {
		static const DIRECTION_UP = -1;
		static const DIRECTION_DOWN = 1;
		static const SCROLL_STEP_MEDIUM = 6;
		static const SCROLL_STEP_LARGE = 18;
		private static const MIN_INCREMENT_RATIO = 0.35;
		private var timerKey = "wrap_text_scroll_animation_" + hashCode();

		private var active = false;
		private var offset; // Number of pixels to skip when scrolling
		private var scrollDelay = 60; // Scroll step time in ms
		private var scrollStep = SCROLL_STEP_MEDIUM; // Number of pixels to proceed on scroll
		private var timer = UniTimer.getTimer();
		hidden var scrollCallback;

		private var scrollDistance = 0; // Distance in pixel left
		private var interpolationDistance = 0; // Distance for which interpolation is applied
		private var scrollDirection = DIRECTION_DOWN;
		private var interpolate = true;

		function setCallback(callback) {
			me.scrollCallback = callback;
		}

		function isActive() {
			return active;
		}

		function getOffset() {
			return offset;
		}

		function setOffset(offset) {
			me.offset = offset;
		}

		function setScrollStep(scrollStep) {
			me.scrollStep = scrollStep;
		}

		function reset() {
			timer.stop(timerKey);
			offset = 0;
		}

		function updateAnimationState(active) {
			me.active = active;
			if (active) {
				proceedAnimationFrame();
				if (!timer.isActive(timerKey)) {
					timer.start(timerKey, scrollCallback, scrollDelay, true);
				}
			} else if (timer.isActive(timerKey) && !active) {
				timer.stop(timerKey);
			}
		}
		
		private function proceedAnimationFrame() {
			var increment;
			if (interpolate && interpolationDistance >= scrollDistance) {
				increment = Mathx.max(interpolateIncrement(scrollStep), MIN_INCREMENT_RATIO);
			} else {
				increment = scrollStep;
			}
			scrollDistance -= increment;
			if (scrollDistance < 0) {
				offset += (increment + scrollDistance) * scrollDirection;
				scrollDistance = 0;
			} else {
				offset += increment * scrollDirection;
			}
		}

		private function interpolateIncrement(value) {
			var t = scrollDistance / interpolationDistance;
			t--;
			return Mathx.max((t * t * t + 1), MIN_INCREMENT_RATIO) *  value;
		}

		function getScrollDistance() {
			return scrollDistance;
		}

		function setInterpolationDistance(interpolationDistance) {
			me.interpolationDistance = interpolationDistance;
		}

		function setScrollDistance(scrollDistance) {
			me.scrollDistance = scrollDistance;
		}

		function setScrollDirection(direction) {
			scrollDirection = direction;
		}

		function setInterpolate(interpolate) {
			me.interpolate = interpolate;
		}
	}

	class TextLine {
		private var text;
		private var width;

		function initialize(text, width) {
			me.text = text;
			me.width = width;
		}

		function getText() {
			return text;
		}

		function getWidth() {
			return width;
		}
	}
}
