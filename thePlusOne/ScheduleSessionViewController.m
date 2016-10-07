//
//  ScheduleSessionViewController.m
//  thePlusOne
//
//  Created by My Star on 6/22/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import "ScheduleSessionViewController.h"
#import "Provider.h"
#import "Appointment.h"
#import "SetTimeViewController.h"
#import "SetTime2ViewController.h"
#import "SubmitPaymentViewController.h"
#import "ConfirmationViewController.h"
#import <MessageUI/MessageUI.h>
#import "SetTimeCustomCell.h"

@interface ScheduleSessionViewController()<MFMessageComposeViewControllerDelegate>{
    Provider *provider;
    UIView *topView;
    AppDelegate *appDelegate;
    
    NSMutableArray *arrAvailability;
    NSMutableArray *arrSlices;
    NSDate *dateSelected;
}
@end

@implementation ScheduleSessionViewController
@synthesize startDate;

-(void)viewDidLoad{
    appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    
    
}
-(void)initSlicesWithDate:(NSDate *)date{
    arrSlices = [[NSMutableArray alloc]init];
    
    
    Provider *tempProvider = [appDelegate.arrProviders objectAtIndex:appDelegate.selectedProviderIndex];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"EEEE"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSString *day = [formatter stringFromDate:date];
    //    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    
    arrSlices = [tempProvider.openSessionTimes objectForKey:day];
    
    [self initAvailabilty:date];
}
-(void)initAvailabilty:(NSDate*) date{
    arrAvailability = [[NSMutableArray alloc]init];
    
//    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
//    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    NSCalendar *gregorianCal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorianCal setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]]; //GMT timezone because all time values are specified with GMT timezone now.
//    [gregorianCal setTimeZone:[NSTimeZone timeZoneWithName:@"America/New_York"]]; //Eastern timezone because all time values are specified with ET timezone now.
    
    //get start time string
    for(NSNumber *number in arrSlices){
        
        NSDateComponents *dateComps = [gregorianCal components: (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |NSCalendarUnitHour | NSCalendarUnitMinute)                                                          fromDate: date];
        dateComps.hour = [number intValue]/60;
        dateComps.minute = [number intValue] % 60;
        
        NSDate *dateToAdd =[gregorianCal dateFromComponents:dateComps];
        
        [arrAvailability addObject:dateToAdd];
        
    }
    
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)viewWillAppear:(BOOL)animated{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setStatusBarHidden:YES]; 
        [self initView];
        [self.view layoutIfNeeded];
    });
    
    [self initSlicesWithDate:self.startDate];
    dateSelected = self.startDate;
}

-(void)initView{
    //set topView
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    topView = window.rootViewController.view;
    
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    provider = [delegate.arrProviders objectAtIndex: delegate.selectedProviderIndex];
    
    
    NSString *temp = [provider.firstName stringByAppendingString:@" "];
    temp = [temp stringByAppendingString:provider.lastName];
    [_lblName setText:temp];
    
    [_lblTitle setText:provider.title];
    
    [_lblSpecialties setText:provider.specialties];
    
    [_ivPhoto setImage:[UIImage imageWithData:provider.pictureData]];
    
    //make photo view round
    CGFloat radius = _ivPhoto.frame.size.width/2.0;
    _ivPhoto.layer.cornerRadius = radius;
    _ivPhoto.layer.masksToBounds = YES;
    _ivPhoto.contentMode = UIViewContentModeScaleAspectFill;
    
    //date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"MMMM dd, yyyy"];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:locale];
    _lblDate.text = [dateFormatter stringFromDate:startDate];
    
    //start time
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat: @"hh:mm a"];
    [timeFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setLocale:locale];
    
    NSString *startTime = [timeFormatter stringFromDate:startDate];
//    NSString *zone = [[NSTimeZone timeZoneWithName:@"GMT"] abbreviation];
//    temp = [NSString stringWithFormat:@"%@ (%@)", startTime, zone];
//    _lblStartTime.text = temp;
    _lblStartTime.text = startTime;
    
}
-(BOOL)isProviderAvailableWithDate:(NSDate*) date{
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"EEEE"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]]; //GMT timezone because all time values are specified with GMT timezone now.
//    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"America/New_York"]]; //Eastern timezone because all time values are specified with ET timezone now.
    NSString *day = [formatter stringFromDate:date];
      
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
            
            // check if the provider is available now
            long curMinutes = gmtHour*60 + [dateComps minute];
            if (curMinutes >= startMinutes && curMinutes <= endMinutes) {
                return YES;
            };
        }
    }
    return NO;
}
- (IBAction)btnScheduleAppointmentTapped:(id)sender {
    
    if (![self isProviderAvailableWithDate:startDate] ) {
        [Engine showErrorMessage:@"Oops!" message:@"The provider is unavailable at that time" onViewController:self];
        return;
    }
    NSLog(@"current date: %@", [NSDate date]);
    if ([startDate compare:[NSDate date]] == NSOrderedAscending) {
        [Engine showErrorMessage:@"Oops!" message:@"Please choose valid Date and Time" onViewController:self];
        return;
    }
    if ([Engine isLoggedIn]) {
        if (appDelegate.profile.sessionsPurchased > appDelegate.profile.sessionsAvailable + appDelegate.profile.sessionsCompleted) {
            //*********** post an appointment *********************
            //prepare params
            NSNumber *userId = appDelegate.profile.userId;
            NSNumber *providerId = appDelegate.selectedProviderId;
            
            NSDateFormatter *dateFormatter=[NSDateFormatter new];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]]; //GMT timezone because all time values are specified with GMT timezone now.
//            [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"America/New_York"]]; //Eastern timezone because all time values are specified with ET timezone now.
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
            NSString *strDate=[dateFormatter stringFromDate:startDate];
            NSLog(@"scheduled time is %@", strDate);
            
            //create an appointment
            [Engine showHUDonView:self.view];
            [[NetworkClient sharedInstance]postAppointmentWithUserId:userId providerId:providerId scheduledFor:strDate success:^(NSDictionary *dicResponse) {
                
                // save the appointment
                Appointment *appointment = [[Appointment alloc]initWithDic:dicResponse];
                appointment.providerId = [appDelegate.selectedProviderId integerValue];
                NSLog(@"appointment : %@", appointment);
                
                [appDelegate.arrAppointments addObject:appointment];
                
                appDelegate.currentAppointment = appointment;
                appDelegate.profile.sessionsAvailable++;
                //**************************************************
                
                                
                [Engine hideHUDonView:self.view];
                appDelegate.startDate = startDate;
                if ([Engine getUserStatus] == USER_STAT_GROUP_SESSION) {
                    //send email to selected contact
                    [self postAppointmentInvites];
                }else{ //USER_STAT_SCHEDULE
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                        ConfirmationViewController *vc = (ConfirmationViewController*)[storyboard instantiateViewControllerWithIdentifier:@"ConfirmationViewController"];
                        vc.isPlusOne = NO;
                        [self.navigationController pushViewController: vc animated:YES ];
                    });
                    
                }
                
                
            } failure:^(NSString *message) {
                [Engine hideHUDonView:self.view];
                [Engine showErrorMessage:@"Oops!" message:message onViewController:self];
                
                NSInteger idx = 0;
                for(idx = 0; idx < [arrAvailability count]; idx ++){
                    NSDate *dateTmp = [arrAvailability objectAtIndex:idx];
                    if([dateTmp isEqualToDate:startDate]) break;
                }
                
                if(idx < [arrAvailability count]) {
                    [arrAvailability removeObjectAtIndex:idx];
                    [_collectionView reloadData];
                }
            }];
            
        }else{ // need payment
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            SubmitPaymentViewController *vc = (SubmitPaymentViewController*)[storyboard instantiateViewControllerWithIdentifier:@"SubmitPaymentViewController"];
            appDelegate.startDate = startDate;
            
            [self.navigationController pushViewController: vc animated:YES ];
        }
        
    }else{ //not logged in
        
        appDelegate.startDate = startDate;
        
        [Engine goToViewController:@"SignupViewController" from:self];
    }
    
}
- (IBAction)btnDateTapped:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SetTimeViewController *vc = (SetTimeViewController*)[storyboard instantiateViewControllerWithIdentifier:@"SetTimeViewController"];
    
    vc.setMode = SET_DATE;
    vc.startDate = startDate;
    vc.delegate = self;

    [self.navigationController pushViewController: vc animated:YES ];
}
- (IBAction)btnStartTimeTapped:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SetTime2ViewController *vc = (SetTime2ViewController*)[storyboard instantiateViewControllerWithIdentifier:@"SetTime2ViewController"];
    
    vc.startDate = startDate;
    vc.delegate = self;
    [self.navigationController pushViewController: vc animated:YES ];
}

- (IBAction)btnMenuTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - SetTimeDelegate
-(void)delegateSetStartDate:(NSDate *)start{
    self.startDate = start;
    [self initSlicesWithDate:self.startDate];
    [self.collectionView reloadData];
}

#pragma mark - send Email to selected contact
-(void)postAppointmentInvites{
    
    appDelegate.currentAppointment.plusOnePhotoData = appDelegate.recipientPhotoData;
    //save appointment id with photoData
    [Engine savePhotoWithId:appDelegate.currentAppointment.iid PhotoData:appDelegate.recipientPhotoData];
    
    NSInteger appointmentId = appDelegate.currentAppointment.iid;
    NSInteger userId = [appDelegate.profile.userId integerValue];
    if (appDelegate.currentAppointment != nil) {
        
        [Engine showHUDonView:self.view];
        [[NetworkClient sharedInstance]postAppointmentInvitesWithappointmentId:appointmentId userId:userId firstName:appDelegate.recipientFirstName lastName:appDelegate.recipientLastName recipentPhone:appDelegate.recipientPhoneNumber success:^(NSDictionary *dic) {
            [Engine hideHUDonView:self.view];
            NSString *inviteCode = [dic objectForKey:@"invite_code"];
            if (inviteCode) {
                [self sendSMSWithInviteCode:inviteCode];
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
-(void)sendSMSWithInviteCode:(NSString*)inviteCode{
    if(![MFMessageComposeViewController canSendText]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"Your device doesn't support SMS!" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                ConfirmationViewController *vc = (ConfirmationViewController*)[storyboard instantiateViewControllerWithIdentifier:@"ConfirmationViewController"];
                vc.isPlusOne = NO;
                [self.navigationController pushViewController: vc animated:YES ];
                
            }];
            [controller addAction:ok];
            [self presentViewController:controller animated:YES completion:nil];
        });
        return;
    }
    if ([appDelegate.recipientPhoneNumber isEqualToString:@""]) {
        [Engine showErrorMessage:@"Oops!" message:@"No mobile number to SMS" onViewController:self];
        return;
    }
    
    NSArray *recipents = @[appDelegate.recipientPhoneNumber];
    
    
    NSString *message;
    if (appDelegate.joinMode == MODE_JOIN_NOW) {
        message = MSG_JOIN_NOW;
        message = [message stringByReplacingOccurrencesOfString:@"sessionId" withString:inviteCode];
    }else if(appDelegate.joinMode == MODE_JOIN_FUTURE){
        message = MSG_JOIN_FUTURE;
        
        NSDate *sessionDate = [Engine dateWithString: appDelegate.currentAppointment.scheduledTime];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setTimeZone:[NSTimeZone localTimeZone]];
        [formatter setDateFormat:@"MMMM dd, yyyy"];
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

#pragma mark - MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    [self dismissViewControllerAnimated:controller completion:nil];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ConfirmationViewController *vc = (ConfirmationViewController*)[storyboard instantiateViewControllerWithIdentifier:@"ConfirmationViewController"];
    vc.isPlusOne = YES;
    [self.navigationController pushViewController: vc animated:YES ];
}

#pragma mark - UICollectionViewDataSource and UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [arrAvailability count];
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SetTimeCustomCell *cell = (SetTimeCustomCell*)[_collectionView dequeueReusableCellWithReuseIdentifier:@"SetTimeCustomCell" forIndexPath:indexPath];
    NSDate *date = [arrAvailability objectAtIndex:indexPath.row];
    
    //get hh:mm a string from date
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    NSCalendar *gregorianCal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorianCal setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDateComponents *dateComps = [gregorianCal components: (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |NSCalendarUnitHour | NSCalendarUnitMinute)                                                          fromDate: date];
    
    [formatter setDateFormat:@"hh:mm a"];
    
    NSString *strStartTime = [formatter stringFromDate:[gregorianCal dateFromComponents:dateComps]];
    ///
    
    cell.lblTime.text = strStartTime;
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    //    NSString *searchTerm = self.searches[indexPath.section]; FlickrPhoto *photo =
    //    self.searchResults[searchTerm][indexPath.row];
    //    // 2
    //    CGSize retval = photo.thumbnail.size.width > 0 ? photo.thumbnail.size : CGSizeMake(100, 100);
    return CGSizeMake(_collectionView.frame.size.width / 3-8, _collectionView.frame.size.width / 6);
}
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(2, 2, 2, 2);
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    dateSelected = [arrAvailability objectAtIndex:indexPath.row];
    
    startDate = dateSelected;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat: @"MMMM dd, yyyy"];
    
    
    //start time
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat: @"hh:mm a"];
    [timeFormatter setTimeZone:[NSTimeZone localTimeZone]];
    
    
    NSString *startTime = [timeFormatter stringFromDate:startDate];
    NSString *zone = [[NSTimeZone localTimeZone] abbreviation];
    NSString *temp = [NSString stringWithFormat:@"%@ (%@)", startTime, zone];
    _lblStartTime.text = temp;
}

@end
