//
//  FlickrImagePageController.h
//  FlickrApp
//
//  Created by Mohit Jain on 6/15/13.
//  Copyright (c) 2013 Mohit Jain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlickrImagePageController : UIViewController<UIScrollViewDelegate> {
   
    
}

@property (weak, nonatomic) IBOutlet UIImageView *recipeImageView;
@property (weak, nonatomic) NSString *flickrImageName;
@property (nonatomic, strong) NSMutableArray *imageViews;
@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;
@property(nonatomic, weak)IBOutlet UIScrollView *scrollView;
@property(nonatomic, strong)NSNumber *selectedPage;


@end
