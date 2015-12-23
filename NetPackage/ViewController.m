//
//  ViewController.m
//  NetPackage
//
//  Created by LinfangTu on 15/12/23.
//  Copyright © 2015年 LinfangTu. All rights reserved.
//

#import "ViewController.h"
#import "LHTTPClient.h"

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UITextView *getText;
@property (nonatomic, weak) IBOutlet UITextView *postText;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *url = @"http://config.sometimes.net.cn/api/columns";
    [[LHTTPClient sharedClient] requestWithURLString:url parameters:nil uploadParam:nil type:NetworkRequestTypeGet resultBlock:^(id responseObject, NSError *error) {
        
        if (!error) {
            NSLog(@"JSON: %@", responseObject);
            self.getText.text = [NSString stringWithFormat:@"%@", responseObject];
        }
        else {
            NSLog(@"Error: %@", error);
        }
    }];
    
    NSString *URLString = @"http://www.perasst.com:8081/perasst_v2/user/login.pa";
    NSDictionary *parameters = @{@"userName":@"18538320461",@"password":@"123456"};
    
    [[LHTTPClient sharedClient] requestWithURLString:URLString parameters:parameters uploadParam:nil type:NetworkRequestTypePost resultBlock:^(id responseObject, NSError *error) {
        
        if (!error) {
            NSLog(@"JSON: %@", responseObject);
            self.postText.text = [NSString stringWithFormat:@"%@", responseObject];

        }
        else {
            NSLog(@"Error: %@", error);
        }
    }];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
