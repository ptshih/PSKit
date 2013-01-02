//
//  UIActionSheet+MKBlockAdditions.m
//  UIKitCategoryAdditions
//
//  Created by Mugunth on 21/03/11.
//  Copyright 2011 Steinlogic All rights reserved.
//

#import "UIActionSheet+MKBlockAdditions.h"

static DismissBlock _dismissBlock;
static CancelBlock _cancelBlock;
static PhotoPickedBlock _photoPickedBlock;
static UIViewController *_presentVC;
static UIPopoverController *_popoverVC;

@implementation UIActionSheet (MKBlockAdditions)

+(void) actionSheetWithTitle:(NSString*) title
                     message:(NSString*) message
                     buttons:(NSArray*) buttonTitles
                  showInView:(UIView*) view
                   onDismiss:(DismissBlock) dismissed                   
                    onCancel:(CancelBlock) cancelled
{    
    [UIActionSheet actionSheetWithTitle:title 
                                message:message 
                 destructiveButtonTitle:nil 
                                buttons:buttonTitles 
                             showInView:view 
                              onDismiss:dismissed 
                               onCancel:cancelled];
}

+ (void) actionSheetWithTitle:(NSString*) title                     
                      message:(NSString*) message          
       destructiveButtonTitle:(NSString*) destructiveButtonTitle
                      buttons:(NSArray*) buttonTitles
                   showInView:(UIView*) view
                    onDismiss:(DismissBlock) dismissed                   
                     onCancel:(CancelBlock) cancelled
{
    [_cancelBlock release];
    _cancelBlock  = [cancelled copy];
    
    [_dismissBlock release];
    _dismissBlock  = [dismissed copy];

    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title 
                                                             delegate:(id)[self class]
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:destructiveButtonTitle 
                                                    otherButtonTitles:nil];
    
    for(NSString* thisButtonTitle in buttonTitles)
        [actionSheet addButtonWithTitle:thisButtonTitle];
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
    actionSheet.cancelButtonIndex = [buttonTitles count];
    
    if(destructiveButtonTitle)
        actionSheet.cancelButtonIndex ++;
    
    if([view isKindOfClass:[UIView class]])
        [actionSheet showInView:view];
    
    if([view isKindOfClass:[UITabBar class]])
        [actionSheet showFromTabBar:(UITabBar*) view];
    
    if([view isKindOfClass:[UIBarButtonItem class]])
        [actionSheet showFromBarButtonItem:(UIBarButtonItem*) view animated:YES];
    
    [actionSheet release];
    
}

+ (void) photoPickerWithTitle:(NSString*) title
                   showInView:(UIView*) view
                    presentVC:(UIViewController*) presentVC
                onPhotoPicked:(PhotoPickedBlock) photoPicked                   
                     onCancel:(CancelBlock) cancelled
{
    [_cancelBlock release];
    _cancelBlock  = [cancelled copy];
    
    [_photoPickedBlock release];
    _photoPickedBlock  = [photoPicked copy];
    
    [_presentVC release];
    _presentVC = [presentVC retain];
    
    int cancelButtonIndex = -1;

    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title 
                                                             delegate:(id)[self class] 
													cancelButtonTitle:nil
											   destructiveButtonTitle:nil
													otherButtonTitles:nil];

	if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
	{
		[actionSheet addButtonWithTitle:NSLocalizedString(@"Camera", @"")];
		cancelButtonIndex ++;
	}
	if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
	{
		[actionSheet addButtonWithTitle:NSLocalizedString(@"Photo library", @"")];
		cancelButtonIndex ++;
	}
    
	[actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
	cancelButtonIndex ++;
	
    actionSheet.tag = kPhotoActionSheetTag;
	actionSheet.cancelButtonIndex = cancelButtonIndex;		 

	if([view isKindOfClass:[UIView class]])
        [actionSheet showInView:view];
    
    if([view isKindOfClass:[UITabBar class]])
        [actionSheet showFromTabBar:(UITabBar*) view];
    
    if([view isKindOfClass:[UIBarButtonItem class]])
        [actionSheet showFromBarButtonItem:(UIBarButtonItem*) view animated:YES];
    
    [actionSheet release];    
}

+ (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    _cancelBlock();
}


+ (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *editedImage = (UIImage*) [info valueForKey:UIImagePickerControllerEditedImage];
    if(!editedImage)
        editedImage = (UIImage*) [info valueForKey:UIImagePickerControllerOriginalImage];
    
    _photoPickedBlock(editedImage);
    if (isDeviceIPad()) {
        [_popoverVC dismissPopoverAnimated:YES];
    } else {
        [picker dismissModalViewControllerAnimated:YES];
    }
	[picker autorelease];
}


+ (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    // Dismiss the image selection and close the program
    if (isDeviceIPad()) {
        [_popoverVC dismissPopoverAnimated:YES];
    } else {
        [picker dismissModalViewControllerAnimated:YES];
    }
	[picker autorelease];
    [_presentVC release];
    _cancelBlock();
}

+(void)actionSheet:(UIActionSheet*) actionSheet didDismissWithButtonIndex:(NSInteger) buttonIndex
{
	if(buttonIndex == [actionSheet cancelButtonIndex])
	{
		_cancelBlock();
	}
    else
    {
        if(actionSheet.tag == kPhotoActionSheetTag)
        {
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                buttonIndex ++;
            }
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
            {
                buttonIndex ++;
            }
            
            
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = (id)[self class];
            picker.allowsEditing = NO;
//            
//            NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
//            if ([availableMediaTypes containsObject:(NSString *)kUTTypeImage]) {
//                picker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
//            }
            
            if(buttonIndex == 1) 
            {                
                picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
            else if(buttonIndex == 2)
            {
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;;
            }
            
//            [_presentVC presentViewController:picker animated:YES completion:NULL];
            if (isDeviceIPad()) {
                _popoverVC = [[UIPopoverController alloc] initWithContentViewController:picker];
                _popoverVC.delegate = self;
                [_popoverVC presentPopoverFromRect:CGRectZero inView:_presentVC.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            } else {
                [_presentVC presentModalViewController:picker animated:YES];
            }
        }
        else
        {
            _dismissBlock(buttonIndex, nil);
        }
    }
}
@end
