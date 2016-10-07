//
//  ProfileViewController.m
//  thePlusOne
//
//  Created by My Star on 6/26/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#import "ProfileViewController.h"
#import "SWRevealViewController.h"
#import "Profile.h"
#import <MobileCoreServices/MobileCoreServices.h>

#import <DZNPhotoEditorViewController.h>
#import <DZNPhotoPickerController/DZNPhotoEditorViewController.h>
#import <DZNPhotoPickerController/UIImagePickerController+Edit.h>

@interface ProfileViewController()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    UIImagePickerController *imagePicker;
    
    AppDelegate *appDelegate;
}
@end

@implementation ProfileViewController

-(void)viewDidLoad{
    
    appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [self initView];
    
}

-(void)initView{
    //slide-out side bar menu
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.btnMenu addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    ///
    
    Profile *profile = appDelegate.profile;
    
    NSString *fullName = [NSString stringWithFormat:@"%@ %@", profile.firstName, profile.lastName];
    _lblFullName.text = fullName;
    
    _lblTitle.text = @"";
    
    _tfFirstName.placeholder = profile.firstName;
    _tfLastName.placeholder = profile.lastName;
    _tfEmail.placeholder = profile.emailAddress;
    
    [_btnSave setHidden:YES];
    
    [_tfFirstName addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_tfLastName addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_tfEmail addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    _lblPassword.text = profile.password;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //make photo view round
        CGFloat radius = _ivPhoto.frame.size.height/2.0;
        _ivPhoto.layer.cornerRadius = radius;
        _ivPhoto.layer.masksToBounds = YES;
        _ivPhoto.contentMode = UIViewContentModeScaleAspectFill;
    });
    
    
    if (profile.photoData != nil) {
        [_ivPhoto setImage:[UIImage imageWithData:profile.photoData]];
    }else{
        [_ivPhoto setImage:[UIImage imageNamed:@"profile_placeholder"]];
    }
}

- (IBAction)btnSaveTapped:(id)sender {
    NSString *strFirstName = _tfFirstName.text;
    NSString *strLastName = _tfLastName.text;
    NSString *strEmail = _tfEmail.text;
    
    if(strFirstName.length == 0) strFirstName = appDelegate.profile.firstName;
    if(strLastName.length == 0) strLastName = appDelegate.profile.lastName;
    if(strEmail.length == 0) strEmail = appDelegate.profile.emailAddress;
    
    NSDictionary *dicInfo = @{@"email": strEmail, @"first_name": strFirstName, @"last_name": strLastName, @"role":@"user"};
    NSString *strUserId = [appDelegate.profile.userId stringValue];
    
    [[NetworkClient sharedInstance] updateProfileWithUserId:strUserId info:dicInfo success:^(NSDictionary *dicResponse) {
        appDelegate.profile.firstName = strFirstName;
        appDelegate.profile.lastName = strLastName;
        appDelegate.profile.emailAddress = strEmail;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"profileInfoUpdated" object:nil];
        [Engine goToViewController:@"SWRevealViewController" from:self];
    } failure:^(NSString *message) {
        
    }];
}

-(void)textFieldDidChange :(UITextField *)theTextField{
    NSLog( @"text changed: %@", theTextField.text);
    NSString *strFirstName = _tfFirstName.text;
    NSString *strLastName = _tfLastName.text;
    NSString *strEmail = _tfEmail.text;
    
    if(strFirstName.length + strLastName.length + strEmail.length > 0) {
        [_btnSave setHidden:NO];
    } else {
        [_btnSave setHidden:YES];
    }
    
    if(strFirstName.length + strLastName.length > 0) {
        if(strFirstName.length < 1) strFirstName = appDelegate.profile.firstName;
        if(strLastName.length < 1) strLastName = appDelegate.profile.lastName;
        
        NSString *fullName = [NSString stringWithFormat:@"%@ %@", strFirstName, strLastName];
        _lblFullName.text = fullName;
    }
}


- (IBAction)btnNewPhotoTapped:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Select source" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *alertTakePhoto = [UIAlertAction
                                     actionWithTitle:@"Take Photo"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action){
                                         
                                         [[NSOperationQueue mainQueue] addOperationWithBlock:^{                                           [self takePhoto];
                                         }];
                                     }];
    UIAlertAction *alertLoadFromLib = [UIAlertAction
                                       actionWithTitle:@"Choose from Gallery"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action){
                                           [[NSOperationQueue mainQueue] addOperationWithBlock:^{                                           [self loadPhotoFromGallery];
                                           }];
                                       }];
    
    UIAlertAction *alertCancel = [UIAlertAction
                                  actionWithTitle:@"Cancel"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action){
                                      [alertController dismissViewControllerAnimated:YES completion:nil];
                                  }];
    
    
    [alertController addAction:alertTakePhoto];
    [alertController addAction:alertLoadFromLib];
    [alertController addAction:alertCancel];
    [self presentViewController:alertController animated:YES completion:nil];
    
//    UIAlertController * alert=   [UIAlertController
//                                  alertControllerWithTitle:nil
//                                  message:nil
//                                  preferredStyle:UIAlertControllerStyleAlert];
//    
//    UIAlertAction* camera = [UIAlertAction
//                             actionWithTitle:@"Camera"
//                             style:UIAlertActionStyleDefault
//                             handler:^(UIAlertAction * action)
//                             {
//                                 [alert dismissViewControllerAnimated:YES completion:nil];
//                                 
//                                 [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                                     [self openPhotoPicker:UIImagePickerControllerSourceTypeCamera];
//                                 }];
//                             }];
//    UIAlertAction* photoGallery = [UIAlertAction
//                                   actionWithTitle:@"Photo gallery"
//                                   style:UIAlertActionStyleDefault
//                                   handler:^(UIAlertAction * action)
//                                   {
//                                       [alert dismissViewControllerAnimated:YES completion:nil];
//                                       
//                                       [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                                           [self openPhotoPicker:UIImagePickerControllerSourceTypePhotoLibrary];
//                                       }];
//                                   }];
//    UIAlertAction* cancel = [UIAlertAction
//                             actionWithTitle:@"Cancel"
//                             style:UIAlertActionStyleDefault
//                             handler:^(UIAlertAction * action)
//                             {
//                                 [alert dismissViewControllerAnimated:YES completion:nil];
//                                 
//                             }];
//    
//    [alert addAction:camera];
//    [alert addAction:photoGallery];
//    [alert addAction:cancel];
//    
//    [self presentViewController:alert animated:YES completion:nil];
}

//- (void)openPhotoPicker:(UIImagePickerControllerSourceType)sourceType {
//    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
//        NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
//        if ([availableMediaTypes containsObject:(NSString *)kUTTypeImage]) {
//            
//            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
//            imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
//            imagePickerController.sourceType = sourceType;
//            imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
//            imagePickerController.delegate = self;
//            
//            [self presentViewController:imagePickerController animated:YES completion:nil];
//        }
//    }
//}

- (void)takePhoto{
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.allowsEditing = YES;
    imagePicker.delegate = self;
    imagePicker.cropMode = DZNPhotoEditorViewControllerCropModeCircular;
//    [self setPickerCompletionBlock];
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)loadPhotoFromGallery{
    imagePicker = [[UIImagePickerController alloc] init];
    
    imagePicker.allowsEditing = YES;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePicker.mediaTypes = @[(NSString*)kUTTypeImage];
    imagePicker.delegate = self;
    imagePicker.cropMode = DZNPhotoEditorViewControllerCropModeCircular;
//    [self setPickerCompletionBlock];
    [self presentViewController:imagePicker animated:YES completion:nil];
}
- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
//    enableUpdateProfile = NO;
    [picker dismissViewControllerAnimated: YES completion: nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:^{
        _ivPhoto.image = image;
        NSData* imageData = UIImageJPEGRepresentation(image, 0.5f);
        AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        delegate.profile.photoData = imageData;
        
    }];
}
/*
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary<NSString *,id> *)editingInfo{
    __weak __typeof(self)weakSelf = self;
    
    
    
    //        weakSelf.enableUpdateProfile = NO;
    [picker dismissViewControllerAnimated:YES completion:^{
        weakSelf.ivPhoto.image = image;
        NSData* imageData = UIImageJPEGRepresentation(image, 0.5f);
        AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        delegate.profile.photoData = imageData;
    }];
}*/

     /*
- (void)setPickerCompletionBlock
{
    __weak __typeof(self)weakSelf = self;
    imagePicker.finalizationBlock = ^(UIImagePickerController *picker, NSDictionary *info) {
        UIImage *image = info[UIImagePickerControllerEditedImage];
        
//        weakSelf.enableUpdateProfile = NO;
        [picker dismissViewControllerAnimated:YES completion:^{
            weakSelf.ivPhoto.image = image;
            NSData* imageData = UIImageJPEGRepresentation(image, 0.5f);
            AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            delegate.profile.photoData = imageData;
//            [[NetworkClient sharedInstance] uploadAvatarWithData: imageData success:^(NSDictionary *dicResponse)
//             {
//                 NSLog(@"uploadAvatar response = %@", dicResponse);
//                 
//                 int result_image_id = [[dicResponse valueForKey: @"id"] intValue];
//                 NSString* updatedAvatar = [dicResponse valueForKey: @"url"];
//                 
//                 [[NetworkClient sharedInstance] editProfile: nil
//                                                       phone: nil
//                                                     website: nil
//                                              status_message: nil
//                                               posts_visible: -1
//                                                    image_id: result_image_id
//                                                     success:^(NSDictionary *result)
//                  {
//                      NSLog(@"result = %@", result);
//                      [AppDelegate getDelegate].curUser.avatarSrc = updatedAvatar;
//                  } failure:^{
//                  }];
//                 
//                 
//             } failure:^{
//             }];
        }];
    };
}*/
     
@end
