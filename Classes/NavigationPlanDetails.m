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

#import "NavigationPlanDetails.h"
#import "TextFormatter.h"

@implementation NavigationPlanDetails

@synthesize track;
@synthesize distance;
@synthesize targetAirSpeed;

- ( id ) init
{
    if ( self = [ super init ] )
    {
        track = -1;
        distance = nil;
        targetAirSpeed = -1;
    }
    return self;
}

- ( id ) initWithTrack: ( int ) theTrack targetAirSpeed: ( int ) theTAS distance: ( NSDecimalNumber * ) theDistance
{
    if ( self = [ super init ] )
    {
        track = theTrack;
        distance = [ theDistance copy ];
        targetAirSpeed = theTAS;
    }
    return self;
}

- ( void ) dealloc
{
    [ distance release ];
    [ super dealloc ];
}

- ( void ) setTrack: ( int ) newTrack
{
    @synchronized ( self )
    {
        if ( track >= -1 && track < 360 )
            track = newTrack;
    }
}

- ( void ) setDistance: ( NSDecimalNumber * ) newDistance
{
    @synchronized ( self )
    {
        if ( newDistance == nil || [ newDistance doubleValue ] >= 0.0 )
        {
            [ distance release ];
            distance = [ newDistance copy ];
        }
    }
}

- ( void ) setTargetAirSpeed: ( int ) newTAS
{
    @synchronized ( self )
    {
        if ( newTAS >= -1 )
            targetAirSpeed = newTAS;
    }
}

- ( NSString * ) description
{
    return [ NSString stringWithFormat: @"NavigationPlanDetails[ track: %@, distance: %@, tas: %@ ]", [ [ TextFormatter defaultFormatter ] formatDirection: track ],
                                                                                                      distance,
                                                                                                      [ [ TextFormatter defaultFormatter ] formatNaturalNumber: targetAirSpeed ] ];
}

#pragma mark -
#pragma mark NSCopying implementation

- ( id ) copyWithZone: ( NSZone * ) zone
{   
    return [ [ NavigationPlanDetails alloc ] initWithTrack: track targetAirSpeed: targetAirSpeed distance: distance ];
}

@end
