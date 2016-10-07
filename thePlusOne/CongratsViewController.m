//
//  CongratsViewController.m
//  thePlusOne
//
//  Created by My Star on 8/3/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import "CongratsViewController.h"

@interface CongratsViewController ()

@end

@implementation CongratsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
- (IBAction)btnGetStartedTapped:(id)sender {
    [Engine goToViewController:@"ViewController" from:self];
}
- (IBAction)btnReferPlusOneTapped:(id)sender {
    
    
    NSString *strShare = @"Link to thePlusOne app";
    NSArray *objectsToShare = @[strShare];
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
    }];
}
- (IBAction)btnGiftASessionTapped:(id)sender {
    [Engine setUserStatus:USER_STAT_GIFT_SESSION];
    [Engine goToViewController:@"ContactsViewController" from:self];
}
- (IBAction)btnBackTapped:(id)sender {
    [Engine goToViewController:@"SWRevealViewController" from:self];
}

@end
