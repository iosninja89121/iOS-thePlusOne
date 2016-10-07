//
//  ConfirmationViewController.h
//  thePlusOne
//
//  Created by My Star on 6/22/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfirmationViewController : UIViewController
@property(nonatomic) BOOL isPlusOne;

@property (weak, nonatomic) IBOutlet UIImageView *ivProviderPhoto;
@property (weak, nonatomic) IBOutlet UIImageView *ivUserPhoto;

@property (weak, nonatomic) IBOutlet UILabel *lblDate;

@property (weak, nonatomic) IBOutlet UIView *viewPlusOne;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet UIView *viewTapToAdd;

@end
