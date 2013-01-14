//
//  GmPagerView.m
//  GmPagerView
//
//  Created by Masamoto Miyata on 2013/01/07.
//  Copyright (c) 2013年 Masamoto Miyata. All rights reserved.
//

#import "GmPagerView.h"

@implementation GmPagerView

@synthesize displayPage = _displayPage;
@synthesize hasNextPage = _hasNextPage;
@synthesize hasPrevPage = _hasPrevPage;

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
        
        _fixing = NO;
        _nextPage = nil;
        
        _reusablePages = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (void)loadPage
{
    [self loadPageWithKey:[self.pagerViewDataSource firstKeyForPagerView:self]];
}

- (void)loadPageWithKey:(id)key
{
    for (UIView *view in self.subviews)
    {
        if([view isKindOfClass:[GmPagerViewPage class]])
        {
            [view removeFromSuperview];
        }
    }
    
    _cachedPages = nil;
    _cachedPages = [[NSMutableDictionary alloc]init];
    
    GmPagerViewPage *displayPage = [self pageWithKey:key];
    [self.pagerViewDelegate pagerView:self willShowPage:displayPage fromPage:nil];
    [self loadPagesWithDisplayKey:displayPage];
}

- (void)nextPageAnimated:(BOOL)animated
{
    if(self.hasNextPage)
    {
        NSInteger targetPos = _currentPagePosition + 1;
        [self setContentOffset:CGPointMake(self.frame.size.width * targetPos, 0) animated:animated];
    }
}

- (void)prevPageAnimated:(BOOL)animated
{
    if(self.hasPrevPage)
    {
        NSInteger targetPos = _currentPagePosition - 1;
        [self setContentOffset:CGPointMake(self.frame.size.width * targetPos, 0) animated:animated];
    }
}

- (GmPagerViewPage *)dequeueReusablePageWithIdentifier:(NSString *)identifier
{
    NSMutableArray *caches = [_reusablePages objectForKey:identifier];
    if(caches == nil)
    {
        return nil;
    }
    
    GmPagerViewPage *page = nil;
    if(caches.count > 0)
    {
        page = [caches objectAtIndex:0];
        [caches removeObjectAtIndex:0];
    }
    
    return page;
}

#pragma mark - private
- (void)loadPagesWithDisplayKey:(GmPagerViewPage *)displayPage
{
    //GmPagerViewPage *displayPage = [self pageWithKey:displayKey];
    
    
    GmPagerViewPage *leftPage = nil;
    id leftKey = [self.pagerViewDataSource pagerView:self keyWithBaseKey:displayPage.pageKey direction:GmPagerViewDirectionLeft];
    
    if(leftKey != nil)
    {
        leftPage = [self pageWithKey:leftKey];
    }
    
    GmPagerViewPage *rightPage = nil;
    id rightKey = [self.pagerViewDataSource pagerView:self keyWithBaseKey:displayPage.pageKey direction:GmPagerViewDirectionRight];
    if(rightKey != nil)
    {
        rightPage = [self pageWithKey:rightKey];
    }
    
    _fixing = YES;
    
    if(leftPage == nil && rightPage == nil)
    {
        self.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
        [self movePageToPosition:0];
        [self setPage:displayPage toPosition:0 withKey:displayPage.pageKey];
        _currentPagePosition = 0;
        _hasNextPage = NO;
        _hasPrevPage = NO;
    }
    else if(leftPage == nil)
    {
        self.contentSize = CGSizeMake(self.frame.size.width * 2, self.frame.size.height);
        [self movePageToPosition:0];
        [self setPage:displayPage toPosition:0 withKey:displayPage.pageKey];
        [self setPage:rightPage toPosition:1 withKey:rightKey];
        _currentPagePosition = 0;
        _hasNextPage = YES;
        _hasPrevPage = NO;
    }
    else if(rightPage == nil)
    {
        self.contentSize = CGSizeMake(self.frame.size.width * 2, self.frame.size.height);
        [self movePageToPosition:1];
        [self setPage:displayPage toPosition:1 withKey:displayPage.pageKey];
        [self setPage:leftPage toPosition:0 withKey:leftKey];
        _currentPagePosition = 1;
        _hasNextPage = NO;
        _hasPrevPage = YES;
    }
    else
    {
        self.contentSize = CGSizeMake(self.frame.size.width * 3, self.frame.size.height);
        [self movePageToPosition:1];
        [self setPage:leftPage toPosition:0 withKey:leftKey];
        [self setPage:displayPage toPosition:1 withKey:displayPage.pageKey];
        [self setPage:rightPage toPosition:2 withKey:rightKey];
        _currentPagePosition = 1;
        _hasNextPage = YES;
        _hasPrevPage = YES;
    }
    
    [self.pagerViewDelegate pagerView:self didShowPage:displayPage fromPage:_displayPage];
    
    _displayPage = displayPage;
    
    _fixing = NO;
}

- (void) setPage:(GmPagerViewPage *)page toPosition:(NSInteger)position withKey:(id)key
{
    page.frame = CGRectMake(self.frame.size.width * position, 0, self.frame.size.width, self.frame.size.height);
    [self addSubview:page];
    
    [_cachedPages setObject:page forKey:[NSNumber numberWithInteger:position]];
}

- (void)clearCacheAtPagePosition:(NSInteger)position
{
    NSNumber *posNumber = [NSNumber numberWithInteger:position];
    GmPagerViewPage *page = [_cachedPages objectForKey:posNumber];
    
    if(page != nil)
    {
        [_cachedPages removeObjectForKey:posNumber];
        [page removeFromSuperview];
        page.pageKey = nil;
        [page prepareForReuse];
        
        NSAssert1(page.reuseIdentifier != nil, @"reuseIdentifier is null for %@", page);
        
        NSMutableArray *caches = [_reusablePages objectForKey:page.reuseIdentifier];
        if(caches == nil)
        {
            caches = [[NSMutableArray alloc]init];
            [_reusablePages setObject:caches forKey:page.reuseIdentifier];
        }
        
        [caches addObject:page];
    }
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
        page = [_cachedPages objectForKey:posNum];
        if([page.pageKey isEqual:key])
        {
            removePosNum = posNum;
            break;
        }
        else
        {
            page = nil;
        }
    }
    
    if(removePosNum != nil)
    {
        [_cachedPages removeObjectForKey:removePosNum];
    }
    
    return page;
}

- (GmPagerViewPage *)pageWithKey:(id)key
{
    GmPagerViewPage *page = [self pageFromCache:key];
    
    if(page == nil)
    {
        page = [self.pagerViewDataSource pagerView:self pageForKey:key];
        page.pageKey = key;
        page.pagerView = self;
    }
    
    return page;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(!_fixing)
    {
        CGFloat pageWidth = scrollView.frame.size.width;
        float fractionalPage = scrollView.contentOffset.x / pageWidth;
        if(_currentPagePosition != fractionalPage)
        {
            NSInteger halfPage = lround(fractionalPage);
            if(_nextPage == nil && halfPage != _currentPagePosition)
            {
                id nextKey;
                if(halfPage > _currentPagePosition)
                {
                    nextKey = [self.pagerViewDataSource pagerView:self keyWithBaseKey:_displayPage.pageKey direction:GmPagerViewDirectionRight];
                }
                else
                {
                    nextKey = [self.pagerViewDataSource pagerView:self keyWithBaseKey:_displayPage.pageKey direction:GmPagerViewDirectionLeft];
                }
                
                _nextPage = [self pageWithKey:nextKey];
                [self.pagerViewDelegate pagerView:self willShowPage:_nextPage fromPage:_displayPage];
            }
            
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
                if(newPage > _currentPagePosition)
                {
                    [self clearCacheAtPagePosition:0];
                }
                else
                {
                    [self clearCacheAtPagePosition:2];
                }
                
                [self loadPagesWithDisplayKey:_nextPage];
                _nextPage = nil;
            }
        }
    }
}

@end
