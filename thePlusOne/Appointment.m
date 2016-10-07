//
//  Schedule.m
//  thePlusOne
//
//  Created by My Star on 7/8/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import "Appointment.h"

@implementation Appointment

- (id) initWithDic: (NSDictionary*) dic{
    if(self = [super init])
    {
        if (![dic isKindOfClass:[NSDictionary class]]) {
            return self;
        }
        
        [self updateWithDic:dic];
    }
    return self;
}

-(void)updateWithDic:(NSDictionary *)dic
{
    self.iid = [[self checkNullValue: [dic valueForKey: @"id"]]integerValue];
    self.userId = [[self checkNullValue: [dic valueForKey:@"user_id"]]integerValue];
    self.providerId = [[self checkNullValue: [dic valueForKey:@"provider_id"]]integerValue];
    self.scheduledTime = [self checkNullValue: [dic valueForKey: @"scheduled_for"]];
    
    self.status = [self checkNullValue: [dic valueForKey: @"status"]];
    if(![self.status isKindOfClass:[NSString class]]) {
            self.status = [[self checkNullValue: [dic valueForKey: @"status"]] stringValue];
    }
    
    self.rating = [[self checkNullValue: [dic valueForKey: @"rating"]]integerValue];
    
    self.feedback = [self checkNullValue: [dic valueForKey: @"feedback"]];
    self.createdTime = [self checkNullValue: [dic valueForKey: @"created_at"]];
    self.updatedTime = [self checkNullValue: [dic valueForKey: @"updated_at"]];
    self.endTime = [self checkNullValue: [dic valueForKey: @"scheduled_end"]];
    
    self.apiKey = @"";
    self.sessionId = @"";
    self.token = @"";
    
    NSArray *arr = [dic objectForKey:@"appointmentInvites"];
    if ([arr count]>0) {
        self.isPlueOne = YES;
    }else{
        self.isPlueOne = NO;
    }
    
}

- (id) checkNullValue: (id) value
{
    if(value == nil || [value isKindOfClass: [NSNull class]])
    {
        return @"";
    }
    
    return value;
}

@end
