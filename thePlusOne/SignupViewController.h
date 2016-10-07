//
//  SignupViewController.h
//  thePlusOne
//
//  Created by My Star on 6/23/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignupViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *btnSignup;
@property (weak, nonatomic) IBOutlet UITextField *tfFirstName;
@property (weak, nonatomic) IBOutlet UITextField *tfLastName;


@property (weak, nonatomic) IBOutlet UITextField *tfEmailAddress;

@property (weak, nonatomic) IBOutlet UITextField *tfPassword;

@property (weak, nonatomic) IBOutlet UITextField *tfCode;



@end
