//
//  ViewController.m
//  SimpleSelectionView
//
//  Created by  Will on 16/2/16.
//  Copyright © 2016年  Will. All rights reserved.
//

#import "ViewController.h"
#import "WZSelectionView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
- (IBAction)showSelectionView:(id)sender {
    
    [WZSelectionView showWithItemsBlock:^(id<WZSelectionItemsProtocol> items) {
        [items addItemWithLabelText:@"加入乐影单" imageName:@"homeAddList" shouldDismiss:YES];
        [items addItemWithLabelText:@"下载" imageName:@"downloaded_icon" shouldDismiss:YES];
    } selectedBlock:^(NSInteger selectedTag) {
        
        [self showTipsWithSelectedIndex:selectedTag];
        
    }];
}


- (void)showTipsWithSelectedIndex:(NSInteger)selectedIndex {
    
    NSDictionary *tipsInfoDic = @{@0 : @"已加入乐影单", @1 : @"下载中..."};
    
    NSNumber *selectedNumber = [NSNumber numberWithInteger:selectedIndex];
    NSString *tipsString = tipsInfoDic[selectedNumber];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:tipsString message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [self presentViewController:alert animated:YES completion:^{
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alert dismissViewControllerAnimated:YES completion:nil];
        });
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
