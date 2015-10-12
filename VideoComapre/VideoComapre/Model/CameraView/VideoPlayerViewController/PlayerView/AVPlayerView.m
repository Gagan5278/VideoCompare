//
//  AVPlayerView.m
//  VideoComapre
//
//  Created by Vishal Mishra, Gagan on 22/09/15.
//  Copyright (c) 2015 Vishal Mishra, Gagan. All rights reserved.
//

#import "AVPlayerView.h"
#import <AVFoundation/AVFoundation.h>

@implementation AVPlayerView
-(void)setPlayer:(AVPlayer*)player
{
     [(AVPlayerLayer*)[self layer] setPlayer:player];
}

-(void)setVideoFillMode:(NSString*)fillMode
{
    AVPlayerLayer *player=(AVPlayerLayer*)[self layer];
    player.videoGravity=fillMode;
}

+(Class)layerClass
{
    return [AVPlayerLayer class];
}

- (AVPlayer*)player
{
    return [(AVPlayerLayer*)[self layer] player];
}


@end
