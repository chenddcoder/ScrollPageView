# ScrollPageView
//定义所需要的变量
@property (weak, nonatomic) IBOutlet UIView *autoPlayView;
@property (nonatomic, strong) DDScrollPageView * pageView;
@property (nonatomic, strong) NSArray * viewArray;
//创建ScrollPageView
    self.pageView=[[DDScrollPageView alloc] initWithFrame:self.autoPlayView.frame];
    self.pageView.pageControlOffsetY=-30;
    self.pageView.interval=2.0;
    self.pageView.isAutoPlay=YES;
    self.pageView.isCycle=YES;
    self.pageView.dataSource=self;
    [self.pageView setPageIndicatorImage:[UIImage imageNamed:@"灰点"] andCurrentPageIndicatorImage:[UIImage imageNamed:@"banner点"]];
    [self.autoPlayView addSubview:self.pageView];
    [self.pageView reloadData];
    
//实现代理
#pragma mark DDScrollPageViewDataSource
-(NSInteger)numberOfViewsInScrollPageView:(DDScrollPageView *)scrollPageView{
    return self.viewArray.count;
    
}
-(UIView *)scrollPageView:(DDScrollPageView *)scrollPageView viewForIndex:(NSInteger)index{
    return self.viewArray[index];
}
