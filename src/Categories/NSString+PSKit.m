//
//  NSString+PSKit.m
//  PSKit
//
//  Created by Peter Shih on 6/21/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "NSString+PSKit.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (PSKit)

double kmFromMeters(double meters) {
    return meters * 0.001;
}

double feetFromMiles(double miles) {
    return miles * 5280;
}

// imperial from metric

double milesFromKM(double km) {
    return km * 0.621371192;
}

double milesFromMeters(double meters) {
    return meters * 0.000621371192;
}

double yardsFromMeters(double meters) {
    return meters * 1.0936133;
}

double feetFromMeters(double meters) {
    return meters * 3.2808399;
}


// metric from imperial

double metersFromMiles(double miles) {
    return miles * 1609.344;
}

double kmFromMiles(double miles) {
    return miles * 1.609344;
}


#pragma mark - UUID
+ (NSString *)stringFromUUID {
  CFUUIDRef theUUID = CFUUIDCreate(NULL);
  CFStringRef string = CFUUIDCreateString(NULL, theUUID);
  CFRelease(theUUID);
  return [(NSString *)string autorelease];
}

#pragma mark - MIME
+ (NSString *)MIMETypeForExtension:(NSString *)extension {
  static NSDictionary *lookupTable = nil;
  
  if (lookupTable == nil) {
    lookupTable = [[NSDictionary alloc] initWithObjectsAndKeys:
                   @"application/postscript", @"ai",
                   @"audio/x-aiff", @"aif",
                   @"audio/x-aiff", @"aifc",
                   @"audio/x-aiff", @"aiff",
                   @"text/plain", @"asc",
                   @"audio/basic", @"au",
                   @"video/x-msvideo", @"avi",
                   @"application/x-bcpio", @"bcpio",
                   @"application/octet-stream", @"bin",
                   @"text/plain", @"c",
                   @"text/plain", @"cc",
                   @"application/clariscad", @"ccad",
                   @"application/x-netcdf", @"cdf",
                   @"application/octet-stream", @"class",
                   @"application/x-cpio", @"cpio",
                   @"text/plain", @"cpp",
                   @"application/mac-compactpro", @"cpt",
                   @"text/plain", @"cs",
                   @"application/x-csh", @"csh",
                   @"text/css", @"css",
                   @"application/x-director", @"dcr",
                   @"application/x-director", @"dir",
                   @"application/octet-stream", @"dms",
                   @"application/msword", @"doc",
                   @"application/msword", @"docx",
                   @"application/msword", @"dot",
                   @"application/drafting", @"drw",
                   @"application/x-dvi", @"dvi",
                   @"application/acad", @"dwg",
                   @"application/dxf", @"dxf",
                   @"application/x-director", @"dxr",
                   @"application/postscript", @"eps",
                   @"text/x-setext", @"etx",
                   @"application/octet-stream", @"exe",
                   @"application/andrew-inset", @"ez",
                   @"text/plain", @"f",
                   @"text/plain", @"f90",
                   @"video/x-fli", @"fli",
                   @"image/gif", @"gif",
                   @"application/x-gtar", @"gtar",
                   @"application/x-gzip", @"gz",
                   @"text/plain", @"h",
                   @"application/x-hdf", @"hdf",
                   @"text/plain", @"hh",
                   @"application/mac-binhex40", @"hqx",
                   @"text/html", @"htm",
                   @"text/html", @"html",
                   @"x-conference/x-cooltalk", @"ice",
                   @"image/ief", @"ief",
                   @"model/iges", @"iges",
                   @"model/iges", @"igs",
                   @"application/x-ipscript", @"ips",
                   @"application/x-ipix", @"ipx",
                   @"image/jpeg", @"jpe",
                   @"image/jpeg", @"jpeg",
                   @"image/jpeg", @"jpg",
                   @"application/x-javascript", @"js",
                   @"audio/midi", @"kar",
                   @"application/x-latex", @"latex",
                   @"application/octet-stream", @"lha",
                   @"application/x-lisp", @"lsp",
                   @"application/octet-stream", @"lzh",
                   @"text/plain", @"m",
                   @"application/x-troff-man", @"man",
                   @"application/x-troff-me", @"me",
                   @"model/mesh", @"mesh",
                   @"audio/midi", @"mid",
                   @"audio/midi", @"midi",
                   @"www/mime", @"mime",
                   @"video/quicktime", @"mov",
                   @"video/x-sgi-movie", @"movie",
                   @"audio/mpeg", @"mp2",
                   @"audio/mpeg", @"mp3",
                   @"video/mpeg", @"mpe",
                   @"video/mpeg", @"mpeg",
                   @"video/mpeg", @"mpg",
                   @"audio/mpeg", @"mpga",
                   @"application/x-troff-ms", @"ms",
                   @"application/x-ole-storage", @"msi",
                   @"model/mesh", @"msh",
                   @"application/x-netcdf", @"nc",
                   @"application/oda", @"oda",
                   @"image/x-portable-bitmap", @"pbm",
                   @"chemical/x-pdb", @"pdb",
                   @"application/pdf", @"pdf",
                   @"image/x-portable-graymap", @"pgm",
                   @"application/x-chess-pgn", @"pgn",
                   @"image/png", @"png",
                   @"image/x-portable-anymap", @"pnm",
                   @"application/mspowerpoint", @"pot",
                   @"image/x-portable-pixmap", @"ppm",
                   @"application/mspowerpoint", @"pps",
                   @"application/mspowerpoint", @"ppt",
                   @"application/mspowerpoint", @"ppz",
                   @"application/x-freelance", @"pre",
                   @"application/pro_eng", @"prt",
                   @"application/postscript", @"ps",
                   @"video/quicktime", @"qt",
                   @"audio/x-realaudio", @"ra",
                   @"audio/x-pn-realaudio", @"ram",
                   @"image/cmu-raster", @"ras",
                   @"image/x-rgb", @"rgb",
                   @"audio/x-pn-realaudio", @"rm",
                   @"application/x-troff", @"roff",
                   @"audio/x-pn-realaudio-plugin", @"rpm",
                   @"text/rtf", @"rtf",
                   @"text/richtext", @"rtx",
                   @"application/x-lotusscreencam", @"scm",
                   @"application/set", @"set",
                   @"text/sgml", @"sgm",
                   @"text/sgml", @"sgml",
                   @"application/x-sh", @"sh",
                   @"application/x-shar", @"shar",
                   @"model/mesh", @"silo",
                   @"application/x-stuffit", @"sit",
                   @"application/x-koan", @"skd",
                   @"application/x-koan", @"skm",
                   @"application/x-koan", @"skp",
                   @"application/x-koan", @"skt",
                   @"application/smil", @"smi",
                   @"application/smil", @"smil",
                   @"audio/basic", @"snd",
                   @"application/solids", @"sol",
                   @"application/x-futuresplash", @"spl",
                   @"application/x-wais-source", @"src",
                   @"application/STEP", @"step",
                   @"application/SLA", @"stl",
                   @"application/STEP", @"stp",
                   @"application/x-sv4cpio", @"sv4cpio",
                   @"application/x-sv4crc", @"sv4crc",
                   @"application/x-shockwave-flash", @"swf",
                   @"application/x-troff", @"t",
                   @"application/x-tar", @"tar",
                   @"application/x-tcl", @"tcl",
                   @"application/x-tex", @"tex",
                   @"image/tiff", @"tif",
                   @"image/tiff", @"tiff",
                   @"application/x-troff", @"tr",
                   @"audio/TSP-audio", @"tsi",
                   @"application/dsptype", @"tsp",
                   @"text/tab-separated-values", @"tsv",
                   @"text/plain", @"txt",
                   @"application/i-deas", @"unv",
                   @"application/x-ustar", @"ustar",
                   @"application/x-cdlink", @"vcd",
                   @"application/vda", @"vda",
                   @"model/vrml", @"vrml",
                   @"audio/x-wav", @"wav",
                   @"model/vrml", @"wrl",
                   @"image/x-xbitmap", @"xbm",
                   @"application/vnd.ms-excel", @"xlc",
                   @"application/vnd.ms-excel", @"xll",
                   @"application/vnd.ms-excel", @"xlm",
                   @"application/vnd.ms-excel", @"xls",
                   @"application/vnd.ms-excel", @"xlw",
                   @"text/xml", @"xml",
                   @"image/x-xpixmap", @"xpm",
                   @"image/x-xwindowdump", @"xwd",
                   @"chemical/x-pdb", @"xyz",
                   @"application/zip", @"zip",
                   @"video/x-m4v", @"m4v",
                   @"video/webm", @"webm",
                   @"video/ogv", @"ogv",
                   nil];
  }
  NSString *mimetype = (NSString *)[lookupTable objectForKey:extension];
  return mimetype == nil ? @"application/octet-stream" : mimetype;
}


#pragma mark - JSON
- (BOOL)notNull {
	return ![self isEqualToString:@"(null)"];
}

#pragma mark - URL Encoding
- (NSString *)stringByURLEncoding {
  NSString* escapedUrlString =
  [self stringByAddingPercentEscapesUsingEncoding:
   NSUTF8StringEncoding];
  return escapedUrlString;
  
//  NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
//                                                                         (CFStringRef)self,
//                                                                         NULL,
//                                                                         CFSTR(":/=,!$&'()*+;[]@#?"),
//                                                                         kCFStringEncodingUTF8);
  
//  return [result autorelease];
}

// This is more rarely used
- (NSString *)stringByEscapingQuery {
  NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                         (CFStringRef)self,
                                                                         NULL,              
                                                                         CFSTR("?=&+"),         
                                                                         kCFStringEncodingUTF8);
  return [result autorelease];
}

- (NSString *)stringWithPercentEscape {
  return [(NSString *) CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)[[self mutableCopy] autorelease], NULL, CFSTR("￼=,!$&'()*+;@?\n\"<>#\t :/"),kCFStringEncodingUTF8) autorelease];
}

#pragma mark - HTML
- (NSString *)stringByEscapingHTML {
	NSMutableString *s = [NSMutableString string];
	
	int start = 0;
	int len = [self length];
	NSCharacterSet *chs = [NSCharacterSet characterSetWithCharactersInString:@"<>&\""];
	
	while (start < len) {
		NSRange r = [self rangeOfCharacterFromSet:chs options:0 range:NSMakeRange(start, len-start)];
		if (r.location == NSNotFound) {
			[s appendString:[self substringFromIndex:start]];
			break;
		}
		
		if (start < r.location) {
			[s appendString:[self substringWithRange:NSMakeRange(start, r.location-start)]];
		}
		
		switch ([self characterAtIndex:r.location]) {
			case '<':
				[s appendString:@"&lt;"];
				break;
			case '>':
				[s appendString:@"&gt;"];
				break;
			case '"':
				[s appendString:@"&quot;"];
				break;
			case '&':
				[s appendString:@"&amp;"];
				break;
		}
		
		start = r.location + 1;
	}
	
	return s;
}

- (NSString *)stringByUnescapingHTML {
	NSMutableString *s = [NSMutableString string];
	NSMutableString *target = [[self mutableCopy] autorelease];
	NSCharacterSet *chs = [NSCharacterSet characterSetWithCharactersInString:@"&"];
	
	while ([target length] > 0) {
		NSRange r = [target rangeOfCharacterFromSet:chs];
		if (r.location == NSNotFound) {
			[s appendString:target];
			break;
		}
		
		if (r.location > 0) {
			[s appendString:[target substringToIndex:r.location]];
			[target deleteCharactersInRange:NSMakeRange(0, r.location)];
		}
		
		if ([target hasPrefix:@"&lt;"]) {
			[s appendString:@"<"];
			[target deleteCharactersInRange:NSMakeRange(0, 4)];
		} else if ([target hasPrefix:@"&gt;"]) {
			[s appendString:@">"];
			[target deleteCharactersInRange:NSMakeRange(0, 4)];
		} else if ([target hasPrefix:@"&quot;"]) {
			[s appendString:@"\""];
			[target deleteCharactersInRange:NSMakeRange(0, 6)];
		} else if ([target hasPrefix:@"&#39;"]) {
			[s appendString:@"'"];
			[target deleteCharactersInRange:NSMakeRange(0, 5)];
		} else if ([target hasPrefix:@"&amp;"]) {
			[s appendString:@"&"];
			[target deleteCharactersInRange:NSMakeRange(0, 5)];
		} else if ([target hasPrefix:@"&hellip;"]) {
			[s appendString:@"…"];
			[target deleteCharactersInRange:NSMakeRange(0, 8)];
		} else {
			[s appendString:@"&"];
			[target deleteCharactersInRange:NSMakeRange(0, 1)];
		}
	}
	
	return s;
}

- (NSString *)stripHTML{
	
	NSString *html = self;
  NSScanner *thescanner = [NSScanner scannerWithString:html];
  NSString *text = nil;
	
  while ([thescanner isAtEnd] == NO) {
		[thescanner scanUpToString:@"<" intoString:NULL];
		[thescanner scanUpToString:@">" intoString:&text];
		html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@" "];
  }
	return html;
}

#pragma mark - MD5
- (NSString *)stringFromMD5Hash {
  const char *cStr = [self UTF8String];
  unsigned char result[16];
  CC_MD5( cStr, strlen(cStr), result );
  return [NSString stringWithFormat:
          @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
          result[0], result[1], result[2], result[3], 
          result[4], result[5], result[6], result[7],
          result[8], result[9], result[10], result[11],
          result[12], result[13], result[14], result[15]
          ];
}

+ (NSString *)localizedStringForDistance:(float)distance {
    BOOL metric = [[[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem] boolValue];
    
    float value;
    NSString* unit;
    int precision = 0;
    
    if (metric) {
        value = kmFromMeters(distance);
        if (value >= 0.1) {
            unit = NSLocalizedString(@"km", @"kilometers (abbreviated distance label)");
            if (value < 10) precision = 1;
        }
        else {
            unit = NSLocalizedString(@"m", @"meters (abbreviated distance label)");
            value = distance;
            if (value > 10)
                value = ((int)value / 10) * 10; // clamp to nearest ten just to make it a little 'friendlier' looking
        }
    }
    else {
        value = milesFromMeters(distance);
        if (value >= 0.1) {
            unit = NSLocalizedString(@"mi", @"miles (abbreviated distance label)");
            if (value < 10) precision = 1;
        }
        else {
            unit = NSLocalizedString(@"ft", @"feet (abbreviated distance label)");
            value = feetFromMeters(distance);
            if (value > 10)
                value = ((int)value / 10) * 10; // clamp to nearest ten just to make it a little 'friendlier' looking
        }
    }
    
    NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMaximumFractionDigits:precision];
    
    return [NSString stringWithFormat:@"%@ %@", [formatter stringFromNumber:[NSNumber numberWithFloat:value]], unit];
}

@end
