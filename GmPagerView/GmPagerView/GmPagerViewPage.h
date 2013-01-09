//
//  GmPagerViewPage.h
//  GmPagerView
//
//  Created by Masamoto Miyata on 2013/01/07.
//  Copyright (c) 2013年 Masamoto Miyata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GmPagerViewPage : UIView
{
    NSString *_reuseIdentifier;
}

@property(nonatomic, readonly) NSString *reuseIdentifier;
@property(nonatomic, strong) id pageKey;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end
