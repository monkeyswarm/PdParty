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
#import <Foundation/Foundation.h>

#define CLAMP(val, min, max) MIN(MAX(val, min), max) // clamp between a min & max
#define RADIANS(degrees) ((degrees)*(M_PI/180)) // degrees to radians
#define DEGREES(radians) ((radians)*(180/M_PI)) // radians to degrees

@interface Util : NSObject

#pragma mark Device

// are we running in the simulator?
+ (BOOL)isDeviceRunningInSimulator;

// is this device an ipad?
+ (BOOL)isDeviceATablet;

// get device iOS version as a float aka 6.1, 7.02, etc
+ (float)deviceOSVersion;

#pragma mark App

// application pixel dimensions, does not include status bar
+ (CGFloat) appWidth;
+ (CGFloat) appHeight;
+ (CGSize) appSize;

#pragma mark Logging Shortcuts

// print the pos & size of a CGRect
+ (void)logRect:(CGRect)rect;
+ (void)logRect:(CGRect)rect withHeader:(NSString *)header;

// print an NSArray, uses object description strings
+ (void)logArray:(NSArray *)array;

// print NSData as raw hex bytes
+ (void)logData:(NSData *)data withHeader:(NSString *)header;

// print a UIColor as RGBA components
+ (void)logColor:(UIColor *)color;

#pragma mark Paths

// full path to the app bundle directory
+ (NSString *)bundlePath;

// full path to the Resources directory
+ (NSString *)resourcePath;

// full path to the Documents directory
+ (NSString *)documentsPath;

// returns YES if given path exists and is a directory
+ (BOOL)isDirectory:(NSString *)path;

// recursively copy srcFolder's contents to destFolder, overrites existing files
+ (BOOL)copyContentsOfFolder:(NSString *)srcFolder toFolder:(NSString *)destFolder error:(NSError *)error;

#pragma mark Images

// renders a given string into a UIImage
+ (UIImage *)imageFromString:(NSString *)string withFont:(UIFont*)font;

// returns a tinted copy of a given image
+ (UIImage *)image:(UIImage *)image withTint:(UIColor *)tint;

#pragma mark Fonts

// register font file with the CoreText font manager,
// returns font family name on success or nil on failure
+ (NSString *)registerFont:(NSString *)fontPath;

// unregister font file with the CoreText font manager
+ (void)unregisterFont:(NSString *)fontPath;

#pragma mark JSON

// parses JSON from a file into an NSDictionary or NSArray,
// returns nil on error
+ (id)parseJSONFromFile:(NSString *)path;

@end

#pragma mark Array Category

@interface NSArray (EasyTypeCheckArray)

// check object type at array pos
- (BOOL)isNumberAt:(int)index;
- (BOOL)isStringAt:(int)index;

@end

#pragma mark String Category

@interface NSMutableString (CharSetString)

- (void)setCharacter:(unichar)c atIndex:(unsigned)i;

@end

#pragma Image Category

@interface UIImage (OverlayColor)

- (UIImage *)imageWithColor:(UIColor *)color;

@end
