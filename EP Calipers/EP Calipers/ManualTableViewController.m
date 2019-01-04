//
//  ManualTableViewController.m
//  EP Calipers
//
//  Created by David Mann on 1/4/19.
//  Copyright © 2019 EP Studios. All rights reserved.
//

#import "ManualTableViewController.h"
#import "ManualLink.h"
#import "ManualCell.h"
#import "WebViewController.h"
#include "Defs.h"

@interface ManualTableViewController ()

@end

@implementation ManualTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:[[ManualLink alloc] initWithChapter:L(@"Quick start") anchor:@"quick-start-id"]];
    [array addObject:[[ManualLink alloc] initWithChapter:L(@"Brugadometer") anchor:@"brugadometer-id"]];
    self.links = array;
    self.title = L(@"Topics");
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.links count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ManualCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ManualCell" forIndexPath:indexPath];
    [cell set:self.links[indexPath.row]];
    return cell;
}


#pragma mark - Delegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"webViewSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        WebViewController *vc = [segue destinationViewController];
        ManualLink *link = self.links[indexPath.row];
        vc.anchor = link.anchor;
    }
}

// Avoids contraint error message.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"webViewSegue" sender:self];
}

@end
