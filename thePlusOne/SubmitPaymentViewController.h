//
//  SubmitPaymentViewController.h
//  thePlusOne
//
//  Created by My Star on 6/21/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PayPalMobile.h>
@interface SubmitPaymentViewController : UIViewController<PayPalPaymentDelegate>
{

    NSDecimalNumber *payAmount;
     UIAlertController * onShowPayAlert;
    
    //IAP
    BOOL isIapSessions;
}

@property (nonatomic, strong, readwrite) PayPalConfiguration *payPalConfiguration;

@property (weak, nonatomic) IBOutlet UIView *viewCardOrPaypal;

@property (weak, nonatomic) IBOutlet UIImageView *ivIAP;
@property (weak, nonatomic) IBOutlet UIImageView *ivCardOrPaypal;
@property (weak, nonatomic) IBOutlet UIImageView *ivInsurance;

@property (weak, nonatomic) IBOutlet UIImageView *ivCard;
@property (weak, nonatomic) IBOutlet UIImageView *ivPaypal;

@property (weak, nonatomic) IBOutlet UILabel *lblSessions;
@property (weak, nonatomic) IBOutlet UIImageView *ivSessions;
@property (weak, nonatomic) IBOutlet UILabel *lblPrice;

@end
