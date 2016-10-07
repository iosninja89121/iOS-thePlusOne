//
//  Engine.m
//
//
//
//

#import "Engine.h"
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "User.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@implementation Engine

//====================================================================================================
+ (id) checkNullValue: (id) value
{
    if(value == nil || [value isKindOfClass: [NSNull class]])
    {
        return @"";
    }
    
    return value;
}

//====================================================================================================
+(BOOL)emailValidate:(NSString *)strEmail
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest =[NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:strEmail];
}

//*****************************************************************************************
+ (BOOL)emailExists:(NSString *)strEmail{
    
    return NO;
}
//====================================================================================================
+(NSDate*)dateWithString:(NSString *)dateSelected{
    
    NSDateFormatter *dateFormatterForGettingDate = [[NSDateFormatter alloc] init];
    
    [dateFormatterForGettingDate setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatterForGettingDate setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ"];
    
    
    NSDate *dateFromStr = [dateFormatterForGettingDate dateFromString:dateSelected];
    return dateFromStr;
    
}

//====================================================================================================
+ (NSString*) getUsername: (NSString*) firstName lastName: (NSString*) lastName
{
    NSString* result = @"";
    if(firstName != nil)
    {
        result = [result stringByAppendingString: firstName];
    }
    if(lastName != nil)
    {
        result = [result stringByAppendingString: [NSString stringWithFormat: @" %@", lastName]];
    }
    
    return result;

}
//====================================================================================================
+ (NSString*) getDiffTime: (double) createdAt
{
    NSString* result = @"";
    NSDate* now = [NSDate date];
    
    float current = [now timeIntervalSince1970];
    NSTimeInterval distanceBetweenDates = current - createdAt;
    if(distanceBetweenDates < 0) distanceBetweenDates = 0;
    
    if(distanceBetweenDates <= 59)
    {
        result = @"Just now";
//        int sec = (int)distanceBetweenDates % 60;
//        if(sec == 1)
//        {
//            result = [NSString stringWithFormat:@"%d second ago", sec];
//        }
//        else
//        {
//            result = [NSString stringWithFormat:@"%d seconds ago", sec];
//        }
    }
    else if((distanceBetweenDates / 60) <= 59)
    {
        int minute = (int)distanceBetweenDates / 60;
        if(minute == 1)
        {
            result = [NSString stringWithFormat:@"%d minute ago", minute];
        }
        else
        {
            result = [NSString stringWithFormat:@"%d minutes ago", minute];
        }
    }
    else if((distanceBetweenDates / 3600) < 24)
    {
        int hour = (int)distanceBetweenDates / 3600;
        if(hour == 1)
        {
            result = [NSString stringWithFormat:@"%d hour ago", hour];
        }
        else
        {
            result = [NSString stringWithFormat:@"%d hours ago", hour];
        }
    }
    else
    {
        int day = (int)distanceBetweenDates / (3600 * 24);
        if(day == 1)
        {
            result = [NSString stringWithFormat:@"%d day ago", day];
        }
        else
        {
            result = [NSString stringWithFormat:@"%d days ago", day];
        }
    }
    
    return result;
}

//====================================================================================================

+ (NSArray*) getPrice: (NSString*) price
{
    if([price floatValue] >= 1000)
    {
        int value = (int)([price floatValue] / 1000.0f);
        NSString* result = [NSString stringWithFormat: @"%dK", value];
        return [NSArray arrayWithObject: result];
    }
    else
    {
        NSMutableArray* arrResult = [[NSMutableArray alloc] init];
        NSArray *listItems = [price componentsSeparatedByString:@"."];
        NSString* dollar = [listItems firstObject];
        [arrResult addObject: dollar];
        
        if([listItems count] > 1)
        {
            int cent = [[listItems lastObject] intValue];
            [arrResult addObject: [NSString stringWithFormat: @"%02i", cent]];
        }

        return arrResult;
    }
}

//====================================================================================================
+ (NSString*) getRate: (int) rate
{
    rate = abs(rate);
    
    if(rate >= 1000)
    {
        return [NSString stringWithFormat: @"%dK", (int)(rate / (float)1000)];
    }
    else
    {
        return [NSString stringWithFormat: @"%d", rate];
    }
}

//====================================================================================================
+ (NSString*) filterText: (NSString*) text
{
    NSString* strFilterText = [text stringByReplacingOccurrencesOfString: @"&amp;" withString: @"&"];
    
    NSMutableArray* arrResult = [[NSMutableArray alloc] init];
    NSMutableArray* wordList = [NSMutableArray arrayWithArray: [strFilterText componentsSeparatedByString: @" "]];
    if(wordList != nil && [wordList count] > 0)
    {
        for(NSString* word in wordList)
        {
            if([word rangeOfString: @"{{uid:"].location != NSNotFound)
            {
                NSArray* temp = [word componentsSeparatedByString: @","];
                NSString* last = [temp objectAtIndex: 1];
                last = [last stringByReplacingOccurrencesOfString: @"}}" withString: @""];
                [arrResult addObject: [NSString stringWithFormat: @"@%@", last]];
            }
            else
            {
                [arrResult addObject: word];
            }
        }
    }
    
    return [arrResult componentsJoinedByString: @" "];
}



//====================================================================================================
+ (float) getDistance: (float) lat1 lng1: (float) lng1 lat2: (float)lat2 lng2: (float)lng2
{
    CLLocation *location1 = [[CLLocation alloc] initWithLatitude:lat1 longitude:lng1];
    CLLocation *location2 = [[CLLocation alloc] initWithLatitude:lat2 longitude:lng2];
    return [location1 distanceFromLocation:location2];
}

//====================================================================================================
+ (NSString*) getFirstName: (NSString*) name;
{
    if(name == nil) return @"";
    
    NSArray* array = [name componentsSeparatedByString: @" "];
    if(array != nil && [array count] > 0)
    {
        return [array firstObject];
    }
    
    return @"";
}

//====================================================================================================
+ (NSString*) getLastName: (NSString*) name
{
    if(name == nil) return @"";
    
    NSArray* array = [name componentsSeparatedByString: @" "];
    if(array != nil && [array count] > 1)
    {
        return [array lastObject];
    }
    
    return @"";
}

//====================================================================================================
+ (NSString*) getOnlyPhoneNumber:(NSString *)phoneNumber
{
    NSString *newString = [[phoneNumber componentsSeparatedByCharactersInSet:
                            [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                           componentsJoinedByString:@""];
    return newString;
}

#pragma mark - 
#pragma mark Comment.

//====================================================================================================
+ (NSString*) getUIDInComment: (NSString*) text username: (NSString*) username
{
    NSString* strFilterText = [text stringByReplacingOccurrencesOfString: @"&amp;" withString: @"&"];
    
    NSMutableArray* arrResult = [[NSMutableArray alloc] init];
    NSMutableArray* wordList = [NSMutableArray arrayWithArray: [strFilterText componentsSeparatedByString: @" "]];
    if(wordList != nil && [wordList count] > 0)
    {
        for(NSString* word in wordList)
        {
            if([word rangeOfString: @"{{uid:"].location != NSNotFound)
            {
                NSArray* temp = [word componentsSeparatedByString: @","];
                NSString* first = [temp objectAtIndex: 0];
                NSString* uid = [first stringByReplacingOccurrencesOfString: @"{{uid:" withString: @""];
                
                NSString* last = [temp objectAtIndex: 1];
                last = [last stringByReplacingOccurrencesOfString: @"}}" withString: @""];
                NSString* itemUsername = [NSString stringWithFormat: @"@%@", last];
                
                if([itemUsername isEqualToString: username])
                {
                    return uid;
                }
            }
            else
            {
                [arrResult addObject: word];
            }
        }
    }
    
    return nil;
}

//====================================================================================================
+ (NSString*) generateCommentID
{
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [formatter setDateFormat: @"yyyyMMddHHmmss"];
    NSString* dateString = [formatter stringFromDate: date];
    
    return [NSString stringWithFormat: @"comment%@", dateString];
}

//====================================================================================================
+ (void) showErrorMessage: (NSString*) title message: (NSString*) message onViewController: (UIViewController*)vc
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [controller addAction:ok];
        [vc presentViewController:controller animated:YES completion:nil];
    });
       
}


//====================================================================================================
+ (void)showMessage:(NSString *)text
{
    [[[UIAlertView alloc] initWithTitle: text
                                message: nil
                               delegate: self
                      cancelButtonTitle: @"OK"
                      otherButtonTitles: nil] show];
}
//*************************************************************************
+ (void) saveProfile: (NSDictionary *)dicResponse{
    
    //init Global
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.profile = [[Profile alloc]initWithDic:dicResponse];
    ///
    
}
//*************************************************************************
+ (void) logout{
    //delete access token
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.accessToken = @"";
    appDelegate.userStatus = USER_STAT_GO_SCHEDULE;
    
    NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
    if([[[defaults dictionaryRepresentation] allKeys] containsObject:KEY_ACCESS_TOKEN]){
        
        [defaults removeObjectForKey:KEY_ACCESS_TOKEN];
        
    }
}
//*************************************************************************
+ (BOOL) isLoggedIn{
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if ([appDelegate.accessToken isEqualToString:@""]) {
        return NO;
    }
    if (appDelegate.accessToken == nil) {
        return NO;
    }
    return YES;
}
//*************************************************************************
+ (void) setUserStatus: (int)n{
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.userStatus = n;
}
+ (int) getUserStatus{
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    return appDelegate.userStatus;
}
//*************************************************************************
+ (void) showStatusBar:(BOOL)flag{
    [[UIApplication sharedApplication] setStatusBarHidden:!flag
                                            withAnimation:UIStatusBarAnimationFade];
}
//*************************************************************************
+ (void) goToViewController: (NSString*) str from: (UIViewController*) src{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *vc = (UIViewController*)[storyboard instantiateViewControllerWithIdentifier:str];
        
        [src.navigationController pushViewController: vc animated:YES ];
    });
    
}

//*************************************************************************
+ (void) setProviders:(NSMutableArray*)providers{
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.arrProviders = providers;
}
+ (NSMutableArray*) getProviders{
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    return appDelegate.arrProviders;
}

//*************************************************************************
+ (void) setWasReviewSession: (BOOL)flag{
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.wasReviewSession = flag;
}
+ (BOOL) getWasReviewSession{
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    return appDelegate.wasReviewSession;
}
//*************************************************************************
+ (NSMutableArray*) getUsers{
    
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    return appDelegate.arrUsers;
}

+(User*) userWithName:(NSString*)name{
    NSMutableDictionary *dicResponse = [[NSMutableDictionary alloc]init];
    [dicResponse setValue:name   forKey:@"name"];
    [dicResponse setValue:@"Psynchologist, PhD"   forKey:@"title"];
    [dicResponse setValue:@"(412) 555 - 1212"      forKey:@"phoneNumber1"];
    [dicResponse setValue:@"(412) 555 - 1212"           forKey:@"phoneNumber2"];
    [dicResponse setValue:@"cindy.arana@family.com"                    forKey:@"emailAddress"];
    [dicResponse setValue:@"February 27, 1967"         forKey:@"birthday"];
    
    [dicResponse setValue:@"http://ww1.prweb.com/prfiles/2012/04/30/9458088/gI_94866_mark-lukin-dds-sugar-land-tx.jpg"
                   forKey:@"photo"];
    
    
    User* user = [[User alloc] initWithDic: dicResponse];
    return user;
    /*
     [arrUsers addObject: user1];
     
     [dicResponse removeAllObjects];
     [dicResponse setValue:@"Aleksander Andrick"   forKey:@"name"];
     [dicResponse setValue:@"2234567890"      forKey:@"phoneNumber1"];
     [dicResponse setValue:@"2122334455"           forKey:@"phoneNumber2"];
     [dicResponse setValue:@"aleksanderandrick@outlook.com"                    forKey:@"emailAddress"];
     [dicResponse setValue:@"May 1, 1981"         forKey:@"birthday"];
     
     [dicResponse setValue:@"http://www.tenne.at/cms/wp-content/uploads/Gutmann-Michael-Tenne-Graz.jpg"
     forKey:@"photo"];
     
     
     User* user2 = [[User alloc] initWithDic: dicResponse];
     [arrUsers addObject: user2];
     */
}
//*************************************************************************
#pragma mark - read/write custom objects
+ (void)saveCustomObject:(NSObject *)object key:(NSString *)key {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:key];
    [defaults synchronize];
    
}

+ (NSObject *)loadCustomObjectWithKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:key];
    NSObject *object = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return object;
}
//*************************************************************************
+ (void)showHUDonView:(UIView*)view{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showHUDAddedTo:view animated:YES];
    });
}
+ (void)hideHUDonView:(UIView*)view{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:view animated:YES];
    });
}
//*************************************************************************
+(void) savePhotoWithId:(NSInteger)iid PhotoData:(NSData*)photoData{
    NSString *key = [NSString stringWithFormat:@"plusOnePhotoData%ld", iid];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:photoData forKey:key];
    [defaults synchronize];
}
+(NSData*) loadPhotoWithId:(NSInteger)iid{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"plusOnePhotoData%ld", iid];
    NSData *photoData = [defaults objectForKey:key];
    if (photoData == nil) {
        
    }
    return photoData;
}
//*************************************************************************
+(NSDate*) dateIn15Increments:(NSDate*)temp{
    //get and change hour and minute to 15-min increments
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:temp];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    
    if (minute < 15) {
        minute = 15;
    }else if(minute < 30){
        minute = 30;
    }else if(minute < 45){
        minute = 45;
    }else{
        minute = 60;
        //        hour++;
    }
    
    [components setHour:hour];
    [components setMinute:minute];
    
    NSDate *result = [calendar dateFromComponents:components];
    return result;
}

+(BOOL) isSpecificAppointment:(Appointment *)appointment specDate:(NSDate *)date {
    NSDate *dateScheduled = [Engine dateWithString:appointment.scheduledTime];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *strScheduled = [dateFormatter stringFromDate:dateScheduled];
    
    NSDateFormatter *dateFormatterSpecific = [[NSDateFormatter alloc] init];
    
    [dateFormatterSpecific setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatterSpecific setDateFormat:@"yyyy-MM-dd"];
    
    NSString *strSpecific = [dateFormatterSpecific stringFromDate:date];
    
    BOOL isEqual = [strScheduled isEqualToString:strSpecific];
    
    return isEqual;
}

//*************************************************************************
+(BOOL) isFutureAppointment:(Appointment*)appointment{
    
    if ([appointment.status isEqualToString:@"completed"]) {
        return NO;
    }
    NSDate *dateAppointment = [Engine dateWithString: appointment.scheduledTime];
    NSDate *datePossiblyCompleted = [Engine dateAfterMinutes:45 fromDate:dateAppointment];
    
    if ([[NSDate date] compare:datePossiblyCompleted] == NSOrderedDescending) {
        return NO;
    }
    return YES;    
}

+(NSDate*) dateAfterMinutes:(NSInteger)minutes fromDate:(NSDate*)temp{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:temp];
    NSInteger minute = [components minute];
    
    
    [components setMinute:minute + minutes];
    
    NSDate *result = [calendar dateFromComponents:components];
    return result;
}
//*************************************************************************
@end
