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

#import "TextSplitter.h"

NSArray * splitStringIntoLines ( NSString * source, int width )
{
    NSMutableArray * lines = [ [ NSMutableArray alloc  ] init ];
    NSArray * words = [ source componentsSeparatedByCharactersInSet: [ NSCharacterSet characterSetWithCharactersInString: @" \r\n\t" ] ];
    
    NSString * line = nil;
    for ( NSString * word in words )
    {
        if ( line && ( [ line length ] + [ word length ] + 1 ) > width )
        {
            [ lines addObject: line ];
            line = nil;
        }
        
        if ( line )
            line = [ NSString stringWithFormat: @"%@ %@", line, word ];
        else
            line = word;
    }
    
    if ( line )
        [ lines addObject: line ];

    return lines;
}
