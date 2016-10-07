//
//  ContactDetailNewViewController.h
//  thePlusOne
//
//  Created by Jane on 9/14/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "User.h"

@interface ContactDetailNewViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate>
@property (nonatomic, strong) User *mUser;
@end
