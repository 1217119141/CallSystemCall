//
//  ViewController.m
//  CallSystemCall
//
//  Created by 乐停 on 2017/8/14.
//  Copyright © 2017年 MrPrograming. All rights reserved.
//

#import "ViewController.h"
#import "Contacts.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Contacts judgeAddressBookPowerWithUIViewController:self contactsBlock:^(NSString *name, NSString *phoneNumber) {
        NSLog(@"%@-%@",name,phoneNumber);
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
