//
//  ContactsViewController.m
//  thePlusOne
//
//  Created by My Star on 6/21/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import "ContactsViewController.h"
#import "User.h"
#import "ContactDetailNewViewController.h"
@import AddressBook;

@interface ContactsViewController()<MFMessageComposeViewControllerDelegate>{
    BOOL searching;
    NSMutableArray *keys;
    NSMutableArray *productDataArray[36];
    NSMutableArray *copyListOfItems;
    NSMutableArray *arrUsers;
    
    __block NSMutableArray *myContacts;
}
@end

@implementation ContactsViewController

-(void)viewDidLoad{
    _searchBar.placeholder=@"User name here";
    searching = NO;
    
    
    [self showContacts];
}

-(void)showContacts{
    myContacts = [[NSMutableArray alloc]init];
    
    CFErrorRef *addressBookError = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, addressBookError);
    
    __block BOOL userDidGrantAddressBookAccess;
    
    
    if ( ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined ||
        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized )
    {
        [Engine showHUDonView:self.view];
        
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            userDidGrantAddressBookAccess = granted;
            dispatch_semaphore_signal(sema);
            if (userDidGrantAddressBookAccess)//(addressBook!=nil)
            {
                NSArray *allContacts = (__bridge_transfer NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
                
                NSUInteger i = 0;
                for (i = 0; i<[allContacts count]; i++)
                {
                    NSMutableDictionary *dicContact = [[NSMutableDictionary alloc]initWithObjects:@[@"", @"", @[], @"", @"", @""] forKeys:@[@"firstName", @"lastName", @"phoneNumber", @"homeEmail", @"birthday", @"title"]];
                    
                    ABRecordRef contactPerson = (__bridge ABRecordRef)allContacts[i];
                    //firstName
                    NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
                    if (firstName!=nil) {
                        [dicContact setObject:firstName forKey:@"firstName"];
                    }
                    
                    //lastName
                    NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
                    if (lastName != nil) {
                        [dicContact setObject:lastName forKey:@"lastName"];
                    }
                    
                    NSMutableDictionary *dicPhoneNumber = [[NSMutableDictionary alloc] init];
                    
                    //phone numbers
                    ABMultiValueRef phonesRef = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
                    for (int i=0; i < ABMultiValueGetCount(phonesRef); i++){
                        CFStringRef phoneLabel = ABMultiValueCopyLabelAtIndex(phonesRef, i);
                        CFStringRef phoneValue = ABMultiValueCopyValueAtIndex(phonesRef, i);
                        
                        if(phoneLabel && phoneValue) {
                            NSString *strLabel = (__bridge NSString*) ABAddressBookCopyLocalizedLabel(phoneLabel);
                            NSString *strVal = (__bridge NSString *)phoneValue;
                            
                            if(strLabel.length > 0 && strVal.length > 0) {
                                [dicPhoneNumber setObject:strVal forKey:strLabel];
                            }
                        }
                        
                        
                        
//                        if (phoneLabel) {
//                            if (CFStringCompare(phoneLabel, kABPersonPhoneMobileLabel, 0) == kCFCompareEqualTo) {
//                                [dicContact setObject:(__bridge NSString *)phoneValue forKey:@"mobileNumber"];
//                            }
//                            
//                            if (CFStringCompare(phoneLabel, kABHomeLabel, 0) == kCFCompareEqualTo) {
//                                [dicContact setObject:(__bridge NSString *)phoneValue forKey:@"homeNumber"];
//                            }
//                        }
                        
                        
//                        CFRelease(phoneLabel);
//                        CFRelease(phoneValue);
                    }
                    
                    [dicContact setObject:dicPhoneNumber forKey:@"phoneNumber"];
                    CFRelease(phonesRef);
                    
                    //email
                    ABMultiValueRef emailsRef = ABRecordCopyValue(contactPerson, kABPersonEmailProperty);
                    for (int i=0; i<ABMultiValueGetCount(emailsRef); i++) {
                        CFStringRef currentEmailLabel = ABMultiValueCopyLabelAtIndex(emailsRef, i);
                        CFStringRef currentEmailValue = ABMultiValueCopyValueAtIndex(emailsRef, i);
                        
                        if (currentEmailLabel) {
                            [dicContact setObject:(__bridge NSString *)currentEmailValue forKey:@"homeEmail"];
//                            if (CFStringCompare(currentEmailLabel, kABHomeLabel, 0) == kCFCompareEqualTo) {
//                                
//                            }
                        }
                        
                        
//                        CFRelease(currentEmailLabel);
//                        CFRelease(currentEmailValue);
                    }
                    CFRelease(emailsRef);
                    ///
                     
                    //birthday
                    NSString *birthday = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonBirthdayProperty);
                    if (birthday!=nil) {
                        [dicContact setObject:(NSDate*)birthday forKey:@"birthday"];
                    }
                    
                    
                    //imageData
                    if (ABPersonHasImageData(contactPerson)) {
                        NSData *contactImageData = (__bridge NSData *)ABPersonCopyImageDataWithFormat(contactPerson, kABPersonImageFormatThumbnail);
                        
                        [dicContact setObject:contactImageData forKey:@"photoData"];
                    }
                    
                    //title
                    NSString *title = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonJobTitleProperty);
                    if (title!=nil) {
                        [dicContact setObject:title forKey:@"title"];
                    }
                    
                    
                    // you need to do a nil check before adding a firstName to the array
                    //
                    // some contacts won't have first names, after all
                    
                    if([firstName length] > 0)
                    {
                        [myContacts addObject:dicContact];
                        /*
                        if ([lastName length]>0) {
                            NSString *fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
                            [myContacts addObject:fullName];
                        }else{
                            [myContacts addObject:firstName];
                        }
                         */
                    }
                }
                CFRelease(addressBook);
                
                [self processAndDisplayUsers];
            }
            else
            {
                CFBridgingRelease(addressBook);
                [Engine hideHUDonView:self.view];
                NSLog(@"Error");
            }
            
            // *** HERE is where to print out the myContacts array***
            NSLog(@"addresses are %@", myContacts);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    else
    {
        if ( ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
            ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted )
        {
            NSLog(@"denied");
            // Display an error.
            UIAlertView *cantAddContactAlert = [[UIAlertView alloc] initWithTitle: @"Cannot Add Contact" message: @"You must give the app permission to add the contact first." delegate:self cancelButtonTitle: @"OK" otherButtonTitles: nil];
            [cantAddContactAlert show];
        }
    }

}

-(NSMutableArray*) getUsersWithContacts:(NSMutableArray*)arrContacts{
    NSMutableArray* arr = [[NSMutableArray alloc]init];
    
    //add
    for (int i=0; i<[arrContacts count]; i++) {
        User *user = [[User alloc]initWithDic:[arrContacts objectAtIndex:i]];
        [arr addObject:user];
    }
    ///
    
    //sort users by their name
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray;
    sortedArray = [arr sortedArrayUsingDescriptors:sortDescriptors];
    
    [arr removeAllObjects];
    
    [arr addObjectsFromArray: sortedArray];
    ///
    return arr;
}

-(void)processAndDisplayUsers{
    
    arrUsers = [self getUsersWithContacts:myContacts];
    
    copyListOfItems=[[NSMutableArray alloc]init];
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",nil];
    keys = array;
    
    for (int i=0; i<=keys.count; i++) {
        productDataArray[i] =[[NSMutableArray alloc]init];
    }
    
    int sectionCount=0;
    
    for (int k=0; k<keys.count; k++) {
        NSString *key=[keys objectAtIndex:k];
        for (int j=0;j<[arrUsers count]; j++) {
            
            User *user = [arrUsers objectAtIndex:j];
            
            NSString *Name = user.firstName;
            
            
            sectionCount=j;
            if ([Name rangeOfString:key options:NSCaseInsensitiveSearch].location==0) {
                
                [productDataArray[k] addObject:user];
                
            }
            
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [Engine hideHUDonView:self.view];
        [_tableView reloadData];
    });
    
    
}
- (IBAction)btnNewMsgTapped:(id)sender {
    if(![MFMessageComposeViewController canSendText]) {
        [Engine showErrorMessage:@"Oops!" message:@"Your device doesn't support SMS!" onViewController:self];
        return;
    }
    
    NSArray *recipents = @[@""];
    
    
    NSString *message = @"";
    
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}

- (IBAction)btnBackTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (searching) {
        return 1;
    }
    else{
        return [keys count];
    }
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    if (searching) {
        return [[NSArray alloc]initWithObjects:@"", nil];
    }
    else{
        return keys;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    CGFloat height;
    if(searching){
        height= 0.0;
    }
    else{
        if (!([productDataArray[section] count]>0) ){
            height =0.0;
        }
        else{
            height =22.0;
        }
    }
    return height ;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(searching){
        return NULL;
    }
    else{
        
        UIView *v=[[UIView alloc] init];
        [v setBackgroundColor:[UIColor lightGrayColor]];
        UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(10, 2, 250, 20)];
        label.text=[NSString stringWithFormat:@" %@  (%lu) ",[keys objectAtIndex:section], (unsigned long)[productDataArray[section] count]];
        label.font=[UIFont boldSystemFontOfSize:16];
        label.font=[UIFont fontWithName:@"ChocolateDulce" size:17];
        label.textColor=[UIColor blackColor];
        label.backgroundColor=[UIColor clearColor];
        [v addSubview:label];
        return v;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (searching){
        return [copyListOfItems count];
    }
    else{
        long count=[productDataArray[section] count];
        return count;
        
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ContactsViewControllerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
//    UIImageView *personselectionImageView;
    
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
        
//        personselectionImageView=[[UIImageView alloc]initWithFrame:cell.frame];
//        [personselectionImageView setTag:7];
//        [cell.contentView addSubview:personselectionImageView];
    }
    // Configure the cell...
    User *user =[[User alloc]init];
    
    if(searching){
        if ([copyListOfItems count]>0) {
            user = [copyListOfItems objectAtIndex:indexPath.row];
        }
    }
    else {
        user = [productDataArray[indexPath.section] objectAtIndex:indexPath.row];
        
    }
    if ([user.lastName isEqualToString:@""]) {
        cell.textLabel.text = user.firstName;
    }else{
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
    }
    cell.textLabel.textColor=[UIColor blackColor];
    
//    if ([user.name isEqualToString:@"David Roman"]) {
//        cell.detailTextLabel.text = @"me";
//    }else{
//        cell.detailTextLabel.text = @"";
//    }
    
//    personselectionImageView=(UIImageView*)[cell.contentView viewWithTag:7];
    
    
    
    return cell;
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    User *user;
    if(searching){
        if ([copyListOfItems count]>0) {
            user = [copyListOfItems objectAtIndex:indexPath.row];

        }
    }
    else {
        user = [productDataArray[indexPath.section] objectAtIndex:indexPath.row];
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ContactDetailNewViewController *vc = (ContactDetailNewViewController*)[storyboard instantiateViewControllerWithIdentifier:@"ContactDetailNewViewController"];
    vc.mUser = user;
    [self.navigationController pushViewController:vc animated:YES];
    
}


#pragma mark - UISearchBarDelegate
- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
    
    searching = YES;
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
//    self.date = [NSDate dateWithTimeIntervalSinceNow:5.0];
    //Remove all objects first.
    [copyListOfItems removeAllObjects];
    
    if([searchText length] > 0) {
        searching = YES;
//        letUserSelectRow = YES;
        _tableView.scrollEnabled = YES;
        [self searchTableView];
    }
    else {
        searching = NO;
//        letUserSelectRow = NO;
    }
    
    [_tableView reloadData];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
    [theSearchBar resignFirstResponder];
    //[self searchTableView];
}

- (void) searchTableView {
    [copyListOfItems removeAllObjects];
    NSString *searchText = _searchBar.text;
    
    for (int i=0; i<keys.count; i++) {
        
        for (User *user in productDataArray[i]) {
            
            NSString *fullName = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
            NSRange titleResultsRange = [fullName rangeOfString:searchText options:NSCaseInsensitiveSearch];
            
            if (titleResultsRange.length > 0){
                [copyListOfItems addObject:user];
                
            }
        }
    }
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    
//    letUserSelectRow = YES;
    searching = NO;
    
    _tableView.scrollEnabled = YES;
    [_tableView reloadData];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    [self dismissViewControllerAnimated:controller completion:nil];
    
}
@end
