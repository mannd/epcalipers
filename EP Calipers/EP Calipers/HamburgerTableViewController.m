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




    cell.label.text = row.name;
    cell.icon.image = [UIImage imageNamed:row.iconName];

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
    EPSMainViewController *mainViewController = (EPSMainViewController *)self.parentViewController;
    [mainViewController hideHamburgerMenu];
    EPSLog(@"row %ld selected", (long)indexPath.row);

    switch (indexPath.row) {
        // FiXME: make sure camera is available
        case Camera:
            [mainViewController takePhoto];
            break;
        case PhotoGallery:
            [mainViewController selectPhoto];
            break;
        case SampleEcg:
            [mainViewController loadDefaultImage];
            break;
        case Preferences:
            [mainViewController openSettings];
            break;
        case Help:
            [mainViewController showHelp];
            break;
        case About:
            [mainViewController showAbout];
            break;
        default:
            break;
    }
}

@end
