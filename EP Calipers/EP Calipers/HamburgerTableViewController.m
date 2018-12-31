//
//  HamburgerTableViewController.m
//  EP Calipers
//
//  Created by David Mann on 12/16/18.
//  Copyright © 2018 EP Studios. All rights reserved.
//

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

// TODO: check if camera available on device, see createImageMenu
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HamburgerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HamburgerCell" forIndexPath:indexPath];
    HamburgerLayer* row = self.rows[indexPath.row];

    if ((row.layer == Lock && self.imageIsLocked) || (row.layer == ToolTips && self.showingToolTips)) {
        cell.label.text = row.altName;
        cell.icon.image = [UIImage imageNamed:row.altIconName];
    }
    else {
        cell.label.text = row.name;
        cell.icon.image = [UIImage imageNamed:row.iconName];
    }
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Delegates
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.mainViewController hideHamburgerMenu];
    EPSLog(@"row %ld selected", (long)indexPath.row);

    switch (indexPath.row) {
        case Camera:
            [self.mainViewController takePhoto];
            break;
        case PhotoGallery:
            [self.mainViewController selectPhoto];
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
        case Help:
            [self.mainViewController showHelp];
            break;
        case Acknowledgments:
            [self.mainViewController showAcknowledgments];
            break;
        case About:
            [self.mainViewController showAbout];
            break;
        default:
            break;
    }
}

@end
