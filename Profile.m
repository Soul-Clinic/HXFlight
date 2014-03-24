//
//  Profile.m
//  HXFlight
//
//  Created by Can EriK Lu on 3/23/14.
//  Copyright (c) 2014 Can EriK Lu. All rights reserved.
//

#import "Profile.h"

@interface Profile ()
{
	NSArray* menus;
}
@end

@implementation Profile


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	menus = @[@[
  			@[@"friend_info_mail", @"帮助中心"],
  			@[@"friend_info_mail", @"意见反馈"],
  			@[@"friend_info_qzone", @"推送设置"]],
              @[
            @[@"friend_info_mail", @"推送设置"],
            @[@"friend_info_qzone", @"关于"],
            @[@"friend_info_mail", @"检查更新"]]];
	self.tableView.contentInset = UIEdgeInsetsMake(70, 0, 0, 0);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return menus.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [menus[section] count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell* cell =  [tableView dequeueReusableCellWithIdentifier:@"main"];
    UIImageView* icon = (UIImageView*)[cell viewWithTag:2];
    UILabel* label = (UILabel*)[cell viewWithTag:1];
	icon.image = [UIImage imageNamed:menus[indexPath.section][indexPath.row][0]];
    label.text = menus[indexPath.section][indexPath.row][1];
    return cell;

}
@end














