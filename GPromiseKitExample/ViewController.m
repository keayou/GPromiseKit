//
//  ViewController.m
//  GPromiseKitExample
//
//  Created by GIKI on 2018/5/8.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "ViewController.h"
#import "GPromiseKit.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView * tableView;
@end

static inline void Delay(NSTimeInterval interval, void (^work)(void)) {
    int64_t const timeToWait = (int64_t)(interval * NSEC_PER_SEC);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, timeToWait),
                   dispatch_get_main_queue(), ^{
                       work();
                   });
}


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadTableView];
}

- (void)loadTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(self.navigationController.navigationBar.frame)) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = [UIColor whiteColor];
}

#pragma mark -- TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableViewCell"];
    }
    cell.textLabel.text = @"1";
    return cell;
}


#pragma mark -- TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [self invoke1];
    } else if (indexPath.row == 1) {
        [self invoke2];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

#pragma mark - private Method
- (void)invoke2
{
    NSUInteger __block count = 0;
    
    GPromise *promise = [GPromise resolved:@42];
    [[[[[[promise then:^id(NSNumber *value) {
        ++count;
        return value;
    }] then:^id(NSNumber *value) {
        ++count;
        return value;
    }] then:^id(NSNumber *value) {
        ++count;
        NSLog(@"%ld",count);
        NSLog(@"%@",value);
        return value;
    }] then:^id(id value) {
        GPromise *promise = [GPromise resolved:GPromiseError(@"有错误啦")];
        return promise;
    }] then:^id(id value) {
        return value;
    }] catchError:^(NSError *error) {
        NSLog(@"errro%@",error.userInfo);
    }];
    
 

}

- (void)invoke1
{
    GPromise *promise1 =
    [GPromise async:^(GPromiseFulfillBlock fulfill, GPromiseRejectBlock __unused _) {
        NSLog(@"1");
        Delay(0.1, ^{
             NSLog(@"1.1");
            fulfill(@42);
        });
    }];
    GPromise *promise2 =
    [GPromise async:^(GPromiseFulfillBlock fulfill, GPromiseRejectBlock __unused _) {
        NSLog(@"2");
        Delay(1, ^{
            NSLog(@"2.1");
            fulfill(@"hello world");
        });
    }];
    GPromise *promise3 =
    [GPromise async:^(GPromiseFulfillBlock fulfill, GPromiseRejectBlock __unused _) {
         NSLog(@"3");
        Delay(2, ^{
             NSLog(@"3.1");
            fulfill(@[ @42 ]);
        });
    }];
    GPromise *promise4 =
    [GPromise async:^(GPromiseFulfillBlock fulfill, GPromiseRejectBlock reject) {
        NSLog(@"4");
        Delay(0.01, ^{
                 NSLog(@"4.1");
            fulfill(@"23");
//           reject([NSError errorWithDomain:GPromiseErrorDomain code:42 userInfo:nil]);
        });
    }];
    
    GPromise *combinedPromise =
    [[[GPromise all:@[ promise1, promise2, promise3, promise4 ]] then:^id(NSArray *value) {
         NSLog(@"value");
        return value;
    }] catchError:^(NSError *error) {
        NSLog(@"error");
    }];
    
    
}


@end
