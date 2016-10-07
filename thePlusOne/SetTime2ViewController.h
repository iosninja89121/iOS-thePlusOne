//
//  SetTime2ViewController.h
//  thePlusOne
//
//  Created by My Star on 8/28/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SetTimeViewController.h"

@interface SetTime2ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property(nonatomic, strong) NSDate *startDate;
@property(nonatomic, weak) id<SetTimeDelegate> delegate;

@end
