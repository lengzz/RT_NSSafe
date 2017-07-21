//
//  ViewController.m
//  RT_NSSafe
//
//  Created by Lzz on 2017/7/20.
//  Copyright © 2017年 Lzz. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //NSArray
//    NSArray *arr = [NSArray array];
//    //数组越界
//    NSLog(@"%@",arr[2]);
    id obj = nil;
//    NSMutableArray *arr1 = [NSMutableArray array];
//    [arr1 addObject:obj];
//    NSLog(@"%@",arr1[1]);
    
    //NSDictionary
    NSMutableDictionary *dic = [@{} mutableCopy];
    NSMutableDictionary *dic0 = [@{@1:@2} mutableCopy];
    NSMutableDictionary *dic1 = [@{@1:@1,@2:@2} mutableCopy];
    [dic0 removeObjectForKey:obj];
    NSLog(@"%@ %@ %@",[dic class],[dic0 class],[dic1 class]);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
