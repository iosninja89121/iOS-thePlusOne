//
//  SetTime2ViewController.m
//  thePlusOne
//
//  Created by My Star on 8/28/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import "SetTime2ViewController.h"
#import "Provider.h"
#import "SetTimeCustomCell.h"


@interface SetTime2ViewController (){
    NSMutableArray *arrAvailability;
    NSMutableArray *arrSlices;
    
    NSDate *dateSelected;
}

@end

@implementation SetTime2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initSlicesWithDate:self.startDate];
    
    dateSelected = self.startDate;
}
-(void)initSlicesWithDate:(NSDate *)date{
    arrSlices = [[NSMutableArray alloc]init];
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    Provider *provider = [appDelegate.arrProviders objectAtIndex:appDelegate.selectedProviderIndex];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"EEEE"];
//    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]]; //GMT timezone because all time values are specified with GMT timezone now.
    NSString *day = [formatter stringFromDate:date];
    //    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    
    NSArray *arrTimes = [provider.availability objectForKey:day];
//    for (NSDictionary *dic in arrTimes) {
    NSDictionary *dic = [arrTimes objectAtIndex:0];
        NSLog(@"dic: %@", dic);
    
    //********** get array of slices **************
    
        int startMinutes = 0, endMinutes = 0;
        startMinutes = [[dic objectForKey:@"start_minutes"]intValue];
        endMinutes = [[dic objectForKey:@"end_minutes"]intValue];
    
    
        if (startMinutes>0 && endMinutes>0) {
            
            
            int startSliceIndex = startMinutes/15;
            int endSliceIndex = endMinutes/15-1;
            
            for (int i=startSliceIndex; i<=endSliceIndex; i++) {
                [arrSlices addObject:[NSNumber numberWithInt:i]];
            }
        }
    //*********************************************
    [self initAvailabilty:date];
}
-(void)initAvailabilty:(NSDate*) date{
    arrAvailability = [[NSMutableArray alloc]init];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    NSCalendar *gregorianCal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorianCal setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]]; //GMT timezone because all time values are specified with GMT timezone now.
//    [gregorianCal setTimeZone:[NSTimeZone timeZoneWithName:@"America/New_York"]]; //Eastern timezone because all time values are specified with ET timezone now.
    
    //get start time string
    for(NSNumber *number in arrSlices){
        
        NSDateComponents *dateComps = [gregorianCal components: (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |NSCalendarUnitHour | NSCalendarUnitMinute)                                                          fromDate: date];
        dateComps.hour = [number intValue]*15/60;
        dateComps.minute = [number intValue]*15 % 60;
        
        NSDate *dateToAdd =[gregorianCal dateFromComponents:dateComps];
        
        [arrAvailability addObject:dateToAdd];
        
    }
    
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
- (IBAction)btnConfirmTapped:(id)sender {
    
    if ([dateSelected compare:[NSDate date]]==NSOrderedAscending) {
        [Engine showErrorMessage:@"Oops!" message:@"Please choose valid Date and Time" onViewController:self];
        return;
    }
    
    self.startDate = dateSelected;
    [self.delegate delegateSetStartDate:self.startDate];
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)btnBackTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource and Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [arrAvailability count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SetTimeCustomCell *cell = (SetTimeCustomCell*)[_tableView dequeueReusableCellWithIdentifier:@"SetTimeCustomCell"];
    NSDate *date = [arrAvailability objectAtIndex:indexPath.row];
    
    //get hh:mm a string from date
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    NSCalendar *gregorianCal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorianCal setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]]; //GMT timezone because all time values are specified with GMT timezone now.
     NSDateComponents *dateComps = [gregorianCal components: (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |NSCalendarUnitHour | NSCalendarUnitMinute)                                                          fromDate: date];
    
    [formatter setDateFormat:@"hh:mm a"];
    
    NSString *strStartTime = [formatter stringFromDate:[gregorianCal dateFromComponents:dateComps]];
    ///
    
    cell.lblTime.text = strStartTime;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    dateSelected = [arrAvailability objectAtIndex:indexPath.row];
}
@end
