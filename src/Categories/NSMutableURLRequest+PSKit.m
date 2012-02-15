//
//  NSMutableURLRequest+PSKit.m
//  Linsanity
//
//  Created by Peter on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSMutableURLRequest+PSKit.h"

static NSString *const kFSAPIURLBase = @"https://api.foursquare.com/v2";
static NSString *const kFSBoundary = @"Boundary+0xAbCdEfGbOuNdArY";

static inline NSString *FSBoundaryStart() {
    return [NSString stringWithFormat:@"--%@\r\n", kFSBoundary];
}

static inline NSString *FSBoundarySeparator() {
    return [NSString stringWithFormat:@"\r\n--%@\r\n", kFSBoundary];
}

static inline NSString *FSBoundaryEnd() {
    return [NSString stringWithFormat:@"\r\n--%@--\r\n", kFSBoundary];
}

NSString *FSURLEncodedStringFromStringWithEncoding(NSString *string, NSStringEncoding encoding) {
    static NSString *const kFSCharactersToEscape = @"?!@#$^&%*+,:;='\"`<>()[]{}/\\|~ ";
    
    return [(NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)[string stringByReplacingPercentEscapesUsingEncoding:encoding], NULL, (CFStringRef)kFSCharactersToEscape, CFStringConvertNSStringEncodingToEncoding(encoding)) autorelease];
}

NSString *FSQueryStringFromParametersWithEncoding(NSDictionary *parameters, NSStringEncoding encoding) {
    NSMutableArray *parameterPairs = [NSMutableArray array];
    for (id key in [parameters allKeys]) {
        id value = [parameters valueForKey:key];
        // NOTE: Ignore any value that isn't a String for now
        if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
            NSString *pair = [NSString stringWithFormat:@"%@=%@", FSURLEncodedStringFromStringWithEncoding([key description], encoding), FSURLEncodedStringFromStringWithEncoding([value description], encoding)];
            [parameterPairs addObject:pair];
        }
    }    
    
    return [parameterPairs componentsJoinedByString:@"&"];
}

@implementation NSMutableURLRequest (FS)

+ (NSMutableURLRequest *)requestWithFoursquareEndpoint:(NSString *)endpoint method:(NSString *)method headers:(NSDictionary *)headers parameters:(NSDictionary *)parameters {
    
    // Set URL
    NSURL *endpointURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kFSAPIURLBase, endpoint]];
    NSMutableDictionary *newHeaders = [NSMutableDictionary dictionaryWithDictionary:headers];
    
    // Add FS headers
    // Set userAgent (User-Agent)
    // Set language
    [newHeaders setObject:[NSString stringWithFormat:@"%@-%@", [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0], [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode]] forKey:@"Accept-Language"];
    
    return [[self class] requestWithURL:endpointURL method:method headers:newHeaders parameters:parameters];
}

+ (NSMutableURLRequest *)requestWithURL:(NSURL *)URL method:(NSString *)method headers:(NSDictionary *)headers parameters:(NSDictionary *)parameters {
    NSStringEncoding stringEncoding = NSUTF8StringEncoding;
    // Create the base request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    
    // Configure the Method
    if (!method) {
        [request setHTTPMethod:@"GET"];
    } else {
        [request setHTTPMethod:method];
    }
    
    // Configure Headers
    if (headers) {
        [headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            // Header keys and values MUST be strings
            if ([key isKindOfClass:[NSString class]] && [obj isKindOfClass:[NSString class]]) {
                [request addValue:obj forHTTPHeaderField:key];
            }
        }];
    }
    
    // Configure Parameters
    if (parameters) {
        method = [method uppercaseString];
        if ([method isEqualToString:@"GET"] || [method isEqualToString:@"HEAD"] || [method isEqualToString:@"DELETE"]) {
            // Embedded query string in URL
            URL = [NSURL URLWithString:[[URL absoluteString] stringByAppendingFormat:@"?%@", FSQueryStringFromParametersWithEncoding(parameters, stringEncoding)]];
            [request setURL:URL];
        } else {
            // Create POST/PUT body
            // Decide if this request needs to be multipart
            __block BOOL multipart = NO;
            [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([obj isKindOfClass:[NSData class]]) {
                    multipart = YES;
                    *stop = YES;
                }
            }];
            
            NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
            if (multipart) {
                [request addValue:[NSString stringWithFormat:@"multipart/form-data; charset=%@; boundary=%@", charset, kFSBoundary] forHTTPHeaderField:@"Content-Type"];
                NSMutableData *data = [NSMutableData data];
                [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    if (data.length == 0) {
                        // Append starting boundary
                        [data appendData:[FSBoundaryStart() dataUsingEncoding:NSUTF8StringEncoding]];
                    } else {
                        // Append separating boundary
                        [data appendData:[FSBoundarySeparator() dataUsingEncoding:NSUTF8StringEncoding]];
                    }
                    
                    // Build boundary header
                    [data appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", key] dataUsingEncoding:stringEncoding]];
                    
                    if ([obj isKindOfClass:[NSData class]]) {
                        NSString *contentType = @"image/jpeg"; // TODO: actually detect mime-type
                        [data appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n", contentType] dataUsingEncoding:stringEncoding]]; 
                        [data appendData:obj];
                    } else {
                        [data appendData:[obj dataUsingEncoding:stringEncoding]];
                    }
                }];
                
                if (data.length > 0) {
                    // Append ending boundary
                    [data appendData:[FSBoundaryEnd() dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    [request setHTTPBody:data];
                }
            } else {
                // URLEncoded
                [request setValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
                [request setHTTPBody:[FSQueryStringFromParametersWithEncoding(parameters, stringEncoding) dataUsingEncoding:stringEncoding]];
            }
        }
    }
    
    return request;
}

#pragma mark - Convenience Methods
- (NSString *)HTTPBodyString {
    NSString *httpBodyString = nil;
    if (self.HTTPBody) {
        httpBodyString = [[[NSString alloc] initWithData:self.HTTPBody encoding:NSUTF8StringEncoding] autorelease];
    }
    return httpBodyString;
}

- (NSDictionary *)requestParameters {
    // Explode the query string if this is a GET/HEAD/DELETE
    
    // Explode the urlEncoded body string if this is a POST
    
    // Explode the formData body if this is a POST FORMDATA
    
    return nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"\r\n\r\n###\r\nURL: %@\r\nHeaders: %@\r\nBody: %@\r\n###\r\n\r\n", self.URL, self.allHTTPHeaderFields, [self HTTPBodyString]];
}

@end
