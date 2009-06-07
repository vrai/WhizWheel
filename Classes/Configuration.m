// ***************************************************************************
//              WhizWheel 1.0.0 - Copyright Vrai Stacey 2009
//
// $Id$
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

static Configuration * s_defaultInstance = 0;

#pragma mark -

@interface Configuration ( )
- ( void ) publishUpdatedNotification;
@end

#pragma mark -

@implementation Configuration

@synthesize maximumWindMagnitude;

- ( id ) init
{
    if ( self = [ super init ] )
    {
        maximumWindMagnitude = 50.0f;
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

#pragma mark -
#pragma mark NSCoding implementation

- ( id ) initWithCoder: ( NSCoder * ) decoder
{
    if ( self = [ super init ] )
    {
        maximumWindMagnitude = [ decoder decodeFloatForKey: CODER_KEY_MAXIMUMWINDMAGNITUDE ];
    }
    return self;
}

- ( void ) encodeWithCoder: ( NSCoder * ) encoder
{
    [ encoder encodeFloat: maximumWindMagnitude forKey: CODER_KEY_MAXIMUMWINDMAGNITUDE ];
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
