//
//  User.h
//  thePlusOne
//
//  Created by My Star on 6/24/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property(nonatomic, strong) NSString *firstName;
@property(nonatomic, strong) NSString *lastName;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSDictionary *dicPhoneNumber;
@property(nonatomic, strong) NSString *homeEmail;
@property(nonatomic, strong) NSDate *birthday;


//@property(nonatomic, strong) NSString *photo;

@property(nonatomic, strong) NSData *photoData;


- (id) initWithDic: (NSDictionary*) dicUser;

@end
