//
//  NSMutableURLRequest+PSKit.m
//  PSKit
//
//  Created by Peter on 2/3/12.
//  Copyright (c) 2012 Peter Shih. All rights reserved.
//

#import "NSMutableURLRequest+PSKit.h"

static NSString *const kPSBoundary = @"Boundary+0xAbCdEfGbOuNdArY";

static inline NSString *PSBoundaryStart() {
    return [NSString stringWithFormat:@"--%@\r\n", kPSBoundary];
}

static inline NSString *PSBoundarySeparator() {
    return [NSString stringWithFormat:@"\r\n--%@\r\n", kPSBoundary];
}

static inline NSString *PSBoundaryEnd() {
    return [NSString stringWithFormat:@"\r\n--%@--\r\n", kPSBoundary];
}

NSString *PSURLEncodedStringFromStringWithEncoding(NSString *string, NSStringEncoding encoding) {
    static NSString *const kPSCharactersToEscape = @"?!@#$^&%*+,:;='\"`<>()[]{}/\\|~ ";
    
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)[string stringByReplacingPercentEscapesUsingEncoding:encoding], NULL, (__bridge CFStringRef)kPSCharactersToEscape, CFStringConvertNSStringEncodingToEncoding(encoding));
}

NSString *PSQueryStringFromParametersWithEncoding(NSDictionary *parameters, NSStringEncoding encoding) {
    NSMutableArray *parameterPairs = [NSMutableArray array];
    for (id key in [parameters allKeys]) {
        id value = [parameters valueForKey:key];
        // NOTE: Ignore any value that isn't a String for now
        if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
            NSString *pair = [NSString stringWithFormat:@"%@=%@", PSURLEncodedStringFromStringWithEncoding([key description], encoding), PSURLEncodedStringFromStringWithEncoding([value description], encoding)];
            [parameterPairs addObject:pair];
        }
    }    
    
    return [parameterPairs componentsJoinedByString:@"&"];
}

@implementation NSMutableURLRequest (PSKit)

+ (NSMutableURLRequest *)requestWithURL:(NSURL *)URL method:(NSString *)method headers:(NSDictionary *)headers parameters:(NSDictionary *)parameters {
    NSStringEncoding stringEncoding = NSUTF8StringEncoding;
    // Create the base request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    
    // Default timeout 30 seconds
    [request setTimeoutInterval:30];
    
    // Configure the Method
    if (!method) {
        [request setHTTPMethod:@"GET"];
    } else {
        [request setHTTPMethod:method];
    }
    
    // Configure Headers
    // Add default Headers
    [request addValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    NSString *preferredLanguageCodes = [[NSLocale preferredLanguages] componentsJoinedByString:@", "];
    [request addValue:[NSString stringWithFormat:@"%@, en-us;q=0.8", preferredLanguageCodes] forHTTPHeaderField:@"Accept-Language"];
    
    // Add custom headers
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
            URL = [NSURL URLWithString:[[URL absoluteString] stringByAppendingFormat:@"?%@", PSQueryStringFromParametersWithEncoding(parameters, stringEncoding)]];
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
            
            NSString *charset = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
            if (multipart) {
                [request addValue:[NSString stringWithFormat:@"multipart/form-data; charset=%@; boundary=%@", charset, kPSBoundary] forHTTPHeaderField:@"Content-Type"];
                NSMutableData *data = [NSMutableData data];
                [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    if (data.length == 0) {
                        // Append starting boundary
                        [data appendData:[PSBoundaryStart() dataUsingEncoding:NSUTF8StringEncoding]];
                    } else {
                        // Append separating boundary
                        [data appendData:[PSBoundarySeparator() dataUsingEncoding:NSUTF8StringEncoding]];
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
                    [data appendData:[PSBoundaryEnd() dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    [request setHTTPBody:data];
                }
            } else {
                // URLEncoded
                [request setValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
                [request setHTTPBody:[PSQueryStringFromParametersWithEncoding(parameters, stringEncoding) dataUsingEncoding:stringEncoding]];
            }
        }
    }
    
    return request;
}

#pragma mark - Convenience Methods
- (NSString *)HTTPBodyString {
    NSString *httpBodyString = nil;
    if (self.HTTPBody) {
        httpBodyString = [[NSString alloc] initWithData:self.HTTPBody encoding:NSUTF8StringEncoding];
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
