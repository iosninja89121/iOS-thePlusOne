//
//  ViewController.m
//  thePlusOne
//
//  Created by My Star on 6/15/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "Engine.h"
#import "HomeViewController.h"
#import "Provider.h"

#import <Crashlytics/Crashlytics.h>


@interface ViewController (){
    UIView *topView;
    AppDelegate *appDelegate;
}

@end

@implementation ViewController
/*
- (IBAction)crashButtonTapped:(id)sender {
    [[Crashlytics sharedInstance] crash];
}
*/
- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*crash test
    UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(20, 50, 100, 30);
    [button setTitle:@"Crash" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(crashButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    */
    
    //set appDelegate
    appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    //set topView
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    topView = window.rootViewController.view;

    [self initView];
    [self initGlobalData]; 
  
   
    if ([Engine isLoggedIn]) {    
        //user will go to schedule page as default
        [Engine setUserStatus:USER_STAT_GO_SCHEDULE];
        
    }

}
-(void)initView{
    UIColor *textColor = [UIColor colorWithRed:86/255.0f green:132/255.0 blue:153/255.0 alpha:1.0];
    NSAttributedString *str = [[NSAttributedString alloc]initWithString:@"Enter Code" attributes:@{NSForegroundColorAttributeName:textColor}];
    _tfGiftCode.attributedPlaceholder = str;
    
    _viewInvite.hidden = YES;
    _viewPurchaseGifts.hidden = YES;
    
}
- (void) initGlobalData{
    
    //get providers, appointments, profile
    if ([[Engine getProviders]count]<1) {
        [self getProviders];
    }
}

-(void)getAppointments{
    if ([Engine isLoggedIn]) {
        
        //get arrAppointments
        if([appDelegate.arrAppointments count]>0){
            return;
        }
        
        if (![appDelegate.accessToken isEqualToString:@""]) {
            [Engine showHUDonView:self.view];
            [[NetworkClient sharedInstance]getAppointmentsWithSuccess:^(NSArray *arrResponse) {
                for (NSDictionary *dic in arrResponse) {
                    NSLog(@"%@", dic);
                    Appointment *appointment = [[Appointment alloc]initWithDic:dic];
                    if (appointment.isPlueOne) {
                        appointment.plusOnePhotoData = [Engine loadPhotoWithId:appointment.iid];
                    }
                    
                    if ([Engine isFutureAppointment:appointment]) {
                        [appDelegate.arrAppointments addObject:appointment];
                    }
                    
                }
                [Engine hideHUDonView:self.view];
                
                //read profile
                NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
                if([[[def dictionaryRepresentation] allKeys] containsObject:KEY_PROFILE]){                    
                }else{
                    [self getProfile];
                }
                
            } failure:^(NSString *message) {
                NSString *alertMessage;
                if([message isEqualToString:@"Your session has expired."]){
                    alertMessage = @"Your session has expired. Please log in again.";
                    [Engine logout];
                    
                }else{
                    alertMessage = message;
                }
            
                [Engine hideHUDonView:self.view];
                [Engine showErrorMessage:@"Oops!" message:alertMessage onViewController:self];
                
            }];
        }
        ///
        
    }
}

-(void)getProfile{
    [Engine showHUDonView:self.view];
    
    NSInteger userId = [appDelegate.profile.userId integerValue];
    
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
        [defaults synchronize];
        ///
        
        appDelegate.profile.sessionsAvailable = [[dic objectForKey:@"sessions_available"]integerValue];
        appDelegate.profile.sessionsCompleted = [[dic objectForKey:@"sessions_completed"]integerValue];
        appDelegate.profile.sessionsPurchased = [[dic objectForKey:@"sessions_purchased"]integerValue];
        
        NSLog(@"sessions: available %ld, completed %ld, purchased %ld", appDelegate.profile.sessionsAvailable, appDelegate.profile.sessionsCompleted, appDelegate.profile.sessionsPurchased);
        
    } failure:^(NSString *message) {
        
        [Engine hideHUDonView:self.view];
        [Engine showErrorMessage:@"Oops!" message:message onViewController:self];
        
    }];
}

-(BOOL)isProviderAvailableNow:(Provider *)provider{
    
    NSDate *date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"EEEE"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]]; //GMT timezone because all time values are specified with GMT timezone now.
    NSString *day = [formatter stringFromDate:date];
    NSLog(@"SearchProviderVC/isProviderAvailable/date : %@", [NSDate date]);
    
    int startMinutes = 0, endMinutes = 0;
    
    NSArray *arrTimes = [provider.availability objectForKey:day];
    for (NSDictionary *dic in arrTimes) {
        NSLog(@"dic: %@", dic);
        startMinutes = [[dic objectForKey:@"start_minutes"]intValue];
        endMinutes = [[dic objectForKey:@"end_minutes"]intValue];
        
        if (startMinutes>0 && endMinutes>0) {
            //get current hour and minute in GMT
            NSCalendar *gregorianCal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            [gregorianCal setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]]; //GMT timezone because all time values are specified with GMT timezone now.
//            [gregorianCal setTimeZone:[NSTimeZone timeZoneWithName:@"America/New_York"]]; //Eastern timezone because all time values are specified with ET timezone now.
            NSDateComponents *dateComps = [gregorianCal components: (NSCalendarUnitHour | NSCalendarUnitMinute)
                                                          fromDate: date];
            //get hour in GMT
            long gmtHour = [dateComps hour];
            NSLog(@"SearchProviderVC/isProviderAvailable/gmtHour : %ld", gmtHour);
            
            // check if the provider is available now
            long curMinutes = gmtHour*60 + [dateComps minute];
            if (curMinutes >= startMinutes && curMinutes <= endMinutes) {
                return YES;
            };
        }
    }
    
    return NO;
}


-(void)getProviders{
    
    //get provider list
    [Engine showHUDonView:self.view];
    
    [[NetworkClient sharedInstance] getProvidersWithSuccessBlock: ^(NSDictionary *dicResponse) {
        [Engine hideHUDonView:self.view];
        
        if(dicResponse != nil)
        {
            if([dicResponse count] > 1)
            {
                NSArray *arr = [dicResponse objectForKey:@"data"];
                NSMutableArray *arrTemp = [[NSMutableArray alloc] init];
                for(NSDictionary* dic in arr)
                {
                    Provider* provider = [[Provider alloc] initWithDic: dic];
                    [arrTemp addObject: provider];
                    [appDelegate.arrProviders addObject:provider];
                }
                
                
                NSInteger nStart = 0, nEnd = [arrTemp count] - 1;
                
                for(NSInteger i = 0; i < [arrTemp count]; i ++) {
                    Provider *provider = [arrTemp objectAtIndex:i];
                    if([self isProviderAvailableNow:provider]){
                        appDelegate.arrProviders[nStart] = provider;
                        nStart ++;
                    }else{
                        appDelegate.arrProviders[nEnd] = provider;
                        nEnd --;
                    }
                }
                
                appDelegate.connectionFailed = NO;
                
                [self getAppointments];
                
                
            }else{
                [Engine showErrorMessage:@"Oops!" message:MSG_NETWORK_ERROR onViewController:self];
            }
        }else{
            [Engine showErrorMessage:@"Oops!" message:MSG_NETWORK_ERROR onViewController:self];
        }
        //         dispatch_async(dispatch_get_main_queue(), ^{
        //         _viewProvider.hidden = NO;
        //         [self checkEmptyLabel];
        
        //         });
        
        
    } failure:^{
        [Engine hideHUDonView:self.view];
        [Engine showErrorMessage:@"Oops!" message:MSG_NETWORK_ERROR onViewController:self];
    }];
    ///
    
}


-(void)goHome{
    
    if ([appDelegate.arrProviders count]>0) {
        [Engine goToViewController:@"SWRevealViewController" from:self];
        
    }
}

-(void)viewWillAppear:(BOOL)animated{
    //hide status bar
    [Engine showStatusBar:NO];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - button actions

- (IBAction)btnGetStartedTapped:(id)sender {
    //get providers
    if ([[Engine getProviders]count]>0) {
        [Engine goToViewController:@"SearchProviderViewController" from:self];
    }
}

- (IBAction)btnLoginTapped:(id)sender {
    //skip to the home page if logged in and wasn't in ReviewSession
    if ([Engine isLoggedIn] && ![Engine getWasReviewSession]) {
        [self goHome];
    }else{
        [Engine goToViewController:@"LoginViewController" from:self];
    }
}
- (IBAction)btnGiftSessionTapped:(id)sender {
    
    if ([[Engine getProviders]count]<1) {
        return;
    }
    
    [Engine setUserStatus:USER_STAT_GIFT_SESSION];
    if ([Engine isLoggedIn]) {
        [Engine goToViewController:@"ContactsViewController" from:self];
    }else{
        [Engine goToViewController:@"GiftSessionViewController" from:self];
    }
}
- (IBAction)btnClaimTapped:(id)sender {
    if ([self.tfGiftCode.text isEqualToString:@""]) {
        [Engine showErrorMessage:@"Oops!" message:@"Please enter Gift Code" onViewController:self];
        return;
    }
    [Engine showHUDonView:self.view];
    
    [[NetworkClient sharedInstance]getGiftSessionsWithGiftCode:_tfGiftCode.text success:^(NSDictionary *dic) {
        [Engine hideHUDonView:self.view];
        NSInteger sessionsCount = [[dic objectForKey:@"sessions_count"]integerValue];
        appDelegate.profile.sessionsPurchased += sessionsCount;
        
    } failure:^(NSString *message) {
        
        [Engine hideHUDonView:self.view];
        [Engine showErrorMessage:@"Oops!" message:message onViewController:self];        
    }];
}
- (IBAction)btnEnterInviteCodeTapped:(id)sender {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:@"Please enter Invite Code" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
     
        appDelegate.inviteCode = [controller.textFields objectAtIndex:0].text;
        if ([Engine isLoggedIn]) {
            [Engine goToViewController:@"LoginViewController" from:self];
        }else{
            [Engine goToViewController:@"SignupViewController" from:self];
        }
/*
        NSString *inviteCode = [controller.textFields objectAtIndex:0].text;
        
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
            
            if ([Engine isLoggedIn]) {
                
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
                
                
            }else{
                [Engine goToViewController:@"SignupViewController" from:self];
            }
            
            
        } failure:^(NSString *message) {
            [Engine hideHUDonView:self.view];
            [Engine showErrorMessage:@"Oops!" message:@"The invite code invalid" onViewController:self];
        }];
        
*/
    }];
    [controller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Invite Code here";
    }];
    [controller addAction:ok];
    [controller addAction:cancel];
    [self presentViewController:controller animated:YES completion:nil];
}



@end
