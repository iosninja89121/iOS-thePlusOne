//
//  SearchProviderViewController.h
//  thePlusOne
//
//  Created by My Star on 6/21/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchProviderViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *viewProvider;
@property (weak, nonatomic) IBOutlet UILabel *lblEmpty;

@property (weak, nonatomic) IBOutlet UIImageView *ivBkPhoto;
@property (weak, nonatomic) IBOutlet UIImageView *ivPhoto;
@property (weak, nonatomic) IBOutlet UIImageView *ivAvailable;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblCareer;
@property (weak, nonatomic) IBOutlet UILabel *lblLocation;
@property (weak, nonatomic) IBOutlet UILabel *lblDepartment;
@property (weak, nonatomic) IBOutlet UILabel *lblSpecialties;
@property (weak, nonatomic) IBOutlet UITextView *tvBio;

@property (weak, nonatomic) IBOutlet UIImageView *ivMeetNow;
@property (weak, nonatomic) IBOutlet UILabel *lblMeetNow;


@property (weak, nonatomic) IBOutlet UIView *viewDarkMask;

@property (weak, nonatomic) IBOutlet UIButton *btnBack;


-(void)swipeHandlerLeft;
-(void)swipeHandlerRight;
@end
