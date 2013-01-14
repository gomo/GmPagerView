//
//  GmPagerViewPage.h
//  GmPagerView
//
//  Created by Masamoto Miyata on 2013/01/07.
//  Copyright (c) 2013年 Masamoto Miyata. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GmPagerView;
@interface GmPagerViewPage : UIView
{
    
}

@property(nonatomic, strong) NSString *reuseIdentifier;
@property(nonatomic, strong) id pageKey;
@property(nonatomic, weak) GmPagerView *pagerView;

- (void)prepareForReuse;

@end
