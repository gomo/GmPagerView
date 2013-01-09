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
    GmPagerViewDirectionLeft,
    GmPagerViewDirectionRight
} GmPagerViewDirection;

@class GmPagerView;
@protocol GmPagerViewDataSource

- (id)initialKeyForPagerView:(GmPagerView *)pagerView;
- (id)pagerView:(GmPagerView *)pagerView keyWithBaseKey:(id)baseKey direction:(GmPagerViewDirection)direction;
- (GmPagerViewPage *)pagerView:(GmPagerView *)pagerView pageForKey:(id)key;

@end

@protocol GmPagerViewDelegate

- (void)pagerView:(GmPagerView *)pagerView willShowPage:(GmPagerViewPage *)page fromPage:(GmPagerViewPage *)prevPage;
- (void)pagerView:(GmPagerView *)pagerView didShowPage:(GmPagerViewPage *)page fromPage:(GmPagerViewPage *)prevPage;

@end

@interface GmPagerView : UIScrollView<UIScrollViewDelegate>
{
    NSMutableDictionary *_cachedPages;
    NSInteger _currentPagePosition;
    GmPagerViewPage *_displayPage;
    NSMutableDictionary *_reusablePages;
}

@property (nonatomic, weak) id<GmPagerViewDataSource> pagerViewDataSource;
@property (nonatomic, weak) id<GmPagerViewDelegate> pagerViewDelegate;

- (void)loadPage;
- (GmPagerViewPage *)dequeueReusablePageWithIdentifier:(NSString *)identifier;

@end
