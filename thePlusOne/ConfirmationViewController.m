//
//  ConfirmationViewController.m
//  thePlusOne
//
//  Created by My Star on 6/22/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import "ConfirmationViewController.h"
#import "Provider.h"
#import "Profile.h"
@import AddressBook;

@interface ConfirmationViewController(){
    AppDelegate* appDelegate;
}
@end

@implementation ConfirmationViewController

-(void)viewDidLoad{
    [self initView];
    
    if (appDelegate.userStatus == USER_STAT_SCHEDULE ||
        appDelegate.userStatus == USER_STAT_GROUP_SESSION || appDelegate.userStatus == USER_STAT_PLUS_ONE
        ) {
        appDelegate.userStatus = USER_STAT_GO_SCHEDULE;
    }
}

-(void) initView{
    appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    Provider *provider = [appDelegate.arrProviders objectAtIndex:appDelegate.selectedProviderIndex];
    
    //set iv for provider
    if (provider.pictureData != nil) {
        [_ivProviderPhoto setImage:[UIImage imageWithData:provider.pictureData]];
    }else{
        [_ivProviderPhoto setImage:[UIImage imageNamed:@"profile_placeholder.png"]];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //make iv round
        CGFloat radius = _ivProviderPhoto.frame.size.width/2.0;
        _ivProviderPhoto.layer.cornerRadius = radius;
        _ivProviderPhoto.layer.masksToBounds = YES;
        _ivProviderPhoto.contentMode = UIViewContentModeScaleAspectFill;
        
        //make iv round
        radius = _ivUserPhoto.frame.size.width/2.0;
        _ivUserPhoto.layer.cornerRadius = radius;
        _ivUserPhoto.layer.masksToBounds = YES;
        _ivUserPhoto.contentMode = UIViewContentModeScaleAspectFill;
        
    });
    
    
    //set iv for user
    if (appDelegate.profile.photoData != nil) {
        [_ivUserPhoto setImage:[UIImage imageWithData:appDelegate.profile.photoData]];
    }else{
        [_ivUserPhoto setImage:[UIImage imageNamed:@"profile_placeholder.png"]];
    }
    
    //set date
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setDateFormat: @"EEEE"];
    NSString *day = [formatter stringFromDate:appDelegate.startDate];
    
    [formatter setDateFormat:@"MMMM dd "];
    [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    NSString *date = [formatter stringFromDate:appDelegate.startDate];
    
    [formatter setDateFormat:@"h:mm a"];
    [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    NSString *time = [formatter stringFromDate:appDelegate.startDate];
    
    _lblDate.text = [NSString stringWithFormat:@"%@, %@ at %@", day, date, time];
    
    if (self.isPlusOne) {
        self.viewPlusOne.hidden = YES;
        self.viewTapToAdd.hidden = YES;
        self.lblDescription.text = DESCRIPTION_AFTER_PLUSONE;
    }else{
        self.viewPlusOne.hidden = NO;
        self.viewTapToAdd.hidden = NO;
        self.lblDescription.text = DESCRIPTION_BEFORE_PLUSONE;
    }    
}

#pragma mark - button listeners
- (IBAction)btnMenuTapped:(id)sender {
    [Engine goToViewController:@"SWRevealViewController" from:self];
}

- (IBAction)btnAddMemberTapped:(id)sender {
    if ( ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied){
        [Engine showErrorMessage:@"Oops!" message:@"Please allow Access to Contacts in Settings" onViewController:self];
        return;
    }
    
    appDelegate.userStatus = USER_STAT_PLUS_ONE;
    appDelegate.joinMode = MODE_JOIN_FUTURE;
    [Engine goToViewController:@"ContactsViewController" from:self];
}
@end
