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
#import "NSObject+JSON.h"
#import "JSONKit.h"
#import "XMLReader.h"



#define BASE_URL @"http://api.flickr.com/services/feeds/photos_public.gne"

@interface FlickrCollectionViewController () {
    NSArray *flickrImages;
    BOOL shareEnabled;
    NSMutableArray *selectedPics;
    NSArray *randomPics;
}

@end

@implementation FlickrCollectionViewController
@synthesize dictionary, loadingAlertView, flickrArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)fetch {
    
     NSString *serverUrl = [NSString stringWithFormat:@"%@?format=json",BASE_URL];
    NSURL *url = [[NSURL alloc] initWithString:
                  [serverUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    
    // Create the request.
      NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // Create url connection and fire request
    NSURLConnection *conn = [[NSURLConnection alloc] init];
    (void)[conn initWithRequest:request delegate:self];
}


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
    [self parseJSON];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
}

-(void)parseJSON {
    //parse out the json data
    NSError* error;
    
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSString *formattedString = [responseString stringByReplacingOccurrencesOfString:@"jsonFlickrFeed" withString:@""];
    NSData *formattedData = [formattedString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:formattedData //1
                          
                          options:kNilOptions
                          error:&error];
    
    NSArray* array = [json objectForKey:@"items"]; //2
    NSDictionary *dict = [formattedString JSONString];
    NSDictionary *d = [formattedString objectFromJSONString];
    NSLog(@"array: %@", array); //3

}


-(void)fetchUsingASIHTTP {
    FlickrWebRequest *webRequest = [FlickrWebRequest sharedInstance];
    
    NSString *fetchedString = [webRequest fetchPhoto];
  /*  NSError *error = nil;
    NSDictionary *jsonInfo = [NSJSONSerialization JSONObjectWithData:[fetchedString dataUsingEncoding:NSUnicodeStringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        NSLog(@"error description...%@", [error description]);
    }
    NSLog(@"data is %@",jsonInfo); */
    
    
    
    NSError *parseError = nil;
    //NSDictionary *xmlDictionary = [XMLReader dictionaryForXMLString:fetchedString error:&parseError];
    dictionary = [XMLReader dictionaryForXMLString:fetchedString error:&parseError];
    // Print the dictionary
    NSLog(@"%@", dictionary);
}

/*
-(void)fetchPicsFromFlickr {
    FlickrWebRequest *webRequest = [FlickrWebRequest sharedInstance];
    NSString *fetchedData = [webRequest fetchPhoto];
    NSLog(@"data is %@",fetchedData);
    NSString *feed = [fetchedData objectFromJSONString];
    //        NSString *string = [fetchedData JSONRepresentation];
    //NSArray *transactions = [dict objectForKey:@"items"];
    
    NSError* err = nil;
    NSURLResponse* response = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *serverUrl = [NSString stringWithFormat:@"%@?format=json",BASE_URL];
    
     NSURL *url = [[NSURL alloc] initWithString:
                  [serverUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy
                                             timeoutInterval:60.0];
    
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [connection start];
    /*
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setTimeoutInterval:30];
    NSData* jsondata = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    NSDictionary *resultsDictionary = [jsondata objectFromJSONData];
    NSDictionary *r = [fetchedData objectFromJSONString];
     //
}

-(void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse *)response {
    
    data = [[NSMutableData alloc] init];
}

-(void)connection: (NSURLConnection *)connection didReceiveData:(NSData *)theData {
    [data appendData:theData];
}

-(void)connectionDidFinishLoading: (NSURLConnection*)connection {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSError* error;
    NSJSONSerialization *myJSONObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSLog(@"dict is %@",myJSONObject);
    [self performSelector:@selector(loadingDismiss)];
    
}



-(void)loadingDismiss {
    [loadingAlertView dismissWithClickedButtonIndex:0 animated:NO];
}

-(void)connection: (NSURLConnection *)connection didFailWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to connect with Server. Please check if connected to 3G or wifi or contact server admin" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [errorView show];
}



*/

- (void)viewDidLoad
{
    [super viewDidLoad];
   // data = [[NSMutableData alloc] init];
//    [self fetch];
    [self fetchUsingASIHTTP];
    
    // Initialize recipe image array
    //NSArray *randomPics
    randomPics = [NSArray arrayWithObjects:@"egg_benedict.jpg", @"full_breakfast.jpg", @"ham_and_cheese_panini.jpg", @"ham_and_egg_sandwich.jpg", @"hamburger.jpg", @"instant_noodle_with_egg.jpg", @"japanese_noodle_with_pork.jpg", @"mushroom_risotto.jpg", @"noodle_with_bbq_pork.jpg", @"thai_shrimp_cake.jpg", @"vegetable_curry.jpg", @"angry_birds_cake.jpg", @"creme_brelee.jpg", @"green_tea.jpg", @"starbucks_coffee.jpg", @"white_chocolate_donut.jpg", nil];
    flickrImages = [NSArray arrayWithObjects:randomPics, nil];
    
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    collectionViewLayout.sectionInset = UIEdgeInsetsMake(20, 0, 20, 0);
    
    selectedPics = [NSMutableArray array];
	// Do any additional setup after loading the view.
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
        // NSString *title = [[NSString alloc]initWithFormat:@"Recipe Group #%i", indexPath.section + 1];
        NSString *title = @"RSS Feed";
        headerView.title.text = title;
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
    recipeImageView.image = [UIImage imageNamed:[flickrImages[indexPath.section] objectAtIndex:indexPath.row]];
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
        destViewController.imageArray = randomPics;
        destViewController.selectedPage = indexPath.row;
        [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (shareEnabled) {
        NSString *selectedRecipe = [flickrImages[indexPath.section] objectAtIndex:indexPath.row];
        [selectedPics addObject:selectedRecipe];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (shareEnabled) {
        NSString *deSelectedRecipe = [flickrImages[indexPath.section] objectAtIndex:indexPath.row];
        [selectedPics removeObject:deSelectedRecipe];
    }
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
