//
//  ScheduleSessionViewController.h
//  thePlusOne
//
//  Created by My Star on 6/22/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SetTimeViewController.h"

@interface ScheduleSessionViewController : UIViewController<SetTimeDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblStartTime;
@property (weak, nonatomic) IBOutlet UITextView *tvMessage;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIImageView *ivPhoto;

@property(nonatomic, strong) NSDate *startDate;
@property (weak, nonatomic) IBOutlet UILabel *lblSpecialties;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;


@end
