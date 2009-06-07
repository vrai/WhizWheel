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

#import "TextValidator.h"

@interface TextValidator ( )
- ( void ) compileRegularExpression: ( regex_t * ) target pattern: ( NSString * ) pattern;
- ( BOOL ) evaluateRegularExpression: ( regex_t * ) expression string: ( NSString * ) string;
@end

@implementation TextValidator

- ( id ) init
{
    if ( self = [ super init ] )
    {
        [ self compileRegularExpression: &directionRegex     pattern: @"^[0-9]?[0-9]?[0-9]?$" ];
        [ self compileRegularExpression: &naturalNumberRegex pattern: @"^([1-9][0-9]*|0)?$" ];
        [ self compileRegularExpression: &decimalNumberRegex pattern: @"^[0-9]*\\.?[0-9]*$" ];
    }
    
    return self;
}

- ( void ) dealloc
{
    regfree ( &directionRegex );
    regfree ( &naturalNumberRegex );
    regfree ( &decimalNumberRegex );
    [ super dealloc ];
}

- ( BOOL ) validateStringAsString: ( NSString * ) string
{
    return string != nil;
}

- ( BOOL ) validateStringAsDirection: ( NSString * ) string
{
    if ( ! [ self evaluateRegularExpression: &directionRegex string: string ] )
        return NO;

    return [ string length ] <= 3 && [ string intValue ] >= 0 && [ string intValue ] <= 359;
}

- ( BOOL ) validateStringAsNaturalNumber: ( NSString * ) string
{
    if ( ! [ self evaluateRegularExpression: &naturalNumberRegex string: string ] )
        return NO;

    return [ string intValue ] >= 0;
}

- ( BOOL ) validateStringAsNaturalNumber: ( NSString * ) string withUpperLimit: ( int ) limit
{
    return [ self validateStringAsNaturalNumber: string ] && [ string intValue ] <= limit;
}

- ( BOOL ) validateStringAsUnsignedDecimal: ( NSString * ) string
{
    return [ self evaluateRegularExpression: &decimalNumberRegex string: string ];
}

#pragma mark -
#pragma mark Regular expression wrapper code

- ( void ) compileRegularExpression: ( regex_t * ) target pattern: ( NSString * ) pattern
{
    const int errorCode = regcomp ( target, [ pattern UTF8String ], REG_EXTENDED );
    if ( errorCode != 0 )
    {
        char errorBuffer [ 1024 ];
        regerror ( errorCode, target, errorBuffer, sizeof ( errorBuffer ) );
        NSString * error = [ NSString stringWithFormat: @"Failed to compile expression \"%@\" - %s", pattern, errorBuffer ];
        NSLog ( error );
        @throw [ NSException exceptionWithName: @"RegularExpression Compilation"
                                        reason: error
                                      userInfo: nil ];
    }
}

- ( BOOL ) evaluateRegularExpression: ( regex_t * ) expression string: ( NSString * ) string
{
    regmatch_t match;
    return regexec ( expression, [ string UTF8String ], 1, &match, 0 ) == 0;
}

#pragma mark -
#pragma mark Static accessor

+ ( id ) defaultValidator
{
    static TextValidator * defaultInstance;
    
    @synchronized ( self )
    {
        if ( ! defaultInstance )
            defaultInstance = [ [ TextValidator alloc ] init ];
    }
    
    return defaultInstance;
}

@end
