//
//  SearchProviderViewController.m
//  thePlusOne
//
//  Created by My Star on 6/21/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import "SearchProviderViewController.h"
#import "MBProgressHUD.h"
#import "NetworkClient.h"
#import "Provider.h"
#import "HCSStarRatingView.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "SWRevealViewController.h"
#import "Engine.h"
#import "VideoCallViewController.h"
#import "ScheduleSessionViewController.h"
#import "FilterProviderViewController.h"
@import AddressBook;

@interface SearchProviderViewController ()
{
    NSMutableArray *arrProviders;
    UIView *topView;
    int providerIndex;
    
    HCSStarRatingView *starRatingView;
    AppDelegate *appDelegate;
    
    BOOL providerAvailable;
}
@end

@implementation SearchProviderViewController
- (IBAction)btnFilterPressed:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FilterProviderViewController *vc = (FilterProviderViewController*)[storyboard instantiateViewControllerWithIdentifier:@"FilterProviderViewController"];
    
    [self.navigationController pushViewController: vc animated:YES ];
    
}


-(void)swipeHandlerLeft{
    [self btnNextTapped:nil];
}
-(void)swipeHandlerRight{
    [self btnPrevTapped:nil];
}

-(void)viewDidLoad{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(providerSelected) name:@"providerSelected" object:nil];
    
    [self initData];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self initView];
    });
}

-(void) providerSelected {
    arrProviders = appDelegate.arrFilteredProviders;
    [self initView];
}

-(void)initData{
    appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    //provider list
    arrProviders = [Engine getProviders];
}
-(void)initView{
    //swipe gesture recognizer
    UISwipeGestureRecognizer *gestureRecognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandlerLeft)];
    [gestureRecognizerLeft setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.view addGestureRecognizer:gestureRecognizerLeft];
    
    UISwipeGestureRecognizer *gestureRecognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandlerRight)];
    [gestureRecognizerRight setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:gestureRecognizerRight];
    ///
    
    
    //enable slide-out side bar menu if logged in
    if ([Engine isLoggedIn]) {
        //slide-out side bar menu
        SWRevealViewController *revealViewController = self.revealViewController;
        if ( revealViewController )
        {
            [_btnBack addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    ///
    
    providerIndex = 0;
    //show the 1st provider as default
    
    AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    Provider *mProvider = [arrProviders objectAtIndex:providerIndex];
    
    NSInteger idx = 0;
    for(idx = 0; idx < [delegate.arrProviders count]; idx ++) {
        Provider *tmpProvider = [delegate.arrProviders objectAtIndex:idx];
        if([tmpProvider isEqual:mProvider]) break;
    }
    
    delegate.selectedProviderIndex = idx;
    
    //show/hide views
    _viewProvider.hidden = NO;
    _lblEmpty.hidden = YES;
    
    //make photo view round
    CGFloat radius = _ivPhoto.frame.size.width/2;
    _ivPhoto.layer.cornerRadius = radius;
    _ivPhoto.clipsToBounds = YES;
    _ivPhoto.contentMode = UIViewContentModeScaleAspectFill;
    
    
    //set photo view border color white
    CGFloat borderWidth = 2.0f;
    _ivPhoto.frame = CGRectInset(_ivPhoto.frame, -borderWidth, -borderWidth);
    _ivPhoto.layer.borderColor = [UIColor whiteColor].CGColor;
    _ivPhoto.layer.borderWidth = borderWidth;
    
    //set scale mode of and darken backgound photo view
    _ivBkPhoto.contentMode = UIViewContentModeScaleAspectFill;
    _ivBkPhoto.clipsToBounds = YES;
    [_viewDarkMask setAlpha:0.8];
    
    
    //set topView
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    topView = window.rootViewController.view;
    
    
    //add star rating view
//    CGFloat y = _lblLocation.frame.origin.y + _lblLocation.frame.size.height + 2 + 44;
//    CGFloat x = self.view.frame.size.width/2 - 55;
//    starRatingView = [[HCSStarRatingView alloc] initWithFrame:CGRectMake(x, y, 110, 15)];
//    starRatingView.maximumValue = 5;
//    starRatingView.minimumValue = 0;
//    starRatingView.tintColor = [UIColor colorWithRed:1.0f green:201/255.0f blue:14/255.0f alpha:1.0f];
//    starRatingView.backgroundColor = [UIColor clearColor];
//    starRatingView.allowsHalfStars = YES;
//    starRatingView.accurateHalfStars = YES;
//    //    [starRatingView addTarget:self action:@selector(didChangeValue:) forControlEvents:UIControlEventValueChanged];
//    [self.view addSubview:starRatingView];
    
    //check and show the default provider
    [self checkEmptyLabel];
}

- (void) checkEmptyLabel
{
    if([arrProviders count] > 0)
    {
        [self showProviderAtIndex:providerIndex];
        _lblEmpty.hidden = YES;
    }
    else
    {
        _lblEmpty.hidden = NO;
        
    }
    
}

-(void)showProviderAtIndex:(int) index{
    Provider *provider = [arrProviders objectAtIndex:index];
    
    NSString *strName = [provider.firstName stringByAppendingString:@" "];
    strName = [strName stringByAppendingString:provider.lastName];
    [_lblName setText:strName];
    
    [_lblCareer setText:provider.title];
    
//    [_lblLocation setText:provider.location];
//    [_lblDepartment setText:provider.department];
    [_lblSpecialties setText:provider.specialties];
    
    [_tvBio setText:provider.bio];
    
    [_ivPhoto setImage:[UIImage imageWithData:provider.pictureData]];
    [_ivBkPhoto setImage:[UIImage imageWithData:provider.pictureData]];
    
    providerAvailable = [self isProviderAvailableWithDate:[NSDate date]];
    if (providerAvailable) {
        [_ivAvailable setImage:[UIImage imageNamed:@"available.png"]];
        [_ivMeetNow setImage:[UIImage imageNamed:@"meet_now_green.png"]];
        [_lblMeetNow setTextColor:[UIColor greenColor]];
    }else{
        [_ivAvailable setImage:[UIImage imageNamed:@"unavailable.png"]];
        [_ivMeetNow setImage:[UIImage imageNamed:@"meet_now.png"]];
        [_lblMeetNow setTextColor:[UIColor whiteColor]];
    }
    
    //add star rating view
    CGFloat rating = [provider.rating floatValue];
    starRatingView.value = rating;
}

-(BOOL)isProviderAvailableWithDate:(NSDate*)date{
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"EEEE"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSString *day = [formatter stringFromDate:date];
    NSLog(@"SearchProviderVC/isProviderAvailable/date : %@", [NSDate date]);
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    Provider *provider = [delegate.arrProviders objectAtIndex:providerIndex];
    
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
#pragma mark - button actions
- (IBAction)btnPrevTapped:(id)sender {
    if (providerIndex>0) {
        providerIndex = providerIndex-1;
        [self showProviderAtIndex:providerIndex];
        
        AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        
        Provider *mProvider = [arrProviders objectAtIndex:providerIndex];
        
        NSInteger idx = 0;
        for(idx = 0; idx < [delegate.arrProviders count]; idx ++) {
            Provider *tmpProvider = [delegate.arrProviders objectAtIndex:idx];
            if([tmpProvider isEqual:mProvider]) break;
        }
        
        delegate.selectedProviderIndex = idx;
    }
    
}
- (IBAction)btnNextTapped:(id)sender {
    if (providerIndex<[arrProviders count]-1) {
        providerIndex = providerIndex+1;
        [self showProviderAtIndex:providerIndex];
        
        AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        
        Provider *mProvider = [arrProviders objectAtIndex:providerIndex];
        
        NSInteger idx = 0;
        for(idx = 0; idx < [delegate.arrProviders count]; idx ++) {
            Provider *tmpProvider = [delegate.arrProviders objectAtIndex:idx];
            if([tmpProvider isEqual:mProvider]) break;
        }
        
        delegate.selectedProviderIndex = idx;
    }
}

- (IBAction)btnBackTapped:(id)sender {
    if (![Engine isLoggedIn]) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [Engine goToViewController:@"SWRevealViewController" from:self];
    }
    
}

- (IBAction)btnMeetNowTapped:(id)sender {
    
    if (!providerAvailable) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Sorry!" message:@"The provider is not available now." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *schedule = [UIAlertAction actionWithTitle:@"Schedule" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self btnScheduleTapped:nil];
            }];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
            [controller addAction:schedule];
            [controller addAction:cancel];
            [self presentViewController:controller animated:YES completion:nil];
        });
        return;
    }
    
    [Engine setUserStatus:USER_STAT_MEET_NOW];
    
    //save the current provider id
    [self saveProviderId];
    
    [self goNext];
}
- (IBAction)btnScheduleTapped:(id)sender {
    
    [Engine setUserStatus: USER_STAT_SCHEDULE];
    
    //save the current provider id
    [self saveProviderId];

    //pass startDate
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ScheduleSessionViewController *vc = (ScheduleSessionViewController*)[storyboard instantiateViewControllerWithIdentifier:@"ScheduleSessionViewController"];
    vc.startDate = [Engine dateIn15Increments:[NSDate date]];//[self availableStartTimeForTomorrow];
    
    
    [self.navigationController pushViewController: vc animated:YES ];
    
}
-(NSDate*)availableStartTimeForTomorrow{
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    [calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
    components.day = components.day + 1;
    NSLog(@"components.day : %ld", components.day);
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [formatter setDateFormat: @"EEEE"];
    NSString *day = [formatter stringFromDate:[calendar dateFromComponents:components]];
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    Provider *provider = [delegate.arrProviders objectAtIndex:providerIndex];
    int startMinutes = 0, endMinutes = 0;
    for (NSDictionary *dic in provider.availability) {
        NSLog(@"dic: %@", dic);
        if ([[dic objectForKey:@"dayOfWeek"] containsObject:day]) {
            startMinutes = [[dic objectForKey:@"start_minutes"]intValue];
            endMinutes = [[dic objectForKey:@"end_minutes"]intValue];
            break;
        }
    }
    if (startMinutes>0 && endMinutes>0) {
        
        // Then use it
        components.hour = startMinutes/60;
        components.minute = startMinutes % 60;
        
        
    }
    return [calendar dateFromComponents:components];
    
}
- (IBAction)btnGroupSessionTapped:(id)sender {
    if ( ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied){
        [Engine showErrorMessage:@"Oops!" message:@"Please allow Access to Contacts in Settings" onViewController:self];
        return;
    }
    
    [Engine setUserStatus: USER_STAT_GROUP_SESSION];
    
    appDelegate.joinMode = MODE_JOIN_FUTURE;
    
    //save the current provider id
    [self saveProviderId];

    [Engine goToViewController:@"ContactsViewController" from:self];
    
}
- (IBAction)btnReferPlusOneTapped:(id)sender {
    
    Provider *provider = [arrProviders objectAtIndex:providerIndex];
    NSString *fullName = [NSString stringWithFormat:@"Provider name: %@ %@", provider.firstName, provider.lastName];
    NSString *specialties = [NSString stringWithFormat:@"Specialties: %@", provider.specialties];
    NSString *bio = [NSString stringWithFormat:@"Bio: %@", provider.bio];
    NSArray *objectsToShare = @[fullName, specialties, bio];
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    [controller setValue:@"Hello" forKey:@"subject"];
    
    NSArray *excludedActivities = @[UIActivityTypePostToFacebook, UIActivityTypePostToTwitter, UIActivityTypePostToWeibo, UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
    controller.excludedActivityTypes = excludedActivities;
    
    //    if (IS_IPAD) {
    //        controller.modalPresentationStyle = UIModalPresentationPopover;
    //    }
    //    [self presentViewController:controller animated:YES completion:nil];
    //    if (IS_IPAD) {
    //        UIPopoverPresentationController * popController = [controller popoverPresentationController];
    //        popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    //        popController.sourceView = self.btnShare;
    //
    //    }
    
    [controller setCompletionWithItemsHandler:^(NSString  *activityType, BOOL completed, NSArray  *returnedItems, NSError * activityError) {
        // react to the completion
        if (completed) {
            
            // user shared an item
            NSLog(@"We used activity type%@", activityType);
            
        } else {
            
            // user cancelled
            NSLog(@"We didn't want to share anything after all.");
        }
        
        if (activityError) {
            NSLog(@"An Error occured: %@, %@", activityError.localizedDescription, activityError.localizedFailureReason);
        }
    }];
    
    // and present it
    [self presentViewController:controller animated:YES completion:^{
        // executes after the user selects something
    }];
    
}




-(void)saveProviderId{
    
    Provider *currentProvider = [arrProviders objectAtIndex:providerIndex];
    appDelegate.selectedProviderId = currentProvider.identifier;
}
-(void)goNext{
    
    if ([Engine isLoggedIn]) {
        if (appDelegate.profile.sessionsPurchased > appDelegate.profile.sessionsAvailable + appDelegate.profile.sessionsCompleted) {
            [self meetNow];
        }else{
            [Engine goToViewController:@"SubmitPaymentViewController" from: self];
        }
    }else{
        [Engine goToViewController:@"SignupViewController" from:self];
    }
}

-(void)meetNow{
    
    [Engine showHUDonView:topView];
    
    //prepare params
    NSNumber *userId = appDelegate.profile.userId;
    NSNumber *providerId = appDelegate.selectedProviderId;
    
    NSDateFormatter *dateFormatter=[NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *dateNow = [Engine dateAfterMinutes:1 fromDate:[NSDate date] ];
    
    NSString *strDate=[dateFormatter stringFromDate:dateNow];
    NSLog(@"meeting time is %@", strDate);
    
    //create an appointment first
    [[NetworkClient sharedInstance]postAppointmentWithUserId:userId providerId:providerId scheduledFor:strDate success:^(NSDictionary *dicResponse) {
        
        
        // save the appointment
        Appointment *appointment = [[Appointment alloc]initWithDic:dicResponse];
        NSLog(@"appointment : %@", appointment);
        
        [appDelegate.arrAppointments addObject:appointment];
        appDelegate.currentAppointment = appointment;
        ///
        
        [self goToVideoCall];
        
    } failure:^(NSString *message) {
        [Engine hideHUDonView:topView];
        [Engine showErrorMessage:@"Oops!" message:message onViewController:self];
    }];
}

-(void)goToVideoCall{
    //get session params
    [[NetworkClient sharedInstance]postAppointmentStreamsWithAppointmentId:appDelegate.currentAppointment.iid success:^(NSDictionary *dic) {
        
        //get apiKey, sessionId and token
        appDelegate.currentAppointment.apiKey = [dic objectForKey:@"tokbox_api_key"];
        appDelegate.currentAppointment.sessionId = [dic objectForKey:@"tokbox_session_id"];
        appDelegate.currentAppointment.token = [dic objectForKey:@"tokbox_token"];
        
        
        [Engine hideHUDonView:topView];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIStoryboard *storyboard;
            VideoCallViewController *videoCallVC;
            
            storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            videoCallVC = (VideoCallViewController*)[storyboard instantiateViewControllerWithIdentifier:@"VideoCallViewController"];
            videoCallVC.isPlusOne = NO;
            
            
            [self.navigationController pushViewController: videoCallVC animated:YES ];
        });
        
        
    } failure:^(NSString *message) {
        [Engine hideHUDonView:topView];        
        [Engine showErrorMessage:@"Oops!" message:@"Couldn't get tokbox session parameters" onViewController:self];
    }];
    
    
}
@end
