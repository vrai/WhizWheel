// ***************************************************************************
//              WhizWheel 1.0.1 - Copyright Vrai Stacey 2009 - 2010
//
// This program is free software; you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the Free
// Software Foundation; either version 2 of the License, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
// more details.
// 
// You should have received a copy of the GNU General Public License along
// with this program; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
// ***************************************************************************

#import "WhizWheelAppDelegate.h"
#import "Configuration.h"
#import "WindCalculator.h"
#import "WindCalculationOperation.h"
#import "NotificationNames.h"

#define CONFIGURATION_FILENAME  @"WhizWheelConfig"

#pragma mark -

@interface WhizWheelAppDelegate ( )
- ( void ) handleWindDetailsNotification: ( NSNotification * ) notification;
- ( void ) handleNavigationDetailsNotification: ( NSNotification * ) notification;
- ( void ) handleWindCalculatorConsumerNotification: ( NSNotification * ) notification;

- ( void ) doHandleDetailsNotificationWithObject: ( id ) object calculatorSetter: ( SEL ) setter;
- ( void ) doQueueRecalculationOperation;

+ ( NSString * ) getConfigurationFilename;
@end

#pragma mark -

@implementation WhizWheelAppDelegate

@synthesize window;
@synthesize tabBarController;

- ( void ) dealloc
{
    [ tabBarController release ];
    [ window release ];
    [ backgroundQueue release ];
    [ super dealloc ];
}

#pragma mark -
#pragma mark UIApplicationDelegate methods

- ( void ) applicationDidFinishLaunching: ( UIApplication * ) application
{
    // Make sure the configuration gets initialised
    [ Configuration initialiseDefaultConfigurationFromFile: [ [ self class ] getConfigurationFilename ] ];
    
    // Create the background operation queue if required
    if ( ! backgroundQueue )
    {
        backgroundQueue = [ [ NSOperationQueue alloc ] init ];
        [ backgroundQueue setMaxConcurrentOperationCount: 1 ];
    }

    // Add the tab bar controller's current view as a subview of the window
    [ window addSubview: tabBarController.view ];
    
    // Wire up the notification handlers
    [ [ NSNotificationCenter defaultCenter ] addObserver: self
                                                selector: @selector ( handleWindDetailsNotification: )
                                                    name: WindDetailsPublished
                                                  object: nil ];
    [ [ NSNotificationCenter defaultCenter ] addObserver: self
                                                selector: @selector ( handleNavigationDetailsNotification: )
                                                    name: NavigationDetailsPublished
                                                  object: nil ];
    [ [ NSNotificationCenter defaultCenter ] addObserver: self
                                                selector: @selector ( handleWindCalculatorConsumerNotification: )
                                                    name: WindCalculatorConsumerCreated
                                                  object: nil ];
                                                  
    // Publish the wind and navigation details from the config
    NSAutoreleasePool * pool = [ [ NSAutoreleasePool alloc ] init ];
    id windDetails = [ [ Configuration defaultConfiguration ] getAsWindDetails ];
    id navigationPlanDetails = [ [ Configuration defaultConfiguration ] getAsNavigationPlanDetails ];
    [ [ NSNotificationCenter defaultCenter ] postNotification: [ NSNotification notificationWithName: WindDetailsPublished
                                                                                              object: windDetails ] ];
    [ [ NSNotificationCenter defaultCenter ] postNotification: [ NSNotification notificationWithName: NavigationDetailsLoaded
                                                                                              object: navigationPlanDetails ] ];
    [ pool release ];
}

- ( void ) applicationWillTerminate: ( UIApplication * ) application
{
    // Save the configuration
    [ [ Configuration defaultConfiguration ] saveToArchive: [ [ self class ] getConfigurationFilename ] ];
}

+ ( NSString * ) getConfigurationFilename
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains ( NSDocumentDirectory, NSUserDomainMask, YES );
    return [ [ paths objectAtIndex: 0 ] stringByAppendingPathComponent: CONFIGURATION_FILENAME ];
}

#pragma mark -
#pragma mark Notification handlers methods

- ( void ) handleWindDetailsNotification: ( NSNotification * ) notification
{
    if ( [ notification name ] == WindDetailsPublished )
    {
        [ self doHandleDetailsNotificationWithObject: [ notification object ] calculatorSetter: @selector ( setWindDetails: ) ];
        [ [ Configuration defaultConfiguration ] setFromWindDetails: [ notification object ] ];
    }
}

- ( void ) handleNavigationDetailsNotification: ( NSNotification * ) notification
{
    if ( [ notification name ] == NavigationDetailsPublished )
    {
        [ self doHandleDetailsNotificationWithObject: [ notification object ] calculatorSetter: @selector ( setNavigationPlanDetails: ) ];
        [ [ Configuration defaultConfiguration ] setFromNavigationPlanDetails: [ notification object ] ];
    }
}

- ( void ) handleWindCalculatorConsumerNotification: ( NSNotification * ) notification
{
    if ( [ notification name ] == WindCalculatorConsumerCreated )
        [ self doQueueRecalculationOperation ];
}

#pragma mark -
#pragma mark Notification handler helper methods

- ( void ) doHandleDetailsNotificationWithObject: ( id ) object calculatorSetter: ( SEL ) setter
{    
    [ [ WindCalculator defaultCalculator ] performSelector: setter withObject: object ];
    [ self doQueueRecalculationOperation ];
}

- ( void ) doQueueRecalculationOperation
{
    NSOperation * operation = [ [ WindCalculationOperation alloc ] initWithCalculator: [ WindCalculator defaultCalculator ] ];
    [ backgroundQueue addOperation: operation ];
    [ operation release ];
}

@end

