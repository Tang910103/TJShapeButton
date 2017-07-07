//
//  ViewController.m
//  TJButton
//
//  Created by Tang杰 on 2017/6/30.
//  Copyright © 2017年 TangJie. All rights reserved.
//

#import "ViewController.h"
#import "ShapeButton.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    ShapeButton *button = [[ShapeButton alloc]init];
    button.frame = CGRectMake(0, 0, 300, 100);
    button.center = self.view.center;
    button.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.3];
    [button addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    ShapeButton *button1 = [[ShapeButton alloc]init];
    button1.frame = button.frame;
    button1.transform = CGAffineTransformMakeTranslation(0, -30);
    button1.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.3];
    [button1 addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    
    ShapeButton *button2 = [[ShapeButton alloc]init];
    button2.frame = button.frame;
    button2.transform = CGAffineTransformMakeTranslation(0, -60);
    button2.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.3];
    [button2 addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];

}
- (void)click
{
    NSLog(@"%@",[NSDate date]);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
