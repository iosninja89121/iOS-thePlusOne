//
//  ContactFormViewController.m
//  thePlusOne
//
//  Created by My Star on 8/28/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import "ContactFormViewController.h"
#import <MessageUI/MessageUI.h>
#import "Engine.h"

@interface ContactFormViewController ()<MFMailComposeViewControllerDelegate>{
    MFMailComposeViewController *mailComposer;
}

@end

@implementation ContactFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (IBAction)btnBackTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)btnSubmitTapped:(id)sender {
    if ([_lblFirstName.text isEqualToString:@""]) {
        [Engine showErrorMessage:@"Oops!" message:@"Please enter your first name" onViewController:self];
        return;
    }
    if ([_lblLastName.text isEqualToString:@""]) {
        [Engine showErrorMessage:@"Oops!" message:@"Please enter your last name" onViewController:self];
        return;
    }
    if ([_lblPhoneNumber.text isEqualToString:@""]) {
        [Engine showErrorMessage:@"Oops!" message:@"Please enter your phone number" onViewController:self];
        return;
    }
    if ([_tvFeedback.text isEqualToString:@""]) {
        [Engine showErrorMessage:@"Oops!" message:@"Please enter your feedback" onViewController:self];
        return;
    }
    
    mailComposer = [[MFMailComposeViewController alloc]init];
    mailComposer.mailComposeDelegate = self;
    NSString *recipient = @"info@plus1health.com";
    [mailComposer setToRecipients:@[recipient]];
    [mailComposer setSubject:@"Feedback"];
    
    NSString *message = [NSString stringWithFormat:@"First Name: %@\nLast Name: %@\nPhone Number: %@\nFeedback: %@", _lblFirstName.text, _lblLastName.text, _lblPhoneNumber.text, _tvFeedback.text];
    [mailComposer setMessageBody:message isHTML:NO];
    [self presentViewController:mailComposer animated:YES completion:nil];
    
    
}
#pragma mark - mail compose delegate
 -(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
     if (result) {
         NSLog(@"Result : %d",result);
     }
     if (error) {
         NSLog(@"Error : %@",error);
     }
     
    [self dismissViewControllerAnimated:YES completion:nil];
     
 }



@end
