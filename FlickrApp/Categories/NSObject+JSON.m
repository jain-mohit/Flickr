//
//  NSObject+JSON.m
//
//  Created by MIBEQJ0 on 9/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/* Do not reuse this class
 This is a custom JSONSerializer that needs to support CoreData and 4.2
 
 */


#import "NSObject+JSON.h"
#import <objc/runtime.h>

@implementation NSObject (JSON)

-(NSString *) JSONRepresentation {
    NSString *json = [NSObject JSONRepresentationFor:self];
    return json;
}


+(NSString *) JSONRepresentationFor : (NSObject*) object {
    Class clazz = [object class];
    u_int count;
    NSString *json = @"{";
    objc_property_t* properties = class_copyPropertyList(clazz, &count);
    NSString *descr = [clazz description];
    if ([descr rangeOfString:@"__NSArrayM"].location == NSNotFound) {
        
    }else{
        json = [json stringByAppendingString:@"\n["];
        NSMutableArray *array = (NSMutableArray*) object;
        for(NSObject *arrObj in array){
            json = [json stringByAppendingString:[NSObject JSONRepresentationFor:arrObj]];
        }
        json = [json stringByAppendingString:@"]\n"];
    }
    
    
    int addedElements = 0;
    
    for (int i = 0; i < count ; i++)
    {
        const char* propertyName = property_getName(properties[i]);
        
        NSString *propName = [NSString  stringWithCString:propertyName encoding:NSUTF8StringEncoding];
        
        
        id value = [object valueForKey:propName];
        
        const char * type = property_getAttributes(class_getProperty(clazz, propertyName));
        NSString * typeString = [NSString stringWithUTF8String:type];
        NSArray * attributes = [typeString componentsSeparatedByString:@","];
        NSString * typeAttribute = [attributes objectAtIndex:0];
        NSString * propertyType = [typeAttribute substringFromIndex:1];
        const char * rawPropertyType = [propertyType UTF8String];
        
        
        NSString *propType =  [NSString  stringWithCString:rawPropertyType  encoding:NSUTF8StringEncoding];
        
        if(value != nil){
            if([propType isEqualToString:@"@\"NSString\""]){
                if(addedElements > 0){
                    json = [json stringByAppendingString:@","];
                }
                NSString *ppp = [NSString stringWithFormat:@"\"%@\":\"%@\"\n",propName,[value description]];
                json = [json stringByAppendingString:ppp];
                addedElements++;
            }
            
            if([propType isEqualToString:@"@\"NSNumber\""]){
                //In JSONRepresentation these BOOLEAN values arrive as NSNumbers and the serializer has
                // no way they were intended to be represented as true/false.
                // Making negative values a flag that these need to be represented as booleans
                if(addedElements > 0){
                    json = [json stringByAppendingString:@","];
                }
                if([[value description] isEqualToString: @"-11"]){
                    NSString *ppp = [NSString stringWithFormat:@"\"%@\":true\n",propName];
                    json = [json stringByAppendingString:ppp];
                }else{
                    if([[value description] isEqualToString: @"-10"]){
                        NSString *ppp = [NSString stringWithFormat:@"\"%@\": false\n",propName];
                        json = [json stringByAppendingString:ppp];
                    }else {
                        NSString *ppp = [NSString stringWithFormat:@"\"%@\":%@\n",propName,[value description]];
                        json = [json stringByAppendingString:ppp];
                    }
                }
                
                addedElements++;
                
            }
            if([propType isEqualToString:@"@\"NSArray\""] || [propType isEqualToString:@"@\"NSMutableArray\""] || [propType isEqualToString:@"@\"NSSet\""]){
                
                NSArray *vv = (NSArray*) value;
                if([vv count] <= 0){
                    continue;
                }
                
                
                if(addedElements > 0){
                    json = [json stringByAppendingString:@","];
                }
                json = [json stringByAppendingString:[NSString stringWithFormat:@"\n \"%@\" :",propName]];
                json = [json stringByAppendingString:@"["];
                int k = 0;
                for(NSObject *arrObj in value){
                    
                    if(k > 0){
                        json = [json stringByAppendingString:@","];
                    }
                    json = [json stringByAppendingString:[NSObject JSONRepresentationFor:arrObj]];
                    k++;
                }
                json = [json stringByAppendingString:@"]"];
                addedElements++;
            }
            
        }
        
    }
    free(properties);
    json = [json stringByAppendingString:@"}\n"];
    return json;
}

-(void)dumpInfo
{
    Class clazz = [self class];
    u_int count;
    
    Ivar* ivars = class_copyIvarList(clazz, &count);
    NSMutableArray* ivarArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count ; i++)
    {
        const char* ivarName = ivar_getName(ivars[i]);
        [ivarArray addObject:[NSString  stringWithCString:ivarName encoding:NSUTF8StringEncoding]];
    }
    free(ivars);
    
    objc_property_t* properties = class_copyPropertyList(clazz, &count);
    NSMutableArray* propertyArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count ; i++)
    {
        const char* propertyName = property_getName(properties[i]);
        NSString *propName = [NSString  stringWithCString:propertyName encoding:NSUTF8StringEncoding];
        id value = [self valueForKey:propName];
        
        NSString *ppp = [NSString stringWithFormat:@"%@=%@",propName,[value description]];
        [propertyArray addObject:ppp];
    }
    free(properties);
    
    Method* methods = class_copyMethodList(clazz, &count);
    NSMutableArray* methodArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count ; i++)
    {
        SEL selector = method_getName(methods[i]);
        const char* methodName = sel_getName(selector);
        [methodArray addObject:[NSString  stringWithCString:methodName encoding:NSUTF8StringEncoding]];
    }
    free(methods);
    
    NSDictionary* classDump = [NSDictionary dictionaryWithObjectsAndKeys:
                               ivarArray, @"ivars",
                               propertyArray, @"properties",
                               methodArray, @"methods",
                               nil];
    
    NSLog(@"%@", classDump);
}



@end
