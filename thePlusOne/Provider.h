//
//  News.h
//  IFCC
//
//  Created by My Star on 6/13/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Provider : NSObject

@property(nonatomic, strong) NSNumber *identifier;//=userId in response

//@property(nonatomic, strong) NSString *userId;

@property(nonatomic, strong) NSString *pictureUrl;

@property(nonatomic, strong) NSString *phoneNumber;

@property(nonatomic, strong) NSString *license;

@property(nonatomic, strong) NSString *npiNumber;

@property(nonatomic, strong) NSString *experience;

@property(nonatomic, strong) NSString *title;

@property(nonatomic, strong) NSString *bio;

@property(nonatomic, strong) NSString *rating;

@property(nonatomic, strong) NSString *firstName;

@property(nonatomic, strong) NSString *lastName;

@property(nonatomic, strong) NSString *location;
@property(nonatomic, strong) NSString *department;
@property(nonatomic, strong) NSString *specialties;
//@property(nonatomic, strong) NSString *available;
@property(nonatomic, strong) NSString *photo;

@property(nonatomic, strong) NSData *pictureData;

@property(nonatomic, strong) NSDictionary *availability;
@property(nonatomic, strong) NSDictionary *openSessionTimes;

- (id) initWithDic: (NSDictionary*) dicProvider;

@end
