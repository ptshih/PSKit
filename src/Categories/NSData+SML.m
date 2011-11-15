//
//  NSData+SML.m
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 6/21/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import "NSData+SML.h"


@implementation NSData (SML)

static char base64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

- (NSString *)base64md5String {
  const void *cStr = [self bytes];
  unsigned char result[CC_MD5_DIGEST_LENGTH];
  
  CC_MD5(cStr, [self length], result);
  
  NSData *md5 = [[[NSData alloc] initWithBytes:result length:CC_MD5_DIGEST_LENGTH] autorelease];
  return [md5 base64EncodedString];
}

- (NSString *)base64EncodedString {
  NSMutableString *result;
  unsigned char *raw;
  unsigned long length;
  short i, nCharsToWrite;
  long cursor;
  unsigned char inbytes[3], outbytes[4];
  
  length = [self length];
  
  if (length < 1) {
    return @"";
  }
  
  result = [NSMutableString stringWithCapacity:length];
  raw = (unsigned char *)[self bytes];
  // Take 3 chars at a time, and encode to 4
  for (cursor = 0; cursor < length; cursor += 3) {
    for (i = 0; i < 3; i++) {
      if (cursor + i < length) {
        inbytes[i] = raw[cursor + i];
      }
      else{
        inbytes[i] = 0;
      }
    }
    
    outbytes[0] = (inbytes[0] & 0xFC) >> 2;
    outbytes[1] = ((inbytes[0] & 0x03) << 4) | ((inbytes[1] & 0xF0) >> 4);
    outbytes[2] = ((inbytes[1] & 0x0F) << 2) | ((inbytes[2] & 0xC0) >> 6);
    outbytes[3] = inbytes[2] & 0x3F;
    
    nCharsToWrite = 4;
    
    switch (length - cursor) {
      case 1:
        nCharsToWrite = 2;
        break;
        
      case 2:
        nCharsToWrite = 3;
        break;
    }
    for (i = 0; i < nCharsToWrite; i++) {
      [result appendFormat:@"%c", base64EncodingTable[outbytes[i]]];
    }
    for (i = nCharsToWrite; i < 4; i++) {
      [result appendString:@"="];
    }
  }
  
  return [NSString stringWithString:result]; // convert to immutable string
}

- (NSString *)signedHMACStringWithKey:(NSString *)key usingAlgorithm:(CCHmacAlgorithm)algorithm {
  CCHmacContext context;
  const char *keyCString = [key cStringUsingEncoding:NSASCIIStringEncoding];
  
  CCHmacInit(&context, algorithm, keyCString, strlen(keyCString));
  CCHmacUpdate(&context, [self bytes], [self length]);
  
  // Both SHA1 and SHA256 will fit in here
  unsigned char digestRaw[CC_SHA256_DIGEST_LENGTH];
  
  int digestLength;
  
  switch (algorithm) {
    case kCCHmacAlgSHA1:
      digestLength = CC_SHA1_DIGEST_LENGTH;
      break;
      
    case kCCHmacAlgSHA256:
      digestLength = CC_SHA256_DIGEST_LENGTH;
      break;
      
    default:
      digestLength = -1;
      break;
  }
  
  if (digestLength < 0) {
    NSLog(@"exception in hmac signature");
  }
  
  CCHmacFinal(&context, digestRaw);
  
  NSData *digestData = [NSData dataWithBytes:digestRaw length:digestLength];
  
  return [digestData base64EncodedString];
}

@end
