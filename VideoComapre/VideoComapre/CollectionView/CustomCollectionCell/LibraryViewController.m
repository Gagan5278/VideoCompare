//
//  LibraryViewController.m
//  VideoComapre
//
//  Created by Vishal Mishra, Gagan on 18/09/15.
//  Copyright (c) 2015 Vishal Mishra, Gagan. All rights reserved.
//

#import "LibraryViewController.h"
#import "CustomCollectionCell.h"
#import "VideoFiles.h"
#import "VideoPlayerViewController.h"

#define cellIdentifier @"CellIdentifier"
@interface LibraryViewController()
@property(nonatomic,strong) NSMutableDictionary *dictionaryOfSelectedVideos;
@property(nonatomic,strong)NSMutableArray *arrayOfVideos;
@end
@implementation LibraryViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    self.arrayOfVideos=[NSMutableArray array];
    [self resetViewsInCollectionView];
    [self fetchAllVideos];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)fetchAllVideos
{
    self.dictionaryOfSelectedVideos=[NSMutableDictionary dictionary];
    self.playBarButton.enabled=NO;
    VideoFiles *objectVideo=  [[VideoFiles alloc]init];
    [objectVideo getArrayOfVideoFilesFromDevice:^(NSArray *resultArray)
     {
         [self.activityViewController stopAnimating];
         if(resultArray.count==0)
         {
             [self.collectionView reloadData];
             UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Message" message:@"No video found from phone library" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
             [alertView show];
             alertView=nil;
         }
         else
         {
             [self.arrayOfVideos addObjectsFromArray:resultArray];
             [self.collectionView reloadData];
         }
     }];
    NSArray *arrayData=[objectVideo getArrayOfVideosFromDocumentDirectory];
    if(arrayData!=nil && arrayData.count>0)
    {
        if(arrayData.count==0)
        {
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Message" message:@"No videos from user" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
            alertView=nil;
        }
        else
        {
            [self.arrayOfVideos addObjectsFromArray:arrayData];
        }
    }
}

-(void)resetViewsInCollectionView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.title=@"User";
        CGRect frame = [[UIScreen mainScreen] bounds];
        int width = frame.size.width;
        int numberOfItems = width/150;
        float remainingWidth = width-numberOfItems*150;
        remainingWidth=remainingWidth/numberOfItems;
        self.collectionViewFlowlayout.minimumInteritemSpacing=remainingWidth/numberOfItems;
        UIEdgeInsets edgeInset= self.collectionViewFlowlayout.sectionInset;
        edgeInset.left=remainingWidth/numberOfItems;
        edgeInset.right=remainingWidth/numberOfItems;
        self.collectionViewFlowlayout.sectionInset=edgeInset;
    });
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.arrayOfVideos.count;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCollectionCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.layer.borderWidth=2.0;
    cell.layer.cornerRadius=2.0;
    cell.layer.borderColor=[UIColor grayColor].CGColor;
    cell.titleLabel.text=[self.arrayOfVideos[indexPath.row] valueForKey:@"name"];
    cell.titleLabel.textColor=[UIColor whiteColor];
    NSString *cellString =[NSString stringWithFormat:@"%ld",(long)indexPath.row];
    if([self.dictionaryOfSelectedVideos objectForKey:cellString]==nil)
    {
        [cell.selectedVideButton setSelected:NO];
    }
    else{
        [cell.selectedVideButton setSelected:YES];
    }
    cell.selectedVideButton.tag=indexPath.row;
    cell.thumbnailImageView.image=(UIImage*)([self.arrayOfVideos[indexPath.row] valueForKey:@"image"]);
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellString =[NSString stringWithFormat:@"%ld",(long)indexPath.row];
    if([self.dictionaryOfSelectedVideos valueForKey:cellString]==nil && self.dictionaryOfSelectedVideos.count>=2)
    {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"message" message:@"Maximum two videos allowed for playing" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        alertView=nil;
    }
    else{
        if([self.dictionaryOfSelectedVideos objectForKey:cellString]==nil)
        {
            [self.dictionaryOfSelectedVideos setObject:cellString forKey:cellString];
        }
        else{
            [self.dictionaryOfSelectedVideos removeObjectForKey:cellString];
        }
        if(self.dictionaryOfSelectedVideos.count==2)
        {
            self.playBarButton.enabled=YES;
        }
        else{
            self.playBarButton.enabled=NO;
        }
        [self.collectionView reloadData];
    }
}

#pragma -mark Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    VideoPlayerViewController *objectViewController=segue.destinationViewController;
    NSMutableArray *arrayData =[NSMutableArray array];
    for(NSString *key in self.dictionaryOfSelectedVideos)
    {
        [arrayData addObject:[self.arrayOfVideos objectAtIndex:[key integerValue]]];
    }
    objectViewController.arrayOfVideoInformation=[arrayData copy];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    [self resetViewsInCollectionView];
}

-(void)viewWillDisappear:(BOOL)animated
{
    //    self.title=nil;
    [super viewWillDisappear:animated];
}
@end
