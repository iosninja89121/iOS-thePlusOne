//
//  GiftSessionViewController.m
//  thePlusOne
//
//  Created by My Star on 6/21/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import "GiftSessionViewController.h"

@implementation GiftSessionViewController
- (IBAction)btnGooglePlusTapped:(id)sender {
    [self goToSubmitPayment];
}
- (IBAction)btnFacebookTapped:(id)sender {
    [self goToSubmitPayment];
}
- (IBAction)btnLoginTapped:(id)sender {
    [Engine goToViewController:@"LoginViewController" from:self];
}
- (IBAction)btnSignupTapped:(id)sender {
    [Engine goToViewController:@"SignupViewController" from:self];
}

-(void)goToSubmitPayment{
    
    [Engine goToViewController:@"SubmitPaymentViewController" from:self];
}

@end
