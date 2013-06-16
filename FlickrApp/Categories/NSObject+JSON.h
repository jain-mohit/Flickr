//
//  NSObject+JSON.h
//
//  Created by MIBEQJ0 on 9/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (JSON)
+(NSString *) JSONRepresentationFor : (NSObject*) object;
-(NSString *) JSONRepresentation;
-(void)dumpInfo;
@end
