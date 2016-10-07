//
//  ContactDetailNewViewController.m
//  thePlusOne
//
//  Created by Jane on 9/14/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import "ContactDetailNewViewController.h"
#import "ConfirmationViewController.h"
#import "VideoCallViewController.h"
#import "ScheduleSessionViewController.h"


@interface ContactDetailNewViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tblDetail;
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic) BOOL isConfirmButtonTapped;
@property (nonatomic) NSInteger nPhoneNumberSelected;
@end

@implementation ContactDetailNewViewController
@synthesize mUser;

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onConfirm:(id)sender {
    NSArray * allKeys = [mUser.dicPhoneNumber allKeys];
    
    if([allKeys count] == 0) {
        [Engine showErrorMessage:@"Oops!" message:@"Please choose a person with mobile number" onViewController:self];
        return;
    }
    
    if(self.nPhoneNumberSelected == -1) {
        [Engine showErrorMessage:@"Oops!" message:@"Please choose a person with mobile number" onViewController:self];
        return;
    }
    
    self.isConfirmButtonTapped = YES;
    
    NSString *strKey = [allKeys objectAtIndex:_nPhoneNumberSelected];
    NSString *strNumber = [mUser.dicPhoneNumber objectForKey:strKey];
    
    if(![MFMessageComposeViewController canSendText]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"Your device doesn't support SMS!" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                
            }];
            [controller addAction:ok];
            [self presentViewController:controller animated:YES completion:nil];
        });
        
        return;
        
    }
    
    UIStoryboard *storyboard;
    switch ([Engine getUserStatus]) {
        case USER_STAT_GIFT_SESSION:
            
            self.appDelegate.recipientPhoneNumber = strNumber;
            [Engine goToViewController:@"SubmitPaymentViewController" from:self];
            
            break;
            
        case USER_STAT_MEET_NOW:
            [self postAppointmentInvites:strNumber];
            
            break;
            
        case USER_STAT_PLUS_ONE:
            [self postAppointmentInvites:strNumber];
            
            break;
            
        case USER_STAT_SCHEDULE:
            [self postAppointmentInvites:strNumber];
            
            break;
            
        case USER_STAT_GROUP_SESSION:
            self.appDelegate.recipientPhoneNumber = strNumber;
            self.appDelegate.recipientFirstName = mUser.firstName;
            self.appDelegate.recipientLastName = mUser.lastName;
            self.appDelegate.recipientPhotoData = mUser.photoData;
            
            storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ScheduleSessionViewController *vc = (ScheduleSessionViewController*)[storyboard instantiateViewControllerWithIdentifier:@"ScheduleSessionViewController"];
            
            vc.startDate = [Engine dateIn15Increments:[NSDate date]];
            [self.navigationController pushViewController: vc animated:YES ];
            break;
            
            //        default:
            //            break;
    }
}

-(void)postAppointmentInvites:(NSString *)strNumber{
    
    self.appDelegate.currentAppointment.plusOnePhotoData = mUser.photoData;
    //save appointment id with photoData
    [Engine savePhotoWithId:self.appDelegate.currentAppointment.iid PhotoData:mUser.photoData];
    
    NSInteger appointmentId = self.appDelegate.currentAppointment.iid;
    NSInteger userId = [self.appDelegate.profile.userId integerValue];
    if (self.appDelegate.currentAppointment != nil) {
        
        [Engine showHUDonView:self.view];
        [[NetworkClient sharedInstance]postAppointmentInvitesWithappointmentId:appointmentId userId:userId firstName:mUser.firstName lastName:mUser.lastName recipentPhone:strNumber success:^(NSDictionary *dic) {
            [Engine hideHUDonView:self.view];
            NSString *inviteCode = [dic objectForKey:@"invite_code"];
            if (inviteCode) {
                [self sendSMSWithInviteCode:inviteCode phoneNumber:strNumber];
            }else{
                [Engine showErrorMessage:@"Oops!" message:@"Couldn't get invite code" onViewController:self];
            }
            
        } failure:^(NSString *message) {
            [Engine hideHUDonView:self.view];
            [Engine showErrorMessage:@"Oops!" message:message onViewController:self];
        }];
    }else{
        [Engine showErrorMessage:@"Oops!" message:@"No selected appointment" onViewController:self];
    }
}

-(void)sendSMSWithInviteCode:(NSString*)inviteCode phoneNumber:(NSString *)strNumber{
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
    if ([strNumber isEqualToString:@""]) {
        [Engine showErrorMessage:@"Oops!" message:@"No mobile number to SMS" onViewController:self];
        return;
    }
    
    NSArray *recipents = @[strNumber];
    
    NSString *message;
    if (self.appDelegate.joinMode == MODE_JOIN_NOW) {
        message = MSG_JOIN_NOW;
        message = [message stringByReplacingOccurrencesOfString:@"sessionId" withString:inviteCode];
    }else if(self.appDelegate.joinMode == MODE_JOIN_FUTURE){
        message = MSG_JOIN_FUTURE;
        
        NSDate *sessionDate = [self dateWithString: self.appDelegate.currentAppointment.scheduledTime];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"MMMM dd, yyyy"];
        [formatter setTimeZone:[NSTimeZone localTimeZone]];
        NSString *strDate = [formatter stringFromDate:sessionDate];
        [formatter setDateFormat:@"HH:mm a"];
        [formatter setTimeZone:[NSTimeZone localTimeZone]];
        NSString *strTime = [formatter stringFromDate:sessionDate];
        
        
        message = [message stringByReplacingOccurrencesOfString:@"sessionDate" withString:strDate];
        message = [message stringByReplacingOccurrencesOfString:@"sessionTime" withString:strTime];
        message = [message stringByReplacingOccurrencesOfString:@"sessionId" withString:inviteCode];
        NSLog(@"MFMessageComposeVC/message: %@", message);
    }else{
        return;
    }
    
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
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


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tblDetail.dataSource = self;
    self.tblDetail.delegate = self;
    
    self.appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.isConfirmButtonTapped = NO;
    self.nPhoneNumberSelected = -1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)btnMsgSelected:(id)sender
{
    NSInteger nIdx = [[(UIButton *)sender accessibilityHint] integerValue];
    
    NSArray * allKeys = [mUser.dicPhoneNumber allKeys];
    NSString *strKey = [allKeys objectAtIndex:nIdx];
    NSString *strNumber = [mUser.dicPhoneNumber objectForKey:strKey];
    
    
    self.isConfirmButtonTapped = NO;
    
    if(![MFMessageComposeViewController canSendText]) {
        [Engine showErrorMessage:@"Oops!" message:@"Your device doesn't support SMS!" onViewController:self];
        return;
    }
    if ([strNumber isEqualToString:@""]) {
        [Engine showErrorMessage:@"Oops!" message:@"No mobile number to SMS" onViewController:self];
        return;
    }
    
    NSArray *recipents = @[strNumber];
    NSString *message = @"";
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
    
}

-(void)btnCallSelected:(id)sender
{
    NSInteger nIdx = [[(UIButton *)sender accessibilityHint] integerValue];
    
    NSArray * allKeys = [mUser.dicPhoneNumber allKeys];
    NSString *strKey = [allKeys objectAtIndex:nIdx];
    NSString *strNumber = [mUser.dicPhoneNumber objectForKey:strKey];
    
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",strNumber]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    } else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops" message:@"Call facility is not available!!!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSArray * allKeys = [mUser.dicPhoneNumber allKeys];
    return 4 + [allKeys count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray * allKeys = [mUser.dicPhoneNumber allKeys];
    NSInteger nPhoneNumbers = [allKeys count];
    
    UITableViewCell *cell;
    
    if(indexPath.row == 0) {
        NSString *CellIdentifier = @"PhotoView";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell==nil) {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
        }
        
        UILabel *lblName = (UILabel *)[cell.contentView viewWithTag:1];
        UILabel *lblTitle = (UILabel *)[cell.contentView viewWithTag:2];
        UIImageView *imgvPhoto = (UIImageView *)[cell.contentView viewWithTag:3];
        
        if ([mUser.lastName isEqualToString:@""]) {
            [lblName setText:mUser.firstName];
        }else{
            NSString *fullName = [NSString stringWithFormat:@"%@ %@", mUser.firstName, mUser.lastName];
            [lblName setText:fullName];
        }
        
        [lblTitle setText:mUser.title];
        
        CGFloat radius = imgvPhoto.frame.size.width/2.0;
        imgvPhoto.layer.cornerRadius = radius;
        imgvPhoto.layer.masksToBounds = YES;
        imgvPhoto.contentMode = UIViewContentModeScaleAspectFill;
        
        if (mUser.photoData != nil) {
            [imgvPhoto setImage:[UIImage imageWithData:mUser.photoData]];
        }else{
            [imgvPhoto setImage:[UIImage imageNamed:@"profile_placeholder.png"]];
        }

        
    } else if(indexPath.row ==  nPhoneNumbers + 1) {
        NSString *CellIdentifier = @"EmailView";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell==nil) {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
        }
        
        UILabel *lblEmail = (UILabel *)[cell.contentView viewWithTag:1];
        [lblEmail setText:mUser.homeEmail];
        
    } else if(indexPath.row == nPhoneNumbers + 2) {
        NSString *CellIdentifier = @"BirthView";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell==nil) {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
        }
        
        UILabel *lblBirth = (UILabel *)[cell.contentView viewWithTag:1];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setTimeZone:[NSTimeZone localTimeZone]];
        [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
        [formatter setDateFormat:@"MMMM dd, yyyy"];
        NSString *strBirthday = [formatter stringFromDate:mUser.birthday];
        [lblBirth setText:strBirthday];
        
    } else if(indexPath.row == nPhoneNumbers + 3) {
        NSString *CellIdentifier = @"NoteView";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell==nil) {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
        }
    } else {
        NSString *CellIdentifier = @"MobileView";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell==nil) {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
        }
        
        UILabel *lblLabel = (UILabel *)[cell.contentView viewWithTag:4];
        UILabel *lblNumber = (UILabel *)[cell.contentView viewWithTag:1];
        UIButton *btnMsg = (UIButton *)[cell.contentView viewWithTag:3];
        UIButton *btnCall = (UIButton *)[cell.contentView viewWithTag:2];
        
        btnMsg.accessibilityHint = [NSString stringWithFormat:@"%ld", indexPath.row - 1];
        btnCall.accessibilityHint = [NSString stringWithFormat:@"%ld", indexPath.row - 1];
        
        NSString *strLabel = [allKeys objectAtIndex:indexPath.row - 1];
        NSString *strNumber = [mUser.dicPhoneNumber objectForKey:strLabel];
        
        [lblLabel setText:strLabel];
        [lblNumber setText:strNumber];
        
        [btnMsg addTarget:self action:@selector(btnMsgSelected:) forControlEvents:UIControlEventTouchUpInside];
        [btnCall addTarget:self action:@selector(btnCallSelected:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray * allKeys = [mUser.dicPhoneNumber allKeys];
    NSInteger nPhoneNumbers = [allKeys count];
    
    if(indexPath.row == 0) return 110;
    if(indexPath.row == nPhoneNumbers + 1 || indexPath.row == nPhoneNumbers + 2) return 67;
    if(indexPath.row == nPhoneNumbers + 3) return 210;
    
    return 83;
}

#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray * allKeys = [mUser.dicPhoneNumber allKeys];
    NSInteger nPhoneNumbers = [allKeys count];
    
    if(indexPath.row > 0 && indexPath.row < nPhoneNumbers + 1) {
        
        
        if(self.nPhoneNumberSelected > -1) {
            NSIndexPath *prevIndexPath = [NSIndexPath indexPathForRow:self.nPhoneNumberSelected + 1 inSection:0];
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:prevIndexPath];
            
            [cell.contentView setBackgroundColor:[UIColor clearColor]];
        }
        
        self.nPhoneNumberSelected = indexPath.row - 1;
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        [cell.contentView setBackgroundColor:[UIColor lightGrayColor]];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

#pragma mark - MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    [self dismissViewControllerAnimated:controller completion:nil];
    
    if (self.isConfirmButtonTapped) {
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
                
                self.appDelegate.currentAppointment.isPlueOne = YES;
                break;
                //        default:
                //            break;
        }
    }
}


@end
