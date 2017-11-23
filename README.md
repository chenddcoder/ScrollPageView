# ScrollPageView
<p>
//定义所需要的变量<br>
@property (weak, nonatomic) IBOutlet UIView *autoPlayView;<br>
@property (nonatomic, strong) DDScrollPageView * pageView;<br>
@property (nonatomic, strong) NSArray * viewArray;<br>
</p>
<p>
//创建ScrollPageView<br>
    self.pageView=[[DDScrollPageView alloc] initWithFrame:self.autoPlayView.frame];<br>
    self.pageView.pageControlOffsetY=-30;<br>
    self.pageView.interval=2.0;<br>
    self.pageView.isAutoPlay=YES;<br>
    self.pageView.isCycle=YES;<br>
    self.pageView.dataSource=self;<br>
    [self.pageView setPageIndicatorImage:[UIImage imageNamed:@"灰点"] andCurrentPageIndicatorImage:[UIImage imageNamed:@"banner点"]];<br>
    [self.autoPlayView addSubview:self.pageView];<br>
    [self.pageView reloadData];<br>
</p>
<p>
//实现代理<br>
#pragma mark DDScrollPageViewDataSource<br>
-(NSInteger)numberOfViewsInScrollPageView:(DDScrollPageView *)scrollPageView{<br>
    return self.viewArray.count;<br>
    <br>
}<br>
-(UIView *)scrollPageView:(DDScrollPageView *)scrollPageView viewForIndex:(NSInteger)index{<br>
    return self.viewArray[index];<br>
}<br>
</p>