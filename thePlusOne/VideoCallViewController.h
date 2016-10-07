//
//  VideoCallViewController.h
//  thePlusOne
//
//  Created by My Star on 6/22/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenTok/OpenTok.h>

@interface VideoCallViewController : UIViewController
<OTSessionDelegate, OTSubscriberDelegate, OTPublisherDelegate>{
    NSMutableDictionary *allStreams;
    NSMutableDictionary *allSubscribers;
    NSMutableArray *allConnectionsIds;
    NSMutableArray *backgroundConnectedStreams;
    
    CGFloat containerWidth;
    CGFloat containerHeight;
    
    
}

@property(nonatomic) BOOL isPlusOne;

@property (weak, nonatomic)  IBOutlet   UIButton *btnPlusOne;
@property (weak, nonatomic) IBOutlet UIButton *btnMic;
@property (weak, nonatomic) IBOutlet UIView *viewVideo;


@property (strong, nonatomic) OTSession* session;
@property (strong, nonatomic) OTPublisher* publisher;

@property (weak, nonatomic) IBOutlet UILabel *lblWaiting;

@end
