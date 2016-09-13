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
@class DDScrollPageView;
@protocol DDScrollPageViewDataSource<NSObject>
@required
- (NSInteger)numberOfViewsInScrollPageView:(DDScrollPageView *)scrollPageView;
- (UIView *)scrollPageView:(DDScrollPageView *)scrollPageView viewForIndex:(NSInteger)index;
@end
typedef enum : NSUInteger {
    DDScrollPageViewDirection_Horizontal,
    DDScrollPageViewDirection_Vertical,
} DDScrollPageViewDirection;
@interface DDScrollPageView : UIView
/**是否循环，默认是NO*/
@property (nonatomic, assign) BOOL isCycle;
/**是否自动播放，默认是NO*/
@property (nonatomic, assign) BOOL isAutoPlay;
/**设置滚动方向，默认是DDScrollPageView_HorizontalDirection*/
@property (nonatomic, assign) DDScrollPageViewDirection direction;
@property (nonatomic, assign) id<DDScrollPageViewDataSource> dataSource;
-(void)reloadData;
-(void)setPageIndicatorImage:(UIImage*)pageIndicatorImage andCurrentPageIndicatorImage:(UIImage*)currentPageIndicatorImage;
@end
