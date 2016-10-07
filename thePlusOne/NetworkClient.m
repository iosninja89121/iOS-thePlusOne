//
//  NetworkClient.m
//  shopcrew
//
//  Created by Alexey Kushnirov on 1/28/15.
//  Copyright (c) 2015 Mike. All rights reserved.
//

#import "NetworkClient.h"
#import "AFNetworking.h"

#import "AppDelegate.h"
#import "Constants.h"
#import "User.h"

@implementation NetworkClient

//***************************************************************************************************
+ (NetworkClient*)sharedInstance
{
    static NetworkClient *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[NetworkClient alloc] init];
    });
    return sharedInstance;    
}
//***************************************************************************************************
- (void)getProvidersWithSuccessBlock:(void(^)(NSDictionary*))success
                           failure:(void(^)(void))failure{
    
    NSURL *URL = [NSURL URLWithString:REQUEST_PROVIDERS];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:URL.absoluteString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"response to getProviders: %@", responseObject);
        NSDictionary *dic = (NSDictionary*)responseObject;
        success(dic);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        failure();
    }];
}

//***************************************************************************************************
- (void)loginWithEmail:(NSString*)strEmail
              password:(NSString*)password
               success:(void(^)(NSDictionary*))success
               failure:(void(^)(NSString*))failure
{
    /*
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    NSDictionary *params = @{@"email": strEmail,
                             @"password": strPassword,
                             @"grant_type": @"password"};
    [manager PUT: REQUEST_SIGN_IN
      parameters:params
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             
             NSLog(@"response to loginWithUsername: %@", responseObject);
             NSDictionary *dic = (NSDictionary*)responseObject;
             success(dic);
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"error = %@", error.description);
     
              NSDictionary* dicResponse = operation.responseObject;
              if(dicResponse != nil)
              {
              NSDictionary* dicErrors = [dicResponse valueForKey: @"errors"];
              if([[dicErrors valueForKey: @"errorCode"] intValue] == 1)
              {
              failure(MSG_EMAIL_NOT_IN_SYSTEM);
              return;
              }
              else
              {
              failure(MSG_EMAIL_IN_SYSTEM);
              return;
              }
              }
     
//             [self errorHandlingWith:operation orError:error failureBlock:nil];
             
             failure(@"");
         }];
   */
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:REQUEST_SIGN_IN] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    
    
    NSError *error;
    NSDictionary *params = @{@"email": strEmail,
                             @"password":password,
                             @"grant_type":@"password"};
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:params
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:jsonData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData  *data, NSURLResponse  *response, NSError * error) {
        
        NSInteger statusCode = -1;
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = [(NSHTTPURLResponse *)response statusCode];
            NSLog(@"%li",(long)statusCode);
            
            //NSData -> NSDictionary
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:&error];
            
            if (statusCode == 200) {
                
                NSArray* arrData = [json objectForKey:@"data"];
                NSLog(@"success! array for response: %@", arrData);
                NSDictionary *dicResponse = [arrData objectAtIndex:0];
                
                success(dicResponse);
            } else {
                NSString* strMessage = [[[json objectForKey:@"meta"]objectForKey:@"error"]objectForKey:@"message"];
                
                
                NSLog(@"failure! message: %@", strMessage);
                
                failure(strMessage);
            }
        }else{
            failure(MSG_NETWORK_ERROR);
        }
        
        
        
    }] resume];
    
}

//***************************************************************************************************
- (void)signUpWithEmail:(NSString*)strEmail
               password:(NSString*)password
              firstName:(NSString*)firstName
               lastName:(NSString*)lastName
                success:(void(^)(NSDictionary*))success
                failure:(void(^)(NSString* message))failure
{
    /*
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    NSDictionary *params = @{@"email": strEmail,
                             @"password":password,
                             @"first_name":firstName,
                             @"last_name":lastName,
                             @"role":@"user"};
    NSLog(@"params: %@", params);
    
    
    [manager POST:REQUEST_SIGN_UP parameters:params progress:nil success: ^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dicResponse = responseObject;
        
        NSLog(@"signup response: %@", dicResponse);
        
        success(dicResponse);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"signup error: %@", error.localizedDescription );
        failure(error.localizedDescription);
        //              [self errorHandlingWith:operation orError:error failureBlock:failure];
    }];
    
  */
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:REQUEST_SIGN_UP] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
    
    
    NSError *error;
    NSDictionary *params = @{@"email": strEmail,
                             @"password":password,
                             @"first_name":firstName,
                             @"last_name":lastName,
                             @"role":@"user"};
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:params
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:jsonData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData  *data, NSURLResponse  *response, NSError * error) {
        
        NSInteger statusCode = -1;
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = [(NSHTTPURLResponse *)response statusCode];
            NSLog(@"%li",(long)statusCode);
        
            //NSData -> NSDictionary
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:&error];
            
            if (statusCode == 200) {
                
                NSArray* arrData = [json objectForKey:@"data"];
                NSLog(@"success! array for response: %@", arrData);
                NSDictionary *dicResponse = [arrData objectAtIndex:0];
                
                success(dicResponse);
            } else {
                NSString* strMessage = [[[json objectForKey:@"meta"]objectForKey:@"error"]objectForKey:@"message"];
                
                
                NSLog(@"failure! message: %@", strMessage);
                
                failure(strMessage);
            }
        }else{
            failure(MSG_NETWORK_ERROR);
        }
        
    }] resume];
    
   
}

//*************************************************************************
- (void) postOrderWithId:(NSNumber*) iid
                  userId:(NSNumber*) userId
           sessionsCount:(NSNumber*) sessionsCount
                  isGift:(NSNumber*) isGift
           paymentMethod:(NSString*) paymentMethod
           transactionId:(NSString*) transactionId
             sessionRate:(NSNumber*) sessionRate
             totalAmount:(NSNumber*) totalAmount
               createdAt:(NSString*) createdTime
               updatedAt:(NSString*) updatedTime
                 success:(void(^)(NSDictionary*))success
                 failure:(void(^)(NSString* message))failure{
    
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSString *strUrl = [REQUEST_POST_ORDER stringByAppendingString:appDelegate.accessToken];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
    
    
    NSError *error;
    NSDictionary *params = @{@"id": iid,
                             @"user_id": userId,
                             @"sessions_count": sessionsCount,
                             @"is_gift": isGift,
                             @"payment_method": paymentMethod,
                             @"transaction_id": transactionId,
                             @"session_rate": sessionRate,
                             @"total_amount": totalAmount,
                             @"created_at": createdTime,
                             @"updated_at":updatedTime};
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:params
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:jsonData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData  *data, NSURLResponse  *response, NSError * error) {
        
        NSInteger statusCode = -1;
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = [(NSHTTPURLResponse *)response statusCode];
            NSLog(@"%li",(long)statusCode);
        
            //NSData -> NSDictionary
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:&error];
            
            if (statusCode == 200) {
                
                NSArray* arrData = [json objectForKey:@"data"];
                NSLog(@"success! array for response: %@", arrData);
                NSDictionary *dicResponse = [arrData objectAtIndex:0];
                
                
                
                success(dicResponse);
            } else {
                NSString* strMessage = [[[json objectForKey:@"meta"]objectForKey:@"error"]objectForKey:@"message"];
                
                
                NSLog(@"failure! message: %@", strMessage);
                
                failure(strMessage);
            }
        }else{
            failure(MSG_NETWORK_ERROR);
        }
      
    }] resume];
    
}
//*************************************************************************
- (void) updateProfileWithUserId:(NSString*) strUserId
                      info:(NSDictionary*) dicInfo
                           success:(void(^)(NSDictionary*))success
                           failure:(void(^)(NSString* message))failure{
    
    NSString *strUrl = [REQUEST_UPDATE_PROFILE stringByAppendingString:strUserId];
    
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    strUrl = [NSString stringWithFormat:@"%@?access_token=%@", strUrl, appDelegate.accessToken];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
    
    NSLog(@"url----%@", strUrl);
    NSLog(@"dictionary info----%@", dicInfo);
    
    
    NSError *error;
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dicInfo
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    [request setHTTPMethod:@"PUT"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:jsonData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData  *data, NSURLResponse  *response, NSError * error) {
        
        NSInteger statusCode = -1;
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = [(NSHTTPURLResponse *)response statusCode];
            NSLog(@"%li",(long)statusCode);
            
            
            //NSData -> NSDictionary
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:&error];
            
            if (statusCode == 200) {
                
                NSArray* arrData = [json objectForKey:@"data"];
                NSLog(@"success! array for response: %@", arrData);
                NSDictionary *dicResponse = [arrData objectAtIndex:0];
                
                success(dicResponse);
            } else {
                NSString* strMessage = [[[json objectForKey:@"meta"]objectForKey:@"error"]objectForKey:@"message"];
                
                
                NSLog(@"failure! message: %@", strMessage);
                
                failure(strMessage);
            }
        }else{
            failure(MSG_NETWORK_ERROR);
        }
        
    }] resume];
    
}
//*************************************************************************
- (void) postAppointmentWithUserId:(NSNumber*) userId
                        providerId:(NSNumber*) providerId
                      scheduledFor:(NSString*) meetingTime
                           success:(void(^)(NSDictionary*))success
                           failure:(void(^)(NSString* message))failure{
    
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSString *strUrl = [REQUEST_POST_APPOINTMENT stringByAppendingString:appDelegate.accessToken];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
    
    
    NSError *error;
    NSDictionary *params = @{@"user_id": userId,
                             @"provider_id": providerId,
                             @"scheduled_for": meetingTime};
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:params
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:jsonData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData  *data, NSURLResponse  *response, NSError * error) {
        
        NSInteger statusCode = -1;
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = [(NSHTTPURLResponse *)response statusCode];
            NSLog(@"%li",(long)statusCode);
            
            
            //NSData -> NSDictionary
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:&error];
            
            if (statusCode == 200) {
                
                NSArray* arrData = [json objectForKey:@"data"];
                NSLog(@"success! array for response: %@", arrData);
                NSDictionary *dicResponse = [arrData objectAtIndex:0];
                
                success(dicResponse);
            } else {
                NSString* strMessage = [[[json objectForKey:@"meta"]objectForKey:@"error"]objectForKey:@"message"];
                
                
                NSLog(@"failure! message: %@", strMessage);
                
                failure(strMessage);
            }
        }else{
            failure(MSG_NETWORK_ERROR);
        }
        
    }] resume];
    
}
//*************************************************************************
- (void) putAppointmentWithAppointmentId:(NSInteger) appointmentId
                               status:(NSString*) status
                               rating:(NSNumber*) rating
                             feedback:(NSString*)feedback
                              success:(void(^)(NSDictionary*))success
                              failure:(void(^)(NSString* message))failure{
    
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSString *strUrl = [NSString stringWithFormat: @"%@%ld", REQUEST_PUT_APPOINTMENT_ID, appointmentId];
    strUrl = [strUrl stringByAppendingString:@"?access_token="];
    strUrl = [strUrl stringByAppendingString:appDelegate.accessToken];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
    
    
    NSError *error;
    NSDictionary *params = @{@"status": status,
                             @"rating": rating,
                             @"feedback": feedback};
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:params
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    [request setHTTPMethod:@"PUT"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:jsonData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData  *data, NSURLResponse  *response, NSError * error) {
        
        NSInteger statusCode = -1;
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = [(NSHTTPURLResponse *)response statusCode];
            NSLog(@"%li",(long)statusCode);
        
            //NSData -> NSDictionary
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:&error];
            
            if (statusCode == 200) {
                
                NSArray* arrData = [json objectForKey:@"data"];
                NSLog(@"success! array for response: %@", arrData);
                NSDictionary *dicResponse = [arrData objectAtIndex:0];
                
                success(dicResponse);
            } else {
                NSString* strMessage = [[[json objectForKey:@"meta"]objectForKey:@"error"]objectForKey:@"message"];
                
                
                NSLog(@"failure! message: %@", strMessage);
                
                failure(strMessage);
            }
        }else{
            failure(MSG_NETWORK_ERROR);
        }
        
    }] resume];
    
}

//*************************************************************************
- (void) postAppointmentStreamsWithAppointmentId:(NSInteger) appointmentId
                                         success:(void(^)(NSDictionary*))success
                                         failure:(void(^)(NSString* message))failure{
    
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSString *strUrl = [NSString stringWithFormat:@"%@%ld?access_token=%@", REQUEST_POST_APPOINTMENT_STREAMS, appointmentId, appDelegate.accessToken];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
    
        
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData  *data, NSURLResponse  *response, NSError * error) {
        
        NSInteger statusCode = -1;
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = [(NSHTTPURLResponse *)response statusCode];
            NSLog(@"%li",(long)statusCode);
            
        
            //NSData -> NSDictionary
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:&error];
            
            if (statusCode == 200) {
                
                NSArray* arrData = [json objectForKey:@"data"];
                NSLog(@"success! array for response: %@", arrData);
                NSDictionary *dicResponse = [arrData objectAtIndex:0];
                
                success(dicResponse);
            } else {
                NSString* strMessage = [[[json objectForKey:@"meta"]objectForKey:@"error"]objectForKey:@"message"];
                
                
                NSLog(@"failure! message: %@", strMessage);
                
                failure(strMessage);
            }
        }else{
            failure(MSG_NETWORK_ERROR);
        }
            
        
    }] resume];
    
}
//*************************************************************************
- (void) getAppointmentsWithSuccess:(void(^)(NSArray* arr))success
                            failure:(void(^)(NSString* message))failure{
    
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSString *strUrl = [NSString stringWithFormat:@"%@%@", REQUEST_GET_APPOINTMENTS, appDelegate.accessToken];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
    
    
    [request setHTTPMethod:@"GET"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData  *data, NSURLResponse  *response, NSError * error) {
        
        NSInteger statusCode = -1;
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = [(NSHTTPURLResponse *)response statusCode];
            NSLog(@"%li",(long)statusCode);
        
            //NSData -> NSDictionary
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:&error];
            
            if (statusCode == 200) {
                
                NSArray* arrData = [json objectForKey:@"data"];
                NSLog(@"success! array for response: %@", arrData);
                
                success(arrData);
            } else {
                NSString* strMessage = [[[json objectForKey:@"meta"]objectForKey:@"error"]objectForKey:@"message"];
                
                
                NSLog(@"failure! message: %@", strMessage);
                
                failure(strMessage);
            }
        }else{
            failure(MSG_NETWORK_ERROR);
        }
        
    }] resume];
    
}
//*************************************************************************
- (void) postGiftSessionsWithuserId:(NSInteger) userId
                            orderId:(NSInteger) orderId
                      sessionsCount:(NSInteger) sessionsCount
                     recipientPhone:(NSString*) recipientPhone
                            success:(void(^)(NSDictionary*))success
                            failure:(void(^)(NSString* message))failure{
    
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSString *strUrl = [NSString stringWithFormat:@"%@%@", REQUEST_POST_GIFT_SESSIONS, appDelegate.accessToken];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
    
    NSError *error;
    NSDictionary *params = @{@"purchased_by_id": [NSNumber numberWithInteger:userId],
                             @"order_id": [NSNumber numberWithInteger:orderId],
                             @"sessions_count": [NSNumber numberWithInteger:sessionsCount],
                             @"recipient_phone":recipientPhone};
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:params
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:jsonData];
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData  *data, NSURLResponse  *response, NSError * error) {
        
        NSInteger statusCode = -1;
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = [(NSHTTPURLResponse *)response statusCode];
            NSLog(@"%li",(long)statusCode);
            
            //NSData -> NSDictionary
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:&error];
            
            if (statusCode == 200) {
                
                NSArray* arrData = [json objectForKey:@"data"];
                NSLog(@"success! array for response: %@", arrData);
                NSDictionary *dicResponse = [arrData objectAtIndex:0];
                
                success(dicResponse);
            } else {
                NSString* strMessage = [[[json objectForKey:@"meta"]objectForKey:@"error"]objectForKey:@"message"];
                
                
                NSLog(@"failure! message: %@", strMessage);
                
                failure(strMessage);
            }
        }else{
            failure(MSG_NETWORK_ERROR);
        }
        
    }] resume];
    
}
//*************************************************************************
- (void) getGiftSessionsWithGiftCode:(NSString*)giftCode
                             success:(void(^)(NSDictionary* dic))success
                             failure:(void(^)(NSString* message))failure{
    
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSString *strUrl = REQUEST_GET_GIFT_SESSIONS;
    strUrl = [strUrl stringByReplacingOccurrencesOfString:@"giftCode" withString:giftCode];
    strUrl = [strUrl stringByReplacingOccurrencesOfString:@"accessToken" withString:appDelegate.accessToken];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
    
    [request setHTTPMethod:@"GET"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData  *data, NSURLResponse  *response, NSError * error) {
        
        NSInteger statusCode = -1;
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = [(NSHTTPURLResponse *)response statusCode];
            NSLog(@"%li",(long)statusCode);
            
            //NSData -> NSDictionary
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:&error];
            
            if (statusCode == 200) {
                
                NSArray* arrData = [json objectForKey:@"data"];
                NSLog(@"success! array for response: %@", arrData);
                
                if ([arrData count]==0) {
                    NSString *strMessage = @"Couldn't get gift code from server";
                    NSLog(@"failure! message: %@", strMessage);
                    
                    failure(strMessage);
                }else{
                    NSDictionary *dicResponse = [arrData objectAtIndex:0];
                    success(dicResponse);
                }
            } else {
                NSString* strMessage = [[[json objectForKey:@"meta"]objectForKey:@"error"]objectForKey:@"message"];
                
                
                NSLog(@"failure! message: %@", strMessage);
                
                failure(strMessage);
            }
        }else{
            failure(MSG_NETWORK_ERROR);
        }
        
    }] resume];
    
}
//*************************************************************************
- (void) postAppointmentInvitesWithappointmentId:(NSInteger) appointmentId
                                          userId:(NSInteger) userId
                                       firstName:(NSString*)firstName
                                        lastName:(NSString*)lastName
                                   recipentPhone:(NSString*) recipientPhone
                                         success:(void(^)(NSDictionary*))success
                                         failure:(void(^)(NSString* message))failure{
    
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSString *strUrl = [NSString stringWithFormat:@"%@%@", REQUEST_POST_APPOINTMENT_INVITES, appDelegate.accessToken];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
    
    NSError *error;
    NSDictionary *params = @{@"appointment_id": [NSNumber numberWithInteger:appointmentId],
                             @"user_id": [NSNumber numberWithInteger:userId],
                             @"first_name": firstName,
                             @"last_name" : lastName,
                             @"phone":recipientPhone};
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:params
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:jsonData];
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData  *data, NSURLResponse  *response, NSError * error) {
        
        NSInteger statusCode = -1;
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = [(NSHTTPURLResponse *)response statusCode];
            NSLog(@"%li",(long)statusCode);
            
            //NSData -> NSDictionary
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:&error];
            
            if (statusCode == 200) {
                
                NSArray* arrData = [json objectForKey:@"data"];
                NSLog(@"success! array for response: %@", arrData);
                NSDictionary *dicResponse = [arrData objectAtIndex:0];
                
                success(dicResponse);
            } else {
                NSString* strMessage = [[[json objectForKey:@"meta"]objectForKey:@"error"]objectForKey:@"message"];
                
                
                NSLog(@"failure! message: %@", strMessage);
                
                failure(strMessage);
            }
        }else{
            failure(MSG_NETWORK_ERROR);
        }
        
    }] resume];
    
}
//*************************************************************************
- (void) getAppointmentInvitesWithInviteCode:(NSString*)inviteCode
                                     success:(void(^)(NSDictionary* dic))success
                                     failure:(void(^)(NSString* message))failure{
    
    NSString *strUrl = REQUEST_GET_APPOINTMENT_INVITES;
    strUrl = [strUrl stringByReplacingOccurrencesOfString:@"inviteCode" withString:inviteCode];
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
    
    [request setHTTPMethod:@"GET"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData  *data, NSURLResponse  *response, NSError * error) {
        
        NSInteger statusCode = -1;
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = [(NSHTTPURLResponse *)response statusCode];
            NSLog(@"%li",(long)statusCode);
            
            //NSData -> NSDictionary
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:&error];
            
            if (statusCode == 200) {
                
                NSArray* arrData = [json objectForKey:@"data"];
                NSLog(@"success! array for response: %@", arrData);
                
                if ([arrData count]==0) {
                    NSString *strMessage = @"Couldn't get gift code from server";
                    NSLog(@"failure! message: %@", strMessage);
                    
                    failure(strMessage);
                }else{
                    NSDictionary *dicResponse = [arrData objectAtIndex:0];
                    success(dicResponse);
                }
            } else {
                NSString* strMessage = [[[json objectForKey:@"meta"]objectForKey:@"error"]objectForKey:@"message"];
                
                
                NSLog(@"failure! message: %@", strMessage);
                
                failure(strMessage);
            }
        }else{
            failure(MSG_NETWORK_ERROR);
        }
        
    }] resume];
    
}
//*************************************************************************
- (void) putAppointmentInvitesWithInviteId:(NSInteger)inviteId
                                    userId:(NSInteger)userId
                                   success:(void(^)(NSDictionary* dic))success
                                   failure:(void(^)(NSString* message))failure{
    
    NSString *strUrl = REQUEST_PUT_APPOINTMENT_INVITES;
    NSString *strInviteId = [NSString stringWithFormat:@"%ld", inviteId];
    strUrl = [strUrl stringByReplacingOccurrencesOfString:@"inviteId" withString:strInviteId];
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    strUrl = [strUrl stringByReplacingOccurrencesOfString:@"accessToken" withString:appDelegate.accessToken];
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
    
    [request setHTTPMethod:@"PUT"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData  *data, NSURLResponse  *response, NSError * error) {
        
        NSInteger statusCode = -1;
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = [(NSHTTPURLResponse *)response statusCode];
            NSLog(@"%li",(long)statusCode);
            
            //NSData -> NSDictionary
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:&error];
            
            if (statusCode == 200) {
                
                NSArray* arrData = [json objectForKey:@"data"];
                NSLog(@"success! array for response: %@", arrData);
                
                if ([arrData count]==0) {
                    NSString *strMessage = @"Couldn't get gift code from server";
                    NSLog(@"failure! message: %@", strMessage);
                    
                    failure(strMessage);
                }else{
                    NSDictionary *dicResponse = [arrData objectAtIndex:0];
                    success(dicResponse);
                }
            } else {
                NSString* strMessage = [[[json objectForKey:@"meta"]objectForKey:@"error"]objectForKey:@"message"];
                
                
                NSLog(@"failure! message: %@", strMessage);
                
                failure(strMessage);
            }
        }else{
            failure(MSG_NETWORK_ERROR);
        }
        
    }] resume];
    
}
//*************************************************************************
- (void) postUserProfileWithUserId:(NSInteger)userId
                     profilePicUrl:(NSString*)profilePictureUrl
                             phone:(NSString*)phone
                     notifications:(BOOL)notifications
                           success:(void(^)(NSDictionary* dic))success
                           failure:(void(^)(NSString* message))failure{
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSString *strUrl = [REQUEST_POST_USER_PROFILE stringByReplacingOccurrencesOfString: @"accessToken" withString: appDelegate.accessToken];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
    //build notifications dictionary
    NSDictionary *dicNotifications = @{
                                       @"appointments":[NSNumber numberWithBool:notifications]
                                       };
    ///
    
    NSError *error;
    NSDictionary *params = @{@"user_id": [NSNumber numberWithInteger:userId],
                             @"profile_pic_url": profilePictureUrl,
                             @"phone":phone,
                             @"notifications":dicNotifications};
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:params
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:jsonData];
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData  *data, NSURLResponse  *response, NSError * error) {
        
        NSInteger statusCode = -1;
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = [(NSHTTPURLResponse *)response statusCode];
            NSLog(@"%li",(long)statusCode);
            
            //NSData -> NSDictionary
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:&error];
            
            if (statusCode == 200) {
                
                NSArray* arrData = [json objectForKey:@"data"];
                NSLog(@"success! array for response: %@", arrData);
                NSDictionary *dicResponse = [arrData objectAtIndex:0];
                
                success(dicResponse);
            } else {
                NSString* strMessage = [[[json objectForKey:@"meta"]objectForKey:@"error"]objectForKey:@"message"];
                
                
                NSLog(@"failure! message: %@", strMessage);
                
                failure(strMessage);
            }
        }else{
            failure(MSG_NETWORK_ERROR);
        }
        
    }] resume];
}
- (void) getUserProfileWithUserId:(NSInteger)userId
                          success:(void(^)(NSDictionary* dic))success
                          failure:(void(^)(NSString* message))failure{
    
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSString *strUrl = [REQUEST_GET_USER_PROFILE stringByReplacingOccurrencesOfString: @"accessToken" withString: appDelegate.accessToken];
    NSString *strUserId = [NSString stringWithFormat:@"%ld", userId];
    strUrl = [strUrl stringByReplacingOccurrencesOfString: @"userId" withString: strUserId];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
    
    
    [request setHTTPMethod:@"GET"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData  *data, NSURLResponse  *response, NSError * error) {
        
        NSInteger statusCode = -1;
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = [(NSHTTPURLResponse *)response statusCode];
            NSLog(@"%li",(long)statusCode);
            
            //NSData -> NSDictionary
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:&error];
            
            if (statusCode == 200) {
                
                NSArray* arrData = [json objectForKey:@"data"];
                NSLog(@"success! array for response: %@", arrData);
                NSDictionary *dicResponse = [arrData objectAtIndex:0];
                
                success(dicResponse);
            } else {
                NSString* strMessage = [[[json objectForKey:@"meta"]objectForKey:@"error"]objectForKey:@"message"];
                
                
                NSLog(@"failure! message: %@", strMessage);
                
                failure(strMessage);
            }
        }else{
            failure(MSG_NETWORK_ERROR);
        }
        
    }] resume];
    
}
- (void) putUserProfileWithProfileId:(NSInteger)profileId
                       profilePicUrl:(NSString*)profilePictureUrl
                               phone:(NSString*)phone
                       notifications:(BOOL)notifications
                             success:(void(^)(NSDictionary* dic))success
                             failure:(void(^)(NSString* message))failure{
    
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSString *strUrl = [REQUEST_PUT_USER_PROFILE stringByReplacingOccurrencesOfString: @"accessToken" withString: appDelegate.accessToken];
    NSString *strProfileId = [NSString stringWithFormat:@"%ld", profileId];
    strUrl = [strUrl stringByReplacingOccurrencesOfString: @"profileId" withString: strProfileId];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
    
    //build notifications dictionary
    NSDictionary *dicNotifications = @{
                                    @"appointments":[NSNumber numberWithBool:notifications]
                                    };
    ///
    
    NSError *error;
    NSDictionary *params = @{@"profile_pic_url": profilePictureUrl,
                             @"phone":phone,
                             @"notifications":dicNotifications};
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:params
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    [request setHTTPMethod:@"PUT"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:jsonData];
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData  *data, NSURLResponse  *response, NSError * error) {
        
        NSInteger statusCode = -1;
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = [(NSHTTPURLResponse *)response statusCode];
            NSLog(@"%li",(long)statusCode);
            
            //NSData -> NSDictionary
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:&error];
            
            if (statusCode == 200) {
                
                NSArray* arrData = [json objectForKey:@"data"];
                NSLog(@"success! array for response: %@", arrData);
                NSDictionary *dicResponse = [arrData objectAtIndex:0];
                
                success(dicResponse);
            } else {
                NSString* strMessage = [[[json objectForKey:@"meta"]objectForKey:@"error"]objectForKey:@"message"];
                
                
                NSLog(@"failure! message: %@", strMessage);
                
                failure(strMessage);
            }
        }else{
            failure(MSG_NETWORK_ERROR);
        }
        
    }] resume];
    
}

//*************************************************************************
/*

#pragma mark - Auth

- (NSData*)encodeDictionary:(NSDictionary*)dictionary {
    NSMutableArray *parts = [[NSMutableArray alloc] init];
    for (NSString *key in dictionary) {
        NSString *encodedValue = [[dictionary objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *encodedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *part = [NSString stringWithFormat: @"%@=%@", encodedKey, encodedValue];
        [parts addObject:part];
    }
    NSString *encodedDictionary = [parts componentsJoinedByString:@"&"];
    return [encodedDictionary dataUsingEncoding:NSUTF8StringEncoding];
}

//====================================================================================================
- (void)loginWithUsername:(NSString*)strUsername
                 password:(NSString*)strPassword
             device_token:(NSString*)deviceToken
                  success:(void(^)(void))success
                  failure:(void(^)(NSString* message))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    NSDictionary *params = @{@"username": strUsername,
                             @"password": strPassword,
                             @"ios_device_token": deviceToken};
    [manager PUT:[NSString stringWithFormat:@"%@%@", SERVER_URL, REQUEST_LOGIN] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dicResponse = responseObject;
        [[CoreDataHandler sharedInstance] saveUserData:[dicResponse objectForKey:@"user"]];
        [Utilities saveAuthKey:[dicResponse objectForKey:@"auth_key"]];
        
        //Save Current User.
        SCUser* curUser = [[SCUser alloc] initWithDic: dicResponse[@"user"]];
        [AppDelegate getDelegate].curUser = curUser;
        [[AppDelegate getDelegate].curUser saveUserInfo];
        
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"error = %@", error.description);
        NSDictionary* dicResponse = operation.responseObject;
        if(dicResponse != nil)
        {
            NSDictionary* dicErrors = [dicResponse valueForKey: @"errors"];
            if([[dicErrors valueForKey: @"errorCode"] intValue] == 1)
            {
                failure(MSG_EMAIL_NOT_IN_SYSTEM);
                return;
            }
            else
            {
                failure(MSG_EMAIL_IN_SYSTEM);
                return;
            }
        }
        
        failure(@"");

    }];
}

//====================================================================================================
- (void)makeLogoutWithSuccessBlock:(void(^)(void))success
                           failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    [manager GET:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_LOGOUT] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success();
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure();
    }];
}

//====================================================================================================
- (void)forgotPassword:(NSString*)strEmail success:(void(^)(void))success failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    NSDictionary *params = @{@"email": strEmail};
    [manager PUT:[NSString stringWithFormat:@"%@%@", SERVER_URL, REQUEST_FORGOT_PASSWORD] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {        
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure();
    }];
}

//====================================================================================================
- (void)resetPassword:(NSString*)strEmail withToken:(NSString*)strToken success:(void(^)(void))success failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    NSDictionary *params = @{@"email": strEmail, @"token": strToken};
    [manager PUT:[NSString stringWithFormat:@"%@%@", SERVER_URL, REQUEST_RESET_PASSWORD] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {        
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure();
    }];
}

//====================================================================================================
- (void)signUpWithEmail:(NSString*)strEmail
            deviceToken: (NSString*) deviceToken
                success:(void(^)(void))success
                failure:(void(^)(NSString* message))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    NSDictionary *params = @{@"email": strEmail,
                             @"ios_device_token": deviceToken};
    [manager POST:[NSString stringWithFormat:@"%@%@", SERVER_URL, REQUEST_SIGNUP] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSDictionary *dicResponse = responseObject;
        if ([[[[dicResponse objectForKey:@"messages"] objectForKey:@"email"] objectAtIndex:0] containsString:@"Email already exists."])
        {
            failure(MSG_EMAIL_EXIST);
            return;
        }
        [[CoreDataHandler sharedInstance] saveUserData:[dicResponse objectForKey:@"user"]];
        [Utilities saveAuthKey:[dicResponse objectForKey:@"auth_key"]];
        [Utilities saveUserId:[[dicResponse objectForKey:@"user"] objectForKey:@""]];
        
        //Save Current User.
        SCUser* curUser = [[SCUser alloc] initWithDic: [dicResponse valueForKey: @"user"]];
        [AppDelegate getDelegate].curUser = curUser;
        [[AppDelegate getDelegate].curUser saveUserInfo];
        
        success();
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        failure([[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding]);
    }];
}

//====================================================================================================
- (void) signUpSetEmail: (NSString*) email
                success:(void(^)(void))success
                failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    NSDictionary *params = @{@"email": email};
    [manager PUT:[NSString stringWithFormat:@"%@%@", SERVER_URL, REQUEST_SIGNUP_SETEMAIL] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"REQUEST_SIGNUP_SETEMAIL = %@", responseObject);
         success();
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"error: %@",  operation.responseString);
         failure();
     }];
    
}

//====================================================================================================
- (void)sighUpDetailsWithDisplayName:(NSString*)strFullName
                            password:(NSString*)strPassword
                             imageId:(NSString*)strUserId
                             success:(void(^)(NSDictionary* result))success
                             failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    NSDictionary *params = @{@"fullname": strFullName, @"password": strPassword, @"image_id": strUserId};
    [manager PUT:[NSString stringWithFormat:@"%@%@", SERVER_URL, REQUEST_SIGNUP_DETAILS] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSLog(@"REQUEST_SIGNUP_DETAILS = %@", responseObject);
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
        NSLog(@"error: %@",  operation.responseString);
        failure();
    }];
}

//====================================================================================================
- (void)addPhoneWithNumber:(NSString*)strPhoneNumber success:(void(^)(void))success failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    NSDictionary *params = @{@"phone": strPhoneNumber};
    [manager PUT:[NSString stringWithFormat:@"%@%@", SERVER_URL, REQUEST_ADD_PHONE] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure();
    }];
}

//====================================================================================================
- (void)inviteFriendsByEmail:(NSArray*)arrEmails success:(void(^)(NSDictionary*))success failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    NSDictionary * params = [[NSDictionary alloc] initWithObjectsAndKeys:arrEmails,@"emails", nil];
    [manager POST:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_INVITE_BY_EMAIL] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dicResponse = (NSDictionary *) responseObject;
        success(dicResponse);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

//====================================================================================================
- (void)signUpWithFacebook:(NSString*)strToken success:(void(^)(NSDictionary*))success failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    NSDictionary *params = @{@"access_token": strToken};
    [manager PUT:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_FACEBOOK] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         success(responseObject);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"signup with facebook error = %@", error);
         failure();
     }];
}

//====================================================================================================
- (void)signUpWithTwitter:(NSString*)strToken
              tokenSecret:(NSString*)strTokenSecret
              expiry_time: (int) expiry_time
                  success:(void(^)(NSString*))success
                  failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            strToken, @"oauth_token",
                            strTokenSecret, @"oauth_token_secret", nil];
    
    [manager PUT:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_TWITTER] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSDictionary *dicResponse = responseObject;
        [Utilities saveAuthKey:[dicResponse objectForKey:@"auth_key"]];
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        [def setObject:[[dicResponse objectForKey:@"user"] objectForKey:@"avatarLink"] forKey:@"FBAvatar"];
        [def synchronize];
        
        //Save Current User.
        SCUser* curUser = [[SCUser alloc] initWithDic: dicResponse];
        NSDictionary* dicUser = [dicResponse valueForKey: @"user"];
        [curUser setUserInfo: dicUser];
        curUser.activeTwitter = @"1";
        [AppDelegate getDelegate].curUser = curUser;
        [[AppDelegate getDelegate].curUser saveUserInfo];

        NSString* action = [dicResponse valueForKey: @"action"];
        success(action);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"twitter sign up error = %@", error);
        failure();
    }];
}

#pragma mark - Socialize

//====================================================================================================
- (void)findFriendsByEmail:(NSString*)strEmail success:(void(^)(NSDictionary*))success failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    NSDictionary *params = @{@"email": strEmail};
    [manager GET:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_FIND_BY_EMAIL] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dicResponse = (NSDictionary *) responseObject;
        success(dicResponse);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

//====================================================================================================
- (void)findFriendsByPhone:(NSString*)strPhone success:(void(^)(NSDictionary*))success failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    NSDictionary *params = @{@"phone": strPhone};
    [manager GET:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_FIND_BY_PHONE] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dicResponse = (NSDictionary *) responseObject;
        success(dicResponse);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

//====================================================================================================
- (void)suggestedFriends:(NSString*)strPhone success:(void(^)(NSDictionary*))success failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    NSDictionary *params = @{@"phone": strPhone};
    [manager GET:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_SUGGESTED_FRIENDS] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dicResponse = (NSDictionary *) responseObject;
        success(dicResponse);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

//====================================================================================================
- (void)getSentRequestWithSuccessBlock:(void(^)(NSDictionary*))success failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    [manager GET:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_RECEIVED_REQUESTS] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dicResponse = (NSDictionary *) responseObject;
        success(dicResponse);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

//====================================================================================================
- (void)receivedRequestWithSuccessBlock:(void(^)(NSDictionary*))success failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    [manager GET:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_GET_SENT_REQUESTS] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dicResponse = (NSDictionary *) responseObject;
        success(dicResponse);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

#pragma mark - Search
//====================================================================================================
- (void)searchUsers:(NSString*)strSearchParam
              limit: (int) limit
               skip: (int) skip
                lat: (float) lat
                lng: (float) lng
            success:(void(^)(NSArray*))success
            failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    NSDictionary *params = @{@"needle": strSearchParam,
                             @"limit": [NSNumber numberWithInt: limit],
                             @"skip": [NSNumber numberWithInt: skip],
                             @"lat": [NSNumber numberWithFloat: lat],
                             @"lng": [NSNumber numberWithFloat: lng],
                             };
    [manager GET:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_SEARCH_USERS] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSDictionary *dicResponse = (NSDictionary *) responseObject;
        if(dicResponse != nil)
        {
            NSArray* users = [dicResponse valueForKey: @"users"];
            success(users);
        }
        
        failure();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"REQUEST_SEARCH_USERS failed = %@", error);
        failure();
    }];
}

//====================================================================================================
- (void)searchByHashtag:(NSString*)strSearchParam
                success:(void(^)(NSArray*))success
                failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    NSDictionary *params = @{@"tagname": strSearchParam};
    [manager GET:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_SEARCH_BY_HASHTAG] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *arrResult = (NSArray *) responseObject;
        success(arrResult);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"REQUEST_SEARCH_BY_HASHTAG error = %@", error);
        failure();
    }];
}

//====================================================================================================
- (void)searchUsersByName: (NSString*)username success:(void(^)(NSArray*))success failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    NSDictionary *params = @{@"username": username};
    [manager GET:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_SEARCH_USERS_BYNAME] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        success(responseObject[@"users"]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"searchUserByName error = %@", error);
        failure();
    }];
}

//====================================================================================================
- (void)searchFriendsFriend: (void(^)(NSArray*))success failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    [manager GET:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_SEARCH_FRIENDS_FRIEND] parameters: nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         success(responseObject[@"users"]);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"REQUEST_FRIENDS_OF_FRIENDS error = %@", error);
         failure();
     }];
}

#pragma mark - Profile
//====================================================================================================
- (void)getMyProfileWithSuccessBlock:(void(^)(NSDictionary*))success failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    [manager GET:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_MY_PROFILE] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dicResponse = (NSDictionary *) responseObject;
        success(dicResponse);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

//====================================================================================================
- (void)getUserProfile:(NSString*)strProfileId success:(void(^)(NSDictionary*))success failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    NSDictionary *params = @{@"id": strProfileId};
    [manager GET:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_GET_OTHER_PROFILE] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dicResponse = (NSDictionary *) responseObject;
        success(dicResponse);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure();
    }];
}

//====================================================================================================
- (void)editProfile:(NSString*)strFullname
              phone:(NSString*)strPhone
            website:(NSString*)website
     status_message:(NSString*)status_message
      posts_visible:(int)posts_visible
           image_id:(int)image_id
            success:(void(^)(NSDictionary*))success
            failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if(strFullname != nil)
    {
        [params setObject: strFullname forKey: @"fullname"];
    }
    
    if(strPhone != nil)
    {
        [params setObject: strPhone forKey: @"phone"];
    }
    
    if(website != nil)
    {
        [params setObject: website forKey: @"website"];
    }
    
    if(status_message != nil)
    {
        [params setObject: status_message forKey: @"status_message"];
    }

    if(posts_visible != -1)
    {
        [params setObject: [NSNumber numberWithInt: posts_visible] forKey: @"posts_visible"];
    }

    if(image_id != -1)
    {
        [params setObject: [NSNumber numberWithInt:image_id] forKey: @"image_id"];
    }

    [manager PUT:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_EDIT_PROFILE] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dicResponse = (NSDictionary *) responseObject;
        success(dicResponse);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"Edit Profile error = %@", error);
        failure();
    }];
}

//====================================================================================================
- (void)uploadAvatarWithData:(NSData*)imgData success:(void(^)(NSDictionary *dicResponse)) success failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    [manager POST:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_UPLOAD_AVATAR] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imgData name:@"File[file]" fileName:@"photo.jpg" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSDictionary *dicResponse = responseObject;
        success(dicResponse);
    }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"Upload Avatar failed = %@", error);
        failure();
    }];
}

//====================================================================================================
- (void) getRegisteredEmails: (NSArray*) arrEmail
                     success:(void(^)(NSDictionary *dicResponse)) success
                     failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    int index = 0;
    for(NSString* email in arrEmail)
    {
        [params setObject: email forKey: [NSString stringWithFormat: @"emails[%d]", index]];
        index++;
    }
    
    [manager GET:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_CHECK_EMAILS]
      parameters: params
         success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSDictionary *dicResponse = (NSDictionary *) responseObject;
        success(dicResponse);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         failure();
    }];
}

//====================================================================================================
- (void) getRegisteredPhones: (NSArray*) arrPhone
                     success:(void(^)(NSDictionary *dicResponse)) success
                     failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    int index = 0;
    for(NSString* phone in arrPhone)
    {
        [params setObject: phone forKey: [NSString stringWithFormat: @"phones[%d]", index]];
        index++;
    }
    
    [manager GET:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_CHECK_PHONES]
      parameters: params
         success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary *dicResponse = (NSDictionary *) responseObject;
         success(dicResponse);
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         failure();
     }];
}

#pragma mark - Settings

//====================================================================================================
- (void) getSettingsView:(void(^)(NSDictionary*))success failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    [manager GET:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_SETTINGS_VIEW] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dicResponse = (NSDictionary *) responseObject;
        success(dicResponse);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

//====================================================================================================
- (void)getSettingsList:(NSString*)strProfileId success:(void(^)(NSDictionary*))success failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    [manager GET:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_SETTINGS_LIST] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dicResponse = (NSDictionary *) responseObject;
        success(dicResponse);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

//====================================================================================================
- (void)editUsername:(NSString*) username
             success:(void(^)(NSDictionary*))success
             failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   username, @"username",
                                   nil];
    
    [manager PUT:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_EDIT_SETTINGS] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dicResponse = (NSDictionary *) responseObject;
        success(dicResponse);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"REQUEST_EDIT_SETTINGS failed = %@", error);
         failure();
     }];
}

//====================================================================================================
- (void)editSettings:(NSString*)strEmail
            password:(NSString*)strPassword
            location:(NSString*)strLocation
              gender:(int)iGender
       posts_visible:(int) posts_visible
       push_messages:(int)push_messages
          push_votes:(int)push_votes
       push_comments:(int)push_comments
         push_follow:(int)push_follow
       push_requests:(int)push_requests
        push_friends:(int)push_friends
  push_feedback_tags:(int)push_feedback_tags
       push_reminder:(int)push_reminder
             success:(void(^)(NSDictionary*))success
             failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithInt:iGender], @"gender",
                                     [NSNumber numberWithInt:posts_visible], @"posts_visible",
                                     [NSNumber numberWithInt:push_messages], @"push_notifications[messages]",
                                     [NSNumber numberWithInt:push_votes], @"push_notifications[votes]",
                                     [NSNumber numberWithInt:push_comments], @"push_notifications[comments]",
                                     [NSNumber numberWithInt:push_follow], @"push_notifications[follow]",
                                     [NSNumber numberWithInt:push_requests], @"push_notifications[requests]",
                                     [NSNumber numberWithInt:push_friends], @"push_notifications[friends]",
                                     [NSNumber numberWithInt:push_feedback_tags], @"push_notifications[feedback_tags]",
                                     [NSNumber numberWithInt:push_reminder], @"push_notifications[reminder]",
                                    nil];
    
    if(strEmail != nil && [strEmail length] > 0)
    {
        [params setObject: strEmail forKey: @"email"];
    }

    if(strPassword != nil && [strPassword length] > 0)
    {
        [params setObject: strPassword forKey: @"password"];
    }

    if(strLocation != nil && [strLocation length] > 0)
    {
        [params setObject: strLocation forKey: @"location"];
    }
    
    [manager PUT:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_EDIT_SETTINGS] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dicResponse = (NSDictionary *) responseObject;
        success(dicResponse);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"REQUEST_EDIT_SETTINGS failed = %@", error);
        failure();
    }];
}

#pragma mark - Activity
//====================================================================================================
- (void)getActivity: (int) userId
              is_my: (int) is_my
              limit: (int) limit
               skip: (int) skip
            success:(void(^)(NSArray *arrResult))success failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    
    NSDictionary *params = @{@"user_id": [NSNumber numberWithInt: userId],
                             @"is_my": [NSNumber numberWithInt: is_my],
                             @"limit": [NSNumber numberWithInt: limit],
                             @"skip": [NSNumber numberWithInt: skip],
                             };
    
    [manager GET:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_GET_ACTIVITY]
      parameters: params
         success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure();
    }];
}

#pragma mark - Crewsters
//====================================================================================================
- (void)getCrewstersWithSuccessBlock:(void(^)(NSDictionary*))success failure:(void(^)(void))failure{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    [manager GET:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_CREWSTERS] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dicResponse = (NSDictionary *) responseObject;
        success(dicResponse);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

//====================================================================================================
- (void)getCrewsters: (int) user_id
             success:(void(^)(NSDictionary*))success
             failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    NSDictionary *params = @{@"user_id": [NSNumber numberWithInt: user_id]};
    
    [manager GET:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_MY_CREWSTERS] parameters: params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dicResponse = (NSDictionary *) responseObject;
        success(dicResponse);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure();
    }];
}

//====================================================================================================
- (void)addUserToCrew:(int)iUserId
              success:(void(^)(NSDictionary*))success
              failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    NSDictionary *params = @{@"id": [NSNumber numberWithInt:iUserId]};
    [manager PUT:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_ADD_TO_CREW] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dicResponse = (NSDictionary *) responseObject;
        success(dicResponse);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"failed user = %d", iUserId);
        NSLog(@"failed authkey = %@", [Utilities getAuthKey]);
        failure();
    }];
}

//====================================================================================================
- (void) unfollowUserToCrew: (int) user_id
                    success:(void(^)(NSDictionary*))success
                    failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    NSDictionary *params = @{@"user_ids[0]": [NSNumber numberWithInt: user_id]};
    [manager POST:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_UNFOLLOW] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dicResponse = (NSDictionary *) responseObject;
        success(dicResponse);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"failed unfollow user = %d", user_id);
         NSLog(@"failed unfollow authkey = %@", [Utilities getAuthKey]);
         failure();
     }];
}

//====================================================================================================
- (void)getCrewzing:(int) user_id
            success:(void(^)(NSDictionary*))success
            failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    NSDictionary *params = @{@"user_id": [NSNumber numberWithInt: user_id]};
    [manager GET:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_GET_CREWZING] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dicResponse = (NSDictionary *) responseObject;
        success(dicResponse);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure();
    }];
}

#pragma mark - Shares

//====================================================================================================
- (void)getFeedbackWithSuccessBlock: (int) limit
                               skip: (int) skip
                            success: (void(^)(NSArray *arrResponse))success
                            failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    NSDictionary *params = @{@"limit": [NSNumber numberWithInt: limit], @"skip": [NSNumber numberWithInt: skip]};

    [manager GET:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_FEEDBACK] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSArray *arrResponse = responseObject;
        success(arrResponse);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"get feedback error = %@", error.description);
        failure();
    }];
}

//====================================================================================================
- (void)getFeedbackOfUser: (int) limit
                     skip: (int) skip
                  user_id: (int) user_id
                  success: (void(^)(NSArray *arrResponse))success
                  failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    NSDictionary *params = @{@"limit": [NSNumber numberWithInt: limit], @"skip": [NSNumber numberWithInt: skip], @"user_id": [NSNumber numberWithInt: user_id]};
    [manager GET:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_SHARED] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSArray *arrResponse = responseObject;
         success(arrResponse);
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"get feedback error = %@", error.description);
         failure();
     }];
}

//====================================================================================================
- (void) getFeedbackByHashTagName: (NSString*) hashtag
                          success: (void(^)(NSArray *arrResponse))success
                          failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    NSDictionary *params = @{@"needle": hashtag};
    
    [manager GET:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_FEEDBACK_HASHTAGNAME]
      parameters:params
         success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSArray* arrData = responseObject;
         success(arrData);
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"get feedback by hashtag error = %@", error.description);
         failure();
     }];

}


//====================================================================================================
- (void) getPopularFeedbacks: (int) limit
                        skip: (int) skip
                     success: (void(^)(NSArray *arrResponse))success
                     failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    NSDictionary *params = @{@"limit": [NSNumber numberWithInt: limit],
                             @"skip": [NSNumber numberWithInt: skip]};
    
    [manager GET:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_POPULAR]
      parameters:params
         success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSArray* arrData = responseObject;
         success(arrData);
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"get feedback by hashtag error = %@", error.description);
         failure();
     }];
}

//====================================================================================================
- (void) getFeedbackByHashtag: (int) hash_id
                        limit: (int) limit
                         skip: (int) skip
                      success: (void(^)(NSArray *arrResponse))success
                      failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    NSDictionary *params = @{@"hashtag_id": [NSNumber numberWithInt: hash_id],
                             @"limit": [NSNumber numberWithInt: limit],
                             @"skip": [NSNumber numberWithInt: skip]};

    [manager GET:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_FEEDBACK_HASHTAG]
      parameters:params
         success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSArray* arrData = responseObject;
         success(arrData);
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"get feedback by hashtag error = %@", error.description);
         failure();
     }];
}

//====================================================================================================
- (void)getNearbyFeedback: (float)lat
                      lng: (float)lng
                    limit: (int) limit
                     skip: (int) skip
                  success: (void(^)(NSArray *arrResponse))success
                  failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    NSDictionary *params = @{@"lat": [NSNumber numberWithFloat: lat],
                             @"lng": [NSNumber numberWithFloat: lng],
                             @"limit": [NSNumber numberWithInt: limit],
                             @"skip": [NSNumber numberWithInt: skip]
                             };
    
    [manager GET:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_NEARBY_FEEDBACK]
      parameters:params
         success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSArray *arrResponse = responseObject;
         success(arrResponse);
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"get feedback error = %@", error.description);
         failure();
     }];
}


//====================================================================================================
- (void) getOneFeedback: (int) feedback_id
                success: (void(^)(NSDictionary *arrResponse))success
                failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    NSDictionary *params = @{@"id": [NSNumber numberWithInt: feedback_id]};
    
    [manager GET:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_GET_FEEDBACK] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary *dicResponse = responseObject;
         success(dicResponse);
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"get one feedback error = %@", error.description);
         failure();
     }];
}

//====================================================================================================
- (void) getPhotoMapFeedback: (NSString*) locationId
                     success: (void(^)(NSArray *arrResponse))success
                     failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    NSDictionary *params = @{@"id": locationId};
    
    [manager GET:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_PHOTO_MAP] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSArray *arrResponse = responseObject;
         success(arrResponse);
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"get photo map feedback error = %@", error.description);
         failure();
     }];
}

//====================================================================================================
- (void) deleteFeedback: (int)feedback_id success:(void(^)(NSDictionary*))success failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
    [serializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt: feedback_id], @"id", nil];
    [manager DELETE:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_DELETE_FEEDBACK] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@",  operation.responseString);
        failure();
    }];
}

//====================================================================================================
- (void) getShareTemplate: (int)feedback_id success:(void(^)(NSDictionary*))success failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    NSDictionary *params = @{@"id": [NSNumber numberWithInt: feedback_id]};
    [manager GET:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_GET_SOCIALTEMPLATE] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        success(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"get share template error = %@", error.description);
         failure();
     }];
}

//====================================================================================================
- (void) reportFeedback: (int) feedback_id success:(void(^)(NSDictionary*))success failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    NSDictionary *params = @{@"id": [NSNumber numberWithInt: feedback_id]};
    [manager PUT:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_REPORT_FEEDBACK] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         success(responseObject);
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"get share template error = %@", error.description);
         failure();
     }];
}

//====================================================================================================
- (void)getExploreWithSuccessBlock:(void(^)(NSDictionary *dicResponse))success failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    
    [manager GET:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_EXPLORE] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dicResponse = responseObject;
        success(dicResponse);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure();
    }];
}

//====================================================================================================
- (void)getCommentsForForItemWithId:(int)itemID success:(void(^)(NSArray *dicResp)) success failure:(void(^)(void))failure{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    NSDictionary *params = @{@"id": [NSNumber numberWithInt:itemID],
                             @"limit": [NSNumber numberWithInt: 10000],
                             @"skip": [NSNumber numberWithInt: 0]};
    
    [manager GET:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_GET_COMMENTS] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *arrResponse = responseObject;
        success(arrResponse);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"get comment error = %@", error);
        failure();
    }];
}

//====================================================================================================
- (void) reportComment:(int)commentID success:(void (^)(void))success failure:(void (^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    NSDictionary * params = [[NSDictionary alloc] initWithObjectsAndKeys: [NSNumber numberWithInt: commentID], @"id", nil];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    [manager PUT:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_REPORT_COMMENT] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
        success();
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure();
    }];
}

//====================================================================================================
- (void)deleteComment: (int)commentID success:(void(^)(void))success failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    NSDictionary * params = [[NSDictionary alloc] initWithObjectsAndKeys: [NSNumber numberWithInt: commentID], @"id", nil];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    [manager DELETE:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_DELETE_COMMENT]
         parameters:params
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                success();
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"error: %@",  operation.responseString);
                failure();
            }];
}

//====================================================================================================
- (void)createShopItem:(NSMutableDictionary*) diccSharedParams
          andImageData:(NSMutableArray*)arrImgData
               success:(void(^)(void)) success
               failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
    [serializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];

    for(int i = 0; i < [arrImgData count]; i++)
    {
        NSString* prefix = [NSString stringWithFormat: @"images[%d]", i];
        NSDictionary* dicItem = [arrImgData objectAtIndex: i];
        for(NSString* key in [dicItem allKeys])
        {
            [diccSharedParams setObject: [dicItem valueForKey: key] forKey: [NSString stringWithFormat: @"%@[%@]", prefix, key]];
        }
    }
    NSLog(@"param = %@", diccSharedParams);
    [manager POST:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_CREATE_ITEM] parameters: diccSharedParams success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        success();
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"create shop error: %@",  operation.responseString);
        failure();
    }];
}

//====================================================================================================
- (void)uploadImageWithData:(NSData*)imgData success:(void(^)(NSDictionary *dicResponse)) success failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    [manager POST:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_UPLOAD_IMAGE] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imgData name:@"File[file]" fileName:@"photo.jpg" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dicResponse = responseObject;
        success(dicResponse);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        failure();
    }];
}

//====================================================================================================
- (void)makeVoteWithItemId:(NSNumber*)itemId success:(void(^)(NSDictionary *dicResponse))success failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    NSDictionary * params = [[NSDictionary alloc] initWithObjectsAndKeys:itemId,@"id", nil];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    [manager PUT:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_VOTE] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure();
    }];
}

//====================================================================================================
- (void) makeVoteWithItemId:(NSNumber*)itemId type:(NSNumber*)type success:(void(^)(NSDictionary *dicResponse))success failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    NSDictionary * params = [[NSDictionary alloc] initWithObjectsAndKeys:itemId, @"id", type, @"type", nil];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    [manager PUT:[NSString stringWithFormat:@"%@%@", SERVER_URL, REQUEST_VOTE] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure();
    }];
}

//====================================================================================================
- (void)findFriendsWithNumbers:(NSArray*)arrNumbers success:(void(^)(NSDictionary*))success failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    NSDictionary * params = [[NSDictionary alloc] initWithObjectsAndKeys:arrNumbers,@"phoneNumbers", nil];
    [manager POST:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_FIND_FRIENDS] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dicResponse = (NSDictionary *) responseObject;
        success(dicResponse);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure();
    }];
}

- (void)sendInviteWithContacts:(NSArray*)attContacts success:(void(^)(void))success failure:(void(^)(void))failure{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    NSDictionary * params = [[NSDictionary alloc] initWithObjectsAndKeys:attContacts,@"user_invited_contact", nil];
    [manager POST:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_SEND_INVITES] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {       
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure();
    }];
}

- (void)getFriendsOfFriends:(NSArray*)arrNumbers success:(void(^)(NSDictionary *dicResp)) success failure:(void(^)(void))failure{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    NSDictionary * params = [[NSDictionary alloc] initWithObjectsAndKeys:arrNumbers,@"phone_numbers", nil];
    [manager PUT:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_FRIENDS_OF_FRIENDS] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dicResponse = (NSDictionary *) responseObject;
        success(dicResponse);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure();
    }];
}


- (void)addCommentsForItemWithId:(int)itemID withText:(NSString*)strText success:(void(^)(void))success failure:(void(^)(void))failur{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    NSDictionary * params = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:itemID],@"id", strText, @"text", nil];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    [manager POST:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_ADD_COMMENT] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        failur();
        NSLog(@"post commenting error: %@",  error);
    }];
}

- (void)getVotesForItemsId:(int)itemID success:(void(^)(NSArray *arrResult)) success failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    NSDictionary* param = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt: itemID], @"id", nil];
    [manager GET:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_GET_VOTES] parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure();
    }];
}

- (void)getCategoriesWithSuccessBlock:(void(^)(NSArray *dicResp)) success failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];   
    [manager GET:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_CATEGORY] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *arrResponse = responseObject;
        success(arrResponse);
//        success([dicResponse objectForKey:@"users"]);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure();
    }];
}

- (void)getBrowseWithSuccessBlock:(void(^)(NSDictionary *dicResponse))success failure:(void(^)(void))failure{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    [manager GET:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_BROWSE] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dicResponse = responseObject;
        success(dicResponse);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure();
    }];
}

- (void)getMyListWithSuccessBlock:(void(^)(NSDictionary *dicResponse))success failure:(void(^)(void))failure{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    [manager GET:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_MY_LIST] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dicResponse = responseObject;
        success(dicResponse);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure();
    }];
}

- (void)getProfileInfo:(void(^)(NSDictionary *dicResponse))success failure:(void(^)(void))failure{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    [manager GET:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_PROFILE_INFO] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dicResponse = responseObject;
        success(dicResponse);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure();
    }];
}

#pragma mark - 
#pragma mark Create Items

//====================================================================================================
- (void)checkSocialTokens:(void(^)(NSDictionary *dicResponse)) success failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    [manager GET:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_CHECKSOCIALTOKEN] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSDictionary *dicResponse = responseObject;
        success(dicResponse);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"checkSocialTokens failed");
        failure();
    }];
}

//====================================================================================================
- (void)setSocialTokens:(int) provider
                  token: (NSString*) token
            expiry_time: (int)expiry_time
         social_user_id: (int)social_user_id
          signedRequest: (NSString*)signedRequest
                 secret: (NSString*)secret
                success:(void(^)(NSDictionary *dicResponse)) success failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    
    expiry_time = 24 * 3600;
    
    NSMutableDictionary * params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                    [NSNumber numberWithInt: provider], @"provider",
                                    token, @"token",
                                    [NSNumber numberWithInt: expiry_time], @"expiry_time",
                                    secret, @"params[secret]",
                                    signedRequest, @"params[signedRequest]",
                             nil];
    
    [manager PUT:[NSString stringWithFormat: @"%@%@",SERVER_URL, REQUEST_SETSOCIALTOKEN] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
        NSDictionary *dicResponse = (NSDictionary *) responseObject;
        success(dicResponse);
         
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"REQUEST_SETSOCIALTOKEN failed");
        failure();
    }];
    
}

//====================================================================================================
- (void)searchPlaces:(NSString *)keyword
              radius:(int)radius
                 lat: (float) lat
                 lng: (float) lng
             success:(void (^)(NSArray *))success
             failure:(void (^)(NSString *))failure
{
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://maps.googleapis.com/maps/api/place/nearbysearch"]];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [NSString stringWithFormat:@"%f,%f", lat, lng], @"location",
                                   @(radius), @"radius",
                                   @"false", @"sensor",
                                   GOOGLE_API_KEY, @"key",
                                   nil];

    if(keyword != nil && [keyword length] > 0)
    {
        [params setValue: keyword forKey: @"keyword"];
    }
    
    [manager GET:@"json" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *dictionary = responseObject;
        NSArray *results = dictionary[@"results"];
        success(results);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error)
    {
        NSLog(@"%@", error.description);
        failure(error.description);
    }];
}

//====================================================================================================
- (void) searchGlobalPlaces: (NSString*) keyword
                    success:(void (^)(NSArray *))success
                    failure:(void (^)(NSString *))failure

{
    NSString* url = [[NSString stringWithFormat: @"%@autocomplete/json?key=%@&input=%@", BASE_GOOGLE_PLACE_URL, GOOGLE_API_KEY, keyword] stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET: url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"response = %@", responseObject);
         NSDictionary *json=(NSDictionary*)responseObject;
         NSMutableArray* arrResult = [[NSMutableArray alloc] init];

         if(json != nil)
         {
             NSArray* predictions = [json valueForKey: @"predictions"];
             if(predictions != nil)
             {
                 for(NSDictionary* dicItem in predictions)
                 {
                     NSString* locationID = [dicItem valueForKey: @"id"];
                     NSString* address = [dicItem valueForKey: @"description"];
                     SCLocation* location = [[SCLocation alloc] init];
                     location.locationId = locationID;
                     location.address = address;
                     [arrResult addObject: location];
                 }
             }
         }
         success(arrResult);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         failure(error.description);
     }];
}

#pragma mark -
#pragma mark User Place

//====================================================================================================
- (void) createUserPlace: (NSString*) google_id
                 address: (NSString*)address
                    name: (NSString*)name
                     lat: (float) lat
                     lng: (float) lng
                 success:(void(^)(NSDictionary *dicResponse)) success
                 failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    
    NSDictionary * params = [[NSDictionary alloc] initWithObjectsAndKeys:
                             google_id, @"google_place_id",
                             address, @"address",
                             name, @"name",
                             [NSNumber numberWithFloat: lat],
                             [NSNumber numberWithFloat: lng],
                             nil];
    
    [manager POST:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_USERPLACE_CREATE] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSDictionary *dicResponse = responseObject;
        success(dicResponse);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         failure();
     }];
}

//====================================================================================================
- (void) getShopList: (int) user_id
             success:(void(^)(NSArray *arrResult)) success
             failure:(void(^)(void))failure;
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    NSDictionary *params = @{@"user_id": [NSNumber numberWithInt: user_id]};
    
    [manager GET:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_USERPLACE_LIST]
      parameters: params
         success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSArray* arrData = responseObject;
         success(arrData);
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         failure();
     }];
}

//====================================================================================================
- (void) deletePlaceList: (int) shopId
                 success:(void(^)(NSDictionary *dicResponse)) success
                 failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
    [serializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt: shopId], @"id", nil];
    [manager DELETE:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_USERPLACE_DELETE]
         parameters:params
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@",  operation.responseString);
        failure();
    }];
}

//====================================================================================================
- (void) userWalking: (float) lat
                 lng: (float) lng
             success:(void(^)(NSDictionary *dicResponse)) success
             failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    NSDictionary *params = @{@"lat": [NSNumber numberWithFloat: lat], @"lng": [NSNumber numberWithFloat: lng], @"radius": [NSNumber numberWithFloat: WALKING_RADIUS]};
    
    [manager GET:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_USERPLACE_WALKING]
      parameters: params
         success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         success(responseObject);
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         failure();
     }];
}

//====================================================================================================
- (void) cancelAllRequest
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.operationQueue cancelAllOperations];
}

#pragma mark - 
#pragma mark Direct Message.

//====================================================================================================
- (void)createDirectMessage:(NSMutableDictionary*) diccSharedParams
               andImageData:(NSMutableArray*)arrImgData
                    success:(void(^)(void)) success
                    failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
    [serializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    
    for(int i = 0; i < [arrImgData count]; i++)
    {
        NSString* prefix = [NSString stringWithFormat: @"images[%d]", i];
        NSDictionary* dicItem = [arrImgData objectAtIndex: i];
        for(NSString* key in [dicItem allKeys])
        {
            [diccSharedParams setObject: [dicItem valueForKey: key] forKey: [NSString stringWithFormat: @"%@[%@]", prefix, key]];
        }
    }
    NSLog(@"param = %@", diccSharedParams);
    [manager POST:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_DM_CREATE] parameters: diccSharedParams success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         success();
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"create shop error: %@",  operation.responseString);
         failure();
     }];
}

//====================================================================================================
- (void)uploadDMImage:(NSData*)imgData success:(void(^)(NSDictionary *dicResponse)) success failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    [manager POST:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_DM_UPLOAD_IMAGE] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imgData name:@"File[file]" fileName:@"photo.jpg" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dicResponse = responseObject;
        success(dicResponse);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         failure();
     }];
}

//====================================================================================================
- (void) getDMList:(int) limit
              skip:(int) skip
           success:(void(^)(NSArray *arrResponse))success
           failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    NSDictionary *params = @{
                             @"limit": [NSNumber numberWithInt: limit],
                             @"skip": [NSNumber numberWithInt: skip],
                             };
    [manager GET:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_DM_LIST] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         success(responseObject);
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"REQUEST_DM_LIST failed = %@", error);
         failure();
     }];
}

//====================================================================================================
- (void) deleteDM:(int) dm_id
          success:(void(^)(void))success
          failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
    [serializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt: dm_id], @"id", nil];
    
    [manager DELETE:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_DM_DELETE] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success();
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"REQUEST_DM_DELETE error: %@",  operation.responseString);
        failure();
    }];
}

//====================================================================================================
- (void)makeDMVoteWithItemId:(NSNumber*)itemId
                     success:(void(^)(NSDictionary *dicResponse))success
                     failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    NSDictionary * params = [[NSDictionary alloc] initWithObjectsAndKeys:itemId,@"id", nil];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    [manager PUT:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_DM_VOTE] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure();
    }];
}

//====================================================================================================
- (void) makeDMVoteWithItemId:(NSNumber*)itemId
                         type:(NSNumber*)type
                      success:(void(^)(NSDictionary *dicResponse))success
                      failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    NSDictionary * params = [[NSDictionary alloc] initWithObjectsAndKeys:itemId, @"id", type, @"type", nil];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    [manager PUT:[NSString stringWithFormat:@"%@%@", SERVER_URL, REQUEST_DM_VOTE] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure();
    }];
}

//====================================================================================================
- (void) getDMComments:(int) message_id
                 limit:(int) limit
                  skip:(int) skip
               success:(void(^)(NSArray *arrResponse))success
               failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    NSDictionary *params = @{
                             @"id": [NSNumber numberWithInt: message_id],
                             @"limit": [NSNumber numberWithInt: limit],
                             @"skip": [NSNumber numberWithInt: skip],
                             };
    [manager GET:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_DM_GET_COMMENT] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         success(responseObject);
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"REQUEST_DM_LIST failed = %@", error);
         failure();
     }];
}

//====================================================================================================
- (void)addDMComment:(int)itemID withText:(NSString*)strText success:(void(^)(void))success failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    NSDictionary * params = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:itemID],@"id", strText, @"text", nil];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    [manager POST:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_DM_ADD_COMMENT] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         success();
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         failure();
         NSLog(@"post commenting error: %@",  error);
     }];
}

//====================================================================================================
- (void)reportDMComment: (int)commentID success:(void(^)(void))success failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    NSDictionary * params = [[NSDictionary alloc] initWithObjectsAndKeys: [NSNumber numberWithInt: commentID], @"id", nil];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    [manager PUT:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_DM_REPORT] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         success();
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         failure();
     }];
}

//====================================================================================================
- (void)deleteDMComment: (int)commentID success:(void(^)(void))success failure:(void(^)(void))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    NSDictionary * params = [[NSDictionary alloc] initWithObjectsAndKeys: [NSNumber numberWithInt: commentID], @"id", nil];
    [manager.requestSerializer setValue:[Utilities getAuthKey] forHTTPHeaderField:@"X-Auth"];
    [manager DELETE:[NSString stringWithFormat:@"%@%@",SERVER_URL, REQUEST_DM_DELETE_COMMENT]
         parameters:params
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                success();
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"error: %@",  operation.responseString);
                failure();
            }];
}

//====================================================================================================
 */
@end
 
