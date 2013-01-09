//
//  GmPagerViewPage.m
//  GmPagerView
//
//  Created by Masamoto Miyata on 2013/01/07.
//  Copyright (c) 2013年 Masamoto Miyata. All rights reserved.
//

#import "GmPagerViewPage.h"

@implementation GmPagerViewPage

@synthesize reuseIdentifier = _reuseIdentifier;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
{
    self = [super init];
    if (self)
    {
        _reuseIdentifier = reuseIdentifier;
    }
    return self;
}

@end
