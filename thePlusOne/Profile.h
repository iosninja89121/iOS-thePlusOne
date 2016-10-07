//
//  Profile.h
//  thePlusOne
//
//  Created by My Star on 6/24/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Profile : NSObject

@property(nonatomic, strong) NSNumber *profileId;
@property(nonatomic, strong) NSNumber *userId;
@property(nonatomic, strong) NSString *firstName;
@property(nonatomic, strong) NSString *lastName;
@property(nonatomic, strong) NSString *emailAddress;
@property(nonatomic, strong) NSString *password;
@property(nonatomic, strong) NSString *photo;

@property(nonatomic, strong) NSData *photoData;

@property(nonatomic) NSInteger sessionsAvailable;
@property(nonatomic) NSInteger sessionsCompleted;
@property(nonatomic) NSInteger sessionsPurchased;

- (id) initWithDic: (NSDictionary*) dicProfile;

@end
