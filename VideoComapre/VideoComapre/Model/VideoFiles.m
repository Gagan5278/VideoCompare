//
//  VideoFiles.m
//  VideoComapre
//
//  Created by Vishal Mishra, Gagan on 18/09/15.
//  Copyright (c) 2015 Vishal Mishra, Gagan. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "VideoFiles.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"
@implementation VideoFiles
-(void)getArrayOfVideoFilesFromDevice:(void(^)(NSArray*))handler
{
    ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc]init];
    NSMutableArray *arrayOfVideo=[NSMutableArray array];
    _completionHandler=[handler copy];
    [assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if(group)
        {
            [group setAssetsFilter:[ALAssetsFilter allVideos]];
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if(result)
                {
                    NSMutableDictionary *dict =[NSMutableDictionary dictionary];
                    ALAssetRepresentation *representation =[result defaultRepresentation];
                    NSString *utiString =[representation UTI];
                    NSURL  *videoURL = [[result valueForProperty:ALAssetPropertyURLs] valueForKey:utiString];
                    NSString *title = [NSString stringWithFormat:@"video %d", arc4random()%100];
                    UIImage *image = [self imageFromVideoURL:videoURL];
                    [dict setValue:image forKey:@"image"];
                    [dict setValue:title forKey:@"name"];
                    [dict setValue:videoURL forKey:@"url"];
                    [arrayOfVideo addObject:dict];
                }
                else if (result==nil && arrayOfVideo.count>0)
                {
                    _completionHandler(arrayOfVideo);
                }
            }];
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"error is : %@",error.localizedDescription);
    }];
}

-(UIImage*)imageFromVideoURL:(NSURL*)videoURL
{
    AVURLAsset *asset1 = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset1];    generator.appliesPreferredTrackTransform = YES;
    //Set the time and size of thumbnail for image
    NSError *err = NULL;
    CMTime thumbTime = CMTimeMakeWithSeconds(0,1);
    CGSize maxSize = CGSizeMake(200,200);
    generator.maximumSize = maxSize;
    CGImageRef imgRef = [generator copyCGImageAtTime:thumbTime actualTime:NULL error:&err];
    UIImage *thumbnail = [[UIImage alloc] initWithCGImage:imgRef];
    return thumbnail;
}

-(NSArray*)getArrayOfVideosFromDocumentDirectory
{
    AppDelegate *objAppDel=[[UIApplication sharedApplication] delegate];
    NSString *pathString=[objAppDel aplicationCustomDicumentDirectory];
    NSArray *array=[[NSFileManager defaultManager]contentsOfDirectoryAtPath:pathString error:nil];
    if(array!=nil)
   {
        NSMutableArray *arrayOfVideos=[NSMutableArray array];
        for(NSString *filePath in array)
        {
            NSMutableDictionary *dict =[NSMutableDictionary dictionary];
            NSURL  *videoURL=[NSURL fileURLWithPath:[ pathString stringByAppendingPathComponent: filePath]];
            UIImage *image = [self imageFromVideoURL:videoURL];
            [dict setValue:image forKey:@"image"];
            [dict setValue:filePath.lastPathComponent forKey:@"name"];
            [dict setValue:videoURL forKey:@"url"];
            [arrayOfVideos addObject:dict];
        }
       return arrayOfVideos;
    }
    else{
        return nil;
    }
}
@end
