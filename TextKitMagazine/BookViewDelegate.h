//
//  BookViewDelegate.h
//  TextKitMagazine
//
//  Created by Perry on 14-8-15.
//  Copyright (c) 2014年 Colin Eberhardt. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BookView;
@protocol BookViewDelegate <NSObject>

- (void)bookView:(BookView *)bookView didHighlightWord:(NSString *)word inRect:(CGRect)rect;

@end
