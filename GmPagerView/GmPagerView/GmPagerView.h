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

- (id<NSCopying>)uniqueKeyInitialForPagerView:(GmPagerView *)pagerView;
- (id<NSCopying>)uniqueKeyWithBaseUniqueKey:(id<NSCopying>)baseUniqueKey direction:(GmPagerViewDirection) direction forPagerView:(GmPagerView *)pagerView;
- (GmPagerViewPage *)pageWithUniqueKey:(id<NSCopying>)uniqueKey forPagerView:(GmPagerView *)pagerView;

@end

@protocol GmPagerViewDelegate

- (void)pagerView:(GmPagerView *)pagerView didShowPage:(GmPagerViewPage *)page;

@end

@interface GmPagerView : UIScrollView<UIScrollViewDelegate>
{
    NSMutableDictionary *_cachedPages;
    NSInteger _currentPagePosition;
    id _currentUniqueKey;
}

@property (nonatomic, weak) id<GmPagerViewDataSource> pagerViewDataSource;
@property (nonatomic, weak) id<GmPagerViewDelegate> pagerViewDelegate;

- (void)loadPage;

@end
