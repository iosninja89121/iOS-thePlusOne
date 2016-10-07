//
//  SetTimeViewController.h
//  thePlusOne
//
//  Created by My Star on 7/23/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SetTimeDelegate <NSObject>

-(void)delegateSetStartDate:(NSDate*)date;

@end


@interface SetTimeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

@property(nonatomic) int setMode;

@property(nonatomic, strong) NSDate *startDate;
@property(nonatomic, strong) NSDate *endDate;

@property(nonatomic, weak) id<SetTimeDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITableView *tblAvailability;

@end


