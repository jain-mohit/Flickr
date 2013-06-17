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
#import "SBJson.h"
#import "JSON/JSON.h"




#define BASE_URL @"http://api.flickr.com/services/feeds/photos_public.gne"

@interface FlickrCollectionViewController () {
    NSArray *flickrImages;
    BOOL shareEnabled;
    NSMutableArray *selectedPics;
    NSMutableArray *randomPics;
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
    [self fetchUsingASIHTTP];
    randomPics = [[NSMutableArray alloc]init];
    [self parseData];
    // Initialize recipe image array
    //NSArray *randomPics
//    randomPics = [NSArray arrayWithObjects:@"egg_benedict.jpg", @"full_breakfast.jpg", @"ham_and_cheese_panini.jpg", @"ham_and_egg_sandwich.jpg", @"hamburger.jpg", @"instant_noodle_with_egg.jpg", @"japanese_noodle_with_pork.jpg", @"mushroom_risotto.jpg", @"noodle_with_bbq_pork.jpg", @"thai_shrimp_cake.jpg", @"vegetable_curry.jpg", @"angry_birds_cake.jpg", @"creme_brelee.jpg", @"green_tea.jpg", @"starbucks_coffee.jpg", @"white_chocolate_donut.jpg", nil];
    flickrImages = [NSArray arrayWithObjects:randomPics, nil];
    
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    collectionViewLayout.sectionInset = UIEdgeInsetsMake(20, 0, 20, 0);
    
    selectedPics = [NSMutableArray array];
	// Do any additional setup after loading the view.
}


-(void)parseData {
    // The dictionary has an entry called "items", which is an array
    items = [dictionary objectForKey:@"items"];
    for(int i =0; i<items.count;i++) {
        NSDictionary *media = [[items objectAtIndex:i] objectForKey:@"media"];
        NSString *pic = [media objectForKey:@"m"];
        [randomPics addObject:pic];
        
    }
    
    NSLog(@"array is %@",randomPics);
    // Iterate over the items. Each item is an object, hence a dictionary
    for (NSDictionary *item in items) {
        // Each item dictionary has an entry called "author_id", which is a string
        NSString *authorId = [item objectForKey:@"author_id"];
        
        // Log the author id
        NSLog(@"author_id = %@", authorId);
    }
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
