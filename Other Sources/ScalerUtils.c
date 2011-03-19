// ***************************************************************************
//              WhizWheel 1.0.2 - Copyright Vrai Stacey 2010
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

#include "ScalerUtils.h"

CGPoint scalePoint ( CGPoint source, float scale )
{
    return CGPointMake ( source.x * scale, source.y * scale );
}

CGRect scaleRect ( CGRect source, float scale )
{
    return CGRectMake ( source.origin.x * scale,
                        source.origin.y * scale,
                        source.size.width * scale,
                        source.size.height * scale );
}
