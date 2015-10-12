//
//  VideoPlayerViewController.m
//  VideoComapre
//
//  Created by Vishal Mishra, Gagan on 21/09/15.
//  Copyright (c) 2015 Vishal Mishra, Gagan. All rights reserved.
//

#import "VideoPlayerViewController.h"
#import "AVPlayerView.h"

@interface VideoPlayerViewController ()
{
    BOOL isSeaking;
}
@end
static void *VideoPlayerViewControllerRateObservationContext = &VideoPlayerViewControllerRateObservationContext;
static void *VideoPlayerViewControllerStatusObservationContext = &VideoPlayerViewControllerStatusObservationContext;
@implementation VideoPlayerViewController
@synthesize arrayOfVideoInformation;

-(void)viewDidLoad{
    [super viewDidLoad];
    restoreAfterScrubbingRate=1.0;  //Initially video has laying speed 1.0
    NSURL *fileURLFirst= [[self.arrayOfVideoInformation objectAtIndex:0] valueForKey:@"url"];
    NSURL *secondVideoURL=[[self.arrayOfVideoInformation objectAtIndex:1] valueForKey:@"url"];
    self.firstTitleLabel.text=fileURLFirst.path.lastPathComponent;
    self.secondTitleLabel.text=secondVideoURL.path.lastPathComponent;
    
    [self performSelector:@selector(hideShowFirstVideoTitles) withObject:nil afterDelay:1.0];
    [self performSelector:@selector(hideShowSecondVideoTitles) withObject:nil afterDelay:1.0];

    
    /*--------------------------------------------------------------------------First Video-------------------------------------------------------------------------*/
    AVURLAsset *assetFirst = [AVURLAsset URLAssetWithURL:fileURLFirst options:nil];
    NSArray *requestedKeysFirst = @[@"playable"];
    [assetFirst loadValuesAsynchronouslyForKeys:requestedKeysFirst completionHandler:
     ^{
         dispatch_async( dispatch_get_main_queue(),
                        ^{
                            [self prepareToPlayAsset:assetFirst withKeys:requestedKeysFirst forPlayerItem:0];
                            /*--------------------------------------------------------------------------Second Video-------------------------------------------------------------------------*/
                            AVURLAsset *assetSecond = [AVURLAsset URLAssetWithURL:secondVideoURL options:nil];
                            NSArray *requestedKeysSecond = @[@"playable"];
                            [assetSecond loadValuesAsynchronouslyForKeys:requestedKeysSecond completionHandler:
                             ^{
                                 dispatch_async( dispatch_get_main_queue(),
                                                ^{
                                                    [self prepareToPlayAsset:assetSecond withKeys:requestedKeysSecond forPlayerItem:1];
                                                });
                             }];
                            
                            
                        });
     }];
    
    [self initScrubberTimerForSlider:self.firstScrubberLabel];
    [self initScrubberTimerForSlider:self.secondScrubberLabel];
    
    [self syncFirstScrubber];   //First Slider Tag
    [self syncSecondScrubber];  //Second Slider Tag
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

//Show & Hide title labels with fade
-(void)hideShowFirstVideoTitles
{
    if(self.firstTitleLabel.alpha==0.0)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        self.firstTitleLabel.alpha=1.0;
        [UIView commitAnimations];
    }
    else{
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        self.firstTitleLabel.alpha=0.0;
        [UIView commitAnimations];
    }
}

-(void)hideShowSecondVideoTitles
{
    if(self.secondTitleLabel.alpha==0.0)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        self.secondTitleLabel.alpha=1.0;
        [UIView commitAnimations];
    }
    else{
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        self.secondTitleLabel.alpha=0.0;
        [UIView commitAnimations];
    }
}


#pragma -mark init Slider
-(void)initScrubberTimerForSlider:(UISlider*)scrubber
{
    double intreval =.1f;
    CMTime playerDuration;
    if(scrubber.tag==10)
    {
        playerDuration=[self  playerItemDurationForPlayer:self.firstPlayer];
    }
    else{
        playerDuration=[self  playerItemDurationForPlayer:self.secondPlayer];
    }
    if(CMTIME_IS_INVALID(playerDuration))
    {
        return;
    }
    double duration= CMTimeGetSeconds(playerDuration);
    if(isfinite(duration))
    {
        float width = CGRectGetWidth(scrubber.bounds);
        intreval=0.5f*duration/width;
    }
    
    __weak VideoPlayerViewController *weakSelf = self;
    
    if(scrubber.tag==10)
    {
        timeObserverFirst = [self.firstPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(intreval, NSEC_PER_SEC) queue:NULL /* If you pass NULL, the main queue is used. */usingBlock:^(CMTime time)
                             {
                                 [weakSelf syncFirstScrubber];
                             }];
    }
    else if (scrubber.tag==20){
        timeObserverSecond = [self.secondPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(intreval, NSEC_PER_SEC) queue:NULL /* If you pass NULL, the main queue is used. */usingBlock:^(CMTime time)
                              {
                                  [weakSelf syncSecondScrubber];
                              }];
    }
}

-(void)syncFirstScrubber
{
    CMTime playerDuration=[self  playerItemDurationForPlayer:self.firstPlayer];
    if(CMTIME_IS_INVALID(playerDuration))
    {
        self.firstScrubberLabel.minimumValue=0.0;
        return;
    }
    double duration = CMTimeGetSeconds(playerDuration);
    if(isfinite(duration))
    {
        float minValue =self.firstScrubberLabel.minimumValue;
        float maxValue=self.firstScrubberLabel.maximumValue;
        double time= CMTimeGetSeconds([self.firstPlayer currentTime]);
        double totalTime =CMTimeGetSeconds(playerDuration);
        self.firstTimerLabel.text=[NSString stringWithFormat:@"%.2f/%.2f",time,totalTime];
        float value=(maxValue - minValue) * time / duration + minValue;
        [self.firstScrubberLabel setValue:value];
    }
}

-(void)syncSecondScrubber
{
    CMTime playerDuration=[self  playerItemDurationForPlayer:self.secondPlayer];
    if(CMTIME_IS_INVALID(playerDuration))
    {
        self.secondScrubberLabel.minimumValue=0.0;
        return;
    }
    double duration = CMTimeGetSeconds(playerDuration);
    if(isfinite(duration))
    {
        float minValue =self.secondScrubberLabel.minimumValue;
        float maxValue=self.secondScrubberLabel.maximumValue;
        double time= CMTimeGetSeconds([self.secondPlayer currentTime]);
        double totalTime =CMTimeGetSeconds(playerDuration);
        self.secondTimerlabel.text=[NSString stringWithFormat:@"%.2f/%.2f",time,totalTime];
        float value=(maxValue - minValue) * time / duration + minValue;
        [self.secondScrubberLabel setValue:value];
    }
}


-(CMTime)playerItemDurationForPlayer:(AVPlayer*)player
{
    AVPlayerItem *playerItem=[player currentItem];
    if(playerItem.status ==AVPlayerItemStatusReadyToPlay)
    {
        return [playerItem duration];
    }
    return kCMTimeInvalid;
}

#pragma -mark Slider Scrbbing
- (IBAction)scrubbingBegins:(id)sender {
    if([sender tag]==10)
    {
        [self.firstPlayer setRate:0.0];
        [self removePlayerTimeObserver:10];
    }
    else if ([sender tag]==20){
        [self.secondPlayer setRate:0.0];
        [self removePlayerTimeObserver:20];
    }
}

- (IBAction)scrubbingEnd:(id)sender {
    AVPlayer *player=nil;
    if([sender tag]==10 && !timeObserverFirst)
    {
        player=self.firstPlayer;
    }
    else if ([sender tag]==20 && !timeObserverSecond)
    {
        player=self.secondPlayer;
    }
    if(player)
    {
        UISlider *slider =(UISlider*)sender;
        CMTime playerDuration=[self  playerItemDurationForPlayer:player];
        if(CMTIME_IS_INVALID(playerDuration))
        {
            return;
        }
        double duration = CMTimeGetSeconds(playerDuration);
        if(isfinite(duration))
        {
            CGFloat width = CGRectGetWidth([slider bounds]);
            double tolerance = 0.5f * duration / width;
            
            __weak VideoPlayerViewController *weakSelf = self;
            if(slider.tag==10)
            {
                timeObserverFirst = [self.firstPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC) queue:NULL usingBlock:^(CMTime time)
                                     {
                                         [weakSelf syncFirstScrubber];
                                     }];
            }
            else if (slider.tag==20){
                timeObserverSecond = [self.secondPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC) queue:NULL usingBlock:^(CMTime time)
                                      {
                                          [weakSelf syncSecondScrubber];
                                      }];
            }
        }
    }
}

- (IBAction)scrubbing:(id)sender {
    if([sender isKindOfClass:[UISlider class]] && !isSeaking)
    {
        isSeaking=YES;
        UISlider *slider =(UISlider*)sender;
        
        AVPlayer *player;
        if(slider.tag==10)
        {
            player=self.firstPlayer;
        }
        else{
            player=self.secondPlayer;
        }
        CMTime playerDuration=[self  playerItemDurationForPlayer:player];
        
        if(CMTIME_IS_INVALID(playerDuration))
        {
            return;
        }
        
        double duration = CMTimeGetSeconds(playerDuration);
        if(isfinite(duration))
        {
            float minValue =slider.minimumValue;
            float maxValue=slider.maximumValue;
            float value = [slider value];
            
            double time = duration * (value - minValue) / (maxValue - minValue);
            
            [player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    isSeaking = NO;
                });
            }];
        }
    }
}

-(void)removePlayerTimeObserver:(int)itemTag
{
    if(itemTag==10)
    {
        @try{
            [self.firstPlayer removeTimeObserver:timeObserverFirst];
        }
        @catch(id anException)
        {
            
        }
    }
    else if(itemTag==20)
    {
        @try{
            [self.secondPlayer removeTimeObserver:timeObserverSecond];
        }
        @catch(id anException)
        {
            
        }
    }
}

#pragma -mark TapGesture On VideoPlayerView
- (IBAction)playPauseButtonPressed:(id)sender {
    UIView *senderView =[sender view];
    if([senderView isEqual:self.videoPlayerBackViewFirst])
    {
        if(self.firstPlayer.rate>0)
        {
            [self.firstPlayer pause];
        }
        else{
            [self.firstPlayer play];
        }
        [self hideShowFirstVideoTitles];
    }
    else if ([senderView isEqual:self.videoPlayerBackViewSecond])
    {
        if(self.secondPlayer.rate>0)
        {
            [self.secondPlayer pause];
        }
        else{
            [self.secondPlayer play];
        }
        [self hideShowSecondVideoTitles];
    }
}

-(void)prepareToPlayAsset:(AVURLAsset*)assets withKeys:(NSArray*)requestedKeys forPlayerItem:(int)item
{
    AVPlayerItem *playerItem=nil;
    if(item==0)
    {
        playerItem=self.mPlayerItemFirst;
    }
    else
    {
        playerItem=self.mPlayerItemSecond;
    }
    for(NSString *keys in requestedKeys)
    {
        NSError *error;
        AVKeyValueStatus status=[assets statusOfValueForKey:keys error:&error];
        if(status==AVKeyValueStatusFailed)
        {
            [self assetsFailedToPlayback:error];
            return;
        }
    }
    
    if(!assets.playable)
    {
        NSString *localizedDescription = NSLocalizedString(@"Item can not play", @"Item can not be play");
        NSString *failureString = NSLocalizedString(@"Error description", @"Error in playing item");
        NSDictionary *errorDictionary =[NSDictionary dictionaryWithObjectsAndKeys:localizedDescription,NSLocalizedDescriptionKey, failureString, NSLocalizedFailureReasonErrorKey,nil];
        NSError *error=[NSError errorWithDomain:@"Failure description" code:0 userInfo:errorDictionary];
        [self assetsFailedToPlayback:error];
        return;
    }
    
    if(playerItem)
    {
        if(item==1)
            [playerItem removeObserver:self forKeyPath:@"status"];
        [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
    }
    playerItem=[AVPlayerItem playerItemWithAsset:assets];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playerItemDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    if(item==0)
    {
        [self setFIrstPlayer:[AVPlayer playerWithPlayerItem:playerItem]];
        self.mPlayerItemFirst=playerItem;
        [self.firstPlayer addObserver:self forKeyPath:@"rate"  options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:VideoPlayerViewControllerRateObservationContext];
        if(self.playerFirst.currentItem != playerItem)
        {
            [self.firstPlayer replaceCurrentItemWithPlayerItem:playerItem];
        }
    }
    else if(item==1){
        self.mPlayerItemSecond=playerItem;
        [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:VideoPlayerViewControllerStatusObservationContext];
        [self setSecondPlayer:[AVPlayer playerWithPlayerItem:playerItem]];
        [self.secondPlayer addObserver:self forKeyPath:@"rate"  options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:VideoPlayerViewControllerRateObservationContext];
        if(self.playerSecond.currentItem != playerItem)
        {
            [self.secondPlayer replaceCurrentItemWithPlayerItem:playerItem];
        }
    }
    
    [self.firstScrubberLabel setValue:0.0];
    [self.secondScrubberLabel setValue:0.0];
}

- (IBAction)rateButtonPressed:(id)sender {
    [self.firstPlayer pause];
    [self.secondPlayer pause];
    if([sender tag]==1)
    {
        if(restoreAfterScrubbingRate>0)
        {
            restoreAfterScrubbingRate=restoreAfterScrubbingRate-0.1;
        }
    }
    else if([sender tag]==2)
    {
        if(restoreAfterScrubbingRate<1)
        {
            restoreAfterScrubbingRate=restoreAfterScrubbingRate+0.1;
        }
    }
    [self.firstPlayer setRate:restoreAfterScrubbingRate];
    [self.secondPlayer setRate:restoreAfterScrubbingRate];
    [self.firstPlayer play];
    [self.secondPlayer play];
}

-(void)assetsFailedToPlayback:(NSError*)error
{
    [self removePlayerTimeObserver:10];
    [self removePlayerTimeObserver:20];
    [self syncFirstScrubber];
    [self syncSecondScrubber];
    NSLog(@"Error in playback : %@",error.localizedDescription);
}

-(void)playerItemDidEnd:(NSNotification*)notification
{
    AVPlayerItem *player = [notification object];
    if([player isEqual:self.mPlayerItemFirst])
    {
        [player seekToTime:kCMTimeZero];
        [self.firstPlayer play];
    }
    else if ([player isEqual:self.mPlayerItemSecond])
    {
        [player seekToTime:kCMTimeZero];
        [self.secondPlayer play];
    }
}

#pragma -mark observer
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(context==VideoPlayerViewControllerStatusObservationContext)
    {
        AVPlayerItemStatus status =[[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status) {
            case AVPlayerItemStatusUnknown:
            {
                [self removePlayerTimeObserver:10];
                [self removePlayerTimeObserver:20];
                
                [self syncFirstScrubber];
                [self syncSecondScrubber];
            }
                break;
            case AVPlayerItemStatusReadyToPlay:
            {
                [self initScrubberTimerForSlider:self.firstScrubberLabel];
                [self initScrubberTimerForSlider:self.secondScrubberLabel];
                [self.videoPlayerBackViewFirst  setPlayer:self.firstPlayer];
                [self.videoPlayerBackViewFirst  setVideoFillMode:AVLayerVideoGravityResizeAspectFill];
                [self setVideoMetadataForPlayer:self.firstPlayer];
                [self.videoPlayerBackViewSecond setPlayer:self.secondPlayer];
                [self.videoPlayerBackViewSecond  setVideoFillMode:AVLayerVideoGravityResizeAspectFill];
                [self setVideoMetadataForPlayer:self.secondPlayer];
                [self.firstPlayer play];
                [self.secondPlayer play];
            }
            case AVPlayerItemStatusFailed:
            {
                AVPlayerItem *playerItem=(AVPlayerItem*)object;
                [self assetsFailedToPlayback:playerItem.error];
            }
                break;
            default:
                break;
        }
    }
    else if (context==VideoPlayerViewControllerRateObservationContext)
    {
        [self initScrubberTimerForSlider:self.firstScrubberLabel];
        [self initScrubberTimerForSlider:self.secondScrubberLabel];
    }
}

-(void)setVideoMetadataForPlayer:(AVPlayer*)player
{
    for (AVMetadataItem* item in ([[[player currentItem] asset] commonMetadata]))
    {
        NSString* commonKey = [item commonKey];
        if ([commonKey isEqualToString:AVMetadataCommonKeyTitle])
        {
            if([player isEqual:self.firstPlayer])
            {
                self.firstTitleLabel.text = [item stringValue];
            }
            else if ([player isEqual:self.secondPlayer]){
                self.secondTitleLabel.text = [item stringValue];
            }
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    @try{
        [self.firstPlayer removeObserver:self forKeyPath:@"rate"];
    }
    @catch(id anException)
    {
        
    }
    
    @try{
        [self.secondPlayer removeObserver:self forKeyPath:@"rate"];
        [self.secondPlayer.currentItem removeObserver:self forKeyPath:@"status"];
    }
    @catch(id anException)
    {
        
    }
    
    [self.firstPlayer pause];
    [self.secondPlayer pause];
    
    [self removePlayerTimeObserver:10];
    [self removePlayerTimeObserver:20];
    
    [super viewWillDisappear:animated];
}

@end
