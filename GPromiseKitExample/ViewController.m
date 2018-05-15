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

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadTableView];
}

- (void)loadTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(self.navigationController.navigationBar.frame)) style:UITableViewStylePlain];
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

#pragma mark - private Method

- (void)invoke1
{
    GPromise * pr1 = [[[GPromise async:^(GPromiseFulfillBlock fulfill, GPromiseRejectBlock reject) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            fulfill(@"1成功");
            NSError *error = [NSError errorWithDomain:GPromiseErrorDomain code:1 userInfo:@{NSLocalizedDescriptionKey : @"error"}];
            reject(error);
        });
    }] then:^id(id value) {
        NSString * s = [NSString stringWithFormat:@"%@+2",value];
        GPromise * pr = [GPromise promise];
        [pr fulfill:s];
//        [pr reject:[NSError errorWithDomain:GPromiseErrorDomain code:1 userInfo:@{NSLocalizedDescriptionKey : @"error"}]];
        return pr;
    }] catchError:^(NSError *error) {
        NSLog(@"%@",error);
    }];
    NSError *error1 = [NSError errorWithDomain:GPromiseErrorDomain code:1 userInfo:@{NSLocalizedDescriptionKey : @"error"}];
    GPromise *pr3 = [GPromise promise];
    [pr3 fulfill:@"string"];
    [pr3 then:^id(id value) {
        NSString * s = [NSString stringWithFormat:@"%@+2",value];
        GPromise * pr = [GPromise promise];
        [pr fulfill:s];
        //        [pr reject:[NSError errorWithDomain:GPromiseErrorDomain code:1 userInfo:@{NSLocalizedDescriptionKey : @"error"}]];
        return pr;
    }];
    [pr3 catchError:^(NSError *error) {
        NSLog(@"%@",error);
    }];
    
//    GPromise * pr2 = [GPromise async:^(GPromiseFulfillBlock fulfill, GPromiseRejectBlock reject) {
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
////        fulfill(@"hahah");
//            NSError *error = [NSError errorWithDomain:GPromiseErrorDomain code:1 userInfo:@{NSLocalizedDescriptionKey : @"error"}];
//            reject(error);
//        });
//        
//    }];
//    
//    GPromise * all = [GPromise all:@[pr1,pr2]];
//    [[all then:^id(id value) {
//        NSLog(@"%@",value);
//        return value;
//    }] catchError:^(NSError *error) {
//        NSLog(@"%@",error);
//    }];
    
    
}


@end
