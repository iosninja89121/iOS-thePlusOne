//
//  SettingsViewController.m
//  thePlusOne
//
//  Created by My Star on 6/21/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import "SettingsViewController.h"
#import "SWRevealViewController.h"

@interface SettingsViewController(){
    AppDelegate *appDelegate;
}
@end

@implementation SettingsViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    //slide-out side bar menu
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.btnMenu addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    ///
    [self initView];
   
    
    
}
-(void)initView{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *strState = [defaults objectForKey:@"switchNotification"];
    if ([strState isEqualToString:@"On"]) {
        [_switchNotification setOn:YES];
    }else{
        [_switchNotification setOn:NO];
    }
    [_switchNotification addTarget:self action:@selector(setState:) forControlEvents:UIControlEventValueChanged];
}
- (void)setState:(id)sender
{
    BOOL state = [sender isOn];
        
    //tell backend whether to send push notifications or not
    [self putProfile:state];
    
}
-(void)putProfile:(BOOL)state{
    [Engine showHUDonView:self.view];
    
    NSInteger profileId = [appDelegate.profile.profileId integerValue];
    NSString *phone = @"912-345-6789";
    
    
    [[NetworkClient sharedInstance]putUserProfileWithProfileId:profileId profilePicUrl:@"" phone:phone notifications:state success:^(NSDictionary *dic) {
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
        
    } failure:^(NSString *message) {
        [Engine hideHUDonView:self.view];
        [Engine showErrorMessage:@"Oops!" message:message onViewController:self];
        
        [_switchNotification setOn:!state];
    }];
   
}

#pragma mark - button actions

- (IBAction)btnReferTapped:(id)sender {
    
    NSString *stringToShare = @"Hi, I'd like to invite you to download the +1 Health app. +1 Health is a digital platform providing social therapy resources to change the landscape of mental health in underserved neighborhoods. +1 Health connects users to mental health services and provides information to empower people to make safer, healthier choices in a frictionless and simple way.";
    NSArray *objectsToShare = @[stringToShare];
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
- (IBAction)btnFeedbackTapped:(id)sender {
    [Engine goToViewController:@"ContactFormViewController" from:self];
}
- (IBAction)btnAboutTapped:(id)sender {
    [Engine goToViewController:@"AboutViewController" from:self];
}

@end
