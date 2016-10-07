//
//  ContactFormViewController.h
//  thePlusOne
//
//  Created by My Star on 8/28/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactFormViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *tvFeedback;
@property (weak, nonatomic) IBOutlet UITextField *lblFirstName;
@property (weak, nonatomic) IBOutlet UITextField *lblLastName;
@property (weak, nonatomic) IBOutlet UITextField *lblPhoneNumber;

@end
