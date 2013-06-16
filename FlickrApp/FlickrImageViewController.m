//
//  FlickrImageViewController.m
//  FlickrApp
//
//  Created by Mohit Jain on 6/15/13.
//  Copyright (c) 2013 Mohit Jain. All rights reserved.
//

#import "FlickrImageViewController.h"


@interface FlickrImageViewController ()
{
    int pageNumber;
    
}

@end

@implementation FlickrImageViewController


// load the view nib and initialize the pageNumber ivar
//- (id)initWithPageNumber:(NSUInteger)page image:(UIImage *)img
- (id)initWithPageNumber:(NSUInteger)page
{
    if (self = [super initWithNibName:@"FlickrImageViewController" bundle:nil])
    {
        pageNumber = page;
        //[self.numberImage setImage:img];
    }
    return self;
}

// set the label and background color when the view has finished loading
- (void)viewDidLoad
{
    self.pageNumberLabel.text = [NSString stringWithFormat:@"Page %d", pageNumber + 1];
    self.numberImage.image = [UIImage imageNamed:[self.images objectAtIndex:pageNumber]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
