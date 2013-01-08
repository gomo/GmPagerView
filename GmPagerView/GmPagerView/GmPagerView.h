//
//  GmPagerView.h
//  GmPagerView
//
//  Created by Masamoto Miyata on 2013/01/07.
//  Copyright (c) 2013年 Masamoto Miyata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GmPagerViewPage.h"

typedef enum {
    GmPagerViewDirectionPrev,
    GmPagerViewDirectionNext
} GmPagerViewDirection;

@class GmPagerView;
@protocol GmPagerViewDataSource

- (id)initialKeyForPagerView:(GmPagerView *)pagerView;
- (id)pagerView:(GmPagerView *)pagerView keyWithBaseKey:(id)baseKey direction:(GmPagerViewDirection)direction;
- (GmPagerViewPage *)pagerView:(GmPagerView *)pagerView pageForKey:(id)key;

@end

@protocol GmPagerViewDelegate

- (void)pagerView:(GmPagerView *)pagerView didShowPage:(GmPagerViewPage *)page;

@end

@interface GmPagerView : UIScrollView<UIScrollViewDelegate>
{
    NSMutableDictionary *_cachedPages;
    NSInteger _currentPagePosition;
    id _prevKey;
    id _currentKey;
    BOOL _isFixingOffset;
}

@property (nonatomic, weak) id<GmPagerViewDataSource> pagerViewDataSource;
@property (nonatomic, weak) id<GmPagerViewDelegate> pagerViewDelegate;

- (void)loadPage;

@end
