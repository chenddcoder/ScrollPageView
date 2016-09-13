//
//  ViewController.m
//  ScrollPageController
//
//  Created by chendd on 15/6/3.
//  Copyright (c) 2015年 icfcc. All rights reserved.
//

#import "ViewController.h"
#import "DDScrollPageView.h"
@interface ViewController ()<DDScrollPageViewDataSource>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    DDScrollPageView * scrollPageView=[[DDScrollPageView alloc]initWithFrame:CGRectMake(0, 64, 320, 320)];
    scrollPageView.dataSource=self;
    scrollPageView.isCycle=YES;
//    scrollPageView.isAutoPlay=YES;
//    scrollPageView.direction=DDScrollPageViewDirection_Vertical;
    [self.view addSubview:scrollPageView];
//    [scrollPageView setPageIndicatorImage:[UIImage imageNamed:@"currentAppleDot"] andCurrentPageIndicatorImage:[UIImage imageNamed:@"appleDot"]];
    [scrollPageView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark ScrollPageViewDataSource
-(NSInteger)numberOfViewsInScrollPageView:(DDScrollPageView *)scrollPageView{
    return 3;
}
-(UIView *)scrollPageView:(DDScrollPageView *)scrollPageView viewForIndex:(NSInteger)index{
    UIView * v=[[UIView alloc]initWithFrame:CGRectMake(0,0,scrollPageView.frame.size.width,scrollPageView.frame.size.height)];
    UIButton * button=[UIButton buttonWithType:UIButtonTypeSystem];
    button.frame=CGRectMake(10, 10, 100, 40);
    button.backgroundColor=[UIColor orangeColor];
    [button setTitle:@"测试" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [v addSubview:button];
    if (index==0) {
        v.backgroundColor=[UIColor colorWithRed:arc4random()%255/255.0 green:arc4random()%255/255.0 blue:arc4random()%255/255.0 alpha:1];
    }else{
        v.backgroundColor=v.backgroundColor=[UIColor colorWithRed:arc4random()%255/255.0 green:arc4random()%255/255.0 blue:arc4random()%255/255.0 alpha:1];
    }
    return v;
}
-(void)buttonClicked:(id)sender{
    NSLog(@"click:%p",sender);
}
@end
