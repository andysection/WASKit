//
//  ViewController.m
//  WASKit
//
//  Created by admin on 17/2/24.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "ViewController.h"
#import "WASProgressView.h"
#import "WASTableViewCell.h"

static NSString *tableViewCellId = @"tableViewCellId";
@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    UITextView *textView = [[UITextView alloc] init];
//    [self.view addSubview:textView];
//    textView.frame = self.view.bounds;
//    
//    NSString *str = @"<p>随着移动互联网的高速发展，智能手机和平板电脑走进千家万户，越来越多的儿童开始接触这些五花八门的电子产品。据一项调查显示，0-6岁的孩子中，有66.6%从4岁开始自己的问题，这时就需要家长们多留个心眼。</p><p>那么，家长们该如何知道孩子视力是否出现问题了呢?</p><p><img alt='这几个征兆表明孩子近视了 你发现了吗' src='http://tnfs.tngou.NET/img/lore/160724/90b96ec647dca2ef9f6037884db7ac59.jpg'></p><p><strong>1.眯眼、频繁频繁眨眼的症状时，应考虑其是否患了早期近视。</p><p><strong>2.皱眉、揉眼睛</strong></p><p>一些患近视的儿童有皱眉的习惯，其实这是他是否也罹患了病理性近视，做到尽早发现，尽早防控，从而减轻成年期的治疗和控制难度。</p><p><br><br></p><p><br></p><p><br></p>123<br/><input   type=\"radio\" value=\"值\"    name=\"名称\"   checked=\"checked\"/><ol><li>我的第一个列表信息。</li><li>我的第一个列表信息。</li></ol><form   method=\"传送方式\"   action=\"服务器文件\"><form    method=\"post\"   action=\"save.php\"><label for=\"username\">用户名:</label><input type=\"text\" name=\"username\" /><label for=\"pass\">密码:</label><input type=\"password\" name=\"pass\" /><input type=\"text/password\" name=\"名称\" value=\"文本\" /></form>";
//    
//    NSAttributedString *arrt = [[NSAttributedString alloc] initWithData:[str dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType} documentAttributes:nil error:nil];
//    
//    textView.attributedwText = arrt;

        
    UITableView *tableView = [[UITableView alloc]init];
    [self.view addSubview:tableView];
    tableView.frame = [UIScreen mainScreen].bounds;
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[WASTableViewCell class] forCellReuseIdentifier:tableViewCellId];
    tableView.rowHeight = 200;

    NSDictionary *dict = @{@"key1":@"v2"};
    NSLog(@"%@, length:%zd",dict[@"key2"], dict[@"key2"]);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WASTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableViewCellId forIndexPath:indexPath];
    return cell;
}


@end
