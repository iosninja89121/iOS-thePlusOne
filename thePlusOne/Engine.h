//
//  Engine.h
//  shopcrew
//
//  Created by jian on 4/13/15.
//  Copyright (c) 2015 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Profile.h"
#import "Constants.h"
#import "Appointment.h"

@interface Engine : NSObject
{
    
}

+ (id) checkNullValue: (id) value;
+ (BOOL)emailValidate:(NSString *)strEmail;
+ (BOOL)emailExists:(NSString *)strEmail;

+ (NSString*) filterText: (NSString*) text;
+ (float) getDistance: (float) lat1 lng1: (float) lng1 lat2: (float)lat2 lng2: (float)lng2;
+ (NSString*) getDiffTime: (double) createdAt;

+ (NSArray*) getPrice: (NSString*) price;
+ (NSString*) getRate: (int) rate;
+ (NSString*) getUsername: (NSString*) firstName lastName: (NSString*) lastName;
+ (NSString*) getFirstName: (NSString*) name;
+ (NSString*) getLastName: (NSString*) name;
+ (NSString*) getOnlyPhoneNumber: (NSString*) phoneNumber;

//Comment.
+ (NSString*) getUIDInComment: (NSString*) text username: (NSString*) username;
+ (NSString*) generateCommentID;

+ (void) showErrorMessage: (NSString*) title message: (NSString*) message  onViewController: (UIViewController*)vc;
+ (void) showMessage:(NSString *)text;

//profile
+ (void) saveProfile: (NSDictionary *)dicProfile;

//logged in flag
+ (BOOL) isLoggedIn;
+ (void) logout;

//user status
+ (void) setUserStatus: (int)n;
+ (int) getUserStatus;

//show/hide status bar
+ (void) showStatusBar: (BOOL)flag;

//go to specific view controller
+ (void) goToViewController: (NSString *)str from:(UIViewController*)src;

//set/get arrProviders
+ (void) setProviders:(NSMutableArray*)providers;
+ (NSMutableArray*) getProviders;

//set/get wasReviewSession
+ (void) setWasReviewSession: (BOOL)flag;
+ (BOOL) getWasReviewSession;

//get users
+ (NSMutableArray*) getUsers;

//load/save custom objects
+ (void)saveCustomObject:(NSObject *)object key:(NSString *)key ;
+ (NSObject *)loadCustomObjectWithKey:(NSString *)key ;

//show/hide HUD
+ (void)showHUDonView:(UIView*)view;
+ (void)hideHUDonView:(UIView*)view;

+(NSDate*)dateWithString:(NSString *)dateSelected;

//save appiontment id with photodata
+(void) savePhotoWithId:(NSInteger)iid PhotoData:(NSData*)photoData;
+(NSData*) loadPhotoWithId:(NSInteger)iid;

//get date in 15 min increments
+(NSDate*) dateIn15Increments:(NSDate*)temp;

//is the appointment for today?
+(BOOL) isSpecificAppointment:(Appointment *)appointment specDate:(NSDate *)date;

//is the appointment future one?
+(BOOL) isFutureAppointment:(Appointment*)appointment;

//get date after certain minutes
+(NSDate*) dateAfterMinutes:(NSInteger)minutes fromDate:(NSDate*)temp;
@end
