//
//  HelpTableViewController.m
//  EP Calipers
//
//  Created by David Mann on 12/26/18.
//  Copyright © 2018 EP Studios. All rights reserved.
//

#import "HelpTableViewController.h"
#import "HelpTopicTableViewCell.h"
#import "HelpTopic.h"
#import "HelpViewModel.h"
#import "HelpModel.h"
#include "Defs.h"

#define ESTIMATED_ROW_HEIGHT 44

@interface HelpTableViewController ()

@end

@implementation HelpTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = L(@"Help");
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setEstimatedRowHeight:ESTIMATED_ROW_HEIGHT];
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    HelpModel *model = [[HelpModel alloc] init];
    NSArray *helpTopicArray = model.helpTopics;
    NSMutableArray *viewModelArray = [[NSMutableArray alloc] init];
    for (HelpTopic *h in helpTopicArray) {
        HelpViewModel *helpViewModel = [[HelpViewModel alloc] initWithHelpTopic:h];
        [viewModelArray addObject:helpViewModel];
    }
    self.helpArray = viewModelArray;
}

- (void)showCell:(UITableViewCell *)cell {
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    cell.alpha = 0.0f;
    [UIView animateWithDuration:0.25
                     animations:^{
                         cell.alpha = 1.0f;
                     } completion:^(BOOL finished){
                         cell.hidden = NO;
                     }];
}

- (void)hideCell:(UITableViewCell *)cell {
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [UIView animateWithDuration:0.25
                     animations:^{
                         cell.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         cell.hidden = YES;
                     }];

}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {

    HelpTopicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HelpTopicCell"];
    HelpViewModel *content = self.helpArray[indexPath.row];
    [cell set:content];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.helpArray count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HelpViewModel *content = self.helpArray[indexPath.row];
    content.expanded = !content.expanded;
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
