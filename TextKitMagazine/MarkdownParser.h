//
//  MarkdownParser.h
//  TextKitMagazine
//
//  Created by Perry on 14-8-12.
//  Copyright (c) 2014年 Colin Eberhardt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MarkdownParser : NSObject

- (NSAttributedString *)parseMarkdownFile:(NSString *)path;

@end
