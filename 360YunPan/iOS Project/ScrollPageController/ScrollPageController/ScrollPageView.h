//
//  ScrollPageView.h
//  ScrollPageController
//
//  Created by chendd on 15/6/3.
//  Copyright (c) 2015年 icfcc. All rights reserved.
//
//用于简化ScrollView与PageControll使用，仅支持横向滚动
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class ScrollPageView;
@protocol ScrollPageViewDataSource<NSObject>
@required
- (NSInteger)numberOfViewsInScrollPageView:(ScrollPageView *)scrollPageView;
- (UIView *)scrollPageView:(ScrollPageView *)scrollPageView viewForIndex:(NSInteger)index;
@end

@interface ScrollPageView : UIView
@property (nonatomic, assign) id<ScrollPageViewDataSource> dataSource;
-(void)reloadData;
-(void)setPageIndicatorImage:(UIImage*)pageIndicatorImage andCurrentPageIndicatorImage:(UIImage*)currentPageIndicatorImage;
@end
