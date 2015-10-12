//
//  LibraryViewController.h
//  VideoComapre
//
//  Created by Vishal Mishra, Gagan on 18/09/15.
//  Copyright (c) 2015 Vishal Mishra, Gagan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LibraryViewController : UICollectionViewController
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *collectionViewFlowlayout;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityViewController;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *playBarButton;

@end
