// ***************************************************************************
//           WhizWheel 1.0.3 - Copyright Vrai Stacey 2009 - 2011
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

#import "Configuration.h"
#import "NotificationNames.h"

#define CODER_KEY_CONFIGURATION         @"Configuration"
#define CODER_KEY_MAXIMUMWINDMAGNITUDE  @"maximumWindMagnitude"
#define CODER_KEY_WINDDIRECTION         @"windDirection"
#define CODER_KEY_WINDSPEED             @"windSpeed"
#define CODER_KEY_VERSION               @"version"
#define CODER_KEY_TRACK                 @"track"
#define CODER_KEY_TARGET_SPEED          @"targetSpeed"
#define CODER_KEY_DISTANCE              @"distance"

#define DEFAULT_WIND_DIRECTION  -1
#define DEFAULT_WIND_SPEED      -1
#define DEFAULT_MAX_WIND_MAG    50.0f
#define DEFAULT_TRACK           -1
#define DEFAULT_TARGET_SPEED    -1
#define DEFAULT_DISTANCE        nil

#define VERSION_1_0_0      10000        // Version 1.0.0 didn't have this configuration field
#define VERSION_1_0_1      10010

#define VERSION_CURRENT    VERSION_1_0_1

static Configuration * s_defaultInstance = 0;

#pragma mark -

@interface Configuration ( )
- ( void ) publishUpdatedNotification;
@end

#pragma mark -

@implementation Configuration

@synthesize maximumWindMagnitude;
@synthesize windDirection;
@synthesize windSpeed;
@synthesize track;
@synthesize targetSpeed;
@synthesize distance;

- ( id ) init
{
    if ( ( self = [ super init ] ) )
    {
        windDirection = DEFAULT_WIND_DIRECTION;
        windSpeed = DEFAULT_WIND_SPEED;
        maximumWindMagnitude = DEFAULT_MAX_WIND_MAG;
        track = DEFAULT_TRACK;
        targetSpeed = DEFAULT_TARGET_SPEED;
        distance = DEFAULT_DISTANCE;
    }
    return self;
}

- ( void ) setMaximumWindMagnitude: ( float ) magnitude
{
    if ( fabsf ( magnitude - maximumWindMagnitude ) > 0.0001 )
    {
        maximumWindMagnitude = magnitude;
        [ self publishUpdatedNotification ];
    }
}

- ( void ) setFromWindDetails: ( WindDetails * ) details
{
    windDirection = [ details direction ];
    windSpeed = [ details speed ];
}

- ( WindDetails * ) getAsWindDetails
{
    return [ [ [ WindDetails alloc ] initWithDirection: windDirection speed: windSpeed ] autorelease ];
}

- ( void ) setFromNavigationPlanDetails: ( NavigationPlanDetails * ) details
{
    track = [ details track ];
    targetSpeed = [ details targetAirSpeed ];
    distance = [ details distance ];
}

- ( NavigationPlanDetails * ) getAsNavigationPlanDetails
{
    return [ [ [ NavigationPlanDetails alloc ] initWithTrack: track targetAirSpeed: targetSpeed distance: distance ] autorelease ];
}

#pragma mark -
#pragma mark NSCoding implementation

- ( id ) initWithCoder: ( NSCoder * ) decoder
{
    if ( ( self = [ super init ] ) )
    {
        // The version number is used to determine what can be loaded. Version 1.0.0 has no version information.
        int version = [ decoder decodeIntForKey: CODER_KEY_VERSION ];
        switch ( version )
        {
            case VERSION_1_0_1:
                windDirection = [ decoder decodeIntForKey: CODER_KEY_WINDDIRECTION ];
                windSpeed = [ decoder decodeIntForKey: CODER_KEY_WINDSPEED ];
                maximumWindMagnitude = [ decoder decodeFloatForKey: CODER_KEY_MAXIMUMWINDMAGNITUDE ];
                track = [ decoder decodeIntForKey: CODER_KEY_TRACK ];
                targetSpeed = [ decoder decodeIntForKey: CODER_KEY_TARGET_SPEED ];
                distance = [ [ decoder decodeObjectForKey: CODER_KEY_DISTANCE ] retain ];
                break;
        
            default:
                // No version information - use default values
                windDirection = DEFAULT_WIND_DIRECTION;
                windSpeed = DEFAULT_WIND_SPEED;
                maximumWindMagnitude = DEFAULT_MAX_WIND_MAG;
                track = DEFAULT_TRACK;
                targetSpeed = DEFAULT_TARGET_SPEED;
                distance = DEFAULT_DISTANCE;
                break;
        }
    }
    return self;
}

- ( void ) encodeWithCoder: ( NSCoder * ) encoder
{
    [ encoder encodeInt:    VERSION_CURRENT      forKey: CODER_KEY_VERSION ];
    [ encoder encodeInt:    windDirection        forKey: CODER_KEY_WINDDIRECTION ];
    [ encoder encodeInt:    windSpeed            forKey: CODER_KEY_WINDSPEED ];
    [ encoder encodeFloat:  maximumWindMagnitude forKey: CODER_KEY_MAXIMUMWINDMAGNITUDE ];
    [ encoder encodeInt:    track                forKey: CODER_KEY_TRACK ];
    [ encoder encodeInt:    targetSpeed          forKey: CODER_KEY_TARGET_SPEED ];
    [ encoder encodeObject: distance             forKey: CODER_KEY_DISTANCE ];
}

- ( void ) saveToArchive: ( NSString * ) path
{
    // Save the object to a keyed archive
    NSMutableData * data = [ [ NSMutableData alloc ] init ];
    NSKeyedArchiver * archiver = [ [ NSKeyedArchiver alloc ] initForWritingWithMutableData: data ];
    [ archiver encodeObject: self forKey: CODER_KEY_CONFIGURATION ];
    [ archiver finishEncoding ];
    [ data writeToFile: path atomically: YES ];
    [ archiver release ];
    [ data release ];
}

- ( void ) publishUpdatedNotification
{
    [ [ NSNotificationCenter defaultCenter ] postNotification: [ NSNotification notificationWithName: ConfigurationUpdated
                                                                                              object: self ] ];
}

#pragma mark -
#pragma mark NSCopying implementation

- ( id ) copyWithZone: ( NSZone * ) zone
{
    Configuration * copy = [ [ [ self class ] allocWithZone: zone ] init ];
    copy.maximumWindMagnitude = maximumWindMagnitude;
    copy.windDirection = windDirection;
    copy.windSpeed = windSpeed;
    return copy;
}

#pragma mark -
#pragma mark Static accessors

+ ( id ) defaultConfiguration
{
    @synchronized ( self )
    {
        if ( ! s_defaultInstance )
            s_defaultInstance = [ [ Configuration alloc ] init ];
    }
    
    return s_defaultInstance;
}

+ ( id ) initialiseDefaultConfigurationFromFile: ( NSString * ) path
{
    @synchronized ( self )
    {
        if ( ! s_defaultInstance )
        {
            // Load the configuration instance from a keyed archive (if the file exists). If the file doesn't exist
            // simply return a new default instance.
            if ( [ [ NSFileManager defaultManager ] fileExistsAtPath: path ] )
            {
                NSMutableData * data = [ [ NSMutableData alloc ] initWithContentsOfFile: path ];
                NSKeyedUnarchiver * unarchiver = [ [ NSKeyedUnarchiver alloc ] initForReadingWithData: data ];
                s_defaultInstance = [ [ unarchiver decodeObjectForKey: CODER_KEY_CONFIGURATION ] retain ];
                [ unarchiver finishDecoding ];
                [ unarchiver release ];
                [ data release ];
            }
            else
                [ self defaultConfiguration ];
        }
    }
    
    return s_defaultInstance;
}

@end
