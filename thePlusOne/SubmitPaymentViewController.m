//
//  SubmitPaymentViewController.m
//  thePlusOne
//
//  Created by My Star on 6/21/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import "SubmitPaymentViewController.h"
#import "Constants.h"
#import "Engine.h"
#import "VideoCallViewController.h"
#import <PayPalMobile.h>
#import "Appointment.h"
#import "ConfirmationViewController.h"
#import <MessageUI/MessageUI.h>
//IAP
#import <StoreKit/StoreKit.h>

@interface SubmitPaymentViewController()<UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate, /*IAP*/SKProductsRequestDelegate, SKPaymentTransactionObserver>{
    
    int selectedPaymentMethod;
    UITableView *tblSessions;
    long nSessions;
    CGFloat fPrice;
    BOOL isDroppedDown;
    AppDelegate *appDelegate;
    
    UIView *topView;
    
    int orderId;//used for gift sessions
}
@end

@implementation SubmitPaymentViewController

-(void)viewDidLoad{
    appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    //set topView
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    topView = window.rootViewController.view;
    
    [self initView];
}

-(void)initView{
    _viewCardOrPaypal.hidden = YES;
    selectedPaymentMethod = PAYMENT_METHOD_IAP;
    nSessions = 1;
    
    [_lblPrice setText:[NSString stringWithFormat:@"%.2f", PRICE_PER_SESSION]];
    [_lblSessions setText:@"1"];
    
    isDroppedDown = NO;
    fPrice = nSessions * PRICE_PER_SESSION;
}
//*************************************************************************
#pragma mark - drop down list
-(void)viewDidAppear:(BOOL)animated{
    
    if (!tblSessions) {
        tblSessions = [self makeTableView];
        tblSessions.delegate = self;
        
        tblSessions.dataSource = self;
        
        
        [tblSessions registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
        [self.view addSubview:tblSessions];
        dispatch_async(dispatch_get_main_queue(), ^{
            [tblSessions reloadData];
        });
        
    }
    
}
-(UITableView *)makeTableView
{
    CGFloat cellHeight = _ivSessions.frame.size.height;
    CGFloat x = _ivSessions.frame.origin.x - 4;
    CGFloat y = _ivSessions.frame.origin.y + cellHeight + 66;
    NSLog(@"%f, %f", x, y);
    CGFloat width =  _ivSessions.frame.size.width;
    
    CGRect tableFrame = CGRectMake(x, y, width, 0);
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:tableFrame style:UITableViewStylePlain];
    
    tableView.rowHeight = cellHeight;
//    tableView.sectionFooterHeight = 11;
//    tableView.sectionHeaderHeight = 11;
    tableView.scrollEnabled = YES;
    tableView.showsVerticalScrollIndicator = YES;
    tableView.userInteractionEnabled = YES;
    tableView.bounces = YES;
    return tableView;
}
- (IBAction)btnSessionsTapped:(id)sender {
    CGFloat cellHeight = _ivSessions.frame.size.height;
    
    CGFloat tableHeight;
    
    if (isDroppedDown) {
        tableHeight = 0.0f;
    }else{
        tableHeight = NUM_OF_SESSIONS * cellHeight;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f;
        f= tblSessions.frame;
        tblSessions.frame = CGRectMake(tblSessions.frame.origin.x, tblSessions.frame.origin.y, tblSessions.frame.size.width, tableHeight);
    } completion:^(BOOL finished) {
        
    }];
    
    isDroppedDown = !isDroppedDown;
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return NUM_OF_SESSIONS;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    cell.backgroundView = [[UIView alloc] init];
    [cell.backgroundView setBackgroundColor:[UIColor clearColor]];
    [[[cell contentView] subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row + 1];
    
    cell.preservesSuperviewLayoutMargins = false;
    cell.separatorInset = UIEdgeInsetsZero;
    cell.layoutMargins = UIEdgeInsetsZero;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    isDroppedDown = NO;
    
    nSessions = indexPath.row + 1;
    fPrice = PRICE_PER_SESSION * nSessions;
    [_lblPrice setText:[NSString stringWithFormat:@"%.2f", fPrice]];
    
    [_lblSessions setText:[NSString stringWithFormat:@"%ld", nSessions]];
    
    [UIView animateWithDuration:0.3 animations:^{
        tblSessions.frame = CGRectMake(tblSessions.frame.origin.x, tblSessions.frame.origin.y, tblSessions.frame.size.width, 0);
    } completion:^(BOOL finished) {
        
        
    }];
    
}


//*************************************************************************
#pragma mark - button listeners
- (IBAction)btnIAPTapped:(id)sender {
    [self clearChecks];
    [_ivIAP setImage:[UIImage imageNamed:@"checked.png"]];
    selectedPaymentMethod = PAYMENT_METHOD_IAP;
    _viewCardOrPaypal.hidden = YES;
}
- (IBAction)btnCardOrPaypalTapped:(id)sender {
    [self clearChecks];
    [_ivCardOrPaypal setImage:[UIImage imageNamed:@"checked.png"]];
    selectedPaymentMethod = PAYMENT_METHOD_CARD;
    _viewCardOrPaypal.hidden = NO;
}
- (IBAction)btnInsuranceTapped:(id)sender {
    [self clearChecks];
    [_ivInsurance setImage:[UIImage imageNamed:@"checked.png"]];
    selectedPaymentMethod = PAYMENT_METHOD_INSURANCE;
    _viewCardOrPaypal.hidden = YES;
}
-(void)clearChecks{
    [_ivIAP setImage:[UIImage imageNamed:@"unchecked.png"]];
    [_ivCardOrPaypal setImage:[UIImage imageNamed:@"unchecked.png"]];
    [_ivInsurance setImage:[UIImage imageNamed:@"unchecked.png"]];
    [_ivCard setImage:[UIImage imageNamed:@"checked.png"]];
    [_ivPaypal setImage:[UIImage imageNamed:@"unchecked.png"]];
}
- (IBAction)btnCardTapped:(id)sender {
    [_ivCard setImage:[UIImage imageNamed:@"checked.png"]];
    [_ivPaypal setImage:[UIImage imageNamed:@"unchecked.png"]];
    
    selectedPaymentMethod = PAYMENT_METHOD_CARD;
}
- (IBAction)btnPaypalTapped:(id)sender {
    [_ivCard setImage:[UIImage imageNamed:@"unchecked.png"]];
    [_ivPaypal setImage:[UIImage imageNamed:@"checked.png"]];
    
    selectedPaymentMethod = PAYMENT_METHOD_PAYPAL;
}




- (IBAction)btnBackTapped:(id)sender {
    //now that user logged in, just go home
    [Engine goToViewController:@"SWRevealViewController" from:self];
}
- (IBAction)btnSubmitPaymentTapped:(id)sender {
//********** commented temporarily **********
//    switch (selectedPaymentMethod) {
//        case PAYMENT_METHOD_IAP:
//            [self iapSessions];
//            break;
//            
//        case PAYMENT_METHOD_CARD:
//            [self creditCardIntegrate];
//            break;
//            
//        case PAYMENT_METHOD_PAYPAL:
//            [self paypalPaymentIntegrate];
//            break;
//            
//        case PAYMENT_METHOD_INSURANCE:
//            
//            break;
//            
//        default:
//            break;
//    }
//********************************************
    [self postOrder];
}

-(void)goNext{
    int userStats = [Engine getUserStatus];
    
    
    switch (userStats) {
        case USER_STAT_MEET_NOW:
            
            [self meetNow];
            return;
            break;
            
        case USER_STAT_SCHEDULE:
            [self schedule];
            return;
            break;
            
        case USER_STAT_GROUP_SESSION:
            [self groupSession];
            
            break;
            
        case USER_STAT_GIFT_SESSION:
            [self giftSession];
            return;
            
            break;
       
    }
    
}
-(void)giftSession{
    NSInteger userId = [appDelegate.profile.userId integerValue];
        
    [[NetworkClient sharedInstance]postGiftSessionsWithuserId :userId orderId:orderId sessionsCount:nSessions recipientPhone:appDelegate.recipientPhoneNumber success:^(NSDictionary *dic) {
        
        
        [Engine hideHUDonView:topView];
        [Engine goToViewController:@"CongratsViewController" from:self];
        
    } failure:^(NSString *message) {
        [Engine hideHUDonView:topView];
        [Engine showErrorMessage:@"Oops!" message:message onViewController:self];
    }];
    
    
}
-(void)groupSession{
    [Engine hideHUDonView:topView];
    
    //prepare params
    [Engine showHUDonView:self.view];
    NSNumber *userId = appDelegate.profile.userId;
    NSNumber *providerId = appDelegate.selectedProviderId;
    
    NSDateFormatter *dateFormatter=[NSDateFormatter new];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSString *strDate=[dateFormatter stringFromDate:appDelegate.startDate];
    NSLog(@"scheduled time is %@", strDate);
    
    //create an appointment
    [[NetworkClient sharedInstance]postAppointmentWithUserId:userId providerId:providerId scheduledFor:strDate success:^(NSDictionary *dicResponse) {
        
        
        // save the appointment(including sessionId and token)
        Appointment *appointment = [[Appointment alloc]initWithDic:dicResponse];
        appointment.providerId = [appDelegate.selectedProviderId integerValue];
        NSLog(@"appointment : %@", appointment);
        
        
        [appDelegate.arrAppointments addObject:appointment];
        
        appDelegate.currentAppointment = appointment;
        ///
        
        [Engine hideHUDonView:self.view];
        [self postAppointmentInvites];
        
    } failure:^(NSString *message) {
        [Engine hideHUDonView:self.view];
        [Engine showErrorMessage:@"Oops!" message:message onViewController:self];
    }];
    
}
-(void)meetNow{
    //prepare params
    
    NSNumber *userId = appDelegate.profile.userId;
    NSNumber *providerId = appDelegate.selectedProviderId;
    
    NSDateFormatter *dateFormatter=[NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *dateNow = [Engine dateAfterMinutes:1 fromDate:[NSDate date]];
    NSString *strDate=[dateFormatter stringFromDate:dateNow];
    NSLog(@"meeting time is %@", strDate);
    
    //create an appointment first
    [[NetworkClient sharedInstance]postAppointmentWithUserId:userId providerId:providerId scheduledFor:strDate success:^(NSDictionary *dicResponse) {
        
        
        // save the appointment
        Appointment *appointment = [[Appointment alloc]initWithDic:dicResponse];
        appointment.providerId = [appDelegate.selectedProviderId integerValue];
        NSLog(@"appointment : %@", appointment);
        
        
        [appDelegate.arrAppointments addObject:appointment];
        
        appDelegate.currentAppointment = appointment;
        ///
       
        [self goToVideoCall];
    } failure:^(NSString *message) {
        [Engine hideHUDonView:topView];
        [Engine showErrorMessage:@"Oops!" message:message onViewController:self];
    }];
    
    
}

-(void)goToVideoCall{
    //get session params
    [[NetworkClient sharedInstance]postAppointmentStreamsWithAppointmentId:appDelegate.currentAppointment.iid success:^(NSDictionary *dic) {
        
        //get apiKey, sessionId and token
        appDelegate.currentAppointment.apiKey = [dic objectForKey:@"tokbox_api_key"];
        appDelegate.currentAppointment.sessionId = [dic objectForKey:@"tokbox_session_id"];
        appDelegate.currentAppointment.token = [dic objectForKey:@"tokbox_token"];
        
        UIStoryboard *storyboard;
        VideoCallViewController *videoCallVC;
        
        storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        videoCallVC = (VideoCallViewController*)[storyboard instantiateViewControllerWithIdentifier:@"VideoCallViewController"];
        videoCallVC.isPlusOne = NO;
        
        
        [Engine hideHUDonView:topView];
        [self.navigationController pushViewController: videoCallVC animated:YES ];
        
    } failure:^(NSString *message) {
        [Engine hideHUDonView:topView];
        
        [Engine showErrorMessage:@"Oops!" message:@"Couldn't get tokbox session parameters" onViewController:self];
    }];
    
    
}

-(void)schedule{
    //prepare params
    
    NSNumber *userId = appDelegate.profile.userId;
    NSNumber *providerId = appDelegate.selectedProviderId;
    
    NSDateFormatter *dateFormatter=[NSDateFormatter new];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSString *strDate=[dateFormatter stringFromDate:appDelegate.startDate];
    NSLog(@"scheduled time is %@", strDate);
    
    //create an appointment
    [[NetworkClient sharedInstance]postAppointmentWithUserId:userId providerId:providerId scheduledFor:strDate success:^(NSDictionary *dicResponse) {
        
        
        // save the appointment(including sessionId and token)
        Appointment *appointment = [[Appointment alloc]initWithDic:dicResponse];
        appointment.providerId = [appDelegate.selectedProviderId integerValue];
        NSLog(@"appointment : %@", appointment);
        
        
        [appDelegate.arrAppointments addObject:appointment];
        
        appDelegate.currentAppointment = appointment;
        ///
        
        //go to ConfirmationViewController
        UIStoryboard *storyboard;
        ConfirmationViewController *vc;
        
        storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        vc = (ConfirmationViewController*)[storyboard instantiateViewControllerWithIdentifier:@"ConfirmationViewController"];
        vc.isPlusOne = NO;
              
        
        [Engine hideHUDonView:topView];
        
        [self.navigationController pushViewController: vc animated:YES ];
        
    } failure:^(NSString *message) {
        [Engine hideHUDonView:topView];
        [Engine showErrorMessage:@"Oops!" message:message onViewController:self];
    }];
}
/////////////////////////////////////////////////////


#pragma mark PayPal

//- (void)onShowPayAlertAction
//{
//    NSString *showPayMessage = [NSString stringWithFormat:@"In order to create new own radio station, you havt to pay %@ us$",@"0.5"];
//    onShowPayAlert=   [UIAlertController
//                       alertControllerWithTitle:@"Payment"
//                       message:showPayMessage
//                       preferredStyle:UIAlertControllerStyleAlert];
//    
//    UIAlertAction* paypal = [UIAlertAction
//                             actionWithTitle:@"PayPal"
//                             style:UIAlertActionStyleDefault
//                             handler:^(UIAlertAction * action)
//                             {
//                                 [self paypalPaymentIntegrate];
//                             }];
//    UIAlertAction* creditCard = [UIAlertAction
//                                 actionWithTitle:@"CreditCard"
//                                 style:UIAlertActionStyleDefault
//                                 handler:^(UIAlertAction * action)
//                                 {
//                                     [self creditCardIntegrate];
//                                     
//                                     
//                                 }];
//    UIAlertAction* cancel = [UIAlertAction
//                             actionWithTitle:@"Cancel"
//                             style:UIAlertActionStyleDefault
//                             handler:^(UIAlertAction * action)
//                             {
//                                 [self onBackHomeView];
//                                 [onShowPayAlert dismissViewControllerAnimated:YES completion:nil];
//                                 
//                             }];
//    
//    [onShowPayAlert addAction:paypal];
//    [onShowPayAlert addAction:creditCard];
//    [onShowPayAlert addAction:cancel];
//    [self presentViewController:onShowPayAlert animated:YES completion:nil];
//    
//    
//}
- (void)paypalPaymentIntegrate{
    
    PayPalPayment *payment = [[PayPalPayment alloc] init];
    payAmount = [[NSDecimalNumber alloc] initWithString: [NSString stringWithFormat:@"%.2f", fPrice]];
    payment.amount = payAmount;
    payment.currencyCode = @"USD";
    payment.shortDescription = @"Create Video Session";
    payment.intent = PayPalPaymentIntentSale;
    
    // If your app collects Shipping Address information from the customer,
    // or already stores that information on your server, you may provide it here.
    //    payment.shippingAddress = address; // a previously-created PayPalShippingAddress object
    if (!payment.processable) {
        // If, for example, the amount was negative or the shortDescription was empty, then
        // this payment would not be processable. You would want to handle that here.
    }
    self.payPalConfiguration.acceptCreditCards = NO;
    PayPalPaymentViewController *paymentViewController;
    paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:payment                                                                   configuration:self.payPalConfiguration                                                                        delegate:self];
    [self presentViewController:paymentViewController animated:YES completion:nil];
    
}
- (void)creditCardIntegrate{
    PayPalPayment *payment = [[PayPalPayment alloc] init];
    payAmount = [[NSDecimalNumber alloc] initWithString: [NSString stringWithFormat:@"%.2f", fPrice]];
    payment.amount = payAmount;
    payment.currencyCode = @"USD";
    payment.shortDescription = @"Create Video Session";
    payment.intent = PayPalPaymentIntentSale;
    if (!payment.processable) {
        // If, for example, the amount was negative or the shortDescription was empty, then
        // this payment would not be processable. You would want to handle that here.
    }
    self.payPalConfiguration.acceptCreditCards = YES;
    PayPalPaymentViewController *paymentViewController;
    paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:payment                                                                   configuration:self.payPalConfiguration                                                                        delegate:self];
    [self presentViewController:paymentViewController animated:YES completion:nil];
    
}
//- (void)onBackHomeView
//{
//    [onShowPayAlert dismissViewControllerAnimated:YES completion:nil];
//    [self dismissViewControllerAnimated:YES completion:nil];
//}

#pragma mark - PayPalPaymentDelegate methods

- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController
                 didCompletePayment:(PayPalPayment *)completedPayment {
    // Payment was processed successfully; send to server for verification and fulfillment.
    [self verifyCompletedPayment:completedPayment];
    [self dismissViewControllerAnimated:YES completion:nil];
    

}

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
    // The payment was canceled; dismiss the PayPalPaymentViewController.
    [self dismissViewControllerAnimated:YES completion:nil];

    
}
-(void) postOrder{
    [Engine showHUDonView:topView];
    
    //prepare params
    NSNumber *userId = appDelegate.profile.userId;
    NSNumber *sessionsCount = [NSNumber numberWithLong:nSessions];
    NSNumber *isGift;
    if ([Engine getUserStatus] == USER_STAT_GIFT_SESSION) {
        isGift = [NSNumber numberWithBool:YES];
    }else{
        isGift = [NSNumber numberWithBool:NO];
    }
    NSString *transactionId = @"12345678";
    NSNumber *sessionRate = [NSNumber numberWithFloat:PRICE_PER_SESSION];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSString *createdTime = [formatter stringFromDate:[NSDate date]];
    
    payAmount = [[NSDecimalNumber alloc] initWithString: [NSString stringWithFormat:@"%.2f", fPrice]];
    
    //save purchasedSessions to NSUserDefaults
    appDelegate.profile.sessionsPurchased += nSessions;

    
    
    [[NetworkClient sharedInstance]postOrderWithId:userId userId:userId sessionsCount:sessionsCount isGift:isGift paymentMethod:@"paypal" transactionId:transactionId sessionRate:sessionRate totalAmount:payAmount createdAt:createdTime updatedAt:createdTime success:^(NSDictionary *dicResponse) {
        
        //save order id for gift sessions
        orderId = [[dicResponse objectForKey:@"id"]intValue];
        
        appDelegate.profile.sessionsAvailable++;
        
        [self goNext];
        
    } failure:^(NSString *message) {
        [Engine hideHUDonView:topView];
        NSString *strMessage = [NSString stringWithFormat:@"PostOrder failed. Reason: %@", message];
        [Engine showErrorMessage:@"Oops!" message:strMessage onViewController:self];
    }];
    
}
- (void)verifyCompletedPayment:(PayPalPayment *)completedPayment {
    // Send the entire confirmation dictionary
    //    NSData *confirmation = [NSJSONSerialization dataWithJSONObject:completedPayment.confirmation
    //                                                           options:0
    //                                                             error:nil];
    
    NSLog(@"completedPayment: %@", completedPayment);
    
    [Engine showHUDonView:topView];
    
    //prepare params
    NSNumber *userId = appDelegate.profile.userId;
    NSNumber *sessionsCount = [NSNumber numberWithLong:nSessions];
    NSNumber *isGift;
    if ([Engine getUserStatus] == USER_STAT_GIFT_SESSION) {
        isGift = [NSNumber numberWithBool:YES];
    }else{
        isGift = [NSNumber numberWithBool:NO];
    }
    NSString *transactionId = [[[completedPayment confirmation] objectForKey:@"response"]objectForKey:@"id"];
    NSNumber *sessionRate = [NSNumber numberWithFloat:PRICE_PER_SESSION];
    NSString *createdTime = [[[completedPayment confirmation] objectForKey:@"response"]objectForKey:@"create_time"];
    
    //save purchasedSessions to NSUserDefaults
    appDelegate.profile.sessionsPurchased += nSessions;
    
    [[NetworkClient sharedInstance]postOrderWithId:userId userId:userId sessionsCount:sessionsCount isGift:isGift paymentMethod:@"paypal" transactionId:transactionId sessionRate:sessionRate totalAmount:payAmount createdAt:createdTime updatedAt:createdTime success:^(NSDictionary *dicResponse) {
        
        //save order id for gift sessions
        orderId = [[dicResponse objectForKey:@"id"]intValue];
        
        appDelegate.profile.sessionsAvailable++;
        
        
        [self goNext];
        
    } failure:^(NSString *message) {
        [Engine hideHUDonView:topView];
        
        [Engine showMessage:message];
    }];
    
}

#pragma mark - send Email to selected contact
-(void)postAppointmentInvites{
    
    NSInteger appointmentId = appDelegate.currentAppointment.iid;
    NSInteger userId = [appDelegate.profile.userId integerValue];
    if (appDelegate.currentAppointment != nil) {
        
        [Engine showHUDonView:self.view];
        [[NetworkClient sharedInstance]postAppointmentInvitesWithappointmentId:appointmentId userId:userId firstName:appDelegate.recipientFirstName lastName:appDelegate.recipientLastName recipentPhone:appDelegate.recipientPhoneNumber success:^(NSDictionary *dic) {
            [Engine hideHUDonView:self.view];
            NSString *inviteCode = [dic objectForKey:@"invite_code"];
            if (inviteCode) {
                [self sendSMSWithInviteCode:inviteCode];
            }else{
                [Engine showErrorMessage:@"Oops!" message:@"Couldn't get invite code" onViewController:self];
            }
            
        } failure:^(NSString *message) {
            [Engine hideHUDonView:self.view];
            [Engine showErrorMessage:@"Oops!" message:message onViewController:self];
        }];
    }else{
        [Engine showErrorMessage:@"Oops!" message:@"No selected appointment" onViewController:self];
    }
    
}
-(void)sendSMSWithInviteCode:(NSString*)inviteCode{
    if(![MFMessageComposeViewController canSendText]) {
        [Engine showErrorMessage:@"Oops!" message:@"Your device doesn't support SMS! Couldn't SMS your contact." onViewController:self];
        return;
    }
    if ([appDelegate.recipientPhoneNumber isEqualToString:@""]) {
        [Engine showErrorMessage:@"Oops!" message:@"No mobile number to SMS" onViewController:self];
        return;
    }
    
    NSArray *recipents = @[appDelegate.recipientPhoneNumber];
    
    
    NSString *message;
    if (appDelegate.joinMode == MODE_JOIN_NOW) {
        message = MSG_JOIN_NOW;
        message = [message stringByReplacingOccurrencesOfString:@"sessionId" withString:inviteCode];
    }else if(appDelegate.joinMode == MODE_JOIN_FUTURE){
        message = MSG_JOIN_FUTURE;
        
        NSDate *sessionDate = [self dateWithString: appDelegate.currentAppointment.scheduledTime];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"MMMM dd, yyyy"];
        [formatter setTimeZone:[NSTimeZone localTimeZone]];
        NSString *strDate = [formatter stringFromDate:sessionDate];
        [formatter setDateFormat:@"HH:mm a"];
        [formatter setTimeZone:[NSTimeZone localTimeZone]];
        NSString *strTime = [formatter stringFromDate:sessionDate];
        
        
        message = [message stringByReplacingOccurrencesOfString:@"sessionDate" withString:strDate];
        message = [message stringByReplacingOccurrencesOfString:@"sessionTime" withString:strTime];
        message = [message stringByReplacingOccurrencesOfString:@"sessionId" withString:inviteCode];
        NSLog(@"MFMessageComposeVC/message: %@", message);
    }else{
        return;
    }
    
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}
-(NSDate*)dateWithString:(NSString *)dateSelected{
    
    NSDateFormatter *dateFormatterForGettingDate = [[NSDateFormatter alloc] init];
    [dateFormatterForGettingDate setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatterForGettingDate setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ"];
    
    
    NSDate *dateFromStr = [dateFormatterForGettingDate dateFromString:dateSelected];
    return dateFromStr;
    
}
#pragma mark - MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    [self dismissViewControllerAnimated:controller completion:nil];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ConfirmationViewController *vc = (ConfirmationViewController*)[storyboard instantiateViewControllerWithIdentifier:@"ConfirmationViewController"];
    vc.isPlusOne = YES;
    [self.navigationController pushViewController: vc animated:YES ];
}

#pragma mark - IAP
#define kIapSessionsProductIdentifier @"product id in iTunesConnect"
- (void)iapSessions{
    
    if([SKPaymentQueue canMakePayments]){
        NSLog(@"User can make payments");
        
        //If you have more than one in-app purchase, and would like
        //to have the user purchase a different product, simply define
        //another function and replace kRemoveAdsProductIdentifier with
        //the identifier for the other product
        
        SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:kIapSessionsProductIdentifier]];
        productsRequest.delegate = self;
        [productsRequest start];
        
    }
    else{
        NSLog(@"User cannot make payments due to parental controls");
        //this is called the user cannot make payments, most likely due to parental controls
    }
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    SKProduct *validProduct = nil;
    NSUInteger count = [response.products count];
    if(count > 0){
        validProduct = [response.products objectAtIndex:0];
        NSLog(@"Products Available!");
        [self purchase:validProduct];
    }
    else if(!validProduct){
        NSLog(@"No products available");
        //this is called if your product id is not valid, this shouldn't be called unless that happens.
    }
}

- (void)purchase:(SKProduct *)product{
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"received restored transactions: %lu", (unsigned long)queue.transactions.count);
    for(SKPaymentTransaction *transaction in queue.transactions){
        if(transaction.transactionState == SKPaymentTransactionStateRestored){
            //called when the user successfully restores a purchase
            NSLog(@"Transaction state -> Restored");
            
            //if you have more than one in-app purchase product,
            //you restore the correct product for the identifier.
            //For example, you could use
            //if(productID == kRemoveAdsProductIdentifier)
            //to get the product identifier for the
            //restored purchases, you can use
            //
            //NSString *productID = transaction.payment.productIdentifier;
            [self postOrder];
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    for(SKPaymentTransaction *transaction in transactions){
        
        switch(transaction.transactionState){
            case SKPaymentTransactionStatePurchasing: NSLog(@"Transaction state -> Purchasing");
                //called when the user is in the process of purchasing, do not add any of your own code here.
                break;
            case SKPaymentTransactionStatePurchased:
                //this is called when the user has successfully purchased the package (Cha-Ching!)
                [self postOrder]; //you can add your code for what you want to happen when the user buys the purchase here, for this tutorial we use removing ads
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                NSLog(@"Transaction state -> Purchased");
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"Transaction state -> Restored");
                //add the same code as you did from SKPaymentTransactionStatePurchased here
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                //called when the transaction does not finish
                if(transaction.error.code == SKErrorPaymentCancelled){
                    NSLog(@"Transaction state -> Cancelled");
                    //the user cancelled the payment ;(
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
        }
    }
}

@end
