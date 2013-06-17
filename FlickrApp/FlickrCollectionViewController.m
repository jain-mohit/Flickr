//
//  FlickrCollectionViewController.m
//  FlickrApp
//
//  Created by Mohit Jain on 6/15/13.
//  Copyright (c) 2013 Mohit Jain. All rights reserved.
//

#import "FlickrCollectionViewController.h"
#import "FlickrHeaderView.h"
#import "FlickrViewCell.h"
#import "FlickrImagePageController.h"
#import "FlickrWebRequest.h"
#import "JSON/JSON.h"



@interface FlickrCollectionViewController () {
    NSArray *flickrImages;
    BOOL shareEnabled;
    NSMutableArray *selectedPics;
    NSMutableArray *randomPics;
    NSMutableArray *arrayWithImages;
}

@end

@implementation FlickrCollectionViewController
@synthesize dictionary, loadingAlertView, flickrArray,items;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)fetchUsingASIHTTP {
    FlickrWebRequest *webRequest = [FlickrWebRequest sharedInstance];
    
    NSString *fetchedString = [webRequest fetchPhoto];

    dictionary = [fetchedString JSONValue];
     NSLog(@"%@", dictionary);
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Refresh" style:UIBarButtonItemStylePlain target:self action:@selector(loadFromFlickr)];
    self.navigationItem.rightBarButtonItem = anotherButton;
    [self loadFromFlickr];
    
	// Do any additional setup after loading the view.
}


-(void)loadFromFlickr {
   [self fetchUsingASIHTTP];
 //   [self fetch];
    randomPics = [[NSMutableArray alloc]init];
    arrayWithImages = [[NSMutableArray alloc]init];
    [self parseData];
    
    flickrImages = [NSArray arrayWithObjects:randomPics, nil];
    
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    collectionViewLayout.sectionInset = UIEdgeInsetsMake(20, 0, 20, 0);
    
    selectedPics = [NSMutableArray array];
}

-(void)fetch {
    
    NSString *serverUrl = [NSString stringWithFormat:@"%@?format=json&nojsoncallback=1",BASE_URL];
    NSURL *url = [[NSURL alloc] initWithString:
                  [serverUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    
    // Create the request.
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // Create url connection and fire request
    NSURLConnection *conn = [[NSURLConnection alloc] init];
    (void)[conn initWithRequest:request delegate:self];
    [conn start];
}

/*
#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    [self parseData];
    //parse out the json data
    NSError* error;
    
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    dictionary = [responseString JSONValue];
    NSLog(@"%@", dictionary);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
}
*/

-(void)parseData {
    // The dictionary has an entry called "items", which is an array
    items = [dictionary objectForKey:@"items"];
    for(int i =0; i<items.count;i++) {
        NSDictionary *media = [[items objectAtIndex:i] objectForKey:@"media"];
        NSString *pic = [media objectForKey:@"m"];
        [randomPics addObject:pic];
        
    }
    
    NSLog(@"array is %@",randomPics);
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [flickrImages count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [[flickrImages objectAtIndex:section] count];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        FlickrHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];

        headerView.title.text = [dictionary objectForKey:@"title"];
        
        headerView.time.text  = [NSString stringWithFormat:@"Feed updated at %@",[dictionary objectForKey:@"modified"]];
         
        
        // UIImage *headerImage = [UIImage imageNamed:@"header_banner.png"];
        //headerView.backgroundImage.image = headerImage;
        
        reusableview = headerView;
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        
        reusableview = footerview;
    }
    
    return reusableview;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    
    FlickrViewCell *cell = (FlickrViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    UIImageView *recipeImageView = (UIImageView *)[cell viewWithTag:100];
    NSURL *url = [NSURL URLWithString:[flickrImages[indexPath.section] objectAtIndex:indexPath.row]];
    
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
    
    UIImage *tmpImage = [[UIImage alloc] initWithData:data];
    recipeImageView.image = tmpImage;
    [arrayWithImages addObject:tmpImage];
    
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo-frame-2.png"]];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo-frame-selected.png"]];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showSelectedPhoto"]) {
        NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
        FlickrImagePageController *destViewController = segue.destinationViewController;
        NSIndexPath *indexPath = [indexPaths objectAtIndex:0];
        destViewController.flickrImageName = [flickrImages[indexPath.section] objectAtIndex:indexPath.row];
        destViewController.imageArray = items;
        destViewController.selectedPage = indexPath.row;
        destViewController.arrayWithImages = arrayWithImages;
        [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    if (shareEnabled) {
//        NSString *selectedPic = [flickrImages[indexPath.section] objectAtIndex:indexPath.row];
//        [selectedPics addObject:selectedPic];
//    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    if (shareEnabled) {
//        NSString *deSelectedRecipe = [flickrImages[indexPath.section] objectAtIndex:indexPath.row];
//        [selectedPics removeObject:deSelectedRecipe];
//    }
}


- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if (shareEnabled) {
        return NO;
    } else {
        return YES;
    }
}




@end
