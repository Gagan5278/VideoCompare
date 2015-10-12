//
//  VideoPlayerViewController.h
//  VideoComapre
//
//  Created by Vishal Mishra, Gagan on 21/09/15.
//  Copyright (c) 2015 Vishal Mishra, Gagan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@class AVPlayerView;
@interface VideoPlayerViewController : UIViewController
{
    id timeObserverFirst;
    id timeObserverSecond;
    
    float restoreAfterScrubbingRate;
}
@property (weak, nonatomic) IBOutlet UILabel *firstTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *firstTimerLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondTimerlabel;

@property (strong) AVPlayerItem* mPlayerItemFirst;
@property (strong) AVPlayerItem* mPlayerItemSecond;

@property (readwrite, strong, setter=setFIrstPlayer:, getter=playerFirst) AVPlayer* firstPlayer;
@property (readwrite, strong, setter=setSecondPlayer:, getter=playerSecond) AVPlayer * secondPlayer;

@property (weak, nonatomic) IBOutlet UISlider *firstScrubberLabel;
@property (weak, nonatomic) IBOutlet UISlider *secondScrubberLabel;

@property(nonatomic,strong) NSMutableArray *arrayOfVideoInformation;

@property (weak, nonatomic) IBOutlet AVPlayerView *videoPlayerBackViewFirst;
@property (weak, nonatomic) IBOutlet AVPlayerView *videoPlayerBackViewSecond;


//Slider Scrubbing
- (IBAction)scrubbingBegins:(id)sender;
- (IBAction)scrubbingEnd:(id)sender;
- (IBAction)scrubbing:(id)sender;

//TapGesture Recognizer
- (IBAction)playPauseButtonPressed:(id)sender;

-(void)prepareToPlayAsset:(AVURLAsset*)assets withKeys:(NSArray*)requestedKeys forPlayerItem:(int)playerItem;


- (IBAction)rateButtonPressed:(id)sender; //Used to set playing rate of video
@end
