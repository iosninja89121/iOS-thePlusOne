//
//  HomeViewController.m
//  thePlusOne
//
//  Created by My Star on 6/21/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import "HomeViewController.h"
#import "SWRevealViewController.h"
#import "Engine.h"
#import "CustomCell.h"
#import "Appointment.h"
#import "Provider.h"
#import "VideoCallViewController.h"
# import "PNChart.h"
#import <MessageUI/MessageUI.h>
@import AddressBook;

@interface HomeViewController()<FSCalendarDelegate, FSCalendarDataSource, MFMessageComposeViewControllerDelegate>{
    AppDelegate *appDelegate;
    NSDate *selectedCalendarDate;
}


@end

@implementation HomeViewController
@synthesize viewHome, viewSchedule, isHome, btnMenu;

-(void)viewDidLoad{
    
    
    // show the status bar
    [Engine showStatusBar: NO];
        
    //slide-out side bar menu
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.btnMenu addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    ///
    
    appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    [self initView];
}
-(void)initView{
    _calendar.delegate = self;
    _calendar.dataSource = self;
    
    _calendar.scope = FSCalendarScopeWeek;    
    _calendar.appearance.headerDateFormat = @"MMM yyyy";
    
    selectedCalendarDate = _calendar.today;

//    UIFont *font = [UIFont fontWithName:@"Arial" size:10.0f];
//    _calendar.appearance.headerTitleFont = font;
//    _calendar.headerHeight = 0.0f;
//    _calendar.weekdayHeight = 50.0f;
    
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"dd MMMM yyyy"];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    _lblToday.text = [formatter stringFromDate:[NSDate date]];
    
    
    //home view
//    _lblSessionsPurchased.text = [NSString stringWithFormat:@"%ld", appDelegate.profile.sessionsPurchased];
//    _lblSessionsRemaining.text = [NSString stringWithFormat:@"%ld", appDelegate.profile.sessionsAvailable];
//    
//    [self drawPieChart];
    
}
-(void)drawPieChart{
    NSInteger sessionsCompleted = appDelegate.profile.sessionsCompleted;
    NSInteger sessionsAvailable = appDelegate.profile.sessionsAvailable;
    
    //for test
    //    sessionsCompleted = 5;
    //    sessionsAvailable = 15;
    
    //For Pie Chart
    UIColor *colorAvailable = [UIColor colorWithRed:(36/255.0f) green:171/255.0f blue:169/255.0f alpha:1.0f];
    UIColor *colorCompleted = [UIColor colorWithRed:(226/255.0f) green:225/255.0f blue:225/255.0f alpha:1.0f];
    NSArray *items = @[[PNPieChartDataItem dataItemWithValue:sessionsCompleted color:colorCompleted],
                       [PNPieChartDataItem dataItemWithValue:sessionsAvailable color:colorAvailable ]
                       ];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect rect = CGRectMake(0, 0, _viewPieChart.frame.size.width, _viewPieChart.frame.size.height);
        PNPieChart *pieChart = [[PNPieChart alloc] initWithFrame:rect items:items];
        
        pieChart.showAbsoluteValues = NO;
        pieChart.hideValues = YES;
        [pieChart strokeChart];
        
        [_viewPieChart addSubview:pieChart];
        
    });
}
-(void)viewWillAppear:(BOOL)animated{
    //show home or schedule view
    
//    if (isHome) {
//        _segHomeOrSchedule.selectedSegmentIndex = 0;
//        [self.viewHome setHidden:NO];
//        [self.viewSchedule setHidden:YES];
//        
//        [self drawPieChart];
//        
//    }else{
//        _segHomeOrSchedule.selectedSegmentIndex = 1;
//        [self.viewHome setHidden:YES];
//        [self.viewSchedule setHidden:NO];
//    }
    ///
    
    
   
}
- (IBAction)segmentSwitch:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    
    if (selectedSegment == 0) {
        //toggle the correct view to be visible
        [self.viewHome setHidden:NO];
        [self.viewSchedule setHidden:YES];
    }
    else{
        //toggle the correct view to be visible
        [self.viewHome setHidden:YES];
        [self.viewSchedule setHidden:NO];
    }
}

#pragma mark - Button actions
- (IBAction)btnNewAppointmentTapped:(id)sender {
    appDelegate.currentAppointment = nil;
    [Engine goToViewController:@"SearchProviderViewController" from:self];
}
- (IBAction)btnSupportTapped:(id)sender {
}
- (IBAction)btnGiftSessionTapped:(id)sender {
    
    [Engine setUserStatus:USER_STAT_GIFT_SESSION];
    [Engine goToViewController:@"ContactsViewController" from:self];
}


- (IBAction)btnEmergencyTapped:(id)sender {
    if(![MFMessageComposeViewController canSendText]) {
        [Engine showErrorMessage:@"Oops!" message:@"Your device doesn't support SMS!" onViewController:self];
        return;
    }
    
    NSArray *recipents = @[@"741-741"];
    
    
    NSString *message = @"";
    
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}


#pragma mark - FSCalendar

// FSCalendarDataSource
- (BOOL)calendar:(FSCalendar *)calendar hasEventForDate:(NSDate *)date{
    
    for (Appointment *appointment in appDelegate.arrAppointments) {
        //get string of session date
        NSDate *dateSession = [Engine dateWithString:appointment.scheduledTime];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setTimeZone:[NSTimeZone localTimeZone]];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSString *strSession = [formatter stringFromDate:dateSession];
        
        
        NSDateFormatter *formatterUTC = [[NSDateFormatter alloc] init];
        [formatterUTC setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [formatterUTC setDateFormat:@"yyyy-MM-dd"];
        //get string of date in calendar
        NSString *strCalendar = [formatterUTC stringFromDate:date];
        
        if ([strCalendar isEqualToString:strSession]) {
            return YES;
        }
    }
    return NO;
}
- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date{
    selectedCalendarDate = date;
    [_tableView reloadData];
    
}
- (nullable UIImage *)calendar:(FSCalendar *)calendar imageForDate:(NSDate *)date{
    return nil;
}

#pragma mark - UITableViewDataSource & Delegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80.0f;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    int nTodayAppointments = 0;
    
    for(Appointment *appointment in appDelegate.arrAppointments) {
        if([Engine isSpecificAppointment:appointment specDate:selectedCalendarDate]) nTodayAppointments ++;
    }
    
    return nTodayAppointments;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"CustomCell";
    
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //make photo view round
        CGFloat radius = cell.ivProviderPhoto.frame.size.width/2;
        cell.ivProviderPhoto.layer.cornerRadius = radius;
        cell.ivProviderPhoto.clipsToBounds = YES;
        cell.ivProviderPhoto.contentMode = UIViewContentModeScaleAspectFill;

    });
    
    
    NSInteger idxTodayAppointment = 0;
    NSInteger idx = 0;
    
    for(idx = 0 ; idx < [appDelegate.arrAppointments count]; idx ++) {
        Appointment *appointment = [appDelegate.arrAppointments objectAtIndex:idx];
        
        if([Engine isSpecificAppointment:appointment specDate:selectedCalendarDate]){
            if(idxTodayAppointment == indexPath.row) break;
            
            idxTodayAppointment ++;
        }
    }
    
    //provider photo
    Appointment *appointment = [appDelegate.arrAppointments objectAtIndex:idx];
    
    Provider *provider = [self providerWithId:appointment.providerId];
    
    cell.ivProviderPhoto.image = [UIImage imageWithData:provider.pictureData];
    
    
    //plusone photo or button
    if (appointment.isPlueOne == NO) {
        cell.ivPlusOnePhoto.hidden = YES;
        cell.btnPlusOne.hidden = NO;
        cell.btnPlusOne.tag = indexPath.row;
        [cell.btnPlusOne addTarget:self
                            action:@selector(btnPlusOneTapped:) forControlEvents:UIControlEventTouchDown];
    }else{
        cell.ivPlusOnePhoto.hidden = NO;
        cell.btnPlusOne.hidden = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //make photo view round
            CGFloat radius = cell.ivProviderPhoto.frame.size.width/2;
            cell.ivPlusOnePhoto.layer.cornerRadius = radius;
            cell.ivPlusOnePhoto.clipsToBounds = YES;
            cell.ivPlusOnePhoto.contentMode = UIViewContentModeScaleAspectFill;
            
        });
        if (appointment.plusOnePhotoData != nil) {
            cell.ivPlusOnePhoto.image = [UIImage imageWithData: appointment.plusOnePhotoData];
        }else{
            cell.ivPlusOnePhoto.image = [UIImage imageNamed:@"profile_placeholder.png"];
        }
        
    }
    
    //time
    NSDate *appointmentDate = [Engine dateWithString:appointment.scheduledTime];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setDateFormat:@"MM-dd-yyyy hh:mm a"];
    cell.lblTime.text = [formatter stringFromDate:appointmentDate];
    
    //provider name
    cell.lblProviderName.text = [NSString stringWithFormat:@"%@ %@", provider.firstName, provider.lastName];
    
    return cell;
}
-(void)btnPlusOneTapped:(UIButton*)sender{
    if ( ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied){
        [Engine showErrorMessage:@"Oops!" message:@"Please allow Access to Contacts in Settings" onViewController:self];
        return;
    }
    
    NSInteger index = sender.tag;
    Appointment *appointment = [appDelegate.arrAppointments objectAtIndex:index];
    
    appDelegate.currentAppointment = appointment;
    appDelegate.startDate = [Engine dateWithString:appointment.scheduledTime];
    [Engine setUserStatus:USER_STAT_PLUS_ONE];
    
    appDelegate.joinMode = MODE_JOIN_FUTURE;
    [Engine goToViewController:@"ContactsViewController" from:self];
    
}
-(Provider*) providerWithId:(NSInteger)providerId{
    for (Provider *provider in appDelegate.arrProviders) {
        if ([provider.identifier integerValue] == providerId) {
            return provider;
        }
    }
    return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger idxTodayAppointment = 0;
    NSInteger idx = 0;
    
    for(idx = 0 ; idx < [appDelegate.arrAppointments count]; idx ++) {
        Appointment *appointment = [appDelegate.arrAppointments objectAtIndex:idx];
        
        if([Engine isSpecificAppointment:appointment specDate:selectedCalendarDate]){
            if(idxTodayAppointment == indexPath.row) break;
            
            idxTodayAppointment ++;
        }
    }
    
    //provider photo
    Appointment *appointment = [appDelegate.arrAppointments objectAtIndex:idx];

    
    appDelegate.currentAppointment = appointment;
    [self goToVideoCall];
}
-(NSString*)stringWithDate:(NSDate*)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MM-dd-yyyy hh:mm a"];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    NSString *startTime = [formatter stringFromDate:date];
    NSString *zone = [[NSTimeZone localTimeZone] abbreviation];
    NSString *temp = [NSString stringWithFormat:@"%@ [%@]", startTime, zone];
    return temp;
}
-(void)goToVideoCall{
    
    if ([appDelegate.currentAppointment.status isEqualToString:@"completed"]) {
        return;
    }
    NSDate *dateScheduled = [Engine dateWithString: appDelegate.currentAppointment.scheduledTime];
    if ([dateScheduled compare:[NSDate date]] == NSOrderedDescending) {
        
        NSString *msg = [NSString stringWithFormat:@"The scheduled time is %@ and it is now %@", [self stringWithDate:dateScheduled], [self stringWithDate:[NSDate date]]];
        [Engine showErrorMessage:@"Oops!" message:msg onViewController:self];
        return;
    }
    
    
    [Engine showHUDonView:self.view];
    //get session params
    [[NetworkClient sharedInstance]postAppointmentStreamsWithAppointmentId:appDelegate.currentAppointment.iid success:^(NSDictionary *dic) {
        
        //get apiKey, sessionId and token
        appDelegate.currentAppointment.apiKey = [dic objectForKey:@"tokbox_api_key"];
        appDelegate.currentAppointment.sessionId = [dic objectForKey:@"tokbox_session_id"];
        appDelegate.currentAppointment.token = [dic objectForKey:@"tokbox_token"];
        
        [Engine hideHUDonView:self.view];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIStoryboard *storyboard;
            VideoCallViewController *videoCallVC;
            
            storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            videoCallVC = (VideoCallViewController*)[storyboard instantiateViewControllerWithIdentifier:@"VideoCallViewController"];
            if (appDelegate.currentAppointment.plusOnePhotoData == nil) {
                videoCallVC.isPlusOne = NO;
            }else{
                videoCallVC.isPlusOne = YES;
            }
            
            appDelegate.userStatus = USER_STAT_MEET_NOW;
            
            [self.navigationController pushViewController: videoCallVC animated:YES ];
        });
        
        
    } failure:^(NSString *message) {
        [Engine hideHUDonView:self.view];
        [Engine showErrorMessage:@"Oops!" message:@"Couldn't get tokbox session parameters" onViewController:self];
    }];
    
    
}

#pragma mark - MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    [self dismissViewControllerAnimated:controller completion:nil];
    
}

@end
