//
//  ContactDetailViewController.m
//  thePlusOne
//
//  Created by My Star on 6/23/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import "ContactDetailViewController.h"
#import "ConfirmationViewController.h"
#import "VideoCallViewController.h"
#import <MessageUI/MessageUI.h>
#import "ScheduleSessionViewController.h"

@interface ContactDetailViewController()<MFMessageComposeViewControllerDelegate>{
    AppDelegate *appDelegate;
    
    BOOL isConfirmButtonTapped;
    int nPhoneNumberSelected;
}
@end

@implementation ContactDetailViewController
@synthesize mUser;

-(void)viewDidLoad{
    
    appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //make photo view round
        CGFloat radius = _ivPhoto.frame.size.width/2.0;
        _ivPhoto.layer.cornerRadius = radius;
        _ivPhoto.layer.masksToBounds = YES;
        _ivPhoto.contentMode = UIViewContentModeScaleAspectFill;
        
    });
    
    [self showUser:mUser];
    
    nPhoneNumberSelected = 0;
    
    UITapGestureRecognizer* myLabelPhoneNumber1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(LabelPhoneNumber1Clicked:)];
    [_lblPhoneNumber1 setUserInteractionEnabled:YES];
    [_lblPhoneNumber1 addGestureRecognizer:myLabelPhoneNumber1];
    
    UITapGestureRecognizer* myLabelPhoneNumber2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(LabelPhoneNumber2Clicked:)];
    [_lblPhoneNumber2 setUserInteractionEnabled:YES];
    [_lblPhoneNumber2 addGestureRecognizer:myLabelPhoneNumber2];
}

-(void)LabelPhoneNumber1Clicked:(UIGestureRecognizer*) gestureRecognizer
{
    if(nPhoneNumberSelected == 1) {
        nPhoneNumberSelected = 0;
        _lblPhoneNumber1.backgroundColor = [UIColor clearColor];
    } else {
        nPhoneNumberSelected = 1;
        _lblPhoneNumber1.backgroundColor = [UIColor lightGrayColor];
        _lblPhoneNumber2.backgroundColor = [UIColor clearColor];
    }
}

-(void)LabelPhoneNumber2Clicked:(UIGestureRecognizer*) gestureRecognizer
{
    if(nPhoneNumberSelected == 2) {
        nPhoneNumberSelected = 0;
        _lblPhoneNumber2.backgroundColor = [UIColor clearColor];
    } else {
        nPhoneNumberSelected = 2;
        _lblPhoneNumber2.backgroundColor = [UIColor lightGrayColor];
        _lblPhoneNumber1.backgroundColor = [UIColor clearColor];
    }
}


-(void)showUser:(User*) user{
    if ([user.lastName isEqualToString:@""]) {
        [_lblName setText:user.firstName];
    }else{
        NSString *fullName = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
        [_lblName setText:fullName];
    }
    
    [_lblTitle setText:user.title];
//    [_lblPhoneNumber1 setText:user.mobileNumber];
//    [_lblPhoneNumber2 setText:user.homeNumber];
    [_lblEmailAddress setText:user.homeEmail];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
    [formatter setDateFormat:@"MMMM dd, yyyy"];
    NSString *strBirthday = [formatter stringFromDate:user.birthday];
    [_lblBirthday setText:strBirthday];

    if (user.photoData != nil) {
        [_ivPhoto setImage:[UIImage imageWithData:user.photoData]];
    }else{
        [_ivPhoto setImage:[UIImage imageNamed:@"profile_placeholder.png"]];
    }
    
}

- (IBAction)btnBackTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)btnPhoneCall1Tapped:(id)sender {
//    NSString *phNo = mUser.mobileNumber;
//    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",phNo]];
//    
//    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
//        [[UIApplication sharedApplication] openURL:phoneUrl];
//    } else
//    {
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops" message:@"Call facility is not available!!!" preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
//        [alertController addAction:ok];
//        [self presentViewController:alertController animated:YES completion:nil];
//        
//    }
}
- (IBAction)btnPhoneCall2Tapped:(id)sender {
//    NSString *phNo = mUser.homeNumber;
//    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",phNo]];
//    
//    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
//        [[UIApplication sharedApplication] openURL:phoneUrl];
//    } else
//    {
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops" message:@"Call facility is not available!!!" preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
//        [alertController addAction:ok];
//        [self presentViewController:alertController animated:YES completion:nil];
//        
//    }
}

- (IBAction)btnSMSTapped:(id)sender {
    isConfirmButtonTapped = NO;
    
    if(![MFMessageComposeViewController canSendText]) {
        [Engine showErrorMessage:@"Oops!" message:@"Your device doesn't support SMS!" onViewController:self];
        return;
    }
//    if ([mUser.mobileNumber isEqualToString:@""]) {
//        [Engine showErrorMessage:@"Oops!" message:@"No mobile number to SMS" onViewController:self];
//        return;
//    }
//    
//    NSArray *recipents = @[mUser.mobileNumber];
    
    
    NSString *message = @"";
    
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
//    [messageController setRecipients:recipents];
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}

-(NSDate*)dateWithString:(NSString *)dateSelected{
    
    NSDateFormatter *dateFormatterForGettingDate = [[NSDateFormatter alloc] init];
    
    [dateFormatterForGettingDate setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatterForGettingDate setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ"];
    
    
    NSDate *dateFromStr = [dateFormatterForGettingDate dateFromString:dateSelected];
    return dateFromStr;
    
}

- (IBAction)btnConfirmTapped:(id)sender {
    
//    if(nPhoneNumberSelected == 0) {
//        [Engine showErrorMessage:@"Oops!" message:@"Please choose a person with mobile number" onViewController:self];
//        return;
//    }
//    
//    isConfirmButtonTapped = YES;
//    
//    if ([mUser.mobileNumber isEqualToString:@""]) {
//        [Engine showErrorMessage:@"Oops!" message:@"Please choose a person with mobile number" onViewController:self];
//        return;
//    }
//    if(![MFMessageComposeViewController canSendText]) {
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"Your device doesn't support SMS!" preferredStyle:UIAlertControllerStyleAlert];
//            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
//                
//            }];
//            [controller addAction:ok];
//            [self presentViewController:controller animated:YES completion:nil];
//        });
//        
//        return;
//        
//    }
//    
//    UIStoryboard *storyboard;
//    switch ([Engine getUserStatus]) {
//        case USER_STAT_GIFT_SESSION:
//            
//            appDelegate.recipientPhoneNumber = mUser.mobileNumber;
//            [Engine goToViewController:@"SubmitPaymentViewController" from:self];
//            
//            break;
//            
//        case USER_STAT_MEET_NOW:
//            [self postAppointmentInvites];
//            
//            break;
//            
//        case USER_STAT_PLUS_ONE:
//            [self postAppointmentInvites];
//            
//            break;
//            
//        case USER_STAT_SCHEDULE:
//            [self postAppointmentInvites];
//            
//            break;
//            
//        case USER_STAT_GROUP_SESSION:
//            appDelegate.recipientPhoneNumber = mUser.mobileNumber;
//            appDelegate.recipientFirstName = mUser.firstName;
//            appDelegate.recipientLastName = mUser.lastName;
//            appDelegate.recipientPhotoData = mUser.photoData;
//            
//            storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//            ScheduleSessionViewController *vc = (ScheduleSessionViewController*)[storyboard instantiateViewControllerWithIdentifier:@"ScheduleSessionViewController"];
//            
//            vc.startDate = [Engine dateIn15Increments:[NSDate date]];
//            [self.navigationController pushViewController: vc animated:YES ];
//            break;
//            
////        default:
////            break;
//    }
}

-(void)postAppointmentInvites{
    
//    appDelegate.currentAppointment.plusOnePhotoData = mUser.photoData;
//    //save appointment id with photoData
//    [Engine savePhotoWithId:appDelegate.currentAppointment.iid PhotoData:mUser.photoData];
//    
//    NSInteger appointmentId = appDelegate.currentAppointment.iid;
//    NSInteger userId = [appDelegate.profile.userId integerValue];
//    if (appDelegate.currentAppointment != nil) {
//        
//        [Engine showHUDonView:self.view];
//        [[NetworkClient sharedInstance]postAppointmentInvitesWithappointmentId:appointmentId userId:userId firstName:mUser.firstName lastName:mUser.lastName recipentPhone:mUser.mobileNumber success:^(NSDictionary *dic) {
//            [Engine hideHUDonView:self.view];
//            NSString *inviteCode = [dic objectForKey:@"invite_code"];
//            if (inviteCode) {
//                [self sendSMSWithInviteCode:inviteCode];
//            }else{
//                [Engine showErrorMessage:@"Oops!" message:@"Couldn't get invite code" onViewController:self];
//            }
//            
//        } failure:^(NSString *message) {
//            [Engine hideHUDonView:self.view];
//            [Engine showErrorMessage:@"Oops!" message:message onViewController:self];
//        }];
//    }else{
//        [Engine showErrorMessage:@"Oops!" message:@"No selected appointment" onViewController:self];
//    }
    
}
-(void)sendSMSWithInviteCode:(NSString*)inviteCode{
 /*   if(![MFMessageComposeViewController canSendText]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"Your device doesn't support SMS!" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                UIStoryboard *storyboard;
                ConfirmationViewController *confirmationVC;
                VideoCallViewController *videoCallVC;
                
                switch ([Engine getUserStatus]) {
                        
                    case USER_STAT_MEET_NOW:
                        
                        storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                        videoCallVC = (VideoCallViewController*)[storyboard instantiateViewControllerWithIdentifier:@"VideoCallViewController"];
                        videoCallVC.isPlusOne = YES;
                        [self.navigationController pushViewController: videoCallVC animated:YES ];
                        
                        break;
                        
                    case USER_STAT_SCHEDULE:
                        
                        storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                        confirmationVC = (ConfirmationViewController*)[storyboard instantiateViewControllerWithIdentifier:@"ConfirmationViewController"];
                        confirmationVC.isPlusOne = NO;
                        [self.navigationController pushViewController: confirmationVC animated:YES ];
                        
                        break;
                        
                    case USER_STAT_PLUS_ONE:
                        
                        storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                        confirmationVC = (ConfirmationViewController*)[storyboard instantiateViewControllerWithIdentifier:@"ConfirmationViewController"];
                        confirmationVC.isPlusOne = NO;
                        [self.navigationController pushViewController: confirmationVC animated:YES ];
                        
                        break;
                        //        default:
                        //            break;
                }
            }];
            [controller addAction:ok];
            [self presentViewController:controller animated:YES completion:nil];
        });
        
        return;
        
    }
  */
//    if ([mUser.mobileNumber isEqualToString:@""]) {
//        [Engine showErrorMessage:@"Oops!" message:@"No mobile number to SMS" onViewController:self];
//        return;
//    }
//    
//    NSArray *recipents = @[mUser.mobileNumber];
//    
//    
//    NSString *message;
//    if (appDelegate.joinMode == MODE_JOIN_NOW) {
//        message = MSG_JOIN_NOW;
//        message = [message stringByReplacingOccurrencesOfString:@"sessionId" withString:inviteCode];
//    }else if(appDelegate.joinMode == MODE_JOIN_FUTURE){
//        message = MSG_JOIN_FUTURE;
//        
//        NSDate *sessionDate = [self dateWithString: appDelegate.currentAppointment.scheduledTime];
//        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
//        [formatter setDateFormat:@"MMMM dd, yyyy"];
//        NSString *strDate = [formatter stringFromDate:sessionDate];
//        [formatter setDateFormat:@"HH:mm a"];
//        NSString *strTime = [formatter stringFromDate:sessionDate];
//        
//        
//        message = [message stringByReplacingOccurrencesOfString:@"sessionDate" withString:strDate];
//        message = [message stringByReplacingOccurrencesOfString:@"sessionTime" withString:strTime];
//        message = [message stringByReplacingOccurrencesOfString:@"sessionId" withString:inviteCode];
//        NSLog(@"MFMessageComposeVC/message: %@", message);
//    }else{
//        return;
//    }
//    
//    
//    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
//    messageController.messageComposeDelegate = self;
//    [messageController setRecipients:recipents];
//    [messageController setBody:message];
//    
//    // Present message view controller on screen
//    [self presentViewController:messageController animated:YES completion:nil];
}
#pragma mark - MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    [self dismissViewControllerAnimated:controller completion:nil];
    
    if (isConfirmButtonTapped) {
        UIStoryboard *storyboard;
        ConfirmationViewController *confirmationVC;
        VideoCallViewController *videoCallVC;
        
        switch ([Engine getUserStatus]) {
                
            case USER_STAT_MEET_NOW:
                
                storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                videoCallVC = (VideoCallViewController*)[storyboard instantiateViewControllerWithIdentifier:@"VideoCallViewController"];
                videoCallVC.isPlusOne = YES;
                [self.navigationController pushViewController: videoCallVC animated:YES ];
                
                break;
                
            case USER_STAT_SCHEDULE:
                
                storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                confirmationVC = (ConfirmationViewController*)[storyboard instantiateViewControllerWithIdentifier:@"ConfirmationViewController"];
                confirmationVC.isPlusOne = YES;
                [self.navigationController pushViewController: confirmationVC animated:YES ];
                
                appDelegate.currentAppointment.isPlueOne = YES;
                break;
                //        default:
                //            break;
        }
    }
}

@end
