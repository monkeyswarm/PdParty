/*
 * Copyright (c) 2011 Dan Wilcox <danomatika@gmail.com>
 *
 * BSD Simplified License.
 * For information on usage and redistribution, and for a DISCLAIMER OF ALL
 * WARRANTIES, see the file, "LICENSE.txt," in this distribution.
 *
 * See https://github.com/danomatika/robotcowboy for documentation
 *
 */
#import "Widget.h"
#import "Log.h"
#import "Util.h"

#import "Slider.h"

// default pd gui font
#define GUI_FONT_NAME @"DejaVu Sans Mono"

// make font a little bigger compared to in the pd gui
#define GUI_FONT_SCALE 1.5

@class PdFile;

@interface Gui : NSObject

// widget array
@property (strong) NSMutableArray *widgets;

// current view bounds
@property (assign) CGRect bounds;

// currently loaded patch
@property (strong) PdFile *currentPatch;

// pixel size of original pd patch
@property (assign) int patchWidth;
@property (assign) int patchHeight;

// font size loaded from patch
@property (assign) int fontSize;

// scale amount between view bounds and original patch size
@property (assign) float scaleX;
@property (assign) float scaleY;

// add a widget using a given atom line (array of NSStrings)
- (void)addComment:(NSArray*)atomLine;
- (void)addNumberbox:(NSArray*)atomLine;
- (void)addBang:(NSArray*)atomLine;
- (void)addToggle:(NSArray*)atomLine;
- (void)addSlider:(NSArray*)atomLine withOrientation:(SliderOrientation)orientation;
- (void)addCanvas:(NSArray*)atomLine;

// add widgets from an array of atom lines
- (void)addWidgetsFromAtomLines:(NSArray*)lines;

// add widgets from a pd patch
- (void)addWidgetsFromPatch:(NSString*)patch;

#pragma Utils

// filter empty values and replace any ocurrances of $0 with the current patch id
- (NSString*)formatAtomString:(NSString*)string;

// replace any occurrances of "//$0" or "$0" with the current patches' dollar zero id
- (NSString*)replaceDollarZeroStringsIn:(NSString*)string;

// convert atom string empty values to an empty string
// nil, @"-", & @"empty" -> @""
+ (NSString *)filterEmptyStringValues:(NSString*)atom;

// convert an IEM color to a UIColor
+ (UIColor*)colorFromIEMColor:(int)iemColor;

@end
