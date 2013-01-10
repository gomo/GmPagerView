//
//  GmPagerViewPage.m
//  GmPagerView
//
//  Created by Masamoto Miyata on 2013/01/07.
//  Copyright (c) 2013年 Masamoto Miyata. All rights reserved.
//

#import "GmPagerViewPage.h"

@implementation GmPagerViewPage

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ [pageKey = %@]", [super description], self.pageKey];
}

- (void)prepareForReuse
{
    
}

@end
