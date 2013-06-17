//
//  FlickrCollectionViewController.h
//  FlickrApp
//
//  Created by Mohit Jain on 6/15/13.
//  Copyright (c) 2013 Mohit Jain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlickrCollectionViewController : UICollectionViewController<NSURLConnectionDelegate> {
    NSMutableData *responseData;
}


@property(nonatomic, strong) NSDictionary *dictionary;
@property (strong, nonatomic) UIAlertView *loadingAlertView;
@property(nonatomic, strong) NSMutableArray *flickrArray;
@property(nonatomic, strong) NSMutableArray *items;

@end
