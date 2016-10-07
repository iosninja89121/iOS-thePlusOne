//
//  ReviewSessionViewController.m
//  thePlusOne
//
//  Created by My Star on 6/30/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import "ReviewSessionViewController.h"
#import "Engine.h"
#import "Provider.h"
#import "ScheduleSessionViewController.h"

@interface ReviewSessionViewController (){
    int mRate;
    AppDelegate *appDelegate;
}

@end

@implementation ReviewSessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [Engine setWasReviewSession:YES];
    mRate = -1;
    
    
    appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.view layoutIfNeeded];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
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
- (IBAction)btnNextAppointmentTapped:(id)sender {
    NSString *errMsg = [self giveFeedback];
    if (![errMsg isEqualToString:@""]) {
        [Engine showErrorMessage:@"Oops!" message:errMsg onViewController:self];
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ScheduleSessionViewController *vc = (ScheduleSessionViewController*)[storyboard instantiateViewControllerWithIdentifier:@"ScheduleSessionViewController"];
        vc.startDate = [Engine dateIn15Increments:[NSDate date]];
        appDelegate.selectedProviderIndex = [self providerIndexWithIdentifier:appDelegate.currentAppointment.providerId];
        
        [self.navigationController pushViewController: vc animated:YES ];
    });
}
-(NSInteger)providerIndexWithIdentifier:(NSInteger)identifier{
    for (int i=0; i<[appDelegate.arrProviders count]; i++) {
        Provider *provider = [appDelegate.arrProviders objectAtIndex:i];
        if ([provider.identifier integerValue] == identifier) {
            return i;
        }
    }
    return 0;
}
- (IBAction)btnReferProviderTapped:(id)sender {
    NSString *errMsg = [self giveFeedback];
    if (![errMsg isEqualToString:@""]) {
        [Engine showErrorMessage:@"Oops!" message:errMsg onViewController:self];
        return;
    }
    

    //direct user to share functionality of provider info and the link to the app
    
    Provider  *provider = [appDelegate.arrProviders objectAtIndex:appDelegate.selectedProviderIndex];
    
    NSString *fullName = [NSString stringWithFormat:@"%@ %@", provider.firstName, provider.lastName];
    NSArray *objectsToShare = @[fullName];
    //    NSMutableArray *temp = [[NSMutableArray alloc]init];
    //    [temp addObject:urlPlayer];
    //    NSArray *objectsToShare = [NSArray arrayWithArray:temp];
    
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
        [Engine goToViewController:@"SWRevealViewController" from:self];
    }];
    
}

-(NSString*) giveFeedback{
    
    
    if (mRate == -1) {
        return @"Please rate the provider";
    }
    NSString *feedback = _tvFeedback.text;
    
//    RLMRealm *realm = [RLMRealm defaultRealm];
//    [realm beginWriteTransaction];
   
    NSInteger iid = appDelegate.currentAppointment.iid;
    [[NetworkClient sharedInstance]putAppointmentWithAppointmentId:iid  status:@"completed" rating:[NSNumber numberWithInt:mRate] feedback:feedback success:^(NSDictionary *dic) {
        NSLog(@"giveFeedback success!");
    } failure:^(NSString *message) {
        NSLog(@"giveFeedback failed...");
    }];
    
    //remove
    [appDelegate.arrAppointments removeObject:appDelegate.currentAppointment];
//    [realm commitWriteTransaction];
    
    
    return @"";
}
- (IBAction)btnSubmitTapped:(id)sender {
    
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *referTheProvider = [UIAlertAction actionWithTitle:@"Refer the Provider" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self btnReferProviderTapped:nil];
    }];
    UIAlertAction *scheduleNextAppointment = [UIAlertAction actionWithTitle:@"Schedule Next Appointment" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self btnNextAppointmentTapped:nil];
    }];
    UIAlertAction *close = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [Engine goToViewController:@"SWRevealViewController" from:self];
    }];
    [alertController addAction:referTheProvider];
    [alertController addAction:scheduleNextAppointment];
    [alertController addAction:close];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)btnRateTapped:(id)sender {
    [self clearButtonColor];
    
    if (sender == _btnRate1) {
        mRate = 1;
        [_btnRate1 setImage:[UIImage imageNamed:@"rate1_inactive.png"] forState:UIControlStateNormal];
    }
    if (sender == _btnRate2) {
        mRate = 2;
        [_btnRate2 setImage:[UIImage imageNamed:@"rate2_inactive.png"] forState:UIControlStateNormal];
    }
    if (sender == _btnRate3) {
        mRate = 3;
        [_btnRate3 setImage:[UIImage imageNamed:@"rate3_inactive.png"] forState:UIControlStateNormal];
    }
    if (sender == _btnRate4) {
        mRate = 4;
        [_btnRate4 setImage:[UIImage imageNamed:@"rate4_inactive.png"] forState:UIControlStateNormal];
    }
    if (sender == _btnRate5) {
        mRate = 5;
        [_btnRate5 setImage:[UIImage imageNamed:@"rate5_inactive.png"] forState:UIControlStateNormal];
    }
    
}
-(void)clearButtonColor{
    [_btnRate1 setImage:[UIImage imageNamed:@"rate1.png"] forState:UIControlStateNormal];
    [_btnRate2 setImage:[UIImage imageNamed:@"rate2.png"] forState:UIControlStateNormal];
    [_btnRate3 setImage:[UIImage imageNamed:@"rate3.png"] forState:UIControlStateNormal];
    [_btnRate4 setImage:[UIImage imageNamed:@"rate4.png"] forState:UIControlStateNormal];
    [_btnRate5 setImage:[UIImage imageNamed:@"rate5.png"] forState:UIControlStateNormal];
}

- (IBAction)btnBackTapped:(id)sender {
    NSString *errMsg = [self giveFeedback];
    if (![errMsg isEqualToString:@""]) {
        [Engine showErrorMessage:@"Oops!" message:errMsg onViewController:self];
        return;
    }
    [Engine goToViewController:@"SWRevealViewController" from:self];
}



@end
