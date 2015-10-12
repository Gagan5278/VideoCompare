//
//  AVPlayerView.h
//  VideoComapre
//
//  Created by Vishal Mishra, Gagan on 22/09/15.
//  Copyright (c) 2015 Vishal Mishra, Gagan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVPlayer;
@interface AVPlayerView : UIView
@property(nonatomic,strong) AVPlayer *playerView;
-(void)setPlayer:(AVPlayer*)player;
-(void)setVideoFillMode:(NSString*)fillMode;
@end

