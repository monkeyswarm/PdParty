/*
 * Copyright (c) 2013 Dan Wilcox <danomatika@gmail.com>
 *
 * BSD Simplified License.
 * For information on usage and redistribution, and for a DISCLAIMER OF ALL
 * WARRANTIES, see the file, "LICENSE.txt," in this distribution.
 *
 * See https://github.com/danomatika/PdParty for documentation
 *
 */
#import "Widget.h"

@class Gui;

@interface IEMWidget : Widget

@property (assign, nonatomic) int labelFontStyle; // loaded font style
@property (assign, nonatomic) int labelFontSize; // loaded font size
@property (weak, nonatomic) Gui *gui; // gui pointer needed for edit message reshapes

// reshape label based on gui bounds & scale changes
- (void)reshapeLabelForGui:(Gui *)gui;

#pragma mark Util

// return the font name from a given font style:
// 0: current gui font
// 1: Helvetica
// 2: Times
- (NSString *)fontNameFromStyle:(int)iemFont;

// convert an IEM color to a UIColor
+ (UIColor *)colorFromIEMColor:(int)iemColor;

@end
