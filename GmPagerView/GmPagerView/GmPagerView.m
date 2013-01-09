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
    _cachedPages = [[NSMutableDictionary alloc]init];
    
    [self loadPagesWithDisplayKey:[self.pagerViewDataSource initialKeyForPagerView:self]];
}

- (GmPagerViewPage *)dequeueReusablePageWithIdentifier:(NSString *)identifier
{
    NSMutableArray *caches = [_reusablePages objectForKey:identifier];
    if(caches == nil)
    {
        return nil;
    }
    
    GmPagerViewPage *page = [caches objectAtIndex:0];
    [caches removeObjectAtIndex:0];
    
    return page;
}

#pragma mark - private
- (void)loadPagesWithDisplayKey:(id)displayKey
{
    GmPagerViewPage *displayPage = [self loadPageWithKey:displayKey];
    
    [self.pagerViewDelegate pagerView:self willShowPage:displayPage fromPage:_displayPage];
    
    GmPagerViewPage *leftPage = nil;
    id leftKey = [self.pagerViewDataSource pagerView:self keyWithBaseKey:displayKey direction:GmPagerViewDirectionLeft];
    
    if(leftKey != nil)
    {
        leftPage = [self loadPageWithKey:leftKey];
    }
    
    GmPagerViewPage *rightPage = nil;
    id rightKey = [self.pagerViewDataSource pagerView:self keyWithBaseKey:displayKey direction:GmPagerViewDirectionRight];
    if(rightKey != nil)
    {
        rightPage = [self loadPageWithKey:rightKey];
    }
    
    if(leftPage == nil && rightPage == nil)
    {
        self.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
        [self setPage:displayPage toPosition:0 withKey:displayKey];
        _currentPagePosition = 0;
    }
    else if(leftPage == nil)
    {
        self.contentSize = CGSizeMake(self.frame.size.width * 2, self.frame.size.height);
        [self setPage:displayPage toPosition:0 withKey:displayKey];
        [self setPage:rightPage toPosition:1 withKey:rightKey];
        _currentPagePosition = 0;
    }
    else if(rightPage == nil)
    {
        self.contentSize = CGSizeMake(self.frame.size.width * 2, self.frame.size.height);
        [self movePageToPosition:1];
        [self setPage:displayPage toPosition:1 withKey:displayKey];
        [self setPage:leftPage toPosition:0 withKey:leftKey];
        _currentPagePosition = 1;
    }
    else
    {
        self.contentSize = CGSizeMake(self.frame.size.width * 3, self.frame.size.height);
        [self movePageToPosition:1];
        [self setPage:leftPage toPosition:0 withKey:leftKey];
        [self setPage:displayPage toPosition:1 withKey:displayKey];
        [self setPage:rightPage toPosition:2 withKey:rightKey];
        _currentPagePosition = 1;
    }
    
    [self.pagerViewDelegate pagerView:self didShowPage:displayPage fromPage:_displayPage];
    
    _displayPage = displayPage;
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
    page.pageKey = nil;
    
    NSMutableArray *caches = [_reusablePages objectForKey:page.reuseIdentifier];
    if(caches == nil)
    {
        caches = [[NSMutableArray alloc]init];
        [_reusablePages setObject:caches forKey:page.reuseIdentifier];
    }
    
    [caches addObject:page];
}

- (void) movePageToPosition:(NSInteger)position
{
    self.contentOffset = CGPointMake(self.frame.size.width * position, 0);
}

- (GmPagerViewPage *)pageFromCache:(id)key
{
    GmPagerViewPage *page = nil;
    NSNumber *removePosNum = nil;
    for (NSNumber *posNum in _cachedPages)
    {
        NSDictionary *dic = [_cachedPages objectForKey:posNum];
        id targetKey = [dic objectForKey:@"key"];
        if([targetKey isEqual:key])
        {
            page = [dic objectForKey:@"page"];
            removePosNum = posNum;
            break;
        }
    }
    
    if(removePosNum != nil)
    {
        [_cachedPages removeObjectForKey:removePosNum];
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
    
    page.pageKey = key;
    
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
                key = [self.pagerViewDataSource pagerView:self keyWithBaseKey:_displayPage.pageKey direction:GmPagerViewDirectionRight];
                if(_cachedPages.count == 3)
                {
                    [self clearCacheAtPagePosition:0];
                }
            }
            else
            {
                key = [self.pagerViewDataSource pagerView:self keyWithBaseKey:_displayPage.pageKey direction:GmPagerViewDirectionLeft];
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
