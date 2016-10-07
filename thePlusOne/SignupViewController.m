//
//  SignupViewController.m
//  thePlusOne
//
//  Created by My Star on 6/23/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import "SignupViewController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "Engine.h"
#import "MBProgressHUD.h"
#import "NetworkClient.h"

@interface SignupViewController(){
    UIView *topView;
    AppDelegate *appDelegate;
    
}
@end

@implementation SignupViewController
-(void)viewDidLoad{
    
    //set topView
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    topView = window.rootViewController.view;
    
    appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    //make signup button corner-rounded
    [_btnSignup.layer setCornerRadius:5.0f];
    [_btnSignup.layer setMasksToBounds:YES];
    
    if (![appDelegate.inviteCode isEqualToString:@""]) {
        _tfCode.text = appDelegate.inviteCode;
    }
}
- (IBAction)btnBackTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnSignupTapped:(id)sender {
    [self textFieldShouldReturn:_tfPassword];
    
}
- (IBAction)btnLoginTapped:(id)sender {
    [Engine goToViewController:@"LoginViewController" from:self];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    if(textField == _tfFirstName)
    {
        [_tfLastName becomeFirstResponder];
        return YES;
    }
    if(textField == _tfLastName)
    {
        [_tfEmailAddress becomeFirstResponder];
        return YES;
    }
    if(textField == _tfEmailAddress)
    {
        [_tfPassword becomeFirstResponder];
        return YES;
    }
    [textField resignFirstResponder];
    
    NSString *firstName = _tfFirstName.text;
    NSString *lastName = _tfLastName.text;
    NSString *emailAddress = _tfEmailAddress.text;
    NSString *password = _tfPassword.text;
    
    if(firstName == nil || [firstName length] == 0)
    {
        [Engine showErrorMessage: @"Oops!" message: MSG_FIRSTNAME_BLANK onViewController:self];
        return YES;
    }
    if(lastName == nil || [lastName length] == 0)
    {
        [Engine showErrorMessage: @"Oops!" message: MSG_LASTNAME_BLANK onViewController:self];
        return YES;
    }
    
    if(![Engine emailValidate: emailAddress])
    {
        [Engine showErrorMessage: @"Oops!" message: MSG_EMAIL_NOT_VALID onViewController:self];
        return YES;
    }
    if(password == nil || [password length] < 5)
    {
        [Engine showErrorMessage: @"Oops!" message: MSG_PASSWORD_EMPTY onViewController:self];
        return YES;
    }
    
    [self signup];
    
    return YES;
}

-(void)signup{

    [Engine showHUDonView:topView];
    
    NSString *strEmail = _tfEmailAddress.text;
    strEmail = [strEmail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *password = _tfPassword.text;
    password = [password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *firstName = _tfFirstName.text;
    firstName = [firstName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *lastName = _tfLastName.text;
    lastName = [lastName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    
    [[NetworkClient sharedInstance]signUpWithEmail:(NSString*)strEmail
                                          password:(NSString*)password
                                         firstName:(NSString*)firstName
                                          lastName:(NSString*)lastName
                                           success:^(NSDictionary* dicResponse)
        {
        
           [Engine hideHUDonView:topView];
            
//            appDelegate.isFirstTime = YES;           
            
            
            [self login];
            
        } failure:^(NSString *message){
                                                    
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [MBProgressHUD hideHUDForView:topView animated:YES];
                
                //check if the same email address exists
                if ([message containsString:@"duplicate key value"])                                              {
                    [Engine showErrorMessage: @"Oops!" message: MSG_EMAIL_EXIST onViewController:self];
                }else{
                    [Engine showErrorMessage: @"Oops!" message: MSG_NETWORK_ERROR onViewController:self];
                }
                
            });
            ///
        }
     ];
    
}
-(void)login{
    
    [Engine showHUDonView:self.view];
    
    
    NSString *strEmail = _tfEmailAddress.text;
    strEmail = [strEmail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *password = _tfPassword.text;
    password = [password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    [[NetworkClient sharedInstance]loginWithEmail:strEmail
                                         password:password
                                          success:^(NSDictionary* dicResponse)
     {
         NSLog(@"login response: %@", dicResponse);
         
         appDelegate.accessToken = [dicResponse objectForKey:@"access_token"];
         NSInteger userId = [[[dicResponse objectForKey:@"user"]objectForKey:@"id"]integerValue];
         
         [Engine hideHUDonView:self.view];
         
         //create profile in backend DB
//         if (appDelegate.isFirstTime) {
             [self postProfile:userId];
//         }else{
//             [self getProfile:userId];
//         }
         
         [[NSUserDefaults standardUserDefaults] setValue:strEmail forKey:@"email_address"];
         
         appDelegate.profile.emailAddress = strEmail;
         
     } failure:^(NSString *message){
         dispatch_async(dispatch_get_main_queue(), ^{
             
             [Engine hideHUDonView:self.view];
             
             //show message if not empty
             if (![message isEqualToString:@""])                                              {
                 [Engine showErrorMessage: @"Oops!" message: message onViewController:self];
             }else{
                 [Engine showErrorMessage: @"Oops!" message: MSG_NETWORK_ERROR onViewController:self];
             }
             
         });
         ///
     } ];
}

-(void)postProfile:(NSInteger)userId{
    [Engine showHUDonView:self.view];
    
    NSString *phone = @"912-345-6789";
    //build notifications dictionary
    NSDictionary *dicNotifications = @{
                                       @"appointments":[NSNumber numberWithBool:true]
                                       };
    ///
    
    [[NetworkClient sharedInstance]postUserProfileWithUserId:userId profilePicUrl:@"" phone:phone notifications:dicNotifications success:^(NSDictionary *dic) {
        [Engine hideHUDonView:self.view];
        
        //Save profile.
        [Engine saveProfile:dic];
        ///
        
        //save notifications flag
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"On" forKey:@"switchNotification"];
        ///
        
        appDelegate.profile.sessionsAvailable = [[dic objectForKey:@"sessions_available"]integerValue];
        appDelegate.profile.sessionsCompleted = [[dic objectForKey:@"sessions_completed"]integerValue];
        appDelegate.profile.sessionsPurchased = [[dic objectForKey:@"sessions_purchased"]integerValue];
//        [self goNext];
        [self getProfile:userId];
        
    } failure:^(NSString *message) {
        
        [Engine hideHUDonView:self.view];
        [Engine showErrorMessage:@"Oops!" message:message onViewController:self];
        
    }];
}
-(void)getProfile:(NSInteger)userId{
    [Engine showHUDonView:self.view];
    
    
    [[NetworkClient sharedInstance]getUserProfileWithUserId:userId success:^(NSDictionary *dic) {
        [Engine hideHUDonView:self.view];
        
        //Save profile.
        [Engine saveProfile:dic];
        ///
        
        //save notifications flag
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        BOOL notifications = [[[dic objectForKey:@"notifications"]objectForKey:@"appointments"]boolValue];
        if (notifications) {
            [defaults setObject:@"On" forKey:@"switchNotification"];
        }else{
            [defaults setObject:@"Off" forKey:@"switchNotification"];
        }
        ///
        
        appDelegate.profile.sessionsAvailable = [[dic objectForKey:@"sessions_available"]integerValue];
        appDelegate.profile.sessionsCompleted = [[dic objectForKey:@"sessions_completed"]integerValue];
        appDelegate.profile.sessionsPurchased = [[dic objectForKey:@"sessions_purchased"]integerValue];
        [self goNext];
        
    } failure:^(NSString *message) {
        
        [Engine hideHUDonView:self.view];
        [Engine showErrorMessage:@"Oops!" message:message onViewController:self];
        
    }];
}
-(void)goNext{
    
    //get appointments
    [Engine showHUDonView:self.view];
    [[NetworkClient sharedInstance]getAppointmentsWithSuccess:^(NSArray *arrResponse) {
        appDelegate.arrAppointments = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dic in arrResponse) {
            Appointment *appointment = [[Appointment alloc]initWithDic:dic];
            if (appointment.isPlueOne) {
                appointment.plusOnePhotoData = [Engine loadPhotoWithId:appointment.iid];
            }
            
            if ([Engine isFutureAppointment:appointment] ) {
                [appDelegate.arrAppointments addObject:appointment];
            }
        }
        [Engine hideHUDonView:self.view];
        //************** if user got invited session on landing page ****
        if (appDelegate.invitedAppointment) {
            [self processInvitedAppointment];
            return;
        }
        
        //************** process invited session if any *****************
        if ([_tfCode.text length] == 8) {
            [self processInviteCode];
        }
        //************** process gift session if any ********************
        else if([_tfCode.text length] == 7){
            [self processGiftCode];
        }
        
        
        else{ //no invited sessions
            dispatch_async(dispatch_get_main_queue(), ^{
                //go next
                int userStatus = [Engine getUserStatus];
                if (userStatus == USER_STAT_GO_SCHEDULE) {
                    [Engine goToViewController:@"SWRevealViewController" from:self];
                }else if(userStatus == USER_STAT_GIFT_SESSION){
                    [Engine goToViewController:@"ContactsViewController" from:self];
                }else{
                    [Engine goToViewController:@"SubmitPaymentViewController" from:self];
                }
            });
        }
        
    } failure:^(NSString *message) {
        [Engine hideHUDonView:self.view];
        [Engine showErrorMessage:@"Oops!" message:message onViewController:self];
        
    }];
    
}
-(void)processInvitedAppointment{
    //associate the invite with the user record
    [Engine showHUDonView:self.view];
    [[NetworkClient sharedInstance]putAppointmentInvitesWithInviteId:appDelegate.inviteId userId:[appDelegate.profile.userId integerValue] success:^(NSDictionary *dic) {
        [Engine hideHUDonView:self.view];
        
        //invite processed
        appDelegate.inviteId = -1;
        
        //get the current appointment
        //and go to video call if join_now mode
        if (appDelegate.inviteMode == INVITE_MODE_JOIN_NOW) {
            [Engine showHUDonView:self.view];
            [[NetworkClient sharedInstance]postAppointmentStreamsWithAppointmentId:appDelegate.invitedAppointment.iid success:^(NSDictionary *dic) {
                
                [Engine hideHUDonView:self.view];
                appDelegate.invitedAppointment.apiKey = [dic objectForKey:@"tokbox_api_key"];
                appDelegate.invitedAppointment.token = [dic objectForKey:@"tokbox_token"];
                appDelegate.invitedAppointment.sessionId = [dic objectForKey:@"tokbox_session_id"];
                
                appDelegate.currentAppointment = appDelegate.invitedAppointment;
                
                [appDelegate.arrAppointments addObject:appDelegate.invitedAppointment];
                
                [Engine goToViewController:@"VideoCallViewController" from:self];
                
            } failure:^(NSString *message) {
                [Engine hideHUDonView:self.view];
                [Engine showErrorMessage:@"Oops!" message:@"Couldn't get video call parameters" onViewController:self];
            }];
        }
        else{//invitemode == join_future
            [appDelegate.arrAppointments addObject:appDelegate.invitedAppointment];
            [Engine goToViewController:@"SWRevealViewController" from:self];
        }
        
        
    } failure:^(NSString *message) {
        [Engine hideHUDonView:self.view];
        
        [Engine showErrorMessage:@"Oops!" message:@"Couldn't associate the invite with the user record" onViewController:self];
    }];
}

-(void)processInviteCode{
    NSString *inviteCode = _tfCode.text;
    
    [Engine showHUDonView:self.view];
    [[NetworkClient sharedInstance]getAppointmentInvitesWithInviteCode:inviteCode success:^(NSDictionary *dic) {
        [Engine hideHUDonView:self.view];
        
        //check if the session is already completed and if yes, return
        if ([[[dic objectForKey:@"appointment"]objectForKey:@"status"]isEqualToString:@"completed"]) {
            [Engine showErrorMessage:@"Oops!" message:@"The invited session is already completed" onViewController:self];
            return;
        }
        
        //get inviteId, appointmentId and invite mode
        appDelegate.inviteId = [[dic objectForKey:@"id"]integerValue];
        appDelegate.invitedAppointment = [[Appointment alloc]initWithDic:[dic objectForKey:@"appointment"]];
        NSString *strSessionDate = [[dic objectForKey:@"appointment"]objectForKey:@"scheduled_for"];
        NSDate *sessionDate = [Engine dateWithString:strSessionDate];
        if ([sessionDate compare:[NSDate date]] == NSOrderedAscending) {
            appDelegate.inviteMode = INVITE_MODE_JOIN_NOW;
        }else{
            appDelegate.inviteMode = INVITE_MODE_JOIN_FUTURE;
        }
        
        
        //associate the invite with the user record
        [Engine showHUDonView:self.view];
        [[NetworkClient sharedInstance]putAppointmentInvitesWithInviteId:appDelegate.inviteId userId:[appDelegate.profile.userId integerValue] success:^(NSDictionary *dic) {
            [Engine hideHUDonView:self.view];
            
            //invite processed
            appDelegate.inviteId = -1;
            
            //get the current appointment
            //and go to video call if join_now mode
            if (appDelegate.inviteMode == INVITE_MODE_JOIN_NOW) {
                [Engine showHUDonView:self.view];
                [[NetworkClient sharedInstance]postAppointmentStreamsWithAppointmentId:appDelegate.invitedAppointment.iid success:^(NSDictionary *dic) {
                    
                    [Engine hideHUDonView:self.view];
                    appDelegate.invitedAppointment.apiKey = [dic objectForKey:@"tokbox_api_key"];
                    appDelegate.invitedAppointment.token = [dic objectForKey:@"tokbox_token"];
                    appDelegate.invitedAppointment.sessionId = [dic objectForKey:@"tokbox_session_id"];
                    
                    appDelegate.currentAppointment = appDelegate.invitedAppointment;
                    
                    [appDelegate.arrAppointments addObject:appDelegate.invitedAppointment];
                    
                    [Engine goToViewController:@"VideoCallViewController" from:self];
                    
                } failure:^(NSString *message) {
                    [Engine hideHUDonView:self.view];
                    [Engine showErrorMessage:@"Oops!" message:@"Couldn't get video call parameters" onViewController:self];
                }];
            }
            else{//invitemode == join_future
                [appDelegate.arrAppointments addObject:appDelegate.invitedAppointment];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //go next
                    int userStatus = [Engine getUserStatus];
                    if (userStatus == USER_STAT_GO_SCHEDULE) {
                        [Engine goToViewController:@"SWRevealViewController" from:self];
                    }else if(userStatus == USER_STAT_GIFT_SESSION){
                        [Engine goToViewController:@"ContactsViewController" from:self];
                    }else{
                        [Engine goToViewController:@"SubmitPaymentViewController" from:self];
                    }
                });
            }
            
            
        } failure:^(NSString *message) {
            [Engine hideHUDonView:self.view];
            
            [Engine showErrorMessage:@"Oops!" message:@"Couldn't associate the invite with the user record" onViewController:self];
        }];

        
        
    } failure:^(NSString *message) {
        [Engine hideHUDonView:self.view];
        [Engine showErrorMessage:@"Oops!" message:@"The invite code invalid" onViewController:self];
    }];
}
-(void)processGiftCode{
    NSString *giftCode = _tfCode.text;
    
    [Engine showHUDonView:self.view];
    
    [[NetworkClient sharedInstance]getGiftSessionsWithGiftCode:giftCode success:^(NSDictionary *dic) {
        [Engine hideHUDonView:self.view];
        NSInteger sessionsCount = [[dic objectForKey:@"sessions_count"]integerValue];
        appDelegate.profile.sessionsPurchased += sessionsCount;
        
    } failure:^(NSString *message) {
        
        [Engine hideHUDonView:self.view];
        [Engine showErrorMessage:@"Oops!" message:message onViewController:self];
    }];
}
@end
