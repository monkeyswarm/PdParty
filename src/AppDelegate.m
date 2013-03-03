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
#import "AppDelegate.h"

#import "Log.h"
#import "Util.h"
#import "PdAudioController.h"
#import "Midi.h"
#import "gui/Widget.h"

@interface AppDelegate () {}

@property (nonatomic, retain) PdAudioController *audioController;
@property (nonatomic, retain) Midi *midi;

- (void)setupPd;
- (void)setupMidi;

// recursively copy dirs and patches in the resource patches dir to the
// Documents folder, removes/overwrites any currently existing dirs
- (void)copyResourcePatchesToDocuments;

@end

@implementation AppDelegate

@synthesize playing;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
	    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
	    UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
	    splitViewController.delegate = (id)navigationController.topViewController;
		splitViewController.presentsWithGesture = NO; // disable swipe gesture for master view
	}
	
	// init logger
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
	[DDLog addLogger:[[DDFileLogger alloc] init]];
	//ddLogLevel = [preferences logLevel];
	DDLogInfo(@"loglevel: %d", ddLogLevel);
	
	// copy patches in the resource folder
	[self copyResourcePatchesToDocuments];
	
	// setup engines
	[self setupPd];
	[self setupMidi];
	
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	
	//self.playing = NO;
}

#pragma mark Private

- (void)setupPd {
	
	// configure a typical audio session with 2 output channels
	self.audioController = [[PdAudioController alloc] init];
	PdAudioStatus status = [self.audioController configurePlaybackWithSampleRate:44100
																  numberChannels:2
																	inputEnabled:NO
																   mixingEnabled:YES];
	if(status == PdAudioError) {
		DDLogError(@"Error: Could not configure PdAudioController");
	} else if(status == PdAudioPropertyChanged) {
		DDLogWarn(@"Warning: Some of the audio parameters were not accceptable");
	} else {
		DDLogInfo(@"Audio Configuration successful");
	}
	[self.audioController print];
	
	// set dispatcher delegate
	self.dispatcher = [[PdDispatcher alloc] init];
	[PdBase setDelegate:self.dispatcher];
	[Widget setDispatcher:self.dispatcher];
	
	// set midi receiver delegate
	[PdBase setMidiDelegate:self];

	// turn on dsp
	[self setPlaying:YES];
}

- (void)setupMidi {
	self.midi = [Midi interface];
	[self.midi enableNetwork:YES];
}

- (void)copyResourcePatchesToDocuments {
	
	NSError *error;
	
	DDLogVerbose(@"Copying resource patches to Documents");
	
	// remove existing folders
	NSString* testPatchesPath = [[Util documentsPath] stringByAppendingPathComponent:@"tests"];
	if([[NSFileManager defaultManager] fileExistsAtPath:testPatchesPath]) {
		if(![[NSFileManager defaultManager] removeItemAtPath:testPatchesPath error:&error]) {
			DDLogError(@"Couldn't remove %@, error: %@", testPatchesPath, error.localizedDescription);
		}
	}
	
	// copy patches into Documents folder
	NSString *resourcePatchesPath = [[Util bundlePath] stringByAppendingPathComponent:@"patches"];
	NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:resourcePatchesPath error:&error];
	if(!contents) {
		DDLogError(@"Couldn't read files in path %@, error: %@", resourcePatchesPath, error.localizedDescription);
		return;
	}
	
	// recursively copy contents of resource folder to Documents
	DDLogVerbose(@"Found %d paths in patches resource folder", contents.count);
	for(NSString *p in contents) {
		NSString *filePath = [resourcePatchesPath stringByAppendingPathComponent:p];
		DDLogVerbose(@"	Copying %@", p);
		if(![[NSFileManager defaultManager] copyItemAtPath:filePath toPath:testPatchesPath error:&error]) {
			DDLogError(@"Couldn't copy %@ to %@, error: %@", filePath, testPatchesPath, error.localizedDescription);
		}
	}
}

#pragma mark PdMidiReceiverDelegate

- (void)receiveNoteOn:(int)pitch withVelocity:(int)velocity forChannel:(int)channel {
	[self.midi sendNoteOn:channel pitch:pitch velocity:velocity];
}

- (void)receiveControlChange:(int)value forController:(int)controller forChannel:(int)channel {
	[self.midi sendControlChange:channel controller:controller value:value];
}

- (void)receiveProgramChange:(int)value forChannel:(int)channel {
	[self.midi sendProgramChange:channel value:value];
}

- (void)receivePitchBend:(int)value forChannel:(int)channel {
	[self.midi sendPitchBend:channel value:value];
}

- (void)receiveAftertouch:(int)value forChannel:(int)channel {
	[self.midi sendAftertouch:channel value:value];
}

- (void)receivePolyAftertouch:(int)value forPitch:(int)pitch forChannel:(int)channel {
	[self.midi sendPolyAftertouch:channel pitch:pitch value:value];
}

- (void)receiveMidiByte:(int)byte forPort:(int)port {}

#pragma mark Accessors

- (BOOL)isPlaying {
    return playing;
}

- (void)setPlaying:(BOOL)newState {
    if(newState == playing) {
		return;
	}
	playing = newState;
	self.audioController.active = playing;
}

@end
