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
	private var offset; // Nr of lines to skip when scrolling
	private var skipped = 0; // Lines skipped
	private var scrollDelay = 5000; // Scroll step time in ms
	private var scrollStep = 3; // Number of lines to proceed on scroll
	private var timer;
	private var overflow = false;

	hidden var textColor = Graphics.COLOR_WHITE;
	hidden var backgroundColor = Graphics.COLOR_TRANSPARENT;
	hidden var font;

	hidden var paddingTop;
	hidden var paddingBottom;

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
		var height = dc.getFontHeight(font);
		var parts = ["", text];
		while (parts.size() == 2) {
			var width = getWidthForLine(posY, height);
			// Now calculate how much fits on the line
			parts = lineSplit(dc, parts[1], font, width);
			if (offset <= skipped) {
				dc.setColor(backgroundColor, backgroundColor);
				dc.fillRectangle(0, posY, screenWidth, height + linePadding);
				dc.setColor(textColor, backgroundColor);
				drawText(dc, width, posY, font, parts[0]);
				posY += height + linePadding;
			} else {
				skipped++;
			}
		}

		// Bottom padding handling
		if (paddingBottom >= 0) {
			dc.setColor(backgroundColor, backgroundColor);
			dc.fillRectangle(0, posY, screenWidth, paddingBottom);
			posY += paddingBottom;
		}

		me.height = posY;
	}

	function reset() {
		if (timer != null) {
			timer.stop();
			timer = null;
		}
		offset = 0;
	}

	// Check if text fits on screen, if not, start scrolling
	private function testFit(posY) {
		overflow = posY > screenHeight;
		if (timer == null && overflow) {
            timer = new Timer.Timer();
            timer.start(method(:scroll), scrollDelay, true);
		}
		skipped = 0;
	}

	// Splits the text into a part that fits on the line, and the remaining text
	private function lineSplit(dc, text, font, width) {
		var os = 0;
		var parts = wordSplit(text, os);
		var count = 0;
		while (parts.size() == 2 && count < 10) {
			var newParts = wordSplit(text, parts[0].length() + 1);
			if (dc.getTextWidthInPixels(newParts[0], font) > width) {
                break;
			}
			count++;
			parts = newParts;
		}
		return parts;
	}

	// Splits the subject into first word and remaining text (if exists)
	private function wordSplit(subject, start) {
		var len = subject.length();
		var substr = subject.substring(start, len);
		var ptr = substr.find(" ");
		return ptr == null ? 
            [subject] : 
            [subject.substring(0, ptr + start), subject.substring(ptr+start + 1, len)];
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

	hidden function scroll() {
		if (overflow) {
			offset += scrollStep;
		} else {
			offset = 0;
		}
		Ui.requestUpdate();
	}

	private function scrollDown() {
		if (!overflow) {
			return false;
		}
		offset += 3;
		timer.stop();
		timer.start(method(:scroll), scrollDelay, true);
		Ui.requestUpdate();
		return true;
	}

}
