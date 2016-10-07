//
//  FilterProviderViewController.m
//  thePlusOne
//
//  Created by iOS Ninja on 9/21/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import "FilterProviderViewController.h"
#import "SWRevealViewController.h"
#import "SearchProviderViewController.h"
#import "Provider.h"

@interface FilterProviderViewController ()
@property (weak, nonatomic) IBOutlet UITextField *tfProvider;
@property (weak, nonatomic) IBOutlet UITextField *tfSpecialty;
@property (weak, nonatomic) IBOutlet UITextField *tfDate;
@property (weak, nonatomic) IBOutlet UITextField *tfTime;
@property (weak, nonatomic) IBOutlet UIButton *btnMenu;
@property (nonatomic, strong) NSDate *dateDate;
@property (nonatomic, strong) NSDate *dateTime;
@property (nonatomic, strong) AppDelegate *appDelegate;
@end

@implementation FilterProviderViewController

- (IBAction)onMenuBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onRemoveFilterPressed:(id)sender {
    self.appDelegate.arrFilteredProviders = self.appDelegate.arrProviders;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"providerSelected" object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onFilterPressed:(id)sender {
    
    NSString *strProvider = [self.tfProvider.text lowercaseString];
    NSString *strSpecialty = [self.tfSpecialty.text lowercaseString];
    NSString *strDate = self.tfDate.text;
    NSString *strTime = self.tfTime.text;
    
    if(strProvider.length + strSpecialty.length + strDate.length + strTime.length == 0) {
        [Engine showErrorMessage:@"Oops!" message:@"pls input the search field" onViewController:self];
        return;
    }
    
    if((strDate.length == 0 && strTime.length > 0) || (strDate.length > 0 && strTime.length == 0)) {
        [Engine showErrorMessage:@"Oops!" message:@"pls input both of date and time" onViewController:self];
        return;
    }
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"EEEE"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSString *day = [formatter stringFromDate:self.dateDate];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDateComponents *dateComps = [calendar components: (NSCalendarUnitHour | NSCalendarUnitMinute)                                                          fromDate: self.dateTime];
    
    NSInteger hour = [dateComps hour];
    NSInteger minute = [dateComps minute];
    
    NSInteger totalMinutes = hour * 60 + minute;
    NSInteger idx;
    
    self.appDelegate.arrFilteredProviders = [[NSMutableArray alloc] init];
    
    for(idx = 0; idx < [self.appDelegate.arrProviders count]; idx ++) {
        Provider *tempProvider = [self.appDelegate.arrProviders objectAtIndex:idx];
        
        NSString *strFullName = [[NSString stringWithFormat:@"%@ %@", tempProvider.firstName, tempProvider.lastName] lowercaseString];
        
        if(strProvider.length > 0 && [strFullName rangeOfString:strProvider].location == NSNotFound) continue;
        
        
        NSString *strTitle = [tempProvider.specialties lowercaseString];
        
        if(strSpecialty.length > 0 && [strTitle rangeOfString:strSpecialty].location == NSNotFound) continue;
        
        if(strDate.length  + strTime.length == 0) {
            [self.appDelegate.arrFilteredProviders addObject:tempProvider];
        }
        
        NSArray *arrOpenSessions = [tempProvider.openSessionTimes objectForKey:day];
        
        BOOL isFind = NO;
        
        for(NSNumber *number in arrOpenSessions) {
            if([number integerValue] <= totalMinutes && [number integerValue] + 15 >totalMinutes) {
                isFind = YES;
                break;
            }
        }
        
        if(isFind) {
            [self.appDelegate.arrFilteredProviders addObject:tempProvider];
        }
    }
    
    if([self.appDelegate.arrFilteredProviders count] == 0){
        [Engine showErrorMessage:@"Oops!" message:@"Sorry, no providers fit your search. Please update and resubmit your request" onViewController:self];
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"providerSelected" object:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
    
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SearchProviderViewController"];
//    
//    ((SearchProviderViewController *)vc).nProviderIndex = idx;
//    
//    [self.revealViewController pushFrontViewController:vc animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    // Do any additional setup after loading the view.
//    SWRevealViewController *revealViewController = self.revealViewController;
//    if ( revealViewController )
//    {
//        [self.btnMenu addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
//    }
    
    UIDatePicker *datePicker = [[UIDatePicker alloc]init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker setDate:[NSDate date]];
    [datePicker addTarget:self action:@selector(updateDateTextField:) forControlEvents:UIControlEventValueChanged];
    [self.tfDate setInputView:datePicker];
//    [self updateDateTextField:self.tfDate];
    
    UIDatePicker *timePicker = [[UIDatePicker alloc]init];
    timePicker.datePickerMode = UIDatePickerModeTime;
    [timePicker setDate:[NSDate date]];
    [timePicker addTarget:self action:@selector(updateTimeTextField:) forControlEvents:UIControlEventValueChanged];
    [self.tfTime setInputView:timePicker];
//    [self updateTimeTextField:self.tfTime];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPickerView)];
    [self.view addGestureRecognizer:tap];
    
    self.dateDate = [NSDate date];
    self.dateTime = [NSDate date];
    
    [self.tfProvider addTarget:self action:@selector(textFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.tfSpecialty addTarget:self action:@selector(textFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
}

- (void)dismissPickerView {
    [self.tfDate resignFirstResponder];
    [self.tfTime resignFirstResponder];
    [self.tfProvider resignFirstResponder];
    [self.tfSpecialty resignFirstResponder];
}

- (void)updateDateTextField:(id)sender
{
    UIDatePicker *picker = (UIDatePicker*)self.tfDate.inputView;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"MMM d, yyyy"];
    NSString *formattedDate = [dateFormatter stringFromDate:picker.date];
    self.tfDate.text = formattedDate;
    self.dateDate = picker.date;
}

-(void)textFieldFinished:(id)sender
{
    UITextField *tfElement = (UITextField *)sender;
    [tfElement resignFirstResponder];
}

-(void)updateTimeTextField:(id)sender
{
    UIDatePicker *picker = (UIDatePicker*)self.tfTime.inputView;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"H:mm a"];
    NSString *formattedDate = [dateFormatter stringFromDate:picker.date];
    self.tfTime.text = formattedDate;
    self.dateTime = picker.date;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
