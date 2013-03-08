/*
 * Copyright (c) 2013 Dan Wilcox <danomatika@gmail.com>
 *
 * BSD Simplified License.
 * For information on usage and redistribution, and for a DISCLAIMER OF ALL
 * WARRANTIES, see the file, "LICENSE.txt," in this distribution.
 *
 * See https://github.com/danomatika/PdParty for documentation
 *
 */
#import "BrowserViewController.h"

#import "PatchViewController.h"
#import "Log.h"
#import "Util.h"

@interface BrowserViewController ()
@property (strong, readwrite) NSMutableArray *pathArray; // table view path
@property (strong, readwrite) NSString *currentDir; // current directory path
@property (assign, readwrite) int currentDirLevel;

// run the given patch in the PatchViewController
- (void)runPatch:(NSString *)fullpath;

// returns true if a given path is a dir with a droidparty_main.pd within
- (BOOL)isDroidPartyDir:(NSString *)fullpath;

// returns true if the given path is a dir with a _main.pd within
- (BOOL)isRjDjDir:(NSString *)fullpath;

@end

@implementation BrowserViewController

- (void)awakeFromNib {
	if([Util isDeviceATablet]) {
	    self.clearsSelectionOnViewWillAppear = NO;
	    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
	}
	self.pathArray = [[NSMutableArray alloc] init];
	self.currentDirLevel = 0;
    [super awakeFromNib];
}

- (void)viewDidLoad {
    // Do any additional setup after loading the view, typically from a nib.
	[super viewDidLoad];
	
	// setup the root view
	// if currentDir is nill, then this is the root layer since currentDir is set when pushing child layers onto the navController
	if(!self.currentDir) {
		self.patchViewController = (PatchViewController *)[[self.parentViewController.splitViewController.viewControllers lastObject] topViewController];
		self.currentDir = [Util documentsPath];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	// Notifies the view controller that its view is about to be added to a view hierarchy.
	[super viewWillAppear:animated];
	
	[self loadDirectory:self.currentDir];
}

- (void)viewDidDisappear:(BOOL)animated {
	// Notifies the view controller that its view was removed from a view hierarchy.
	[super viewDidDisappear:animated];
	
	[self unloadDirectory];
}

- (void)didReceiveMemoryWarning {
    // Dispose of any resources that can be recreated.
	[super didReceiveMemoryWarning];
}

#pragma mark File Browsing

// file access error codes:
// https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Miscellaneous/Foundation_Constants/Reference/reference.html

- (void)loadDirectory:(NSString *)dirPath {

	NSError *error;

	DDLogVerbose(@"Browser: Loading directory %@", dirPath);

	// search for files in the given path
	NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:&error];
	if(!contents) {
		DDLogError(@"Browser: Couldn't load directory %@, error: %@", dirPath, error.localizedDescription);
		return;
	}
	
	// add contents to pathArray as absolute paths
	DDLogVerbose(@"Browser: Found %d paths", contents.count);
	for(NSString *p in contents) {
		DDLogVerbose(@"Browser: 	%@", p);
		
		// remove Finder DS_Store garbage (created over WebDAV)
		if([p isEqualToString:@"._.DS_Store"] || [p isEqualToString:@".DS_Store"]) {
			if(![[NSFileManager defaultManager] removeItemAtPath:[dirPath stringByAppendingPathComponent:p] error:&error]) {
				DDLogError(@"Browser: Couldn't remove %@, error: %@", p, error.localizedDescription);
			}
			else {
				DDLogVerbose(@"Browser: Removed %@", p);
			}
		}
		else { // add paths
			NSString *fullPath = [dirPath stringByAppendingPathComponent:p];
			if([Util isDirectory:fullPath]) { // add directory
				[self.pathArray addObject:fullPath];
			}
			else if([[p pathExtension] isEqualToString: @"pd"]) { // add patch
				[self.pathArray addObject:fullPath];
			}
		}
	}
	[self.tableView reloadData];
	
	self.navigationItem.title = [dirPath lastPathComponent]; // set title of back button
	self.currentDir = dirPath;
	self.navigationController.title = [dirPath lastPathComponent]; // set title of current dir
	DDLogVerbose(@"Browser: Current directory now %@", dirPath);
}

- (void)unloadDirectory {
	[self.pathArray removeAllObjects];
	[self.tableView reloadData];
}

#pragma mark UITableViewController

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// Return the number of sections.
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// Return the number of rows in the section.
	return self.pathArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Customize the appearance of table view cells.
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BrowserCell" forIndexPath:indexPath];

	NSString *path = self.pathArray[indexPath.row];
	
//  BOOL isDir;
//	if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]) {
//		if(isDir) {
//			//cell.imageView =
//		}
//		else {
//			// is patch
//			//cell.imageView =
//		}
//	}
//	else {
//		DDLogError(@"Can't select row in table view, file dosen't exist: %@", path);
//		[tableView deselectRowAtIndexPath:indexPath animated:NO];
//	}

	cell.textLabel.text = [path lastPathComponent];
	
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        [self.pathArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if(editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSString *path = self.pathArray[indexPath.row];
	
	BOOL isDir;
	if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]) {
		if(isDir) {
		
			if([self isDroidPartyDir:path]) {
				[self runPatch:[path stringByAppendingPathComponent:@"droidparty_main.pd"]];
			}
			else if([self isRjDjDir:path]) {
				[self runPatch:[path stringByAppendingPathComponent:@"_main.pd"]];
			}
			else { // regular dir
				// create a new browser table view and push it on the stack
				UIStoryboard *board;
				if([Util isDeviceATablet]) {
					board = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
				}
				else {
					board = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
				}
				BrowserViewController *browserLayer = [board instantiateViewControllerWithIdentifier:@"BrowserViewController"];
				browserLayer.patchViewController = self.patchViewController;
				browserLayer.currentDir = path;
				browserLayer.currentDirLevel = self.currentDirLevel+1;
				[self.navigationController pushViewController:browserLayer animated:YES];
			}
		}
		else {
			[self runPatch:path];
		}
	}
	else {
		DDLogError(@"Browser: Can't select row in table view, file dosen't exist: %@", path);
		[tableView deselectRowAtIndexPath:indexPath animated:NO];
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

	// load the selected patch
	if([[segue identifier] isEqualToString:@"runPatch"]) {
		NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
		NSString *path = self.pathArray[indexPath.row];
		[[segue destinationViewController] setCurrentPatch:path];
    }
}

#pragma mark Private / Util

- (void)runPatch:(NSString *)fullpath {
	if([Util isDeviceATablet]) {
		self.patchViewController.currentPatch = fullpath;
	}
	else {
		[self performSegueWithIdentifier:@"runPatch" sender:self];
	}
}

- (BOOL)isDroidPartyDir:(NSString *)fullpath {
	return [[NSFileManager defaultManager] fileExistsAtPath:[fullpath stringByAppendingPathComponent:@"droidparty_main.pd"]];
}

- (BOOL)isRjDjDir:(NSString *)fullpath {
	return [[NSFileManager defaultManager] fileExistsAtPath:[fullpath stringByAppendingPathComponent:@"_main.pd"]];

}

@end