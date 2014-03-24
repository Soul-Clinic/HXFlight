//
//  Common.m
//  Scratch
//
//  Created by Can EriK Lu on 9/3/13.
//  Copyright (c) 2013 Can EriK Lu. All rights reserved.
//

#import "Common.h"
#import <sys/utsname.h>
#define kUMengEventError			@"Error"


NSString* machineName()
{
    struct utsname systemInfo;
    uname(&systemInfo);

    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

NSString* systemInfo(NSString* productName)
{
	NSString* productVersion = [NSBundle mainBundle].infoDictionary[(NSString*)kCFBundleVersionKey];
    NSString* machinVersion = machineName();
    if ([machinVersion hasPrefix:@"iPhone6"]) {
        machinVersion = [machinVersion stringByAppendingString:@"(iPhone 5s)"];
    }
    UIDevice *device = [UIDevice currentDevice];
    NSString* systemInfo = [NSString stringWithFormat:@"%@(%@)",device.systemName, device.systemVersion];
    NSLocale *enLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSString* localeIdentifier = [[NSLocale currentLocale] localeIdentifier];
    NSString* locale = [NSString stringWithFormat:@"%@ %@", localeIdentifier, [enLocale displayNameForKey:NSLocaleIdentifier value:localeIdentifier]];

    NSString* information = [NSString stringWithFormat:
                             @"\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n---------------------------------------\nSystem:%@\nDevice:%@\n%@ version:%@\nLocale:%@\n---------------------------------------\n",
                             systemInfo, machinVersion, productName, productVersion, locale];

    return information;
}

UIColor* rgba(int r, int g, int b, float a)
{
    return [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a];;
}
UIColor* rgb(int r, int g, int b)
{
    return rgba(r, g, b, 1.0);
}

NSArray* imagesWithNames(NSArray* names)
{
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:names.count];

    for (NSString* name in names) {
        [array addObject:[UIImage imageNamed:name]];
    }
    return array;
}
BOOL isRetina()
{
	return [UIScreen mainScreen].scale == 2.0;
}

NSString* documentDirectory()
{
    static NSString* path;
    if (!path) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        path = paths[0];
        FELog(@"Document directory -> %@", path);
    }

    return path;
}

NSString* deviceInformation()
{
    UIDevice *device = [UIDevice currentDevice];

    return [NSString stringWithFormat:@"\nMachine Name = %@\nName = %@\nSystem Name = %@\t System version = %@\nModal = %@\tLocalized Modal = %@\nIdiom = %@\nDevice ID = %@\nLocale lanugate = %@", machineName(),
            device.name, device.systemName, device.systemVersion, device.model, device.localizedModel,
            device.userInterfaceIdiom == UIUserInterfaceIdiomPhone ? @"UIUserInterfaceIdiomPhone" : @"UIUserInterfaceIdiomPad" , device.identifierForVendor.UUIDString, [NSLocale preferredLanguages][0]];

}
#pragma mark - Objects related
void printClassTrees(id object)
{
    Class class = [object class];
	FELog(@"Self --> %@", NSStringFromClass(class));

    while ([class superclass] != [NSObject class]) {
        class = [class superclass];
        FELog(@"Super -> %@", NSStringFromClass(class));
    }

    FELog(@"Super -> NSObject\n-------------\n");
}

#pragma mark -

BOOL isSimulator()
{
#if TARGET_IPHONE_SIMULATOR
    //[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kBinaryName];
    return YES;
#else
	return NO;
#endif

}

BOOL isiOS7() {
    return floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1;
}

void logSize(NSString* format, CGSize size)
{
    NSLog(format, NSStringFromCGSize(size));
}
void logFrame(NSString* text, UIView* view)
{
    FELog(@"%@  -->  %@", text, NSStringFromCGRect(view.frame));
}
void FELogError(NSString* format, ...)
{
    va_list args;
    va_start(args, format);
#ifdef __FEDEBUG
    NSLogv(format, args);
#else
//    NSString* content = [[NSString alloc] initWithFormat:format arguments:args];
//	[MobClick event:kUMengEventError label:content];
#endif
    va_end(args);

}
NSString* getLanguageCode(void)
{
    return [[NSLocale preferredLanguages] objectAtIndex:0];
}

@implementation UIColor(Image)

-(UIImage *)image
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [self CGColor]);
    CGContextFillRect(context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}
@end


@implementation UIImage(Resize)

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {

    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);

    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    
    return newImage;
}

@end




@implementation Common

+ (NSString*)textToHtml:(NSString*)htmlString
{
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&"  withString:@"&amp;"];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<"  withString:@"&lt;"];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@">"  withString:@"&gt;"];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"""" withString:@"&quot;"];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"'"  withString:@"&#039;"];
    htmlString = [@"<p>" stringByAppendingString:htmlString];
    htmlString = [htmlString stringByAppendingString:@"</p>"];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"\n" withString:@"</p><p>"];

    while ([htmlString rangeOfString:@"  "].length > 0) {
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"  " withString:@"&nbsp;&nbsp;"];
    }
    return htmlString;
}


+ (UIViewController*)topViewController
{
    return [Common topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}


+ (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController
{
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [Common topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [Common topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [Common topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}

+ (NSMutableURLRequest*)jsonRequestURL:(NSURL*)url withParams:(NSDictionary*)params
{
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField: @"Content-Type"];
	NSError* error;
	NSData* json = [NSJSONSerialization dataWithJSONObject:params options:kNilOptions error:&error];
    NSLog(@"Json -> %@", [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding]);
    NSMutableData *body = [NSMutableData dataWithData:json];

    if (error != nil) {
        NSLog(@"Error when converting to json -> %@", error);
        return nil;
    }

    [request setHTTPBody:body];

    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];

    // set URL
    [request setURL:url];

    return request;
}

+ (NSMutableURLRequest*)requestURL:(NSURL*)url withParams:(NSDictionary*)params andImage:(UIImage*)image withName:(NSString*)imageFieldName
{
    // the boundary string : a random string, that will not repeat in post data, to separate post data fields.
    NSString* const BoundaryConstant = @"----------Apps-with-Love";

    // create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];

    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];

    // post body
    NSMutableData *body = [NSMutableData data];

    // add params (all params are strings)
    for (NSString *key in params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", params[key]] dataUsingEncoding:NSUTF8StringEncoding]];
    }

    if (image && imageFieldName) {

        // add image data
        NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
        NSLog(@"Image data length = %i", imageData.length);
        if (imageData) {
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", imageFieldName] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:imageData];
            [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }

    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];

    // setting the body of the post to the reqeust
    [request setHTTPBody:body];

    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];

    // set URL
    [request setURL:url];

    return request;
}

+ (UIImage*)imageFromText:(NSString*)text maxWidth:(float)width
{
    //    const float padding = 10, paddingBottom = 50;
    const float fontSize = 10.f;
    NSStringDrawingContext* dc = [[NSStringDrawingContext alloc] init];
    dc.minimumScaleFactor = [UIScreen mainScreen].scale;

    //   CGContextSetFillColorWithColor(context, [UIColor purpleColor].CGColor);		//Background
    //CGContextFillRect(context, rect);
    //		Or draw a background image
    UIEdgeInsets padding = UIEdgeInsetsMake(54, 45, 44, 50);
    UIImage* background = [[UIImage imageNamed:@"letterpaper.jpg"] resizableImageWithCapInsets:padding resizingMode:UIImageResizingModeStretch];

    NSLog(@"Image size = %@", NSStringFromCGSize(background.size));
    //iOS 7
    CGRect rect = [text boundingRectWithSize:CGSizeMake(background.size.width - padding.left - padding.right, MAXFLOAT)
                                     options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin)
                                  attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]}
                                     context:dc];

    NSLog(@"Text boudning rect = %@", NSStringFromCGRect(rect));

	CGSize canvas = CGSizeMake(background.size.width, rect.size.height + padding.top + padding.bottom);

    UIGraphicsBeginImageContextWithOptions(canvas, NO, 0);

    //	CGContextRef context = UIGraphicsGetCurrentContext();
    [background drawInRect:CGRectMake(0, 0, canvas.width, canvas.height)];


    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:24];
    //    [attString addAttribute:NSParagraphStyleAttributeName
    //                      value:style
    //                      range:NSMakeRange(0, strLength)];

    [text drawInRect:UIEdgeInsetsInsetRect(CGRectMake(0, 0, canvas.width, canvas.height), padding) withAttributes:
     @{NSFontAttributeName: [UIFont systemFontOfSize:fontSize],
       NSForegroundColorAttributeName: [UIColor blackColor]//,	NSParagraphStyleAttributeName: style
       }];

    NSString* brand = @"By Instantly";
	CGRect brandSize = [brand boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                           options:kNilOptions
                                        attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13.f]}
                                           context:nil];
    //rect.size.width - brandSize.size.width - padding / 4     Draw in left in case of the Weibo logo
	CGRect drawingRect = CGRectMake(30, canvas.height - brandSize.size.height - 12, brandSize.size.width, brandSize.size.height);
    [brand drawInRect:drawingRect
       withAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Thonburi" size:13.f], NSForegroundColorAttributeName:rgb(10, 140, 210)}];

    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData* jpeg = UIImageJPEGRepresentation(image, 1.f);
    NSData* png = UIImagePNGRepresentation(image);
    NSLog(@"Jpeg length = %i\tPng length = %i", jpeg.length / 1024, png.length / 1024);
    
    return image;
}


@end








