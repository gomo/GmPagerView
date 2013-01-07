//
//  GmPagerView.m
//  GmPagerView
//
//  Created by Masamoto Miyata on 2013/01/07.
//  Copyright (c) 2013年 Masamoto Miyata. All rights reserved.
//

#import "GmPagerView.h"

@implementation GmPagerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.delegate = self;
        self.pagingEnabled = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.scrollsToTop = NO;
    }
    return self;
}

- (void)loadPage
{
    _cachedPages = [[NSMutableDictionary alloc]init];
    
    if(_currentUniqueKey == nil)
    {
        _currentUniqueKey = [self.pagerViewDataSource uniqueKeyInitialForPagerView:self];
    }
    
    [self loadPagesWithDisplayUniqueKey:_currentUniqueKey];
}

#pragma mark - private
- (void)loadPagesWithDisplayUniqueKey:(id)displayUniqueKey
{
    GmPagerViewPage *displayPage = [self loadPageWithUniqueKey:displayUniqueKey];
    GmPagerViewPage *prevPage = [self loadPageWithBaseUniqueKey:displayUniqueKey direction:GmPagerViewDirectionPrev];
    GmPagerViewPage *nextPage = [self loadPageWithBaseUniqueKey:displayUniqueKey direction:GmPagerViewDirectionNext];
    
    if(prevPage == nil && nextPage == nil)
    {
        self.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
        displayPage.frame = [self createRectForPagePosition:0];
        [self addSubview:displayPage];
        _currentPagePosition = 0;
    }
    else if(prevPage == nil)
    {
        self.contentSize = CGSizeMake(self.frame.size.width * 2, self.frame.size.height);
        displayPage.frame = [self createRectForPagePosition:0];
        nextPage.frame = [self createRectForPagePosition:1];
        [self addSubview:displayPage];
        [self addSubview:nextPage];
        _currentPagePosition = 0;
    }
    else if(nextPage == nil)
    {
        self.contentSize = CGSizeMake(self.frame.size.width * 2, self.frame.size.height);
        displayPage.frame = [self createRectForPagePosition:1];
        prevPage.frame = [self createRectForPagePosition:0];
        [self movePageToPosition:1];
        [self addSubview:displayPage];
        [self addSubview:prevPage];
        _currentPagePosition = 1;
    }
    else
    {
        self.contentSize = CGSizeMake(self.frame.size.width * 3, self.frame.size.height);
        displayPage.frame = [self createRectForPagePosition:1];
        prevPage.frame = [self createRectForPagePosition:0];
        nextPage.frame = [self createRectForPagePosition:2];
        [self movePageToPosition:1];
        [self addSubview:displayPage];
        [self addSubview:prevPage];
        [self addSubview:nextPage];
        _currentPagePosition = 1;
    }
    
    _currentUniqueKey = displayUniqueKey;
}

- (void) movePageToPosition:(NSInteger)position
{
    self.contentOffset = CGPointMake(self.frame.size.width * position, 0);
}

- (CGRect)createRectForPagePosition:(NSInteger)position
{
    return CGRectMake(self.frame.size.width * position, 0, self.frame.size.width, self.frame.size.height);
}

- (GmPagerViewPage *)loadPageWithUniqueKey:(id)uniqueKey
{
    GmPagerViewPage *page = [_cachedPages objectForKey:uniqueKey];
    if(page == nil)
    {
        page = [self.pagerViewDataSource pageWithUniqueKey:uniqueKey forPagerView:self];
        [_cachedPages setObject:page forKey:uniqueKey];
    }
    
    return page;
}

- (GmPagerViewPage *)loadPageWithBaseUniqueKey:(id)baseUniqueKey direction:(GmPagerViewDirection)direction
{
    GmPagerViewPage *page = nil;
    id uniqueKey = [self.pagerViewDataSource uniqueKeyWithBaseUniqueKey:baseUniqueKey direction:direction forPagerView:self];
    if(uniqueKey != nil)
    {
        page = [self loadPageWithUniqueKey:uniqueKey];
    }
    
    return page;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    
    if(_currentPagePosition != fractionalPage)
    {
        NSInteger newPage;
        if(fractionalPage > _currentPagePosition)
        {
            newPage = floorf(fractionalPage);
        }
        else if(fractionalPage < _currentPagePosition)
        {
            newPage = ceilf(fractionalPage);
        }
        
        if(newPage != _currentPagePosition)
        {
            id uniqueKey;
            if(newPage > _currentPagePosition)
            {
                uniqueKey = [self.pagerViewDataSource uniqueKeyWithBaseUniqueKey:_currentUniqueKey direction:GmPagerViewDirectionNext forPagerView:self];
            }
            else
            {
                uniqueKey = [self.pagerViewDataSource uniqueKeyWithBaseUniqueKey:_currentUniqueKey direction:GmPagerViewDirectionPrev forPagerView:self];
            }
            
            [self loadPagesWithDisplayUniqueKey:uniqueKey];
        }
    }
}

@end
