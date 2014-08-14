//
//  MarkdownParser.m
//  TextKitMagazine
//
//  Created by Perry on 14-8-12.
//  Copyright (c) 2014年 Colin Eberhardt. All rights reserved.
//

#import "MarkdownParser.h"

@implementation MarkdownParser
{
    NSDictionary *_bodyTextAttributes;
    NSDictionary *_headingOneAttributes;
    NSDictionary *_headingTwoAttributes;
    NSDictionary *_headingThreeAttributes;
}

- (id)init
{
    if (self = [super init]) {
        [self createTextAttributes];
    }
    return self;
}

- (void)createTextAttributes
{
    // 1. Create the font descriptors
    /**
     *  Create two font descriptors for the Bakerville family: one normal, and one bold. Remember from the previous chapter that font descriptors are a new way in iOS 7 to specify a font that matches a collection of attributes, rather than hard-coding a particular font like in previous versions of iOS.
     */
    UIFontDescriptor *baskerville = [UIFontDescriptor fontDescriptorWithFontAttributes:@{UIFontDescriptorFamilyAttribute: @"Baskerville"}];
    
    UIFontDescriptor *baskervilleBold = [baskerville fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    
    // 2. determine the current text size preference
    /**
     *  Determine the required point size of the body text; this allows you to honor the user's text size preferences without using the default font.
     */
    UIFontDescriptor *bodyFont = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    NSNumber *bodyFontSize = bodyFont.fontAttributes[UIFontDescriptorSizeAttribute];
    float bodyFontSizeValue = [bodyFontSize floatValue];
    
    // 3. create the attributes for the various styles
    /**
     *  Create various attributes for the styles to be used in the document such as the body and headings, using appropriate Baskerville font and various multiplications of the user's preferred body text size.
     */
    _bodyTextAttributes = [self attributesWithDescriptor:baskerville size:bodyFontSizeValue];
    _headingOneAttributes = [self attributesWithDescriptor:baskervilleBold
                                                      size:bodyFontSizeValue * 2.0f];
    _headingTwoAttributes = [self attributesWithDescriptor:baskervilleBold size:bodyFontSizeValue * 1.8f];
    _headingThreeAttributes = [self attributesWithDescriptor:baskervilleBold
                                                        size:bodyFontSizeValue * 1.4f];
}

- (NSDictionary *)attributesWithDescriptor:(UIFontDescriptor *)descriptor size:(float)size
{
    UIFont *font = [UIFont fontWithDescriptor:descriptor
                                         size:size];
    return @{NSFontAttributeName: font};
}

- (NSAttributedString *)parseMarkdownFile:(NSString *)path
{
    NSMutableAttributedString *parsedOutput = [[NSMutableAttributedString alloc] init];
    
    // 1. break the file into lines and iterate over each line
    /**
     *  The componentsSeparatedByCharactersInSet: method is used to split the text into an array of individual lines.
     */
    NSString *text = [NSString stringWithContentsOfFile:path
                                               encoding:NSUTF8StringEncoding
                                                  error:nil];
    NSArray *lines = [text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    for (__strong NSString *line in lines) {
        if ([line isEqualToString:@""]) {
            continue;
        }
        
        // 2. match the various 'heading' styles
        /**
         *  If the line starts with one or more 'hash' characters, the required tex attributes for this level of heading are obtained.
         */
        NSDictionary *textAttributes = _bodyTextAttributes;
        if (line.length > 3) {
            if ([[line substringToIndex:3] isEqualToString:@"###"]) {
                textAttributes = _headingThreeAttributes;
                line = [line substringFromIndex:3];
            } else if ([[line substringToIndex:2] isEqualToString:@"##"]) {
                textAttributes = _headingTwoAttributes;
                line = [line substringFromIndex:2];
            } else if ([[line substringToIndex:1] isEqualToString:@"#"]) {
                textAttributes = _headingOneAttributes;
                line = [line substringFromIndex:1];
            }
        }
        
        // 3. apply the attributes to this line of text
        /**
         *  An attributed text string is constructed, which takes the current line of text and applies the attributes determined in step(2).
         */
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:line attributes:textAttributes];
        
        // 4. append to the output
        /**
         *   Each complete line of text is appended to the output.
         */
        [parsedOutput appendAttributedString:attributedText];
        [parsedOutput appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n\n"]];
    }
    
    // 1. Locate images
    /**
     *  A regular expression is used to locate all the markdown images in the book text. You'll look at this regular expression in detail shortly.
     */
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\!\\[.*\\]\\((.*)\\)" options:0 error:nil];
    NSArray *matches = [regex matchesInString:[parsedOutput string]
                                      options:0
                                        range:NSMakeRange(0, parsedOutput.length)];
    
    // 2. Iterate over matches in reverse
    /**
     *  A for loop is used to iterate over the matches in reverse. This might seem a bit odd, but where is a perfectly good reason for this. Since each image tag is replaced with an attachment, the overall string length will decrease. Enumerating in reverse avoids having to recalculate the ranges returned by the regular expression.
     */
    for (NSTextCheckingResult *result in [matches reverseObjectEnumerator]) {
        NSRange matchRange = [result range];
        NSRange captureRange = [result rangeAtIndex:1];
        
        // 3. Create an attachment for each image
        /**
         *  An NSTextAttachment instance is created for each image.
         */
        NSTextAttachment *textAttachment = [NSTextAttachment new];
        textAttachment.image = [UIImage imageNamed:[parsedOutput.string substringWithRange:captureRange]];
        
        // 4. Replace the image markup with the attachment
        /**
         *  The image markdown is replaced with an attributed string based on this attachment
         */
        NSAttributedString *replacementString = [NSAttributedString attributedStringWithAttachment:textAttachment];
        [parsedOutput replaceCharactersInRange:matchRange withAttributedString:replacementString];
    }
    
    return parsedOutput;
}


@end
