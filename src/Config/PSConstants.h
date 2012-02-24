//
//  PSConstants.h
//  PSKit
//
//  Created by Peter Shih on 8/9/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

// Global Imports
#import "PSStyleSheet.h"
#import "PSObject.h"
#import "PSView.h"
#import "PSCell.h"
#import "PSImageView.h"
#import "PSRandomSortDescriptor.h"
//#import "PSNavigationBar.h"
#import "PSErrorView.h"
#import "PSTextField.h"
#import "PSTextView.h"
#import "PSSearchField.h"
#import "CoreGraphics-PSKit.h"

// Import PSKit Categories
#import "PSCategories.h"

#ifdef __APPLE__
#include "TargetConditionals.h"
#endif

/**
 Macros
 */
// declare a temporary block version of a variable; use to prevent retain cycles
#define BLOCK_VAR(block_var, original_var) __block __typeof__(original_var) block_var = original_var

// declare a temporary block version of self called blockSelf; use to prevent retain cycles
#define BLOCK_SELF BLOCK_VAR(blockSelf, self)

// check if an object is not nil and not NSNull
#define NOT_NULL(obj) \
({ id _obj = (obj); _obj && !IS_KIND(_obj, NSNull); })


// return the object if it is non-nil, or else return NSNull
#define OBJ_OR_NULL(obj) \
({ id _obj = (obj); _obj ? _obj : [NSNull null]; })

// return the object if it is non-nil, or else return nil
#define OBJ_OR_NIL(obj) \
({ id _obj = (obj); _obj ? _obj : nil; })

/**
 Device
 */
#define IS_DEVICE_PHONE ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
#define IS_DEVICE_RETINA ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2)
#define IS_DEVICE_MULTITASKING ([[UIDevice currentDevice] multitaskingSupported])

/**
 Alert Tags
 */
#define kAlertFacebookPermissionsPublish 7001

/**
 Notifications
 */


// Math Macros
#define RADIANS(degrees) ((degrees * M_PI) / 180.0)
#define DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0)
#define RADIANS_TO_DEGREES(x) ((x) * 180.0 / M_PI)
#define CLAMP(x, min, max) (MAX((min), MIN((max), (x))))

#define CENTERED_WITHIN(smaller, bigger) (floor(((bigger) - (smaller)) / 2.0))
#define HOURS_AGO(x) (60.0 * 60.0 * (x) * -1.0)

// Convenience Macros
#define APP [UIApplication sharedApplication]
#define APP_DELEGATE [[UIApplication sharedApplication] delegate]
#define APP_DEFAULTS [NSUserDefaults standardUserDefaults]
#define APP_BUNDLE [NSBundle mainBundle]
#define APP_FILEMANAGER [NSFileManager defaultManager]
#define APP_BOUNDS (CGRect)[[[UIApplication sharedApplication] keyWindow] bounds]

// This is always 320x480
#define APP_SCREEN_BOUNDS (CGRect)[[UIScreen mainScreen] bounds]

// This changes based on statusBar hidden
#define APP_FRAME (CGRect)[APP_SCREEN applicationFrame]


// Directory Macros
#define APP_DOCUMENTS [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
#define APP_CACHES [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]

/**
 View Macros
 */
#define UIViewAutoresizingFlexibleAllMargins (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin)
#define UIViewAutoresizingFlexibleSize (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)

/**
 Locale/Language
 */
#define USER_LANGUAGE [[NSLocale preferredLanguages] objectAtIndex:0]
#define USER_LOCALE [[NSLocale autoupdatingCurrentLocale] localeIdentifier]

/**
 Colors
 */
#define RGBCOLOR(R,G,B) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1.0]
#define RGBACOLOR(R,G,B,A) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]

/**
 Logging Macros
 */
#ifdef DEBUG
#	define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#	define DLog(...)
#endif

#define VERBOSE_DEBUG
#ifdef VERBOSE_DEBUG
#define VLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define VLog(...)
#endif

// ALog always displays output regardless of the DEBUG setting
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

/**
 Safe Releases
 */
#define RELEASE_SAFELY(__POINTER) { if (nil != (__POINTER)) { [__POINTER release]; __POINTER = nil; } }
#define RELEASE_CF_SAFELY(__REF) { if (nil != (__REF)) { CFRelease(__REF); __REF = nil; } }
#define INVALIDATE_TIMER(__TIMER) { [__TIMER invalidate]; __TIMER = nil; }
#define INVALIDATE_AND_RELEASE_TIMER(__TIMER) { [__TIMER invalidate]; [__TIMER release]; __TIMER = nil; }

#define CLEAR_DELEGATES(__REF) { if (__REF.delegate != nil) { __REF.delegate = nil; } }
#define CLEAR_DATASOURCES(__REF) { if (__REF.dataSource != nil) { __REF.dataSource = nil; } }

/**
 Regex
 */
// Gruber's regex for finding URLs in a string (http://daringfireball.net/2009/11/liberal_regex_for_matching_urls)
//
// \b(([\w-]+://?|www[.])[^\s()<>]+(?:\([\w\d]+\)|([^[:punct:]\s]|/)))
//
// Also with the help of Apple's regular expression guide:
//
// http://developer.apple.com/iphone/library/documentation/General/Conceptual/iPadProgrammingGuide/Text/Text.html
//
#define kFLURLRegex (@"\\b(([\\w-]+://?|www[.])[^\\s()<>]+(?:\\([\\w\\d]+\\)|([^[:punct:]\\s]|/)))")
#define kFLAtReplyRegex  (@"\\B(\\@\\w*|\\s+$)") // Regex for getting @replies in tweets
#define kFLHashtagRegex  (@"\\B(\\#\\w*|\\s+$)") // Regex for getting #hashtags in tweets

/**
 Is Multitasking supported?
 */
static BOOL isMultitaskingSupported() {
  return [UIDevice currentDevice].multitaskingSupported;
}

/**
 Detect iPad
 */
static BOOL isDeviceIPad() {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    return YES; 
  }
#endif
  return NO;
}

/**
 Is Yelp installed?
 */
static BOOL isYelpInstalled() {
  return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"yelp:"]];
}

/**
 System Versioning Preprocessor Macros
 */ 
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)