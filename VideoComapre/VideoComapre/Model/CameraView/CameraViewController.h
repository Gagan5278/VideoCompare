//
//  CameraViewController.h
//  VideoComapre
//
//  Created by Vishal Mishra, Gagan on 21/09/15.
//  Copyright (c) 2015 Vishal Mishra, Gagan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *thumbImageView;
@property (weak, nonatomic) IBOutlet UITextField *videoTitleTesrField;


- (IBAction)cameraButtonPressed:(id)sender;

@end
