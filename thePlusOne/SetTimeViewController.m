//
//  SetTimeViewController.m
//  thePlusOne
//
//  Created by My Star on 7/23/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import "SetTimeViewController.h"
#import "Provider.h"

@interface SetTimeViewController (){
    NSMutableArray *arrAvailability;
}

@end

@implementation SetTimeViewController
@synthesize datePicker;
@synthesize setMode;
@synthesize startDate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initView];
    [self initAvailabilityWithDate:self.startDate];
}

- (NSDate *) convertDateToNewDate: (NSDate *)date{ //return the new date have the same hour/minute/second as self.startDate
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    NSDateComponents *componentsDate = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    
    NSCalendar *calendarStartDate = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *componentsStartDate = [calendarStartDate components:NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:self.startDate];
    
    [componentsDate setHour:componentsStartDate.hour];
    [componentsDate setMinute:componentsStartDate.minute];
    [componentsDate setSecond:componentsStartDate.second];
    
    NSDate *newDate = [calendar dateFromComponents:componentsDate];
    
    return newDate;
}

-(void)initAvailabilityWithDate:(NSDate *)date{
    arrAvailability = [[NSMutableArray alloc]init];
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    Provider *provider = [appDelegate.arrProviders objectAtIndex:appDelegate.selectedProviderIndex];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"EEEE"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSString *day = [formatter stringFromDate:date];
//    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    
    NSArray *arrTimes = [provider.availability objectForKey:day];
    for (NSDictionary *dic in arrTimes) {
        NSLog(@"dic: %@", dic);
        int startMinutes = 0, endMinutes = 0;
        startMinutes = [[dic objectForKey:@"start_minutes"]intValue];
        endMinutes = [[dic objectForKey:@"end_minutes"]intValue];
        
        if (startMinutes>0 && endMinutes>0) {
            //get start time string
            NSCalendar *gregorianCal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            [gregorianCal setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]]; //GMT timezone because all time values are specified with GMT timezone now.
//            [gregorianCal setTimeZone:[NSTimeZone timeZoneWithName:@"America/New_York"]]; //Eastern timezone because all time values are specified with ET timezone now.
            NSDateComponents *dateComps = [gregorianCal components: (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |NSCalendarUnitHour | NSCalendarUnitMinute)                                                          fromDate: date];
            
            
            dateComps.hour = startMinutes/60;
            dateComps.minute = startMinutes % 60;
            
            [formatter setDateFormat:@"hh:mm a"];
            [formatter setTimeZone:[NSTimeZone localTimeZone]];
            NSLog(@"SetTimeVC/initAvailability/startDate: %@", [gregorianCal dateFromComponents:dateComps]);
            
            NSString *strStartTime = [formatter stringFromDate:[gregorianCal dateFromComponents:dateComps]];
            
            //get end time string
            dateComps.hour = endMinutes/60;
            dateComps.minute = endMinutes % 60;
            
            [formatter setDateFormat:@"hh:mm a"];
            
            NSString *strEndTime = [formatter stringFromDate:[gregorianCal dateFromComponents:dateComps]];
            
            //combine 2 strings and add to array
            NSString *strCombined = [NSString stringWithFormat:@"%@ - %@", strStartTime, strEndTime];
            
            [arrAvailability addObject:strCombined];
        }
    }
    
     if (self.setMode == SET_DATE) {
         [_tblAvailability reloadData];
     }
    
}

-(void)initView{
    
//    NSCalendar *gregorianCal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
//    [gregorianCal setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
//    [datePicker setCalendar:gregorianCal];
    
    
    
    switch (setMode) {
        case SET_DATE:
            _lblTitle.text = @"Set Date of Session";
            datePicker.datePickerMode = UIDatePickerModeDate;
            
            datePicker.timeZone = [NSTimeZone localTimeZone];
            datePicker.minimumDate = [NSDate date];
            datePicker.maximumDate = [Engine dateAfterMinutes:10080 fromDate:[NSDate date]];
            
            
            datePicker.date = self.startDate;
            break;
            
        case SET_START_TIME:
            _lblTitle.text = @"Set Start time of Session";
            datePicker.datePickerMode = UIDatePickerModeTime;
            
            datePicker.timeZone = [NSTimeZone localTimeZone];
            
            datePicker.minuteInterval = 15;
            datePicker.date = self.startDate;
            break;
            
        case SET_END_TIME:
            _lblTitle.text = @"Set End time of Session";
            datePicker.datePickerMode = UIDatePickerModeTime;
            NSLog(@"self.endDate : %@", self.endDate);
            datePicker.date = self.endDate;
            NSLog(@"datePicker.date : %@", datePicker.date);
            break;
            
        default:
            break;
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
#pragma mark - button action
- (IBAction)btnConfirmTapped:(id)sender {
    NSLog(@"datePicker.date : %@", datePicker.date);
    
    if ([datePicker.date compare:[NSDate date]]==NSOrderedAscending) {
        [Engine showErrorMessage:@"Oops!" message:@"Please choose valid Date and Time" onViewController:self];
        return;
    }
    
    if(self.setMode == SET_DATE){
        
        self.startDate = [self convertDateToNewDate:datePicker.date];
        [self.delegate delegateSetStartDate:self.startDate];
        
        NSLog(@"startDate: %@", self.startDate);
    }
    if(self.setMode == SET_START_TIME){
        if ([datePicker.date compare:self.endDate]==NSOrderedDescending) {
            [Engine showErrorMessage:@"Oops!" message:@"The start time should be before the start time" onViewController:self];
            return;
        }
        if ([self isProviderAvailableWithDate:datePicker.date]) {
            self.startDate = datePicker.date;
            [self.delegate delegateSetStartDate:self.startDate];
        }else{
            [Engine showErrorMessage:@"Oops!" message:@"The provider is unavailable at that time" onViewController:self];
            return;
        }
        
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}
-(BOOL)isProviderAvailableWithDate:(NSDate*) date{
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"EEEE"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]]; //GMT timezone because all time values are specified with GMT timezone now.
    NSString *day = [formatter stringFromDate:[NSDate date]];
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    Provider *provider = [appDelegate.arrProviders objectAtIndex:appDelegate.selectedProviderIndex];
    
    int startMinutes = 0, endMinutes = 0;
    NSArray *arrTimes = [provider.availability objectForKey:day];
    for (NSDictionary *dic in arrTimes) {
        NSLog(@"dic: %@", dic);
        startMinutes = [[dic objectForKey:@"start_minutes"]intValue];
        endMinutes = [[dic objectForKey:@"end_minutes"]intValue];
        
        if (startMinutes>0 && endMinutes>0) {
            //get current hour and minute in GMT
            NSCalendar *gregorianCal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            [gregorianCal setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]]; //GMT timezone because all time values are specified with GMT timezone now.
//            [gregorianCal setTimeZone:[NSTimeZone timeZoneWithName:@"America/New_York"]]; //Eastern timezone because all time values are specified with ET timezone now.
            NSDateComponents *dateComps = [gregorianCal components: (NSCalendarUnitHour | NSCalendarUnitMinute)
                                                          fromDate: date];
            //get hour in GMT
            long gmtHour = [dateComps hour];
            NSLog(@"SearchProviderVC/isProviderAvailable/gmtHour : %ld", gmtHour);
            
            // check if the provider is available now
            long curMinutes = gmtHour*60 + [dateComps minute];
            if (curMinutes >= startMinutes && curMinutes <= endMinutes) {
                return YES;
            };
        }
    }
    return NO;
}
- (IBAction)btnBackTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [arrAvailability count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = (UITableViewCell*)[_tblAvailability dequeueReusableCellWithIdentifier:@"AvailabilityTableViewCell"];
    cell.textLabel.text = [arrAvailability objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - UIDatePicker action
- (IBAction)datePickerValueChanged:(id)sender {
    if (self.setMode == SET_DATE) {
        [self initAvailabilityWithDate:[self convertDateToNewDate:datePicker.date]];
    }
}


@end
