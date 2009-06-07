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

#import "WindRoseDetails.h"
#import "TextFormatter.h"

@interface OffsetSpeedPair : NSObject
{
    int offset;
    int speed;
}

@property int offset;
@property int speed;

- ( id ) initWithOffset: ( int ) theOffset speed: ( int ) theSpeed;

@end

@implementation OffsetSpeedPair

@synthesize offset;
@synthesize speed;

- ( id ) initWithOffset: ( int ) theOffset speed: ( int ) theSpeed
{
    if ( self = [ super init ] )
    {   
        offset = theOffset;
        speed = theSpeed;
    }
    return self;
}

- ( NSString * ) description
{
    return [ NSString stringWithFormat: @"OffsetSpeedPair[ offset: %d, speed:%d ]", offset, speed ];
}

@end

#pragma mark -

@interface WindRoseDetails ( Private )
- ( OffsetSpeedPair * ) getPairForDirection: ( int ) direction;
@end

#pragma mark -

@implementation WindRoseDetails

@synthesize directionToOffsetMap;
@synthesize error;

- ( id ) init
{
    if ( self = [ super init ] )
        directionToOffsetMap = [ [ NSMutableDictionary alloc ] init ];
    return self;
}

- ( id ) initWithError: ( NSString * ) theError
{
    if ( self = [ super init ] )
    {
        directionToOffsetMap = nil;
        error = [ theError retain ];
    }
    return self;
}

- ( void ) dealloc
{
    [ directionToOffsetMap release ];
    [ error release ];
    [ super dealloc ];
}

- ( BOOL ) isValid
{
    return error == nil;
}

- ( NSString * ) description
{
    // Construct an array of string representations of the offset/speed pair
    NSMutableArray * elements = [ [ NSMutableArray alloc ] init ];
    for ( NSNumber * direction in [ [ directionToOffsetMap allKeys ] sortedArrayUsingSelector: @selector ( compare: ) ] )
    {
        OffsetSpeedPair * pair = [ self getPairForDirection: [ direction intValue ] ];
        [ elements addObject: [ NSString stringWithFormat: @"%d = %@/%d", [ direction intValue ],
                                                                          [ [ TextFormatter defaultFormatter ] formatSignedInteger: [ pair offset ] ],
                                                                          [ pair speed ] ] ];
    }
    
    NSString * output = [ NSString stringWithFormat: @"WindRoseDetails[ %@ ]", [ elements componentsJoinedByString: @", " ] ];
    [ elements release ];
    return output;
}

#pragma mark -
#pragma mark Direction keyed setters

- ( void ) setOffset: ( int ) offset speed: ( int ) speed forDirection: ( int ) direction
{
    OffsetSpeedPair * pair = [ [ OffsetSpeedPair alloc ] initWithOffset: offset speed: speed ];
    [ directionToOffsetMap setObject: pair forKey: [ NSNumber numberWithInt: direction ] ];
    [ pair release ];
}

#pragma mark -
#pragma mark Direction keyed getters

- ( BOOL ) hasDirection: ( int ) direction
{
    return [ self getPairForDirection: direction ] != nil;
}

- ( int ) getOffsetForDirection: ( int ) direction
{
    OffsetSpeedPair * pair = [ self getPairForDirection: direction ];
    if ( pair )
        return [ pair offset ];
    else
    {
        [ NSException exceptionWithName: @"GetOffsetForDirection"
                                 reason: [ NSString stringWithFormat: @"No offset for direction %d", direction ]
                               userInfo: nil ];
        return 0;
    }
}

- ( int ) getSpeedForDirection: ( int ) direction
{
    OffsetSpeedPair * pair = [ self getPairForDirection: direction ];
    if ( pair )
        return [ pair speed ];
    else
    {
        [ NSException exceptionWithName: @"GetSpeedForDirection"
                                 reason: [ NSString stringWithFormat: @"No speed for direction %d", direction ]
                               userInfo: nil ];
        return 0;
    }
}

- ( OffsetSpeedPair * ) getPairForDirection: ( int ) direction
{
    return [ directionToOffsetMap objectForKey: [ NSNumber numberWithInt: direction ] ];
}

@end
