//
//  VideoCallViewController.m
//  thePlusOne
//
//  Created by My Star on 6/22/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import "VideoCallViewController.h"
#import "Engine.h"
@import AddressBook;

@interface VideoCallViewController (){
    UIView *topView;
    AppDelegate *appDelegate;
}
@end

@implementation VideoCallViewController
@synthesize isPlusOne;

-(void)viewDidLoad{
    
}

-(void)viewWillAppear:(BOOL)animated{
    appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    //set topView
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    topView = window.rootViewController.view;
    
    //waiting the provider to join
    _lblWaiting.hidden = NO;
    
    //init OpenTok params
    NSString *sessionId = appDelegate.currentAppointment.sessionId;
    NSString *apiKey = appDelegate.currentAppointment.apiKey;
    NSString *token = appDelegate.currentAppointment.token;
    
    if (isPlusOne == YES) {
        _btnPlusOne.hidden = YES;
    }else{
        _btnPlusOne.hidden = NO;
    }
    
    
    self.session = [[OTSession alloc] initWithApiKey:apiKey
                                           sessionId:sessionId
                                            delegate:self];
    [self.session connectWithToken:token error:nil];
    
    
    allStreams = [[NSMutableDictionary alloc] init];
    allSubscribers = [[NSMutableDictionary alloc] init];
    allConnectionsIds = [[NSMutableArray alloc] init];
    backgroundConnectedStreams = [[NSMutableArray alloc] init];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        containerWidth = _viewVideo.frame.size.width;//CGRectGetWidth(self.view.bounds);
        containerHeight = _viewVideo.frame.size.height;//CGRectGetHeight(self.view.bounds);
    });
    
    
    
    [_btnMic setImage:[UIImage imageNamed:@"mic_off.png"] forState:UIControlStateNormal];
}

- (IBAction)btnPlusOneTapped:(id)sender {
    if ( ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied){
        [Engine showErrorMessage:@"Oops!" message:@"Please allow Access to Contacts in Settings" onViewController:self];
        return;
    }
    
    [self endCallAction:nil];
    appDelegate.joinMode = MODE_JOIN_NOW;
    [Engine goToViewController:@"ContactsViewController" from:self];
}
- (IBAction)btnHangupTapped:(id)sender {
    [self endCallAction:nil];
    
    [self updateSessions];
    appDelegate.userStatus = USER_STAT_GO_SCHEDULE;
    
    
    [Engine goToViewController:@"ReviewSessionViewController" from:self];
}
-(void)updateSessions{
    
    appDelegate.profile.sessionsCompleted++;
    appDelegate.profile.sessionsAvailable--;
    if (appDelegate.profile.sessionsAvailable<0) {
        appDelegate.profile.sessionsAvailable=0;
    }
    
}
/*
-(void)removeAppointmentWithId:(NSInteger)iid{
    for (Appointment *ap in  appDelegate.arrAppointments) {
        if (ap.iid == iid) {
            [appDelegate.arrAppointments removeObject:ap];
            break;
        }
    }
}
*/
//*************************************************************************
#pragma mark - OTSessionDelegate
- (void)sessionDidConnect:(OTSession*)session
{
    
    self.publisher = [[OTPublisher alloc]
                      initWithDelegate:self];
    
    OTError *error = nil;
    [session publish:self.publisher error:&error];
    if(error){
        [self showAlert:[error localizedDescription]];
    }else{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.publisher.view setFrame:CGRectMake(containerWidth*2/3-10,
                                                     containerHeight*2/3-10,
                                                     containerWidth/3,
                                                     containerHeight/3)];
            [self.view addSubview:self.publisher.view];
        });
        
    }
    
    
}

- (void)session:(OTSession*)session
  streamCreated:(OTStream*)stream
{
    // create subscriber
    [self createSubscriber:stream];
    
}

- (void)subscriberDidConnectToStream:(OTSubscriberKit*)subscriber
{
    NSLog(@"subscriberDidConnectToStream (%@)",
          subscriber.stream);
    
    // create subscriber
    OTSubscriber *sub = (OTSubscriber *)subscriber;
    [allSubscribers setObject:subscriber forKey:sub.stream.connection.connectionId];
    [allConnectionsIds addObject:sub.stream.connection.connectionId];
    
    // set subscriber position and size
    
    int count = (int)[allConnectionsIds count];
    if (count==1) {
        [sub.view setFrame:
         CGRectMake(0,
                    0,
                    containerWidth,
                    containerHeight)];
        _lblWaiting.hidden = YES;
    }
    if (count==2) {
        [sub.view setFrame:
         CGRectMake(10,
                    containerHeight*2/3-10,
                    containerWidth/3,
                    containerHeight/3)];
    }
    
    
    sub.view.tag = count;
    
    // add to video container view
    [self.view addSubview:sub.view];
    [self.view bringSubviewToFront:self.publisher.view];
    
    
    [allStreams setObject:sub.stream forKey:sub.stream.connection.connectionId];
}


- (void)subscriberVideoDataReceived:(OTSubscriber *)subscriber{
    
}

- (void)sessionDidDisconnect:(OTSession*)session{
    
    NSLog(@"Session disconnected");
    
    // remove all subscriber views from video container
    for (int i = 0; i < [allConnectionsIds count]; i++)
    {
        OTSubscriber *subscriber = [allSubscribers valueForKey:
                                    [allConnectionsIds objectAtIndex:i]];
        [subscriber.view removeFromSuperview];
    }
    
    [self.publisher.view removeFromSuperview];
    
    [allSubscribers removeAllObjects];
    [allConnectionsIds removeAllObjects];
    [allStreams removeAllObjects];
    
    
}

- (void)session:(OTSession*)session
streamDestroyed:(OTStream*)stream
{
    
    NSLog(@"session streamDestroyed (%@)", stream.streamId);
    // get subscriber for this stream
    OTSubscriber *subscriber = [allSubscribers objectForKey:
                                stream.connection.connectionId];
    
    // remove from superview
    [subscriber.view removeFromSuperview];
    
    [allSubscribers removeObjectForKey:stream.connection.connectionId];
    [allConnectionsIds removeObject:stream.connection.connectionId];
    
}

- (void)publisher:(OTPublisherKit *)publisher
    streamCreated:(OTStream *)stream
{
    
}

- (void) session:(OTSession*)session
didFailWithError:(OTError*)error
{
    NSLog(@"didFailWithError: (%@)", error);
    
    [self showAlert:
     [NSString stringWithFormat:@"There was an error connecting to session %@",
      session.sessionId]];
    [self endCallAction:nil];
}
- (void)publisher:(OTPublisherKit*)publisher
 didFailWithError:(OTError*) error
{
    NSLog(@"publisher didFailWithError %@", error);
    
    [self showAlert:[NSString stringWithFormat:
                     @"There was an error publishing."]];
    [self endCallAction:nil];
}
- (void)subscriber:(OTSubscriberKit*)subscriber
  didFailWithError:(OTError*)error
{
    NSLog(@"subscriber %@ didFailWithError %@", subscriber.stream.streamId, error);
}
//*************************************************************************
#pragma mark - Helper Methods
- (void)showAlert:(NSString *)string
{
    // show alertview on main UI
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Message from video session"
                              message:string
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] ;
        [alert show];
    });
}

- (void)createSubscriber:(OTStream *)stream
{
    
    if ([[UIApplication sharedApplication] applicationState] ==
        UIApplicationStateBackground ||
        [[UIApplication sharedApplication] applicationState] ==
        UIApplicationStateInactive)
    {
        [backgroundConnectedStreams addObject:stream];
    } else
    {
        // create subscriber
        OTSubscriber *subscriber = [[OTSubscriber alloc]
                                    initWithStream:stream delegate:self];
        
        // subscribe now
        OTError *error = nil;
        [_session subscribe:subscriber error:&error];
        if (error)
        {
            [self showAlert:[error localizedDescription]];
        }else{
            NSLog(@"subscriber created for stream: %@", stream);
        }
        
    }
}


- (IBAction)endCallAction:(UIButton *)button
{
    if (_session && _session.sessionConnectionStatus ==
        OTSessionConnectionStatusConnected) {
        // disconnect session
        NSLog(@"disconnecting....");
        [_session disconnect:nil];
        return;
    }
}

- (IBAction)toggleAudioPublish:(id)sender
{
    if (_publisher.publishAudio == YES) {
        _publisher.publishAudio = NO;
        [_btnMic setImage:[UIImage imageNamed:@"mic_on.png"] forState:UIControlStateNormal];
    } else {
        _publisher.publishAudio = YES;
        [_btnMic setImage:[UIImage imageNamed:@"mic_off.png"] forState:UIControlStateNormal];
    }
}

- (void)enteringBackgroundMode:(NSNotification*)notification
{
    _publisher.publishVideo = NO;
    
    for (OTSubscriber *subscriber in allSubscribers) {
        subscriber.subscribeToVideo = NO;
    }
}

- (void)leavingBackgroundMode:(NSNotification*)notification
{
    _publisher.publishVideo = YES;
    for (OTSubscriber *subscriber in allSubscribers) {
        subscriber.subscribeToVideo = NO;
    }
    
    //now subscribe to any background connected streams
    for (OTStream *stream in backgroundConnectedStreams)
    {
        // create subscriber
        OTSubscriber *subscriber = [[OTSubscriber alloc]
                                    initWithStream:stream delegate:self];
        // subscribe now
        OTError *error = nil;
        [_session subscribe:subscriber error:&error];
        if (error)
        {
            [self showAlert:[error localizedDescription]];
        }
        
    }
    [backgroundConnectedStreams removeAllObjects];
}



@end
