//
//  ViewController.m
//  JZFMagazineWebView
//
//  Created by 贾卓峰 on 2017/7/24.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "ViewController.h"
#import "MyWKWebViewVC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

//查看网页
- (IBAction)lookWebView:(id)sender {

    MyWKWebViewVC * WKVC = [MyWKWebViewVC new];
    [self.navigationController pushViewController:WKVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
