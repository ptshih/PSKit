//
//  PSConstants.h
//  SevenMinuteLibrary
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
#import "PSNavigationBar.h"
#import "PSNullView.h"
#import "PSTextField.h"
#import "PSTextView.h"
#import "PSSearchField.h"

// Import PSKit Categories
#import "PSCategories.h"

// Import any project-specific constants here
#import "AppDelegate.h"

#ifdef __APPLE__
#include "TargetConditionals.h"
#endif

#define RADIANS(degrees) ((degrees * M_PI) / 180.0)

// App Delegate Macro
#define APP_DELEGATE ((AppDelegate *)[[UIApplication sharedApplication] delegate])

/**
 Alert Tags
 */
#define kAlertFacebookPermissionsPublish 7001

/**
 Locale/Language
 */
#define USER_LANGUAGE [[NSLocale preferredLanguages] objectAtIndex:0]
#define USER_LOCALE [[NSLocale autoupdatingCurrentLocale] localeIdentifier]

/**
 Core Data (FILL THIS IN LOCAL CONSTANTS)
 */
//#define CORE_DATA_SQL_FILE
//#define CORE_DATA_MOM

#define RGBCOLOR(R,G,B) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1.0]
#define RGBACOLOR(R,G,B,A) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]

/**
 Font Defines
 */
#define PS_CAPTION_FONT [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0]
#define PS_TITLE_FONT [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0]
#define PS_LARGE_FONT [UIFont fontWithName:@"HelveticaNeue" size:16.0]
#define PS_NORMAL_FONT [UIFont fontWithName:@"HelveticaNeue" size:14.0]
#define PS_BOLD_FONT [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0]
#define PS_SUBTITLE_FONT [UIFont fontWithName:@"HelveticaNeue" size:12.0]
#define PS_TIMESTAMP_FONT [UIFont fontWithName:@"HelveticaNeue" size:10.0]
#define PS_NAV_BUTTON_FONT [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0]

/**
 Notifications
 */
#define kApplicationBackgrounded @"ApplicationBackgrounded"
#define kApplicationForegrounded @"ApplicationForegrounded"
#define kApplicationResumed @"ApplicationResumed"
#define kApplicationSuspended @"ApplicationSuspended"
#define kCoreDataDidReset @"CoreDataDidReset"
#define kPSImageCacheDidCacheImage @"PSImageCacheDidCacheImage"


/**
 Logging Macros
 */
#ifdef DEBUG
#	define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#	define DLog(...)
#endif

// Define this in Constants.h
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
#define RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }
#define INVALIDATE_TIMER(__TIMER) { [__TIMER invalidate]; __TIMER = nil; }
#define INVALIDATE_AND_RELEASE_TIMER(__TIMER) { [__TIMER invalidate]; [__TIMER release]; __TIMER = nil; }
// Release a CoreFoundation object safely.
#define RELEASE_CF_SAFELY(__REF) { if (nil != (__REF)) { CFRelease(__REF); __REF = nil; } }

/**
 Is Yelp installed?
 */
static BOOL isYelpInstalled() {
  return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"yelp:"]];
}

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