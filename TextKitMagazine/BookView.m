//
//  BookView.m
//  TextKitMagazine
//
//  Created by Perry on 14-8-8.
//  Copyright (c) 2014年 Colin Eberhardt. All rights reserved.
//

#import "BookView.h"

@implementation BookView
{
    NSLayoutManager *_layoutManager;
    NSRange _wordCharacterRange;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.delegate = self;
        UIGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                             action:@selector(handleTap:)];
        [self addGestureRecognizer:recognizer];
    }
    return self;
}

- (void)handleTap:(UITapGestureRecognizer *)tapRecognizer
{
    NSTextStorage *textStorage = _layoutManager.textStorage;
    
    // 1
    /**
     *  First, locate the tapped instance of UITextView by iterating over all the subviews belonging to the view and check whether its frame contains the point of the tap.
     */
    CGPoint tappedLocation = [tapRecognizer locationInView:self];
    UITextView *tappedTextView = nil;
    for (UITextView *textView in [self textSubViews]) {
        if (CGRectContainsPoint(textView.frame, tappedLocation)) {
            tappedTextView = textView;
            break;
        }
    }
    if (!tappedTextView) {
        return;
    }
    
    // 2
    /**
     *  Next, convert the tap point into the coordinate system of the respective view and subtract the text container's margin accordingly.
     */
    CGPoint subViewLocation = [tapRecognizer locationInView:tappedTextView];
    subViewLocation.y -= 8.0;
    
    // 3
    /**
     *  Determine the index of the tapped glyph using NSLayoutManager and convert the glyph index into a character index. This allows you to look up the corresponding character in the text storage.
     */
    NSUInteger glyphIndex = [_layoutManager glyphIndexForPoint:subViewLocation
                                               inTextContainer:tappedTextView.textContainer];
    NSUInteger charIndex = [_layoutManager characterIndexForGlyphAtIndex:glyphIndex];
    
    // 4
    /**
     *  Determine whether the tapped character is a letter; it's a bit troublesome to perform dictionary lookups on spaces, numbers, and attachments.
     */
    if (![[NSCharacterSet letterCharacterSet] characterIsMember:[textStorage.string characterAtIndex:charIndex]]) {
        return;
    }
    
    // 5
    /**
     *  Expand the character index into a word range.
     */
    _wordCharacterRange = [self wordThatContainsCharacter:charIndex
                                                   string:textStorage.string];
    
    // 6
    /**
     *  Finally apply a text color attribute to the word range.
     */
    [textStorage addAttribute:NSForegroundColorAttributeName value:[UIColor redColor]
                        range:_wordCharacterRange];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self buildViewsForCurrentOffset];
}

- (void)navigateToCharacterLocation:(NSUInteger)location
{
    CGFloat offset = 0.0f;
    for (NSTextContainer *container in _layoutManager.textContainers) {
        NSRange glyphRange = [_layoutManager glyphRangeForTextContainer:container];
        NSRange charRange = [_layoutManager characterRangeForGlyphRange:glyphRange
                                                       actualGlyphRange:nil];
        
        if (location >= charRange.location && location < NSMaxRange(charRange)) {
            self.contentOffset = CGPointMake(offset, 0);
            [self buildViewsForCurrentOffset];
            return;
        }
        offset += self.bounds.size.width / 2.0f;
    }
}

- (void)buildViewsForCurrentOffset
{
    // 1
    /**
     *  Iterate over all instances of NSTextContainer that have been added to the layout manager.
     */
    NSLog(@"the text containers is %d",_layoutManager.textContainers.count);
    for (NSUInteger index = 0; index < _layoutManager.textContainers.count; index++) {
        // 2
        /**
         *  Obtain the view that renders this container. textViewForContainer: will return nil if a view is not present.
         */
        NSTextContainer *textContainer = _layoutManager.textContainers[index];
        UITextView *textView = [self textViewForContainer:textContainer];
        
        // 3
        /**
         *  Determine the frame for this view, and whether or not it should be rendered.
         */
        CGRect textViewRect = [self frameForViewAtIndex:index];
        if ([self shouldRenderView:textViewRect]) {
            // 4
            /**
             *  If it should be rendered, check whether it already . If it does, move it.
             */
            if (!textView) {
                NSLog(@"Adding view at index %u", index);
                UITextView *textView = [[UITextView alloc] initWithFrame:textViewRect textContainer:textContainer];
                [self addSubview:textView];
            }
        } else {
            // 5
            /**
             *  If it should be rendered, check whether it already exists. It it does, do noting; it not ,create it.
             */
            if (textView) {
                NSLog(@"Deleting view at index %u", index);
                [textView removeFromSuperview];
            }
        }
    }
}

- (void)buildFrames
{
    /*
    // create the text storage
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:self.bookMarkup];
    
    // create the layout manager
    _layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:_layoutManager];
    
    // create a container
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(self.bounds.size.width, FLT_MAX)];
    [_layoutManager addTextContainer:textContainer];
    
    // create a view
    UITextView *textView = [[UITextView alloc] initWithFrame:self.bounds textContainer:textContainer];
    textView.scrollEnabled = YES;
    [self addSubview:textView];
    */

    // create the text storage
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:self.bookMarkup];
    
    // create the layout manager
    _layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:_layoutManager];
    
    // build the frames
    NSRange range = NSMakeRange(0, 0);
    NSUInteger containerIndex = 0;
    while (NSMaxRange(range) < _layoutManager.numberOfGlyphs) {
        // 1
        /**
         *  Create a frame for the view at this index; you'll implement this method shortly.Remember, you are creating all of the text views necessary to display the entire book at once, and laying out the text views one at a time from left to right.
         */
        CGRect textViewRect = [self frameForViewAtIndex:containerIndex];
        NSLog(@"the text view rect frame is %@",NSStringFromCGRect(textViewRect));
        // 2
        /**
         *  Create an instance of NSTextContainer with a size based on the frame returned from frameForViewAtIndex:. Note the 16.0f magic number; you decrease the height by this amount as UITextView adds an 8.0f margin above and below the container.
         */
        CGSize containerSize = CGSizeMake(textViewRect.size.width, textViewRect.size.height - 16.0f);
        NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:containerSize];
        NSLog(@"the container size is %@",NSStringFromCGSize(containerSize));
        [_layoutManager addTextContainer:textContainer];
        
//        // 3
//        /**
//         *  Create the UITextView for this container.
//         */
//        UITextView *textView = [[UITextView alloc] initWithFrame:textViewRect textContainer:textContainer];
//        [self addSubview:textView];
        containerIndex++;
        
        // 4
        /**
         *  Determine the glyph range for the new text container. This value is used to determine whether further text containers are required.
         */
        range = [_layoutManager glyphRangeForTextContainer:textContainer];
    }
    self.contentOffset = CGPointMake(0, 0);
    [self buildViewsForCurrentOffset];
    
    // 5
    /**
     *  Finally update the size of the scroll view based on the number of containers created.
     */
    self.contentSize = CGSizeMake((self.bounds.size.width / 2) * (CGFloat)containerIndex, self.bounds.size.height);
    self.pagingEnabled = YES;
}

- (CGRect)frameForViewAtIndex:(NSUInteger)index
{
    CGRect textViewRect = CGRectMake(0, 0, self.bounds.size.width / 2, self.bounds.size.height);
    textViewRect = CGRectInset(textViewRect, 10.0, 20.0);
    textViewRect = CGRectOffset(textViewRect, (self.bounds.size.width / 2) * (CGFloat)index, 0.0);
    return textViewRect;
}

// return all the instances of UITextView that have been added as subvivews of BookView.
- (NSArray *)textSubViews
{
    NSMutableArray *views = [NSMutableArray new];
    for (UIView *subview in self.subviews) {
        if ([subview class] == [UITextView class]) {
            [views addObject:subview];
        }
    }
    return views;
}

//return owning UITextView for the NSTextContainer instance passed in, if one exists.
- (UITextView *)textViewForContainer:(NSTextContainer *)textContainer
{
    for (UITextView *textView in [self textSubViews]) {
        if (textView.textContainer == textContainer) {
            return textView;
        }
    }
    return nil;
}

// This method determines whether or not a view with the given frame should be rendered, based on the current content offset of the scroll view.
- (BOOL)shouldRenderView:(CGRect)viewFrame
{
    if (viewFrame.origin.x + viewFrame.size.width < (self.contentOffset.x - self.bounds.size.width)) {
        return NO;
    }
    if (viewFrame.origin.x > (self.contentOffset.x + self.bounds.size.width * 2.0)) {
        return NO;
    }
    return YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (NSRange)wordThatContainsCharacter:(NSUInteger)charIndex string:(NSString *)string
{
    NSUInteger startLocation = charIndex;
    while (startLocation > 0 && [[NSCharacterSet letterCharacterSet] characterIsMember:[string characterAtIndex:startLocation-1]]) {
        startLocation--;
    }
    NSUInteger endLocation = charIndex;
    while (endLocation < string.length && [[NSCharacterSet letterCharacterSet] characterIsMember:[string characterAtIndex:endLocation+1]]) {
        endLocation ++;
    }
    return NSMakeRange(startLocation, endLocation-startLocation+1);
}

@end
