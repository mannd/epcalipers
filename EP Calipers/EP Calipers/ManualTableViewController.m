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
#import "Translation.h"
#import "Defs.h"

// These can't be yes for release version
#ifdef DEBUG
// Set to yes to use local web page for testing.
#define USE_LOCAL_ACKNOWLEDGMENTS_URL
#endif

#ifdef USE_LOCAL_ACKNOWLEDGMENTS_URL
// MARK: To developers, this absolute path will need to be changed to your
// file scheme.
#define ACKNOWLEDGMENTS_URL @"file://localhost/Users/mannd/dev/epcalipers-ghpages/%@.lproj/EPCalipers-help/acknowledgments_ios.html"
#else
#define ACKNOWLEDGMENTS_URL @"https://mannd.github.io/epcalipers/%@.lproj/EPCalipers-help/acknowledgments_ios.html"
#endif

@interface ManualTableViewController ()

@end

@implementation ManualTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:[[ManualLink alloc] initWithChapter:L(@"Quick_start_ht") anchor:@"quick-start-id"]];
    [array addObject:[[ManualLink alloc] initWithChapter:L(@"Loading_image_ht") anchor:@"loading-image-id"]];
    [array addObject:[[ManualLink alloc] initWithChapter:L(@"Adjusting_image_ht") anchor:@"adjusting-image-id"]];
    [array addObject:[[ManualLink alloc] initWithChapter:L(@"Lock_image_ht") anchor:@"lock-image-id"]];
    [array addObject:[[ManualLink alloc] initWithChapter:L(@"Moving_calipers_ht") anchor:@"moving-calipers-id"]];
    [array addObject:[[ManualLink alloc] initWithChapter:L(@"Adding_deleting_calipers_ht") anchor:@"adding-deleting-calipers-id"]];
    [array addObject:[[ManualLink alloc] initWithChapter:L(@"Selecting_caliper_ht") anchor:@"selecting-caliper-id"]];
    [array addObject:[[ManualLink alloc] initWithChapter:L(@"More_caliper_options_ht") anchor:@"more-caliper-options-id"]];
    [array addObject:[[ManualLink alloc] initWithChapter:L(@"Calibration_ht") anchor:@"calibration-id"]];
    [array addObject:[[ManualLink alloc] initWithChapter:L(@"Changing_calibration_ht") anchor:@"changing-calibration-id"]];
    [array addObject:[[ManualLink alloc] initWithChapter:L(@"Making_measurements_ht") anchor:@"making-measurements-id"]];
    [array addObject:[[ManualLink alloc] initWithChapter:L(@"Interval_rate_ht") anchor:@"interval-rate-id"]];
    [array addObject:[[ManualLink alloc] initWithChapter:L(@"Mean_rate_ht") anchor:@"mean-rate-id"]];
    [array addObject:[[ManualLink alloc] initWithChapter:L(@"QTc_ht") anchor:@"qtc-id"]];
    [array addObject:[[ManualLink alloc] initWithChapter:L(@"Brugadometer_ht") anchor:@"brugadometer-id"]];
    [array addObject:[[ManualLink alloc] initWithChapter:L(@"Acknowledgments_ht") link:ACKNOWLEDGMENTS_URL]];
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
        vc.fullLink = link.fullLink;
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
