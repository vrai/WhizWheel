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

#import "TextFormatter.h"

@implementation TextFormatter

- ( NSString * ) formatSignedInteger: ( int ) integer
{
    char prefix = '+';
    if ( integer < 0 )
    {
        prefix = '-';
        integer *= -1;
    }
    
    return [ NSString stringWithFormat: @"%c%i", prefix, integer ];
}

- ( NSString * ) formatDirection: ( int ) degrees
{
    return [ [ NSString stringWithFormat: @"%3i", degrees ] stringByReplacingOccurrencesOfString: @" " withString: @"0" ];
}

- ( NSString * ) formatNaturalNumber: ( int ) number
{
    return [ NSString stringWithFormat: @"%i", number ];
}

- ( NSString * ) formatDecimalNumber: ( NSDecimalNumber * ) number
{
    return number ? [ number stringValue ] : @"";
}

- ( NSString * ) formatHTMLString: ( NSString * ) content
{
    // The HTML "page" - the expansion tag is where the content goes
    NSString * base=  @"<html>\n"
                       "  <head>\n"
                       "    <style type=\"text/css\">\n"
                       "      body\n"
                       "      {\n"
                       "        background-color: transparent;\n"
                       "        color: black;\n"
                       "        font-size: 10pt;\n"
                       "        font-family: Helvetica, sans-serif;\n"
                       "        padding: 0px;\n"
                       "        margin: 0px;\n"
                       "      }\n"
                       "      h1, h2\n"
                       "      {\n"
                       "        font-weight: bold;\n"
                       "        margin: 0px 0px 2px 0px;\n"
                       "        text-align: center\n"
                       "      }\n"
                       "      h1\n"
                       "      {\n"
                       "        font-size: 12pt;\n"
                       "      }\n"
                       "      h2\n"
                       "      {\n"
                       "        font-size: 10pt;\n"
                       "      }\n"
                       "    </style>\n"
                       "  </head>\n"
                       "  <body>\n"
                       "%@\n"
                       "  </body>\n"
                       "</html>\n";
                       
    return [ NSString stringWithFormat: base, content ];
}

#pragma mark -
#pragma mark Static accessor

+ ( id ) defaultFormatter
{
    static TextFormatter * defaultInstance;
    
    @synchronized ( self )
    {
        if ( ! defaultInstance )
            defaultInstance = [ [ TextFormatter alloc ] init ];
    }
    
    return defaultInstance;
}

@end
