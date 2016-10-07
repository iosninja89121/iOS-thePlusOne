//
//  MenuViewController.m
//  thePlusOne
//
//  Created by My Star on 6/21/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import "MenuViewController.h"
#import "SWRevealViewController.h"
#import "HomeViewController.h"
#import "Engine.h"
#import "ViewController.h"
#import "PNChart.h"
@interface MenuViewController(){
    CGFloat fPieChartWidth;
}
@end

@implementation MenuViewController

-(void)viewDidLoad{
    //show status bar
    [Engine showStatusBar:YES];
 
    [_viewPieChart layoutIfNeeded];
    fPieChartWidth = _viewPieChart.bounds.size.width;
    
    [self initView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(profileInfoChanged) name:@"profileInfoUpdated" object:nil];
}

-(void) profileInfoChanged {
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    Profile *profile = appDelegate.profile;
    
    NSString *fullName = [NSString stringWithFormat:@"%@ %@", profile.firstName, profile.lastName];
    _lblFullName.text = fullName;

}

-(void)initView{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //make photo view round
        CGFloat radius = _ivPhoto.frame.size.height/2.0;
        _ivPhoto.layer.cornerRadius = radius;
        _ivPhoto.layer.masksToBounds = YES;
        _ivPhoto.contentMode = UIViewContentModeScaleAspectFill;
        
        
        [self drawPieChart];
    });
    
    
}
-(void)drawPieChart{
    
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSInteger sessionsCompleted = appDelegate.profile.sessionsCompleted;
    NSInteger sessionsAvailable = appDelegate.profile.sessionsAvailable;
    if (sessionsAvailable<0) {
        sessionsAvailable = 0;
    }
    if (sessionsCompleted<0) {
        sessionsCompleted = 0;
    }
    //for test
    //    sessionsCompleted = 5;
    //    sessionsAvailable = 15;
    
    //For Pie Chart
    UIColor *colorAvailable = [UIColor colorWithRed:(36/255.0f) green:171/255.0f blue:169/255.0f alpha:1.0f];
    UIColor *colorCompleted = [UIColor colorWithRed:7/255.0f green:67/255.0f blue:62/255.0f alpha:1.0f];
    NSArray *items = @[[PNPieChartDataItem dataItemWithValue:sessionsCompleted color:colorCompleted],
                       [PNPieChartDataItem dataItemWithValue:sessionsAvailable color:colorAvailable ]
                       ];
    
    
    CGRect rect = CGRectMake(0, 0, 110, 110);
    PNPieChart *pieChart = [[PNPieChart alloc] initWithFrame:rect items:items];
    
    pieChart.showAbsoluteValues = NO;
    pieChart.hideValues = YES;
    [pieChart strokeChart];
    
    
    [_viewPieChart addSubview:pieChart];
    [_viewPieChart layoutIfNeeded];
        
    
    NSInteger temp = (sessionsAvailable + sessionsCompleted);
    NSInteger percentOfAvailable;
    if (temp > 0) {
         percentOfAvailable = sessionsAvailable * 100 / temp;
    }else{
        percentOfAvailable = 0;
    }
    
    _lblPercent.text = [NSString stringWithFormat:@"%ld%%", percentOfAvailable];
    
    _lblSessionsRemaining.text = [NSString stringWithFormat:@"%ld", appDelegate.profile.sessionsAvailable ];
    _lblSessionsPurchased.text = [NSString stringWithFormat:@"%ld", appDelegate.profile.sessionsPurchased ];
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    Profile *profile = appDelegate.profile;
    
    NSString *fullName = [NSString stringWithFormat:@"%@ %@", profile.firstName, profile.lastName];
    _lblFullName.text = fullName;
    
    
    if (profile.photoData != nil) {
        [_ivPhoto setImage:[UIImage imageWithData:profile.photoData]];
    }else{
        [_ivPhoto setImage:[UIImage imageNamed:@"profile_placeholder"]];
    }
    
    
}

- (IBAction)btnSignoutTapped:(id)sender {
    
    NSLog(@"signed out");
    //delete access token to log out
    [Engine logout];
    
    [Engine goToViewController:@"ViewController" from:self];
    
//    
//    UINavigationController *passcodeNavigationController = [[UINavigationController alloc] initWithRootViewController:vc];
//    // [self.navigationController presentModalViewController:passcodeNavigationController animated:YES];
//    [self.navigationController pushViewController:passcodeNavigationController animated:YES];
}
- (IBAction)btnProfileTapped:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    
    [self.revealViewController pushFrontViewController:vc animated:YES];
}

- (IBAction)btnFilterProviderTapped:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"FilterProviderViewController"];
    
    [self.revealViewController pushFrontViewController:vc animated:YES];
}

- (IBAction)btnSearchProvidersTapped:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SearchProviderViewController"];
    
    [self.revealViewController pushFrontViewController:vc animated:YES];
}

- (IBAction)btnSessionsTapped:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HomeViewController *vc = (HomeViewController*)[storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
    vc.isHome = YES;
    [self.revealViewController pushFrontViewController:vc animated:YES];
    
}
- (IBAction)btnMyScheduleTapped:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HomeViewController *vc = (HomeViewController*)[storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
    vc.isHome = NO;
    [self.revealViewController pushFrontViewController:vc animated:YES];
    
}
- (IBAction)btnSettingsTapped:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];

    [self.revealViewController pushFrontViewController:vc animated:YES];
}
@end
