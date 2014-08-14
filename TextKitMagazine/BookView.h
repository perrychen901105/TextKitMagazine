//
//  BookView.h
//  TextKitMagazine
//
//  Created by Perry on 14-8-8.
//  Copyright (c) 2014年 Colin Eberhardt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookView : UIScrollView<UIScrollViewDelegate>

@property (nonatomic, copy) NSAttributedString *bookMarkup;

- (void)buildFrames;
- (void)navigateToCharacterLocation:(NSUInteger)location;

@end
