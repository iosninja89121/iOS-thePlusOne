//
//  AppDelegate.m
//  thePlusOne
//
//  Created by My Star on 6/15/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import "AppDelegate.h"
#import "User.h"
#import "Provider.h"
#import "NetworkClient.h"
#import "PaypalMobile.h"
#import "Appointment.h"
#import "TestFairy.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>


@interface AppDelegate (){
    
}

@end

@implementation AppDelegate
@synthesize userStatus, wasReviewSession;
@synthesize arrProviders, arrUsers, connectionFailed, profile;
@synthesize accessToken;
@synthesize arrAppointments, currentAppointment;
@synthesize startDate;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize joinMode;
@synthesize recipientPhoneNumber;
@synthesize inviteId;
@synthesize invitedAppointment;
//@synthesize isFirstTime;
@synthesize inviteCode;



- (void) initGlobalData{
    
    self.wasReviewSession = NO;
    arrProviders = [[NSMutableArray alloc]init];
    
    //read access token
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if([[[def dictionaryRepresentation] allKeys] containsObject:KEY_ACCESS_TOKEN]){
        accessToken = [[NSUserDefaults standardUserDefaults]
                       stringForKey:KEY_ACCESS_TOKEN];
    }else{
        accessToken = @"";
    }
    
    //read profile    
    if([[[def dictionaryRepresentation] allKeys] containsObject:KEY_PROFILE]){
        profile = (Profile*)[Engine loadCustomObjectWithKey:KEY_PROFILE];
    }
    
    //init arrAppointments
    arrAppointments = [[NSMutableArray alloc]init];
    
    
    inviteId = -1; //no invitiation yet
    inviteCode = @""; //no invite code
    
    //go home as default
    [Engine setUserStatus:USER_STAT_GO_SCHEDULE];
    
//    self.isFirstTime = NO;
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [TestFairy begin:@"015e53f5e7bc1da699eb274e09d23dd6a6acc8bb"];

    
    [Fabric with:@[[Crashlytics class]]];
    // TODO: Move this to where you establish a user session

    
    [self initGlobalData];    
    
        
//        self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
//        
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        
//        UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
//        
//        self.window.rootViewController = viewController;
//        
//        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
//        
//        [self.window makeKeyAndVisible];
//        [self.window addSubview:navController.view];
    
#pragma mark PayPal Integration
    [PayPalMobile initializeWithClientIdsForEnvironments:
  @{PayPalEnvironmentProduction : @"AULKsAyKMKycVrkj6uArFNDCw6Mkp0e8MNYgGNTYmF-qD8mnuT0Vb3YVf5llYd_8phxFCpe-EZGtrBjP"/*@"YOUR_CLIENT_ID_FOR_PRODUCTION"*/,
    PayPalEnvironmentSandbox : @"ASg7o3fKjf8Dletk4CLZAz8MMzTC769y5oz6BAhHU2K64LI9XsTETMs_S2zEPgoCDKRQTGjx-renklGT"}];
    //    [Stripe setDefaultPublishableKey:@"pk_test_NkZ0uX8ji7sigRjjGPKRO5D6"];
        
    
    if (launchOptions != nil)
    {
        NSDictionary *dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (dictionary != nil)
        {
            NSLog(@"Launched from push notification: %@", dictionary);
            [self updateUI:dictionary];
        }
    }
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
#ifdef __IPHONE_8_0
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert
                                                                                             | UIUserNotificationTypeBadge
                                                                                             | UIUserNotificationTypeSound) categories:nil];
        [application registerUserNotificationSettings:settings];
#endif
    } else {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:myTypes];
    }
    
    
    return YES;
}


-(void)updateUI:(NSDictionary *)userInfo
{
    NSLog(@"AppDelegate/updateUI/userInfo: %@", userInfo);
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
 /*
    NSString *message = [userInfo objectForKey:@"message"];
        
        NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
        
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
        
        [parser setDelegate:self];
        
        BOOL success = [parser parse];
        
        if(success){
            NSLog(@"No Errors");
        }
        else{
            NSLog(@"Error Error Error!!!");
        }
        
        switch ([responseValue intValue]) {
            case 0:
            {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionCallNow) name:@"actionCallNow" object:nil];
                //get amount
                
                NSString *amount = [dic objectForKey:@"user_amount_for_service"];
                
                self.objCallNow = [[CallNowViewController alloc]initWithNibName:@"CallNowViewController" bundle:nil];
                objCallNow.amount = amount;
                UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
                
                [controller.view addSubview:objCallNow.view];
                
                
                //presentModalViewController:objDocPrivacyStaticViewController animated:NO];
                
                // presentViewController:objDocPrivacyStaticViewController animated:NO completion:nil];
                
                break;
            }
            case 1:
            {
                [NSIUtility showAlert:@"Aviso" withMessage:@"Llamar en 5 minutos" delegate:nil];
                break;
            }
            case 2:
            {
                [NSIUtility showAlert:@"Aviso" withMessage:@"No puedo atender en este momento" delegate:nil];
                break;
            }
            case 3:
            {
                [NSIUtility showAlert:@"Aviso" withMessage:@"Llame ahora sin costo" delegate:self];
                break;
            }
            default:
                break;
        }
        
       NSString *message = [userInfo objectForKey:@"message"];
        
        if ([message rangeOfString:@"<sender_id>"].location == NSNotFound)
        {
            UIApplication *app = [UIApplication sharedApplication];
            
            if (app.applicationState == UIApplicationStateActive)
            {
                
                NSString *lblDocName = [NSString stringWithUTF8String:[[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] cStringUsingEncoding:NSUTF8StringEncoding]];
                
                // Nothing to do if applicationState is Inactive, the iOS already displayed an alert view.
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:lblDocName delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                
                [alertView show];
                
                return;
            }
        }
        else
        {
            if (isBusy) {
                NSLog(@"DocAppDelegate/updateUI: already got a call...");
                return;
            }
            NSString *prefix = @"<sender_id>"; // string prefix, not needle prefix!
            NSString *suffix = @"</sender_id><message></message><status></status>"; // string suffix, not needle suffix!
            NSRange needleRange = NSMakeRange(prefix.length,
                                              message.length - prefix.length - suffix.length);
            NSString *needle = [message substringWithRange:needleRange];
            NSLog(@"needle: %@", needle); // -> "hello World"
            
            obj = [[DocHomeScreenViewController alloc] initWithNibName:@"DocHomeScreenViewController" bundle:nil];
            obj.docID = needle;
            
            UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
            
            [controller.view addSubview:obj.view];
            self.isBusy = YES;
            NSLog(@"DocAppDelegate/updateUI: added a view");
            
        }
    */
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    //save profile
    [Engine saveCustomObject:profile key:KEY_PROFILE];
    
    //save accessToken
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:accessToken forKey:KEY_ACCESS_TOKEN];
    [def synchronize];    
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.    
    
    
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)saveContext{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (NSManagedObjectContext *)managedObjectContext{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"NAMEOFYOURMODELHERE.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Delegate Methods

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}
#endif

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSLog(@"My token is: %@", deviceToken);
    
    NSString *dt = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    dt = [dt stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [[NSUserDefaults standardUserDefaults] setValue:dt forKey:@"DeviceToken"];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    // [[[UIAlertView alloc] initWithTitle:@"Failed to register push" message:error.localizedDescription delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
    
    NSLog(@"Failed to get token, error: %@", error);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    NSLog(@"Push is %@",userInfo);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateUI:userInfo];
    });
}

@end
