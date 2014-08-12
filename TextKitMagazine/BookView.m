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
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
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
        
        // 3
        /**
         *  Create the UITextView for this container.
         */
        UITextView *textView = [[UITextView alloc] initWithFrame:textViewRect textContainer:textContainer];
        [self addSubview:textView];
        containerIndex++;
        
        // 4
        /**
         *  Determine the glyph range for the new text container. This value is used to determine whether further text containers are required.
         */
        range = [_layoutManager glyphRangeForTextContainer:textContainer];
    }
    
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/



@end
