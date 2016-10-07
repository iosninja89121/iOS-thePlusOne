//
//  CustomCell.h
//  thePlusOne
//
//  Created by My Star on 8/13/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *ivDot;
@property (weak, nonatomic) IBOutlet UIImageView *ivProviderPhoto;
@property (weak, nonatomic) IBOutlet UIImageView *ivPlusOnePhoto;
@property (weak, nonatomic) IBOutlet UIButton *btnPlusOne;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UILabel *lblProviderName;

@end
