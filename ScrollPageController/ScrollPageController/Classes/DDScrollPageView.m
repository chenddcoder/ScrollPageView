//
//  ScrollPageView.m
//  ScrollPageController
//
//  Created by chendd on 15/6/3.
//  Copyright (c) 2015年 icfcc. All rights reserved.
//

#import "DDScrollPageView.h"
#import <SMPageControl/SMPageControl.h>
@interface DDScrollPageView()<UIScrollViewDelegate>
{
    CGRect scrollViewRect;
    dispatch_source_t timer;//定时器用于自动滚页
}
@property (nonatomic, strong) UIScrollView * scrollView;//宽高等于initWithFrame中的宽高
@property (nonatomic, strong) SMPageControl * pageControl;//用于控制翻页，可以设定ScrollPageView自动翻页
@property (nonatomic, strong) UIImageView * leftImageView;//缓存最后一张View的图片
@property (nonatomic, strong) UIView * firstView;//第一张图片
@property (nonatomic, strong) UIView * lastView;//最后一张图片
@property (nonatomic, strong) UIImageView * rightImageView;//缓存第一张View的图片
@end
@implementation DDScrollPageView
-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        self.frame=frame;
        _isCycle=NO;
        _isAutoPlay=NO;
        _isShowPageIcon=YES;
        _pageControlOffsetY=-40;
        _interval=1.0;
        _direction=DDScrollPageViewDirection_Horizontal;
        [self addSubview:self.scrollView];
        [self addSubview:self.pageControl];
    }
    return self;
}
-(void)dealloc{
//    NSLog(@"dealloc");
}
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if (newSuperview) {
        if (_isAutoPlay) {
            [self createTimer];
        }
    } else {
        [self fireTimer];
    }
}
-(void)setDirection:(DDScrollPageViewDirection)direction{
    //外部设置滚动方向
    _direction=direction;
    //如果是横向，pageControll隐藏，纵向则显示
    self.pageControl.hidden=(direction==DDScrollPageViewDirection_Vertical);
}
-(void)setIsAutoPlay:(BOOL)isAutoPlay{
    _isAutoPlay=isAutoPlay;
    if (_isAutoPlay) {
        [self createTimer];
    }
}
-(void)createTimer{
    if (!timer) {
        // 获得队列
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        // 创建一个定时器(dispatch_source_t本质还是个OC对象)
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_t itimer = timer;
        // 设置定时器的各种属性（几时开始任务，每隔多长时间执行一次）
        // GCD的时间参数，一般是纳秒（1秒 == 10的9次方纳秒）
        // 何时开始执行第一个任务
        // dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC) 比当前时间晚3秒
        dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.interval * NSEC_PER_SEC));
        uint64_t interval = (uint64_t)(3.0 * NSEC_PER_SEC);
        dispatch_source_set_timer(timer, start, interval, 0);
        __weak typeof(self) weakSelf = self;
        // 设置回调
        dispatch_source_set_event_handler(timer, ^{
            if (_pageControl) {
                if (!weakSelf) {
                    dispatch_source_cancel(itimer);
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //为兼容isAutoCycle，将currentPage定为numberOfPages+1，当超过numberOfPages置为0
                        NSInteger newPage=_pageControl.currentPage+1;
                        _pageControl.currentPage= newPage%_pageControl.numberOfPages;
                        [weakSelf setContentOffsetForChangePage:newPage];
                    });
                }
            }
        });
        dispatch_source_set_cancel_handler(timer, ^{
            dispatch_release(itimer);
        });
        // 启动定时器
        dispatch_resume(timer);
    }
}
-(void)fireTimer{
    if (timer) {
        dispatch_source_cancel(timer);
        timer=nil;
    }
}
-(void)setPageControlOffsetY:(float)pageControlOffsetY{
    _pageControlOffsetY=pageControlOffsetY;
    self.pageControl.frame=CGRectMake(0, self.frame.size.height+self.pageControlOffsetY, self.frame.size.width, 30);
}
-(UIScrollView *)scrollView{
    if (_scrollView==nil) {
        _scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _scrollView.backgroundColor=[UIColor clearColor];
        _scrollView.pagingEnabled=YES;
        _scrollView.bounces=NO;
        _scrollView.showsHorizontalScrollIndicator=NO;
        _scrollView.showsVerticalScrollIndicator=NO;
        _scrollView.delegate=self;
        scrollViewRect=self.frame;
    }
    return _scrollView;
}
-(void)setIsShowPageIcon:(BOOL)isShowPageIcon{
    _isShowPageIcon=isShowPageIcon;
    self.pageControl.hidden=!_isShowPageIcon;
}
-(SMPageControl *)pageControl{
    if (_pageControl==nil) {
        //添加分页控制器
        _pageControl=[[SMPageControl alloc]initWithFrame:CGRectMake(0, self.frame.size.height+self.pageControlOffsetY, self.frame.size.width, 30)];
        _pageControl.backgroundColor=[UIColor clearColor];
        _pageControl.tapBehavior=SMPageControlTapBehaviorJump;
        _pageControl.hidesForSinglePage=YES;
        [_pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    }
    return _pageControl;
}
-(void)clearScrollView{
    for (UIView * v in _scrollView.subviews) {
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
        if (_direction==DDScrollPageViewDirection_Horizontal) {
            _scrollView.contentSize=CGSizeMake(scrollViewRect.size.width*(numberOfViews+_isCycle*2), scrollViewRect.size.height);
        }else{
            _scrollView.contentSize=CGSizeMake(scrollViewRect.size.width, scrollViewRect.size.height*(numberOfViews+_isCycle*2));
        }
        
        _pageControl.numberOfPages=numberOfViews;
    }else{
        NSLog(@"please realize numberOfViewsInScrollPageView,otherwise view not effect");
    }
    if (numberOfViews>0) {
        if ([_dataSource respondsToSelector:@selector(scrollPageView:viewForIndex:)]) {
            for (NSInteger i=0; i<numberOfViews; i++) {
                UIView * view=[_dataSource scrollPageView:self viewForIndex:i];
                [self addViewToScrollView:view ForIndex:i];
            }
        }
        if (_isCycle) {
            BOOL isHorizontal=_direction==DDScrollPageViewDirection_Horizontal;
            BOOL isVertical=_direction==DDScrollPageViewDirection_Vertical;
            _scrollView.contentOffset=CGPointMake(_scrollView.frame.size.width*isHorizontal,_scrollView.frame.size.width*isVertical );
        }
    }
}
-(UIImage *)imageFromView:(UIView *)view{
    CGSize size = view.bounds.size;
    //参数1:表示区域大小 参数2:如果需要显示半透明效果,需要传NO,否则传YES 参数3:屏幕密度
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
-(void)addViewToScrollView:(UIView*)view ForIndex:(NSInteger)index{
    //根据index,direction,isCycle偏移view，如果isCycle是YES则需要添加额外的2个View
    BOOL isHorizontal=_direction==DDScrollPageViewDirection_Horizontal;
    BOOL isVertical=_direction==DDScrollPageViewDirection_Vertical;
    CGSize cycleOffsetSize=CGSizeMake(0, 0);
    if (_isCycle) {
        cycleOffsetSize=scrollViewRect.size ;
        if (index==0) {//当是第一个时
            _firstView=view;
            _rightImageView=[[UIImageView alloc] initWithFrame:view.frame];
            _rightImageView.image=[self imageFromView:view];
            CGRect rect=_rightImageView.frame;
            _rightImageView.frame=CGRectMake(rect.origin.x+scrollViewRect.size.width*(_pageControl.numberOfPages+1)*isHorizontal, rect.origin.y+scrollViewRect.size.height*(_pageControl.numberOfPages+1)*isVertical, rect.size.width, rect.size.height);
            [_scrollView addSubview:_rightImageView];
//            NSLog(@"添加额外页面0");
//            NSLog(@"frame=%@",NSStringFromCGRect(dupView.frame));
        }else if(index==_pageControl.numberOfPages-1){//最后一个放到第一个
            _lastView=view;
            _leftImageView=[[UIImageView alloc] initWithFrame:view.frame];
            _leftImageView.image=[self imageFromView:view];
            [_scrollView addSubview:_leftImageView];
//            NSLog(@"添加额外页面$");
//            NSLog(@"frame=%@",NSStringFromCGRect(dupView.frame));
        }
        
    }
    CGRect rect=view.frame;
    view.frame=CGRectMake(rect.origin.x+scrollViewRect.size.width*index*isHorizontal+cycleOffsetSize.width*isHorizontal, rect.origin.y+scrollViewRect.size.height*index*isVertical+cycleOffsetSize.height*isVertical, rect.size.width, rect.size.height) ;
    [_scrollView addSubview:view];
//    NSLog(@"frame=%@",NSStringFromCGRect(view.frame));
}

-(void)setPageIndicatorImage:(UIImage*)pageIndicatorImage andCurrentPageIndicatorImage:(UIImage*)currentPageIndicatorImage{
    _pageControl.pageIndicatorImage=pageIndicatorImage;
    _pageControl.currentPageIndicatorImage=currentPageIndicatorImage;
}
-(void)changePage:(id)sender{
    NSInteger page = _pageControl.currentPage;
//    NSLog(@"page=%ld",(long)page);
    [self setContentOffsetForChangePage:page];
}
-(void)setContentOffsetForChangePage:(NSInteger)pageIndex{
    CGSize cycleOffsetSize=CGSizeMake(0, 0);
    if (_isCycle) {
        cycleOffsetSize=scrollViewRect.size;
        ////当显示第一张和最后一张view的时候复制图片
        if (pageIndex==0) {
            _rightImageView.image=[self imageFromView:_firstView];
        }else if(pageIndex==_pageControl.numberOfPages-1){
            _leftImageView.image=[self imageFromView:_lastView];
        }
    }
    if (_direction==DDScrollPageViewDirection_Horizontal) {
        [_scrollView setContentOffset:CGPointMake(scrollViewRect.size.width * pageIndex+cycleOffsetSize.width, 0) animated:YES];
    }else{
        [_scrollView setContentOffset:CGPointMake(0, scrollViewRect.size.height * pageIndex+cycleOffsetSize.height) animated:YES];
    }
    if (_isAutoPlay&& (pageIndex>=_pageControl.numberOfPages)) {
        _scrollView.contentOffset=CGPointMake(_scrollView.contentOffset.x-scrollViewRect.size.width*_pageControl.numberOfPages, _scrollView.contentOffset.y);
    }
}
#pragma mark UIScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    BOOL isHorizontal=_direction==DDScrollPageViewDirection_Horizontal;
    BOOL isVertical=_direction==DDScrollPageViewDirection_Vertical;
    long page=_scrollView.contentOffset.x/scrollViewRect.size.width*isHorizontal+_scrollView.contentOffset.y/scrollViewRect.size.height*isVertical;
    //当时循环时，需要判断当前的offset是否是第一个和最后一个，然后重置offset
    if (_isCycle) {
        if (page==0) {
            page=_pageControl.numberOfPages-1;
            _scrollView.contentOffset=CGPointMake(_scrollView.contentOffset.x+scrollViewRect.size.width*isHorizontal*_pageControl.numberOfPages, _scrollView.contentOffset.y+scrollViewRect.size.height*isVertical*_pageControl.numberOfPages);
        }else if(page==_pageControl.numberOfPages+1){
            page=0;
            _scrollView.contentOffset=CGPointMake(_scrollView.contentOffset.x-scrollViewRect.size.width*isHorizontal*_pageControl.numberOfPages, _scrollView.contentOffset.y-scrollViewRect.size.height*isVertical*_pageControl.numberOfPages);
        }else{
            //当显示第一张和最后一张view的时候复制图片
            if (page==1) {
                _rightImageView.image=[self imageFromView:_firstView];
            }else if(page==_pageControl.numberOfPages){
                _leftImageView.image=[self imageFromView:_lastView];
            }
            page--;
        }
    }
    _pageControl.currentPage=page;
    scrollView.userInteractionEnabled=YES;
    if (self.isAutoPlay) {
        [self createTimer];
    }
//    NSLog(@"scroll.....");
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self fireTimer];
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (decelerate) {
        scrollView.userInteractionEnabled=NO;
    }
}
@end
