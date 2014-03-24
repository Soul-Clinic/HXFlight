//
//  Common.h
//  Scratch
//
//  Created by Can EriK Lu on 9/3/13.
//  Copyright (c) 2013 Can EriK Lu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIView+Position.h"

//#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

#define kMoreAppsResourcesDirectory @".MoreApps"

UIColor* rgba(int r, int g, int b, float a);
UIColor* rgb(int r, int g, int b);

NSArray* imagesWithNames(NSArray* names);
BOOL isRetina();

NSString* documentDirectory();
NSString* deviceInformation();
NSString* machineName();
NSString* systemInfo(NSString* productName);
BOOL isSimulator();

void logSize(NSString* format, CGSize size);
void logFrame(NSString* text, UIView* view);
void printClassTrees(id object);
BOOL isiOS7();
void FELogError(NSString* format, ...);
NSString* getLanguageCode();
@interface UIColor(Image)
- (UIImage*)image;
@end

@interface UIImage(Resize)
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
@end



#define userDefaultsValueForKey(key) [[NSUserDefaults standardUserDefaults] objectForKey:key]
#define userDefaultsStringForKey(key) [[NSUserDefaults standardUserDefaults] stringForKey:key]
#define userDefaultsBoolForKey(key) [[NSUserDefaults standardUserDefaults] boolForKey:key]
#define userDefaultsIntegerForKey(key) [[NSUserDefaults standardUserDefaults] integerForKey:key]
#define userDefaultsFloatForKey(key) [[NSUserDefaults standardUserDefaults] floatForKey:key]

#define setUserDefaults(key, obj) [[NSUserDefaults standardUserDefaults] setValue:obj forKey:key]

@interface Common : NSObject
+ (NSString*)textToHtml:(NSString*)htmlString;
+ (UIViewController*)topViewController;
+ (NSMutableURLRequest*)jsonRequestURL:(NSURL*)url withParams:(NSDictionary*)params;
+ (NSMutableURLRequest*)requestURL:(NSURL*)url withParams:(NSDictionary*)params andImage:(UIImage*)image withName:(NSString*)imageFieldName;
+ (UIImage*)imageFromText:(NSString*)text maxWidth:(float)width;
@end