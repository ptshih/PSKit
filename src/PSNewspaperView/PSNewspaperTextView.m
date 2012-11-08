//
//  PSNewspaperTextView.m
//  Vip
//
//  Created by Peter Shih on 7/5/12.
//  Copyright (c) 2012 Peter Shih. All rights reserved.
//

#import "PSNewspaperTextView.h"

@implementation PSNewspaperTextView

@synthesize
text = _text,
font = _font,
fontColor = _fontColor,
flowAroundRect = _flowAroundRect;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.contentMode = UIViewContentModeTopLeft;
        self.clipsToBounds = YES;
        
        self.font = [UIFont systemFontOfSize:14.0];
        self.fontColor = [UIColor blackColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Flip the coordinate system
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // Create a path to render text in
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds );
    
    // An attributed string containing the text to render
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:self.text];
    
    NSRange stringRange = NSMakeRange(0, attString.length);
    CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)self.font.fontName, self.font.pointSize, NULL);
    CGColorRef fontColor = [self.fontColor CGColor];
    
    if (font) {
        [attString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:stringRange];
        [attString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(__bridge id)fontColor range:stringRange];
        CFRelease(font);
    }
    
    
    // Create a path to wrap around
    CGMutablePathRef clipPath = CGPathCreateMutable();
    
    CGRect invertedRect = self.flowAroundRect;
    invertedRect.origin.y = self.height - invertedRect.size.height;
    CGPathAddRect(clipPath, NULL, invertedRect);
    //    CGPathAddEllipseInRect(clipPath, NULL, CGRectMake(0, 0, 300, 300) );
    
    // A CFDictionary containing the clipping path
    CFStringRef keys[] = { kCTFramePathClippingPathAttributeName };
    CFTypeRef values[] = { clipPath };
    CFDictionaryRef clippingPathDict = CFDictionaryCreate(NULL, 
                                                          (const void **)&keys, (const void **)&values,
                                                          sizeof(keys) / sizeof(keys[0]), 
                                                          &kCFTypeDictionaryKeyCallBacks, 
                                                          &kCFTypeDictionaryValueCallBacks);
    
    // An array of clipping paths -- you can use more than one if needed!
    NSArray *clippingPaths = [NSArray arrayWithObject:(__bridge NSDictionary*)clippingPathDict];
    
    // Create an options dictionary, to pass in to CTFramesetter
    NSDictionary *optionsDict = [NSDictionary dictionaryWithObject:clippingPaths forKey:(NSString*)kCTFrameClippingPathsAttributeName];
    
    // Finally create the framesetter and render text
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attString); //3
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter,
                                                CFRangeMake(0, [attString length]), path, (__bridge CFDictionaryRef)optionsDict);
    
    CTFrameDraw(frame, context);
    
    // Clean up
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framesetter);
}

@end
