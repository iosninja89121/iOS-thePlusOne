//
//  User.m
//  thePlusOne
//
//  Created by My Star on 6/24/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import "User.h"

@implementation User

- (id) initWithDic: (NSDictionary*) dicUser{
    if(self = [super init])
    {
        if (![dicUser isKindOfClass:[NSDictionary class]]) {
            return self;
        }
        
        [self updateWithDic:dicUser];
    }
    return self;
}

-(void)updateWithDic:(NSDictionary *)dicUser
{
    self.firstName = [self checkNullValue: [dicUser valueForKey: @"firstName"]];
    self.lastName = [self checkNullValue: [dicUser valueForKey: @"lastName"]];
    self.title = [self checkNullValue: [dicUser valueForKey: @"title"]];
    self.dicPhoneNumber = [self checkNullValueForDictionary:[dicUser valueForKey:@"phoneNumber"]];
    self.homeEmail = [self checkNullValue: [dicUser valueForKey: @"homeEmail"]];
    self.birthday = [self checkNullValue: [dicUser valueForKey: @"birthday"]];
    
//    self.photo = [self checkNullValue: [dicUser valueForKey: @"photo"]];
//    
//    NSURL *url = [NSURL URLWithString:self.photo];
    self.photoData = [dicUser valueForKey: @"photoData"];
    
}
- (id) checkNullValue: (id) value
{
    if(value == nil || [value isKindOfClass: [NSNull class]])
    {
        return @"";
    }
    
    return value;
}

- (id) checkNullValueForDictionary: (id) value
{
    if(value == nil || [value isKindOfClass:[NSNull class]])
    {
        return @[];
    }
    
    return value;
}

@end
