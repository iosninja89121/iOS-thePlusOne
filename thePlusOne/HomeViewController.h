//
//  HomeViewController.h
//  thePlusOne
//
//  Created by My Star on 6/21/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSCalendar.h"


@interface HomeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *viewSchedule;
@property (weak, nonatomic) IBOutlet UIView *viewHome;

@property(nonatomic) Boolean isHome;
@property (weak, nonatomic) IBOutlet UIButton *btnMenu;

@property (weak, nonatomic) IBOutlet FSCalendar *calendar;

//shedule view
@property (weak, nonatomic) IBOutlet UILabel *lblToday;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

//home view
@property (weak, nonatomic) IBOutlet UILabel *lblSessionsRemaining;
@property (weak, nonatomic) IBOutlet UILabel *lblSessionsPurchased;
@property (weak, nonatomic) IBOutlet UIView *viewPieChart;




@end
