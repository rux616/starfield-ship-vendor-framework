; Copyright 2025 Dan Cassidy

; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <https://www.gnu.org/licenses/>.

; SPDX-License-Identifier: GPL-3.0-or-later


ScriptName ShipVendorFramework:SVF_DataStructures
{ contains data structures used by Ship Vendor Framework scripts }


; STRUCTS
; -------

; struct to hold the data for a ship vendor
Struct ShipVendorDataMap
    ActorBase Vendor

    FormList ListRandom
    FormList ListAlways
    FormList ListUnique

    int RandomShipsForSaleMin
    int RandomShipsForSaleMax

    ObjectReference VendorContainer
EndStruct

; struct to hold the mapping of a ship reference to its originating leveled ship
; this is unused at the moment, but if a v2 of the framework is made, the plan is to have it replace the
; "ShipRefToSpaceshipLeveledListMapping" struct in ShipVendorScript
Struct ShipLVLBToREFMap
    LeveledSpaceshipBase LeveledShip
    SpaceshipReference ShipRef
EndStruct

; struct to hold the status of a ship vendor for when the various activator scripts are checking if the vendor is ready
Struct ShipVendorStatus
    bool IsReady  ; true if the vendor is fully initialized and NOT currently running one of the key startup functions

    bool IsFullyInitialized
    bool IsFunctionRunning
EndStruct
