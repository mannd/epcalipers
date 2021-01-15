//
//  HamburgerTableViewController.m
//  EP Calipers
//
//  Created by David Mann on 12/16/18.
//  Copyright © 2018 EP Studios. All rights reserved.
//

// Side "hamburger" menu implentation based on https://medium.com/@qbo/hamburger-menu-on-ios-done-right-a1b076cbdea1

#import "HamburgerTableViewController.h"
#import "HamburgerCell.h"
#import "HamburgerViewModel.h"
#import "EPSMainViewController.h"
#import "EPSLogging.h"

@interface HamburgerTableViewController ()
@property (weak, nonatomic) EPSMainViewController *mainViewController;
@end

@implementation HamburgerTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    HamburgerViewModel* viewModel = [[HamburgerViewModel alloc] init];
    self.rows = [viewModel allLayers];
}

- (void)viewWillAppear:(BOOL)animated {
    EPSLog(@"Hamburger will appear");
    [super viewWillAppear:animated];
    self.mainViewController = (EPSMainViewController *)self.parentViewController;
    self.imageIsLocked = [self.mainViewController imageIsLocked];
    self.showingToolTips = self.mainViewController.showingToolTips;
}

- (void)reloadData {
    self.imageIsLocked = [self.mainViewController imageIsLocked];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.rows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HamburgerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HamburgerCell" forIndexPath:indexPath];
    HamburgerLayer* row = self.rows[indexPath.row];

    if ((row.layer == Lock && self.imageIsLocked) || (row.layer == ToolTips && self.showingToolTips)) {
        cell.label.text = row.altName;
        cell.icon.image = row.altIcon;
    }
    else {
        cell.label.text = row.name;
        cell.icon.image = row.icon;
    }
    cell.label.adjustsFontSizeToFitWidth = YES;
    return cell;
}

// Default header is a little too big when using a grouped tableview.
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1.0f;
}

#pragma mark - Delegates
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.mainViewController hideHamburgerMenu];
    EPSLog(@"row %ld selected", (long)indexPath.row);

    switch (indexPath.row) {
        case Camera:
            [self.mainViewController takePhoto];
            break;
        case PhotoGallery:
            [self.mainViewController selectImageSource];
            break;
        case SampleEcg:
            [self.mainViewController loadDefaultImage];
            break;
        case Lock:
            [self.mainViewController lockImage];
            break;
        case Preferences:
            [self.mainViewController openSettings];
            break;
        case ToolTips:
            [self.mainViewController showToolTips];
            break;
        case Manual:
            [self.mainViewController showManual];
            break;
        case About:
            [self.mainViewController showAbout];
            break;
        default:
            break;
    }
}

@end
