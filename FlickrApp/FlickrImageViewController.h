//
//  FlickrImageViewController.h
//  FlickrApp
//
//  Created by Mohit Jain on 6/15/13.
//  Copyright (c) 2013 Mohit Jain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlickrImageViewController : UIViewController

@property (nonatomic, strong) IBOutlet UILabel *photoTitle;

@property (nonatomic, strong) IBOutlet UILabel *author;
@property (nonatomic, strong) IBOutlet UIImageView *numberImage;
@property (nonatomic, strong) NSArray *images;

//- (id)initWithPageNumber:(NSUInteger)page image:(UIImage *)img;
- (id)initWithPageNumber:(NSUInteger)page;
@end
