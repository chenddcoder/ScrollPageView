//
//  ScrollPageView.m
//  ScrollPageController
//
//  Created by chendd on 15/6/3.
//  Copyright (c) 2015年 icfcc. All rights reserved.
//

#import "ScrollPageView.h"
#import <SMPageControl/SMPageControl.h>
@interface ScrollPageView()<UIScrollViewDelegate>
{
    NSMutableArray * pageViews;//ScrollView中显示的所有View
    UIScrollView * scrollView;//宽高等于initWithFrame中的宽高
    CGRect scrollViewRect;
    SMPageControl * pageControl;//用于控制翻页，可以设定ScrollPageView自动翻页
}
@end
@implementation ScrollPageView
-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        self.frame=frame;
        scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        scrollView.backgroundColor=[UIColor clearColor];
        scrollView.pagingEnabled=YES;
        scrollView.showsHorizontalScrollIndicator=NO;
        scrollView.delegate=self;
        scrollViewRect=frame;
        [self addSubview:scrollView];
        //添加分页控制器
        pageControl=[[SMPageControl alloc]initWithFrame:CGRectMake(0, frame.size.height-40, frame.size.width, 30)];
        pageControl.backgroundColor=[UIColor clearColor];
        [pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:pageControl];
    }
    return self;
}
-(void)clearScrollView{
    for (UIView * v in scrollView.subviews) {
        [v removeFromSuperview];
    }
}
-(void)reloadData{
    //清空scrollView的subView
    [self clearScrollView];
    NSInteger numberOfViews=0;
    if ([_dataSource respondsToSelector:@selector(numberOfViewsInScrollPageView:)]) {
        numberOfViews=[_dataSource numberOfViewsInScrollPageView:self];
        //根据View的个数，决定scrollView的contentView
        //如果是ScrollPageViewDirectionHorizontal,宽度 x numberOfViews
        scrollView.contentSize=CGSizeMake(scrollViewRect.size.width*numberOfViews, scrollViewRect.size.height);
        pageControl.numberOfPages=numberOfViews;
    }
    if (numberOfViews>0) {
        if ([_dataSource respondsToSelector:@selector(scrollPageView:viewForIndex:)]) {
            for (NSInteger i=0; i<numberOfViews; i++) {
                UIView * view=[_dataSource scrollPageView:self viewForIndex:i];
                [self addViewToScrollView:view ForIndex:i];
            }
        }
    }
}
-(void)addViewToScrollView:(UIView*)view ForIndex:(NSInteger)index{
    //根据index偏移view
    CGRect rect=view.frame;
    view.frame=CGRectMake(rect.origin.x+scrollViewRect.size.width*index, rect.origin.y, scrollViewRect.size.width, rect.size.height) ;
    [scrollView addSubview:view];
}

-(void)setPageIndicatorImage:(UIImage*)pageIndicatorImage andCurrentPageIndicatorImage:(UIImage*)currentPageIndicatorImage{
    pageControl.pageIndicatorImage=pageIndicatorImage;
    pageControl.currentPageIndicatorImage=currentPageIndicatorImage;
}
-(void)changePage:(id)sender{
    NSInteger page = pageControl.currentPage;
    [scrollView setContentOffset:CGPointMake(scrollViewRect.size.width * page, 0)];
}
#pragma mark UIScrollViewDelegate
-(void)scrollViewDidScroll:(id)pscrollView{
    int page=scrollView.contentOffset.x/scrollViewRect.size.width;
    pageControl.currentPage=page;
}
@end
