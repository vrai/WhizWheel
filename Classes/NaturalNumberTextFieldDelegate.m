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

#import "NaturalNumberTextFieldDelegate.h"
#import "TextFormatter.h"
#import "TextValidator.h"

@implementation NaturalNumberTextFieldDelegate

@synthesize maximum;

- ( id ) initWithSelector: ( SEL ) theValueUpdatedSelector target: ( id ) theSelectorTarget maximum: ( unsigned int ) theMaximum
{
    if ( self = [ super initWithSelector: theValueUpdatedSelector target: theSelectorTarget ] )
        maximum = theMaximum;
    return self;
}

#pragma mark -
#pragma mark CommonTextFieldDelegate functionality

- ( NSString * ) formatTextFieldContents: ( NSString * ) contents
{
    return [ [ TextFormatter defaultFormatter ] formatNaturalNumber: [ contents intValue ] ];
}

- ( BOOL ) validateTextFieldContents: ( NSString * ) contents
{
    return maximum ? [ [ TextValidator defaultValidator ] validateStringAsNaturalNumber: contents withUpperLimit: maximum ]
                   : [ [ TextValidator defaultValidator ] validateStringAsNaturalNumber: contents ];
}

@end
