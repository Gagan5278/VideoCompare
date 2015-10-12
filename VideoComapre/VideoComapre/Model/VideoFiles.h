//
//  VideoFiles.h
//  VideoComapre
//
//  Created by Vishal Mishra, Gagan on 18/09/15.
//  Copyright (c) 2015 Vishal Mishra, Gagan. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface VideoFiles : NSObject
{
    void (^_completionHandler)(NSArray *arrayOfVideoItems);
}
-(void)getArrayOfVideoFilesFromDevice:(void(^)(NSArray*))handler;

-(NSArray*)getArrayOfVideosFromDocumentDirectory;

-(UIImage*)imageFromVideoURL:(NSURL*)videoURL;
@end
