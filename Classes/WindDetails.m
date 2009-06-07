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

#import "WindDetails.h"
#import "TextFormatter.h"

@implementation WindDetails

@synthesize direction;
@synthesize speed;

- ( id ) init
{
    if ( self = [ super init ] )
    {
        direction = -1;
        speed = -1;
    }
    return self;
}

- ( id ) initWithDirection: ( int ) theDirection speed: ( int ) theSpeed
{
    if ( self = [ super init ] )
    {
        direction = theDirection;
        speed = theSpeed;
    }
    return self;
}

- ( void ) dealloc
{
    [ super dealloc ];
}

- ( void ) setDirection: ( int ) newDirection
{
    @synchronized ( self )
    {
        if ( newDirection >= -1 && newDirection < 360 )
            direction = newDirection;
    }
}

- ( void ) setSpeed: ( int ) newSpeed
{
    @synchronized ( self )
    {
        if ( newSpeed >= -1 )
            speed = newSpeed;
    }
}

- ( BOOL ) isEqual: ( id ) other
{
    if ( ! [ other isKindOfClass: [ self class ] ] )
        return FALSE;
        
    return [ other speed ] == speed && [ other direction ] == direction;
}

- ( NSString * ) description
{
    return [ NSString stringWithFormat: @"WindDetails[ direction: %@, speed: %i ]", [ [ TextFormatter defaultFormatter ] formatDirection: direction ], speed ];
}

#pragma mark === NSCopying implementation ===

- ( id ) copyWithZone: ( NSZone * ) zone
{  
    return [ [ WindDetails alloc ] initWithDirection: direction speed: speed ];
}

@end
