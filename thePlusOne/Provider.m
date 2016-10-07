//
//  News.m
//  IFCC
//
//  Created by My Star on 6/13/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import "Provider.h"

@implementation Provider

- (id) initWithDic: (NSDictionary*) dicProvider{
    if(self = [super init])
    {
        if (![dicProvider isKindOfClass:[NSDictionary class]]) {
            return self;
        }
        
        [self updateWithDic:dicProvider];
    }
    return self;
}

-(void)updateWithDic:(NSDictionary *)dicProvider
{
    NSLog(@"Provider.m/updateWithDic/dicProvider: %@", dicProvider);
    self.identifier = [self checkNullValue: [dicProvider valueForKey: @"user_id"]];
//    self.userId= [self checkNullValue: [dicProvider valueForKey: @"user_id"]];
    self.pictureUrl = [self checkNullValue: [dicProvider valueForKey: @"profile_pic_url"]];
    
    NSURL *url = [NSURL URLWithString:self.pictureUrl];
    self.pictureData = [NSData dataWithContentsOfURL:url];
    
    self.phoneNumber= [self checkNullValue: [dicProvider valueForKey: @"phone"]];
    self.license= [self checkNullValue: [dicProvider valueForKey: @"license"]];
    self.npiNumber= [self checkNullValue: [dicProvider valueForKey: @"npi_number"]];
    self.experience= [self checkNullValue: [dicProvider valueForKey: @"experience"]];
    self.title= [self checkNullValue: [dicProvider valueForKey: @"title"]];
    self.bio= [self checkNullValue: [dicProvider valueForKey: @"bio"]];
    self.rating= [self checkNullValue: [dicProvider valueForKey: @"rating"]];
    
    NSDictionary *dic = [dicProvider valueForKey:@"user"];
    self.firstName= [self checkNullValue: [dic valueForKey: @"first_name"]];
    self.lastName= [self checkNullValue: [dic valueForKey: @"last_name"]];
    
    
    self.location = [self checkNullValue: [dicProvider valueForKey: @"location"]];
    self.department = [self checkNullValue: [dicProvider valueForKey: @"department"]];
    NSArray *arrTemp = [dicProvider valueForKey: @"specialties"];
    
    NSString *strTemp = @"";
    for (int i=0; i<[arrTemp count]; i++) {
        strTemp = [strTemp stringByAppendingString:[arrTemp objectAtIndex:i]];
        if (i<[arrTemp count]-1) {
            strTemp = [strTemp stringByAppendingString:@", "];
        }
    }
    self.specialties = [self checkNullValue: strTemp];
//    self.available = [self checkNullValue: [dicProvider valueForKey: @"available"]];
    
    self.availability = [self checkNullValue: [dicProvider valueForKey: @"availability"]];
    self.openSessionTimes = [self checkNullValue: [dicProvider valueForKey: @"open_session_times"]];
    
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
