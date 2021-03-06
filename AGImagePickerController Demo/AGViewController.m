//
//  AGViewController.m
//  AGImagePickerController Demo
//
//  Created by Artur Grigor on 2/16/12.
//  Copyright (c) 2012 - 2013 Artur Grigor. All rights reserved.
//

#import "AGViewController.h"

#import "AGIPCToolbarItem.h"

@interface AGViewController ()
{
    AGImagePickerController *ipc;
}

@end

@implementation AGViewController

#pragma mark - Properties

@synthesize selectedPhotos;

#pragma mark - Object Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.selectedPhotos = [NSMutableArray array];
        
        __block AGViewController *blockSelf = self;
        
        ipc = [AGImagePickerController sharedInstance:self];
        ipc.didFailBlock = ^(NSError *error) {
            NSLog(@"Fail. Error: %@", error);
            
            if (error == nil) {
                [blockSelf.selectedPhotos removeAllObjects];
                NSLog(@"User has cancelled.");
                
                [blockSelf dismissViewControllerAnimated:YES completion:NULL];
            } else {
                
                // We need to wait for the view controller to appear first.
                double delayInSeconds = 0.5;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [blockSelf dismissViewControllerAnimated:YES completion:NULL];
                });
            }
            
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
            
        };
        ipc.didFinishBlock = ^(NSArray *info) {
            [blockSelf.selectedPhotos setArray:info];
            
            NSLog(@"Info: %@", info);
            [blockSelf dismissViewControllerAnimated:YES completion:NULL];
            
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        };
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.view.frame = [UIScreen mainScreen].bounds;
    
    NSLog(@"self.view %@", self.view);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - Public methods

- (void)openAction:(id)sender
{    
    // Show saved photos on top
    ipc.shouldShowSavedPhotosOnTop = NO;
    ipc.shouldChangeStatusBarStyle = YES;
    ipc.selection = self.selectedPhotos;
    ipc.maximumNumberOfPhotosToBeSelected = 9;
    
    // Custom toolbar items
    AGIPCToolbarItem *selectAll = [[AGIPCToolbarItem alloc] initWithBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"+ Select All" style:UIBarButtonItemStyleBordered target:nil action:nil] andSelectionBlock:^BOOL(NSUInteger index, ALAsset *asset) {
        return YES;
    }];
    AGIPCToolbarItem *flexible = [[AGIPCToolbarItem alloc] initWithBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] andSelectionBlock:nil]; 
    AGIPCToolbarItem *selectOdd = [[AGIPCToolbarItem alloc] initWithBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"+ Select Odd" style:UIBarButtonItemStyleBordered target:nil action:nil] andSelectionBlock:^BOOL(NSUInteger index, ALAsset *asset) {
        return !(index % 2);
    }];
    AGIPCToolbarItem *deselectAll = [[AGIPCToolbarItem alloc] initWithBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"- Deselect All" style:UIBarButtonItemStyleBordered target:nil action:nil] andSelectionBlock:^BOOL(NSUInteger index, ALAsset *asset) {
        return NO;
    }];  
    ipc.toolbarItemsForManagingTheSelection = @[selectAll, flexible, selectOdd, flexible, deselectAll];

    [self presentViewController:ipc animated:YES completion:NULL];
    
    // Show first assets list, modified by springox(20140503)
    [ipc showFirstAssetsController];
    
    //// Show assets list with name, added by springox(20150719)
    //[ipc showAssetsControllerWithName:@"Camera Roll"];
}

#pragma mark - AGImagePickerControllerDelegate methods

- (NSUInteger)agImagePickerController:(AGImagePickerController *)picker
   numberOfItemsPerRowForDevice:(AGDeviceType)deviceType
        andInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (deviceType == AGDeviceTypeiPad)
    {
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation))
            return 11;
        else
            return 8;
    } else {
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
            if (480 == self.view.bounds.size.width) {
                return 6;
            }
            return 7;
        } else
            return 4;
    }
}

- (BOOL)agImagePickerController:(AGImagePickerController *)picker shouldDisplaySelectionInformationInSelectionMode:(AGImagePickerControllerSelectionMode)selectionMode
{
    return (selectionMode == AGImagePickerControllerSelectionModeSingle ? NO : YES);
}

- (BOOL)agImagePickerController:(AGImagePickerController *)picker shouldShowToolbarForManagingTheSelectionInSelectionMode:(AGImagePickerControllerSelectionMode)selectionMode
{
    return (selectionMode == AGImagePickerControllerSelectionModeSingle ? NO : YES);    
}

- (AGImagePickerControllerSelectionBehaviorType)selectionBehaviorInSingleSelectionModeForAGImagePickerController:(AGImagePickerController *)picker
{
    return AGImagePickerControllerSelectionBehaviorTypeRadio;
}

@end
