//
//  Schedule.h
//  thePlusOne
//
//  Created by My Star on 7/8/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Appointment : NSObject

@property(nonatomic) NSInteger iid;
@property(nonatomic) NSInteger userId;
@property(nonatomic) NSInteger providerId;

@property(nonatomic, strong) NSString *scheduledTime;

@property(nonatomic, strong) NSString *status;
@property(nonatomic) NSInteger rating;

@property(nonatomic, strong) NSString *feedback;

@property(nonatomic, strong) NSString *createdTime;
@property(nonatomic, strong) NSString *updatedTime;
@property(nonatomic, strong) NSString *endTime;

@property(nonatomic, strong) NSString *apiKey;
@property(nonatomic, strong) NSString *sessionId;
@property(nonatomic, strong) NSString *token;

@property(nonatomic) BOOL isPlueOne;
@property(nonatomic, strong) NSData *plusOnePhotoData;

- (id) initWithDic: (NSDictionary*) dic;

@end


