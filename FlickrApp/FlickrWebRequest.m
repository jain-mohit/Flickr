//
//  FlickrWebRequest.m
//  FlickrApp
//
//  Created by Mohit Jain on 6/15/13.
//  Copyright (c) 2013 Mohit Jain. All rights reserved.
//

#import "FlickrWebRequest.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "NSObject+JSON.h"
#import "JSONKit.h"

#define BASE_URL @"http://api.flickr.com/services/feeds/photos_public.gne"

@implementation FlickrWebRequest

-(id)init {
    self =[super init];
    return self;
    
}

+ (FlickrWebRequest *) sharedInstance
{
	static dispatch_once_t pred;
	static FlickrWebRequest *sharedInstance = nil;
    
	dispatch_once(&pred, ^{ sharedInstance = [[self alloc] init]; });
	
    return sharedInstance;
}

-(NSString *)serviceAvailable: (ASIHTTPRequest *)request {
    NSError *error = [request error];
    if (error || [request responseStatusCode] != 200) {
        // This will happen probably when server is offline or not reachable
        NSString *message = [NSString stringWithFormat: @"Service not Available: %@ %@",[error localizedDescription],@"Error connecting to server"];
        return message;
    } else {
        return [request responseString];
    }
}


-(id)sendRequest: (NSURL *)url {
    NSLog(@"url is %@",url);
    [ASIHTTPRequest setDefaultTimeOutSeconds:60];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:url];
    [request startSynchronous];
    return request;
}


// fetch pics from flickr
-(NSString*)fetchPhoto {
    
//    NSString *serverUrl = [NSString stringWithFormat:@"%@?format=json",BASE_URL];
    NSString *serverUrl = [NSString stringWithFormat:BASE_URL];
    NSURL *url = [[NSURL alloc] initWithString:
                  [serverUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    
    NSLog(@"url is %@",url);
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:url];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (error || [request responseStatusCode] != 200) {
        // This will happen probably when server is offline or not reachable
        NSString *message = [NSString stringWithFormat: @"Service not Available: %@ %@",[error localizedDescription],[request responseString]];
        NSLog(@"message is %@",message);
    } else {
        NSLog(@"response string is %@",[request responseString]);
    }
    
    
   NSString *string = [request responseString];
    string = [string stringByReplacingOccurrencesOfString:@"jsonFlickrFeed(" withString:@""];
   // string = [string substringToIndex:string.length - 1];
    return string;
}


//Check server connectivity
-(BOOL)verifyWebserviceConnection {
    NSString *serverUrl = [NSString stringWithFormat:@"www.flickr.com"];
    //  NSLog(@"url is %@",serverUrl);
    NSURL *url = [[NSURL alloc] initWithString:
                  [serverUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    if([[self serviceAvailable:[self sendRequest:url]] isEqualToString:@"OK"]) {
        return TRUE;
    }
    return FALSE;
}


@end
