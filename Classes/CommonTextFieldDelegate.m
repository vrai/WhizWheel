// ***************************************************************************
//            WhizWheel 1.0.3 - Copyright Vrai Stacey 2009 - 2011
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

#import "CommonTextFieldDelegate.h"

@interface CommonTextFieldDelegate ( Private )
- ( NSString * ) formatTextFieldContents: ( NSString * ) contents;
- ( BOOL ) validateTextFieldContents: ( NSString * ) contents;
@end

#pragma mark -

@implementation CommonTextFieldDelegate

@synthesize valueUpdatedSelector;
@synthesize valueUpdatedSelectorTarget;

- ( id ) initWithSelector: ( SEL ) theValueUpdatedSelector target: ( id ) theSelectorTarget
{
    if ( ( self = [ super init ] ) )
    {   
        [ self setValueUpdatedSelector: theValueUpdatedSelector ];
        [ self setValueUpdatedSelectorTarget: theSelectorTarget ];
    }
    return self;
}

- ( void ) dealloc
{
    [ valueUpdatedSelectorTarget release ];
    [ super dealloc ];
}

- ( void ) setText: ( NSString * ) text forField: ( UITextField * ) textField
{
    [ textField setText: [ text length ] > 0 ? [ self formatTextFieldContents: text ]
                                             : text ];
}

#pragma mark -
#pragma mark UITextFieldDelegate functionality

- ( BOOL ) textFieldShouldReturn: ( UITextField * ) theTextField
{
    [ theTextField resignFirstResponder ];
    return YES;
}

- ( void ) textFieldDidEndEditing: ( UITextField * ) theTextField
{
    [ self setText: [ theTextField text ] forField: theTextField ];
    [ valueUpdatedSelectorTarget performSelectorOnMainThread: valueUpdatedSelector
                                                  withObject: [ [ theTextField text ] retain ]
                                               waitUntilDone: YES ];
}

- ( BOOL ) textField: ( UITextField * ) theTextField shouldChangeCharactersInRange: ( NSRange ) range replacementString: ( NSString * ) string
{
    NSString * text = [ [ theTextField text ] stringByReplacingCharactersInRange: range withString: string ];
    return [ self validateTextFieldContents: text ];
}

@end
