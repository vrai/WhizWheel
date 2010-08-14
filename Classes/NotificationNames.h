// ***************************************************************************
//             WhizWheel 1.0.1 - Copyright Vrai Stacey 2009 - 2010
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

#pragma mark Simple request notifications (no arguments)

NSString * const ConfigurationUpdated;              // Triggered by changes to the Configuration singleton
NSString * const WindCalculatorConsumerCreated;     // Triggered by the creation of a WindRoseResults/NavigationResults consumer
NSString * const WindDetailsRepublishRequest;       // Triggered by the creation of a WindDetails consumer

#pragma mark -
#pragma mark Payload carrying notifications

NSString * const NavigationDetailsPublished;        // Contains NavigationDetails instance
NSString * const NavigationDetailsLoaded;           // Contains NavigationDetails instance
NSString * const NavigationResultsPublished;        // Contains NavigationResults instance
NSString * const WindDetailsInternalPublished;      // Contains WindDetails instance - only for consumption by children of WindViewController
NSString * const WindDetailsPublished;              // Contains WindDetails instance - for general consumption
NSString * const WindRoseResultsPublished;          // Contains WindRoseResults instance
