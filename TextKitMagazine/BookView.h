//
//  BookView.h
//  TextKitMagazine
//
//  Created by Perry on 14-8-8.
//  Copyright (c) 2014年 Colin Eberhardt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookViewDelegate.h"

@interface BookView : UIScrollView<UIScrollViewDelegate>

@property (nonatomic, copy) NSAttributedString *bookMarkup;
@property (nonatomic, weak) id<BookViewDelegate> bookViewDelegate;

- (void)removeWordHighlight;
- (void)buildFrames;
- (void)navigateToCharacterLocation:(NSUInteger)location;

@end
