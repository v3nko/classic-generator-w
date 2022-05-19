// Copyright 2017 by HarryOnline
// https://creativecommons.org/licenses/by/4.0/
//
// Wrap text so lines will fit on the screen
// https://gitlab.com/harryonline/fortune-quote

using Toybox.WatchUi as Ui;
using Toybox.System;
using Toybox.Graphics as Gfx;
using Toybox.Math;
using Toybox.Timer;

class WrapText extends Ui.Drawable {
	private const TEXT_COLOR_DEFAULT = Graphics.COLOR_WHITE;
	private const BACKGROUND_COLOR_DEFAULT = Graphics.COLOR_TRANSPARENT;
	private const FONT_DEFAULT = Graphics.FONT_SYSTEM_TINY;
	private const PADDING_TOP_DEFAULT = 0;
	private const PADDING_BOTTOM_DEFAULT = 0;

	hidden var screenWidth;
	hidden var screenHeight;
	hidden var screenShape;
	private var linePadding = 1; // Padding between lines
	private var sidePadding = 5; // Padding on the sides of the screen;
	private var roundMargin = 15; // Minimal margin at the top of round screens;
	private var rectangleAlignment = Gfx.TEXT_JUSTIFY_LEFT;
	private var offset; // Number of pixels to skip when scrolling
	private var scrollDelay = 60; // Scroll step time in ms
	private var scrollStep = 6; // Number of pixels to proceed on scroll
	private var timer;
	private var overflow = false;

	hidden var textColor = Graphics.COLOR_WHITE;
	hidden var backgroundColor = Graphics.COLOR_TRANSPARENT;
	hidden var font;

	hidden var paddingTop;
	hidden var paddingBottom;

	hidden var textDrawingSpec;

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

		offset = 0;
	}

	function setText(text) {
		me.text = text;
		offset = 0;
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
			posY = drawTextSpec(dc, posY - offset);
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

	function createSpecAndDraw(dc, posY) {
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

	function drawTextSpec(dc, posY) {
		var textParts = textDrawingSpec.getTextParts();
		var height = textDrawingSpec.getlineHeight();
		for (var i = 0; i < textParts.size(); i++) {
			var line = textParts[i];
			drawTextLine(dc, line.getWidth(), height, posY, line.getText());
			posY += height + linePadding;
		}
		return posY;
	}

	function drawTextLine(dc, width, height, posY, text) {
		if (posY < screenHeight && posY + height > 0) {
			dc.setColor(backgroundColor, backgroundColor);
			dc.fillRectangle(0, posY, screenWidth, height + linePadding);
			dc.setColor(textColor, backgroundColor);
			drawText(dc, width, posY, font, text);
		}
	}

	function reset() {
		if (timer != null) {
			timer.stop();
			timer = null;
		}
		offset = 0;
	}

	// Check if text fits on screen, if not, start scrolling
	private function testFit() {
		overflow = textDrawingSpec != null && 
			textDrawingSpec.getScrollTreshold() != 0 &&
			me.height - offset > textDrawingSpec.getScrollTreshold();
		if (timer == null && overflow) {
			offset += scrollStep;
            timer = new Timer.Timer();
            timer.start(method(:scroll), scrollDelay, true);
		} else if (timer != null && !overflow) {
			timer.stop();
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

	function scroll() {
		if (overflow) {
			offset += scrollStep;
		} else {
			offset = 0;
		}
		Ui.requestUpdate();
		testFit();
	}

	public function scrollDown() {
		testFit();
		if (!overflow) {
			return false;
		}
		Ui.requestUpdate();
		return true;
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
