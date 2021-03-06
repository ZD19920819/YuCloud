//
//  AppDelegate.m
//  YuCloud
//
//  Created by 熊国锋 on 15/8/21.
//  Copyright (c) 2015年 VIROYAL-ELEC. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "LeftOptionsViewController.h"
#import "WelcomeViewController.h"
#import "LoginViewController.h"
#import "SignupViewController.h"
#import "RunInfo.h"


@interface AppDelegate ()

@end

AppDelegate *getAppDelegate()
{
    AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return tempAppDelegate;
}

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //this is the main window
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen]bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    //main view
    MainViewController *mainVC = [[MainViewController alloc] init];
    self.mainNavigationController = [[UINavigationController alloc] initWithRootViewController:mainVC];
    LeftOptionsViewController *leftVC = [[LeftOptionsViewController alloc] init];
    self.LeftSlideVC = [[LeftSlideViewController alloc] initWithLeftView:leftVC andMainView:self.mainNavigationController];
    self.window.rootViewController = self.LeftSlideVC;
    
    //here signup and login
    if([self startAutoLogin] == NO)
    {
        [self showLogin:NO];
    }
    
    //top most is the welcome screen
    if([self isFirstRun])
    {
        [self showWelcome:NO];
    }
    [self changeFirstRun:NO];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor purpleColor]];
    return YES;
}

- (BOOL)isFirstRun
{
    if([[self.fetchedResultsController fetchedObjects] count])
    {
        RunInfo *item = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        return item.first_run;
    }
    
    return YES;
}

- (void)changeFirstRun:(BOOL)first
{
    RunInfo *item = nil;
    if([[self.fetchedResultsController fetchedObjects] count])
    {
        item = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    }
    else
    {
        item = (RunInfo *)[NSEntityDescription insertNewObjectForEntityForName:@"RunInfo" inManagedObjectContext:self.managedObjectContext];
    }
    [item setValue:[NSNumber numberWithBool:first] forKey:@"first_run"];
    
    [self saveContext];
}

- (void)updateLastAccount:(AccountInfo *)account
{
    RunInfo *item = nil;
    if([[self.fetchedResultsController fetchedObjects] count])
    {
        item = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    }
    else
    {
        item = (RunInfo *)[NSEntityDescription insertNewObjectForEntityForName:@"RunInfo" inManagedObjectContext:self.managedObjectContext];
    }
    [item setValue:account.userid forKey:@"account"];
    [item setValue:account.access_token forKey:@"token"];
    
    [self saveContext];
}

- (BOOL)startAutoLogin
{
    RunInfo *item = nil;
    BOOL autoLogin = NO;
    NSString *token = nil;
    NSString *userid = nil;
    if([[self.fetchedResultsController fetchedObjects] count])
    {
        item = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        userid = [item valueForKey:@"account"];
        token = [item valueForKey:@"token"];
        if([userid length] > 0 && [token length] > 0)
        {
            autoLogin = YES;
        }
    }
    
    if(autoLogin)
    {
        YuAccountManager *manager = [YuAccountManager manager];
        [manager startLogin:userid pass:nil token:token block:^(BOOL success) {
            if(success)
            {
            }
            else
            {
                //自动登录失败，弹出登录界面
                [self showLogin:NO];
            }
        }];
    }
    
    return autoLogin;
}

- (void)showLogin:(BOOL)animated
{
    LoginViewController *login = [[LoginViewController alloc] initWithNibName:@"Login" bundle:nil];
    [self.mainNavigationController pushViewController:login animated:animated];
}

- (void)showSignup:(BOOL)animated
{
    SignupViewController *signup = [[SignupViewController alloc] initWithNibName:@"Signup" bundle:nil];
    [self.mainNavigationController pushViewController:signup animated:animated];
}

- (void)showWelcome:(BOOL)animated
{
    WelcomeViewController *welcome = [[WelcomeViewController alloc] init];
    [self.mainNavigationController pushViewController:welcome animated:NO];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext        = _managedObjectContext;
@synthesize managedObjectModel          = _managedObjectModel;
@synthesize persistentStoreCoordinator  = _persistentStoreCoordinator;
@synthesize fetchedResultsController    = _fetchedResultsController;

- (NSURL *)applicationDocumentsDirectory
{
    // The directory the application uses to store the Core Data store file. This code uses a directory named "viroyal.YuCloud" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel
{
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil)
    {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"YuCloud" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"YuCloud.sqlite"];
    NSLog(@"NSPersistentStoreCoordinator %@", storeURL);
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext
{
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator)
    {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if(_fetchedResultsController)
    {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"RunInfo" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Create the sort descriptors array.
    NSSortDescriptor *authorDescriptor = [[NSSortDescriptor alloc] initWithKey:@"first_run" ascending:YES];
    NSArray *sortDescriptors = @[authorDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Create and initialize the fetch results controller.
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    
    NSError *error;
    [_fetchedResultsController performFetch:&error];
    
    return _fetchedResultsController;
}

#pragma mark - Core Data Saving support

- (void)saveContext
{
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        NSError *error = nil;
        if (![managedObjectContext save:&error])
        {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        [_fetchedResultsController performFetch:&error];
    }
}

@end


