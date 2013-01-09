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
        
        _reusablePages = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (void)loadPage
{
    _cachedPages = [[NSMutableDictionary alloc]initWithCapacity:3];
    
    if(_currentKey == nil)
    {
        _currentKey = [self.pagerViewDataSource initialKeyForPagerView:self];
    }
    
    [self loadPagesWithDisplayKey:_currentKey];
}

- (GmPagerViewPage *)dequeueReusablePageWithIdentifier:(NSString *)identifier
{
    GmPagerViewPage *page = [_reusablePages objectForKey:identifier];
    [_reusablePages removeObjectForKey:identifier];
    return page;
}

#pragma mark - private
- (void)loadPagesWithDisplayKey:(id)displayKey
{
    GmPagerViewPage *displayPage = [self loadPageWithKey:displayKey];
    
    GmPagerViewPage *prevPage = nil;
    id prevKey = [self.pagerViewDataSource pagerView:self keyWithBaseKey:displayKey direction:GmPagerViewDirectionPrev];
    if(prevKey != nil)
    {
        prevPage = [self loadPageWithKey:prevKey];
    }
    
    GmPagerViewPage *nextPage = nil;
    id nextvKey = [self.pagerViewDataSource pagerView:self keyWithBaseKey:displayKey direction:GmPagerViewDirectionNext];
    if(nextvKey != nil)
    {
        nextPage = [self loadPageWithKey:nextvKey];
    }
    
    if(prevPage == nil && nextPage == nil)
    {
        self.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
        [self setPage:displayPage toPosition:0 withKey:displayKey];
        _currentPagePosition = 0;
    }
    else if(prevPage == nil)
    {
        self.contentSize = CGSizeMake(self.frame.size.width * 2, self.frame.size.height);
        [self setPage:displayPage toPosition:0 withKey:displayKey];
        [self setPage:nextPage toPosition:1 withKey:nextvKey];
        _currentPagePosition = 0;
    }
    else if(nextPage == nil)
    {
        self.contentSize = CGSizeMake(self.frame.size.width * 2, self.frame.size.height);
        [self movePageToPosition:1];
        [self setPage:displayPage toPosition:1 withKey:displayKey];
        [self setPage:prevPage toPosition:0 withKey:prevKey];
        _currentPagePosition = 1;
    }
    else
    {
        self.contentSize = CGSizeMake(self.frame.size.width * 3, self.frame.size.height);
        [self movePageToPosition:1];
        [self setPage:prevPage toPosition:0 withKey:prevKey];
        [self setPage:displayPage toPosition:1 withKey:displayKey];
        [self setPage:nextPage toPosition:2 withKey:nextvKey];
        _currentPagePosition = 1;
    }
    
    _currentKey = displayKey;
}

- (void) setPage:(GmPagerViewPage *)page toPosition:(NSInteger)position withKey:(id)key
{
    page.frame = CGRectMake(self.frame.size.width * position, 0, self.frame.size.width, self.frame.size.height);
    [self addSubview:page];
    
    [_cachedPages setObject:@{@"page":page, @"key":key} forKey:[NSNumber numberWithInteger:position]];
}

- (void)clearCacheAtPagePosition:(NSInteger)position
{
    NSNumber *posNumber = [NSNumber numberWithInteger:position];
    
    NSDictionary *dic = [_cachedPages objectForKey:posNumber];
    [_cachedPages removeObjectForKey:posNumber];
    GmPagerViewPage *page = [dic objectForKey:@"page"];
    
    [page removeFromSuperview];
    
    [_reusablePages setObject:page forKey:page.reuseIdentifier];
}

- (void) movePageToPosition:(NSInteger)position
{
    self.contentOffset = CGPointMake(self.frame.size.width * position, 0);
}

- (GmPagerViewPage *)pageFromCache:(id)key
{
    GmPagerViewPage *page = nil;
    for (NSNumber *posNum in _cachedPages)
    {
        NSDictionary *dic = [_cachedPages objectForKey:posNum];
        id targetKey = [dic objectForKey:@"key"];
        if([targetKey isEqual:key])
        {
            page = [dic objectForKey:@"page"];
            break;
        }
    }
    
    return page;
}

- (GmPagerViewPage *)loadPageWithKey:(id)key
{
    GmPagerViewPage *page = [self pageFromCache:key];
    
    if(page == nil)
    {
        page = [self.pagerViewDataSource pagerView:self pageForKey:key];
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
            id key;
            if(newPage > _currentPagePosition)
            {
                key = [self.pagerViewDataSource pagerView:self keyWithBaseKey:_currentKey direction:GmPagerViewDirectionNext];
                if(_cachedPages.count == 3)
                {
                    [self clearCacheAtPagePosition:0];
                }
            }
            else
            {
                key = [self.pagerViewDataSource pagerView:self keyWithBaseKey:_currentKey direction:GmPagerViewDirectionPrev];
                if(_cachedPages.count == 3)
                {
                    [self clearCacheAtPagePosition:2];
                }
            }
            
            [self loadPagesWithDisplayKey:key];
        }
    }
}

@end
