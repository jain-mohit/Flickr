//
//  FlickrWebRequest.m
//  FlickrApp
//
//  Created by Mohit Jain on 6/15/13.
//  Copyright (c) 2013 Mohit Jain. All rights reserved.
//

#import "FlickrWebRequest.h"

@implementation FlickrWebRequest



-(NSString *)serviceAvailable: (ASIHTTPRequest *)request {
    NSError *error = [request error];
    if (error || [request responseStatusCode] != 200) {
        // This will happen probably when server is offline or not reachable
        //NSString *message = [NSString stringWithFormat: @"Service not Available: %@ %@",[error localizedDescription],[request responseString]];
        NSString *message = [NSString stringWithFormat: @"Service not Available: %@ %@",[error localizedDescription],@"Evol Was here"];
        return message;
    } else {
        return [request responseString];
    }
}
@end
