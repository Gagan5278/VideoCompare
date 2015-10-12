//
//  CameraViewController.m
//  VideoComapre
//
//  Created by Vishal Mishra, Gagan on 21/09/15.
//  Copyright (c) 2015 Vishal Mishra, Gagan. All rights reserved.
//

#import "CameraViewController.h"
#import "AppDelegate.h"
#import "VideoFiles.h"
#import <MobileCoreServices/MobileCoreServices.h>
@interface CameraViewController()<UITextFieldDelegate>
{
    UIImagePickerController *imagePickerComtroller;
    NSURL *recordVideoURL;
}
@property(nonatomic,strong)  UIImagePickerController *imagePickerComtroller;
@end
@implementation CameraViewController
@synthesize imagePickerComtroller;

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.videoTitleTesrField.hidden=YES;
    self.thumbImageView.hidden=YES;
    self.thumbImageView.layer.cornerRadius=2.0;
    self.thumbImageView.layer.borderColor=[UIColor whiteColor].CGColor;
    self.thumbImageView.layer.borderWidth=2.0;
}

- (IBAction)cameraButtonPressed:(id)sender {
    self.imagePickerComtroller=[[UIImagePickerController alloc]init];
    self.imagePickerComtroller.delegate=self;
    [self.imagePickerComtroller setSourceType:UIImagePickerControllerSourceTypeCamera];
    self.imagePickerComtroller.mediaTypes=@[(NSString*)kUTTypeMovie];
    [self presentViewController:self.imagePickerComtroller animated:YES completion:nil];
}

#pragma -mark ImagePicker Delegates
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    recordVideoURL=[[info valueForKey:UIImagePickerControllerMediaURL] copy];
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Message" message:@"Do you want to save video file?" delegate:self cancelButtonTitle:nil otherButtonTitles:@"No", @"Save", nil];
    [alertView show];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma -mark AlertView Delegate
-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title=[alertView buttonTitleAtIndex:buttonIndex];
    if([title caseInsensitiveCompare:@"Save"]==NSOrderedSame)
    {
        NSDate *curDate =[NSDate date];
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd:HH:mm:ss"];
        NSString *stringDate= [dateFormatter stringFromDate:curDate];
       stringDate= [stringDate stringByReplacingOccurrencesOfString:@"-" withString:@""];
        NSData *videoData =[NSData dataWithContentsOfURL:recordVideoURL];
        NSString *path=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        path=[path stringByAppendingPathComponent:@"UserVideos"];
        if(![[NSFileManager defaultManager]fileExistsAtPath:path])
        {
            [[NSFileManager defaultManager]createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
        }
        path=[path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",stringDate]];
       if( [videoData writeToFile:path atomically:NO])
       {
           self.videoTitleTesrField.hidden=NO;
           self.thumbImageView.hidden=NO;
           NSLog(@"File Created Successfully");
           self.videoTitleTesrField.text=stringDate;
           VideoFiles *object=[[VideoFiles alloc]init];
           self.thumbImageView.image=[object imageFromVideoURL:[NSURL fileURLWithPath:path]];
       }
    }
}

#pragma -textField Delegates
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

@end
