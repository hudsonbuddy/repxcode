//
//  PictureDelegate.m
//  Rep
//
//  Created by Hudson on 5/17/13.
//  Copyright (c) 2013 Hud. All rights reserved.
//

#import "PictureDelegate.h"
#import "PictureViewController.h"
#import "MFSideMenu.h"


@implementation PictureDelegate


//// For responding to the user tapping Cancel.
//- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
//    
//    [[picker parentViewController] dismissViewControllerAnimated:YES completion:nil];
//}

// For responding to the user accepting a newly-captured picture or movie
- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
    
    // Handle a still image capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        
        editedImage = (UIImage *) [info objectForKey:
                                   UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            imageToSave = editedImage;
        } else {
            imageToSave = originalImage;
        }
        
        //Do something with Image
        NSLog(@"doing something with image %@", imageToSave);
        
        
        [[MFSideMenuManager sharedManager].navigationController dismissViewControllerAnimated:YES
                                              completion:^{
                                                  
                                                  PictureViewController *myController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]
                                                                                         instantiateViewControllerWithIdentifier:@"pictureID"];
                                                  myController.myPictureManager = self.myPictureManager;
                                                  myController.imageToUse = imageToSave;
                                                  [[MFSideMenuManager sharedManager].navigationController presentModalViewController:myController animated:YES];

        
        
        }];
    }
    
    // Handle a movie capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0)
        == kCFCompareEqualTo) {
        
//        NSString *moviePath = [[info objectForKey:
//                                UIImagePickerControllerMediaURL] path];
//        
//        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath)) {
//            UISaveVideoAtPathToSavedPhotosAlbum (
//                                                 moviePath, nil, nil, nil);
//        }
        
        [[MFSideMenuManager sharedManager].navigationController dismissViewControllerAnimated:YES completion:nil];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hey!" message:@"We don't have video support yet..." delegate:nil cancelButtonTitle:@"OK..." otherButtonTitles: nil];
        [alert show];
        
    }
    
    [[picker parentViewController] dismissModalViewControllerAnimated: YES];
}


@end
