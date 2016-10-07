//
//  ContactDetailViewController.h
//  thePlusOne
//
//  Created by My Star on 6/23/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface ContactDetailViewController : UIViewController

@property(nonatomic, strong) User* mUser;

@property (weak, nonatomic) IBOutlet UIImageView *ivPhoto;

@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblPhoneNumber1;
@property (weak, nonatomic) IBOutlet UILabel *lblPhoneNumber2;
@property (weak, nonatomic) IBOutlet UILabel *lblEmailAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblBirthday;
@end
