//
//  FlickrImagePageController.m
//  FlickrApp
//
//  Created by Mohit Jain on 6/15/13.
//  Copyright (c) 2013 Mohit Jain. All rights reserved.
//

#import "FlickrImagePageController.h"
#import "FlickrImageViewController.h"


@interface FlickrImagePageController ()

@end

@implementation FlickrImagePageController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
}


-(void)setup {
    
    NSUInteger numberPages = self.imageArray.count;
    
    // view controllers are created lazily
    // in the meantime, load the array with placeholders which will be replaced on demand
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < numberPages; i++)
    {
		[controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;
    
    // a page is the width of the scroll view
    self.scrollView.pagingEnabled = YES;
    self.scrollView.contentSize =
    CGSizeMake(CGRectGetWidth(self.view.frame) * numberPages, CGRectGetHeight(self.view.frame));
    self.scrollView.scrollsToTop = YES;
    self.scrollView.delegate = self;
    
    //       int selectedPage = [self.selectedPage integerValue];
    // pages are created on demand
    // load the visible page
    // load the page on either side to avoid flashes when the user starts scrolling
    
    
    //  [self loadAlbum];
    CGRect visibleRect = CGRectMake(320*self.selectedPage, 0, 320, 504);
    [self.scrollView scrollRectToVisible:visibleRect animated:NO];
    
    int selectedPage = self.selectedPage;
    if (selectedPage > 0)
    {
        [self loadScrollViewWithPage:selectedPage-1];
    }
    if (selectedPage < self.imageArray.count)
    {
        [self loadScrollViewWithPage:selectedPage+1];
    }
    [self loadScrollViewWithPage:selectedPage];
    
}

- (void) loadRequiredPages:(int) selectedPage
{
    if (selectedPage > 0)
    {
        [self loadScrollViewWithPage:selectedPage-1];
    }
    if (selectedPage < self.imageArray.count)
    {
        [self loadScrollViewWithPage:selectedPage+1];
    }
    [self loadScrollViewWithPage:selectedPage];
}

// rotation support for iOS 5.x and earlier, note for iOS 6.0 and later this will not be called
//
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    // return YES for supported orientations
    return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
#endif

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self loadAlbum];
}

- (void) loadAlbum {
    // remove all the subviews from our scrollview
    for (UIView *view in self.scrollView.subviews)
    {
        [view removeFromSuperview];
    }
    
    NSUInteger numPages = self.imageArray.count;
    
    // adjust the contentSize (larger or smaller) depending on the orientation
    self.scrollView.contentSize =
    CGSizeMake(CGRectGetWidth(self.scrollView.frame) * numPages, CGRectGetHeight(self.scrollView.frame));
    
    // clear out and reload our pages
    self.viewControllers = nil;
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < numPages; i++)
    {
		[controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;
    
    //    [self loadRequiredPages:self.pageControl.currentPage];
    [self loadRequiredPages:self.selectedPage];
    [self gotoPage:NO]; // remain at the same page (don't animate)
}

- (void)loadScrollViewWithPage:(NSUInteger)page
{
    if (page >= self.imageArray.count)
        return;
    
    // replace the placeholder if necessary
    FlickrImageViewController *controller = [self.viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null])
    {
        controller = [[FlickrImageViewController alloc] initWithPageNumber:page];
        controller.images = self.imageArray;
        controller.arrayWithImages = self.arrayWithImages;
        [self.viewControllers replaceObjectAtIndex:page withObject:controller];
    }
    
    // add the controller's view to the scroll view
    if (controller.view.superview == nil)
    {
        CGRect frame = self.view.frame;
        frame.origin.x = CGRectGetWidth(frame) * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        
        [self addChildViewController:controller];
        [self.scrollView addSubview:controller.view];
        [controller didMoveToParentViewController:self];
        
        NSDictionary *numberItem = [self.imageArray objectAtIndex:page];
        //     controller.numberImage.image = [UIImage imageNamed:[numberItem valueForKey:kImageKey]];
        //     controller.numberTitle.text = [numberItem valueForKey:kNameKey];
    }
}

// at the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    // switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = CGRectGetWidth(self.scrollView.frame);
    NSUInteger page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
    self.selectedPage = page;
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    //    // switch the indicator when more than 50% of the previous/next page is visible
    //    CGFloat pageWidth = CGRectGetWidth(self.scrollView.frame);
    //
    //    NSInteger page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    ////    self.pageControl.currentPage = page;
    //self.selectedPage = [NSNumber numberWithInteger:page];
    //    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    //    [self loadRequiredPages:page];
    
    // a possible optimization would be to unload the views+controllers which are no longer visible
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    NSLog(@"page...%d", page);
    //    [self loadScrollViewWithPage:page];
	
}

- (void)gotoPage:(BOOL)animated
{
    //    NSInteger page = self.pageControl.currentPage;
    //    NSInteger page = [self.selectedPage integerValue];
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadRequiredPages:self.selectedPage];
    
	// update the scroll view to the appropriate page
    CGRect bounds = self.scrollView.bounds;
    bounds.origin.x = CGRectGetWidth(bounds) * self.selectedPage;
    bounds.origin.y = 0;
    [self.scrollView scrollRectToVisible:bounds animated:animated];
}

- (IBAction)changePage:(id)sender
{
    
    [self gotoPage:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
