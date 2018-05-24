//
//  ViewController.m
//  LRCollectionTableLayout
//
//  Created by 阮凌奇 on 16/9/28.
//  Copyright © 2016年 HXQC.com. All rights reserved.
//

#import "ViewController.h"
#import "DemoCollectionViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pushTo:(UIButton *)sender {
    DemoCollectionViewController *demoVC = [[DemoCollectionViewController alloc] initWithCollectionViewLayout:[UICollectionViewLayout new]];
    [self presentViewController:demoVC animated:YES completion:nil];
}

@end
