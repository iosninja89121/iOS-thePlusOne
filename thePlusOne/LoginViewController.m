//
//  LoginViewController.m
//  thePlusOne
//
//  Created by My Star on 6/21/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import "LoginViewController.h"
#import "HomeViewController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "MBProgressHUD.h"
#import "Engine.h"
#import "HomeViewController.h"
#import "NetworkClient.h"


@interface LoginViewController ()<UITextFieldDelegate>
{
    
    UIView *topView;
    int providerIndex;
    AppDelegate *appDelegate;
}
@end

@implementation LoginViewController

-(void)viewDidLoad{
    
    //set topView
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    topView = window.rootViewController.view;

    appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    //make signup button corner-rounded
    [_btnLogin.layer setCornerRadius:5.0f];
    [_btnLogin.layer setMasksToBounds:YES];
    
    if (![appDelegate.inviteCode isEqualToString:@""]) {
        _tfCode.text = appDelegate.inviteCode;
    }
}
- (IBAction)btnSignupTapped:(id)sender {
    [Engine goToViewController:@"SignupViewController" from:self];
}
- (IBAction)btnBackTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnGooglePlusTapped:(id)sender {
   
}
- (IBAction)btnFacebookTapped:(id)sender {
    
/*    [MBProgressHUD showHUDAddedTo:topView animated:YES];
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login
     logInWithReadPermissions: @[@"public_profile", @"email", @"user_friends"]
     fromViewController:self
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             NSLog(@"Process error");
         } else if (result.isCancelled) {
             NSLog(@"Cancelled");
         } else {
             NSLog(@"Logged in");
             NSLog(@"AccessToken =  %@",result.token);
             
             //get full name, user name, email address and password from FB
             
             [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"picture.type(large), email, name, id, gender,age_range,birthday,location"}]
              startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                  
                  if (!error) {
                      
                      ///Get User Friends//////////
                      NSString *getUserQuery = [NSString stringWithFormat:@"/%@/%@",@"me",@"invitable_friends"];
                      FBSDKGraphRequest *friendGetRequest = [[FBSDKGraphRequest alloc]
                                                             initWithGraphPath:getUserQuery
                                                             parameters:nil
                                                             HTTPMethod:@"GET"];
                      [friendGetRequest startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                                                     id friendresult,
                                                                     NSError *frienderror) {
                          if (!frienderror) {
                              NSLog(@"Friend_list Error %@",frienderror);
                              NSLog(@"Friends_List =  %@",friendresult);
                              NSArray *friendArray = [friendresult objectForKey:@"data"];
                              NSMutableArray *friendStringArray = [NSMutableArray array];
                              
                              ///User_friends GET/////////////
                              
                              for (NSDictionary *theFriendInfoDic in friendArray)
                              {
                                  NSString *tempStr = [NSString stringWithFormat:@"%@ = %@ = %@",theFriendInfoDic[@"id"],theFriendInfoDic[@"name"],theFriendInfoDic[@"picture"][@"data"][@"url"]];
                                  [friendStringArray addObject:tempStr];
                              }
                              /////////////////////////////////
                              
                              ///////USER_Model_make//////////
                              userID = [result objectForKey:@"id"];
                              NSDictionary *ageRangeDict = [result objectForKey:@"age_range"];
                              NSString *age_range = [NSString stringWithFormat:@"%@-%@",
                                                     [ageRangeDict objectForKey:@"min"],
                                                     [ageRangeDict objectForKey:@"max"]];
                              NSString *profile_url = result[@"picture"][@"data"][@"url"];
                              NSString *gender = result[@"gender"];
                              NSLog(@"RESULT = %@",result);
                              [AppDelegate sharedAppDelegate].profile_picture_url = profile_url;
                              NSDictionary *userModelDic = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                            userID,USERID,
                                                            result[@"name"],USERNAME,
                                                            result[@"email"],USEREMAIL,
                                                            age_range,USER_AGE,
                                                            gender,USERGENDER,
                                                            profile_url,USERPROFILEIMGET,
                                                            friendStringArray,USERFRIENDS, nil];
                              NSLog(@"USERMODEL = %@",userModelDic);
                             ////////////////////////////////////
                              
                              ///////Creat_User////////////
                              [ApiService creatUser:USER_CREAT_URI withJsonUserData:userModelDic withCompletion:^(BOOL succes_flag) {
                                  if (succes_flag == true) {
                                      NSLog(@"UserCreat :  OK");
                                      
                                      /////Creat_Session///////////
                                      [ApiService creatSession:USER_CREAT_SESSION_URI withUserID:userID withDeviceID:deviceID
                                                withCompletion:^(SessionModel *sessionModel) {
                                                    [[AppDelegate sharedAppDelegate] hideWaitingScreen];
                                                    [self successLogin];
                                                    [CommonFunction saveUserID:userID];
                                                    [CommonFunction saveSessionID:sessionModel._id];
                                                } failure:^(NSError *error) {
                                                    [[AppDelegate sharedAppDelegate] hideWaitingScreen];
                                                }];
                                      
                                  }else{
                                      
                                      [[[UIAlertView alloc ] initWithTitle:@"" message:@"Login Failed!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                                      NSLog(@"UserCreat :  NO");
                                      [[AppDelegate sharedAppDelegate] hideWaitingScreen];
                                  }
                              } failure:^(NSError *error) {
                                  [[AppDelegate sharedAppDelegate] hideWaitingScreen];
                                  NSLog(@"%@",error);
                              }];
                          }else{
                              [[AppDelegate sharedAppDelegate] hideWaitingScreen];
                              [[[UIAlertView alloc ] initWithTitle:@"" message:@"Network Connection Error90!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                          }
                          // Handle the result
                      }];
                      
                      
                  }else{
                      [MBProgressHUD hideHUDForView:topView animated:YES];
                      [[[UIAlertView alloc ] initWithTitle:@"" message:@"Network Connection Error!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                  }
              }];
             
         }
     }];
*/
    
}
- (IBAction)btnLoginTapped:(id)sender {
    
    [self textFieldShouldReturn:_tfPassword];
    
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    if(textField == _tfEmailAddress)
    {
        [_tfPassword becomeFirstResponder];
        return YES;
    }
    
    NSString* email = _tfEmailAddress.text;
    NSString* password = _tfPassword.text;
    
    if(email == nil || [email length] < 5)
    {
        [Engine showErrorMessage: @"Oops!" message: MSG_EMAIL_BLANK onViewController:self];
        return YES;
    }
    
    if(![Engine emailValidate: email])
    {
        [Engine showErrorMessage: @"Oops!" message: MSG_EMAIL_NOT_VALID onViewController:self];
        return YES;
    }
    
    if(password == nil || [password length] == 0)
    {
        [Engine showErrorMessage: @"Oops!" message: MSG_PASSWORD_EMPTY onViewController:self];
        return YES;
    }
    
    [textField resignFirstResponder];
    
    [self login];
    return YES;
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
//        if (appDelegate.isFirstTime) {
//            [self postProfile:userId];
//        }else{
            [self getProfile:userId];
//        }
        
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
        
        //save notifications flag
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"On" forKey:@"switchNotification"];
        ///
        
        //Save profile.
        [Engine saveProfile:dic];
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
-(void)getProfile:(NSInteger)userId{
    [Engine showHUDonView:self.view];
    
    [[NetworkClient sharedInstance]getUserProfileWithUserId:userId success:^(NSDictionary *dic) {
        [Engine hideHUDonView:self.view];
        
        //save notifications flag
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        BOOL notifications = [[[dic objectForKey:@"notifications"]objectForKey:@"appointments"]boolValue];
        if (notifications) {
            [defaults setObject:@"On" forKey:@"switchNotification"];
        }else{
            [defaults setObject:@"Off" forKey:@"switchNotification"];
        }
        ///
        
        //Save profile.
        [Engine saveProfile:dic];
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
