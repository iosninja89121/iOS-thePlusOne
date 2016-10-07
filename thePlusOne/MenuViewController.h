//
//  MenuViewController.h
//  thePlusOne
//
//  Created by My Star on 6/21/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *ivPhoto;
@property (weak, nonatomic) IBOutlet UILabel *lblFullName;
@property (weak, nonatomic) IBOutlet UIView *viewPieChart;
@property (weak, nonatomic) IBOutlet UILabel *lblPercent;
@property (weak, nonatomic) IBOutlet UILabel *lblSessionsRemaining;
@property (weak, nonatomic) IBOutlet UILabel *lblSessionsPurchased;

@end
