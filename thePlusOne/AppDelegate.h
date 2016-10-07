//
//  AppDelegate.h
//  thePlusOne
//
//  Created by My Star on 6/15/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Appointment.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

//global data
@property(nonatomic) int userStatus;
@property(nonatomic, strong) NSMutableArray *arrProviders;
@property(nonatomic, strong) NSMutableArray *arrFilteredProviders;
@property(nonatomic) BOOL wasReviewSession; /*shows if user came to landing page from review session page*/
@property(nonatomic, strong) NSMutableArray *arrUsers;
@property(nonatomic) BOOL connectionFailed;
@property(nonatomic) NSInteger selectedProviderIndex;
@property(nonatomic, strong) NSNumber *selectedProviderId;
@property(nonatomic, strong) Appointment *currentAppointment;
@property(nonatomic, strong) NSDate *startDate;
@property(nonatomic, strong) NSMutableArray *arrAppointments;
@property(nonatomic) int joinMode;

@property(nonatomic, strong) NSString *recipientPhoneNumber;//of the person to get gift session(s)
@property(nonatomic, strong) NSString *recipientFirstName;
@property(nonatomic, strong) NSString *recipientLastName;
@property(nonatomic, strong) NSData *recipientPhotoData;

@property(nonatomic) NSInteger inviteId;
@property(nonatomic) NSInteger inviteMode;
@property(nonatomic, strong) Appointment* invitedAppointment;

@property(nonatomic, strong) NSString *inviteCode;

//post profile to backend first time
//@property(nonatomic) BOOL isFirstTime;

//saved data
@property(nonatomic, strong) Profile *profile;
@property(nonatomic, strong) NSString *accessToken;

//core data
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory; // nice to have to reference files for core data

@end

