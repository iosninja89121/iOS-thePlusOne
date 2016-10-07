//
//  Profile.m
//  thePlusOne
//
//  Created by My Star on 6/24/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import "Profile.h"

@implementation Profile

- (id) initWithDic: (NSDictionary*) dicProfile{
    if(self = [super init])
    {
        if (![dicProfile isKindOfClass:[NSDictionary class]]) {
            return self;
        }
        
        [self updateWithDic:dicProfile];
    }
    return self;
}

-(void)updateWithDic:(NSDictionary *)dicProfile
{
    self.profileId = [self checkNullValue: [dicProfile valueForKey: @"id"]];
    self.userId = [self checkNullValue: [dicProfile valueForKey: @"user_id"]];
    self.firstName = [self checkNullValue: [[dicProfile objectForKey:@"user"] valueForKey: @"first_name"]];
    self.lastName = [self checkNullValue: [[dicProfile objectForKey:@"user"] valueForKey: @"last_name"]];
    self.emailAddress = [[NSUserDefaults standardUserDefaults] objectForKey:@"email_address"];
    
//    self.emailAddress = [self checkNullValue: [dicProfile valueForKey: @"email"]];
//    self.password = [self checkNullValue: [dicProfile valueForKey: @"password"]];
    
    self.photo = [self checkNullValue: [dicProfile valueForKey: @"profile_pic_url"]];
    
    if ([self.photo isEqualToString:@""]) {
        self.photoData = nil;
    }else{
        NSURL *url = [NSURL URLWithString:self.photo];
        self.photoData = [NSData dataWithContentsOfURL:url];
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

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.userId forKey:@"userId"];
    [encoder encodeObject:self.firstName forKey:@"firstName"];
    [encoder encodeObject:self.lastName forKey:@"lastName"];
    [encoder encodeObject:self.emailAddress forKey:@"emailAddress"];
    [encoder encodeObject:self.password forKey:@"password"];
    [encoder encodeObject:self.photo forKey:@"photo"];
    [encoder encodeObject:self.photoData forKey:@"photoData"];
    
    NSNumber *available = [NSNumber numberWithInteger:self.sessionsAvailable];
    NSNumber *completed = [NSNumber numberWithInteger:self.sessionsCompleted];
    NSNumber *purchased = [NSNumber numberWithInteger:self.sessionsPurchased];
    [encoder encodeObject:available forKey:@"sessionsAvailable"];
    [encoder encodeObject:completed forKey:@"sessionsCompleted"];
    [encoder encodeObject:purchased forKey:@"sessionsPurchased"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.userId = [decoder decodeObjectForKey:@"userId"];
        self.firstName = [decoder decodeObjectForKey:@"firstName"];
        self.lastName = [decoder decodeObjectForKey:@"lastName"];
        self.emailAddress = [decoder decodeObjectForKey:@"emailAddress"];
        self.password = [decoder decodeObjectForKey:@"password"];
        self.photo = [decoder decodeObjectForKey:@"photo"];
        self.photoData = [decoder decodeObjectForKey:@"photoData"];
        
        self.sessionsAvailable = [[decoder decodeObjectForKey:@"sessionsAvailable"]integerValue];
        self.sessionsCompleted = [[decoder decodeObjectForKey:@"sessionsCompleted"]integerValue];
        self.sessionsPurchased = [[decoder decodeObjectForKey:@"sessionsPurchased"]integerValue];
    }
    return self;
}

@end
