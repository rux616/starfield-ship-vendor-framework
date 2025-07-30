; Copyright 2024 Dan Cassidy

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


ScriptName ShipVendorFramework:SVF_Control Extends Quest


; imports
import ShipVendorFramework:SVF_DataStructures
import ShipVendorFramework:SVF_Utility


int Property SVFControlVersion = 1 Auto Const Hidden
{ The desired version of the SVF_Control script. }

; The current version of the SVF_Control script.
int SVFControlVersionCurrent = 0

string Property SVFVersion = "1.5.4" Auto Const Hidden
{ The Ship Vendor Framework version. }

Actor Property PlayerRef Auto Hidden ; hide this for now since the CK can't assign actors to script properties
{ The player reference. }

; form lists that keep track of the unique ships that the player has purchased from ship vendors
FormList Property UniqueShipsSoldToPlayerLVLB Auto Const
FormList Property UniqueShipsSoldToPlayerREF Auto Const

; default values for the vendor mappings
Group DefaultVendorMappingValues
    bool Property BuysShipsDefault = true Auto Const
    bool Property SellsShipsDefault = true Auto Const
    int Property RandomShipsForSaleMinDefault = 4 Auto Const
    int Property RandomShipsForSaleMaxDefault = 8 Auto Const
EndGroup

Group ShipVendorMappings
    ; list of type Actor
    FormList Property Vendors Auto Const
    ; list of type FormList
    FormList Property ShipListsRandom Auto Const
    ; list of type FormList
    FormList Property ShipListsAlways Auto Const
    ; list of type FormList
    FormList Property ShipListsUnique Auto Const
    ; list of type GlobalVariable
    FormList Property RandomShipsForSaleMin Auto Const
    ; list of type GameplayOption
    FormList Property RandomShipsForSaleMax Auto Const
EndGroup

int Property LogLevel = 3 Auto Const  ; TODO change back to 0 for release
{ The log level for the script. -1=none, 0=info, 1=warning, 2=error, 3=debug. }

; log levels
; "info" log level
int LL_INFO = 0 Const
; "warning" log level
int LL_WARNING = 1 Const
; "error" log level
int LL_ERROR = 2 Const
; "debug" log level
int LL_DEBUG = 3 Const


; local opinionated log function
Function _Log(string asFunctionName, string asLogMessage, int aiSeverity = 0)
    Log("SVF_Control", GetFormID(), asFunctionName, asLogMessage, aiSeverity, LogLevel)
EndFunction


Event OnInit()
    string fnName = "OnInit" Const
    _Log(fnName, "begin", LL_DEBUG)
    Log("SVF_Control", 0, "Init", "begin_direct", -1)
    VersionInfo(false)
    Log("SVF_Control", 0, "Init", "end_direct", -1)
    _Log(fnName, "end", LL_DEBUG)
EndEvent


Event OnQuestInit()
    string fnName = "OnQuestInit" Const
    _Log(fnName, "begin", LL_DEBUG)
    Log("SVF_Control", 0, "OnQuestInit", "begin_direct", -1)
    Initialize()
    Log("SVF_Control", 0, "OnQuestInit", "end_direct", -1)
    _Log(fnName, "end", LL_DEBUG)
EndEvent


Event Actor.OnPlayerLoadGame(Actor akPlayer)
    string fnName = "Actor.OnPlayerLoadGame" Const
    _Log(fnName, "begin", LL_DEBUG)
    Log("SVF_Control", 0, "Actor.OnPlayerLoadGame", "begin_direct", -1)
    VersionInfo()
    Initialize()
    VendorMappingsSanityCheck()
    Log("SVF_Control", 0, "Actor.OnPlayerLoadGame", "end_direct", -1)
    _Log(fnName, "end", LL_DEBUG)
EndEvent


Function Initialize()
    string fnName = "Initialize" Const
    _Log(fnName, "begin", LL_DEBUG)
    _Log(fnName, "SVF_Control version: current=" + SVFControlVersionCurrent + ", desired=" + SVFControlVersion)

    If SVFControlVersionCurrent != SVFControlVersion
        If SVFControlVersionCurrent == 0
            _Log(fnName, "SVF_Control initializing")
            ; because the CK (still) can't assign actors to script properties, we have to do this manually
            PlayerRef = Game.GetPlayer()
            RegisterForRemoteEvent(PlayerRef, "OnPlayerLoadGame")
            SVFControlVersionCurrent = SVFControlVersion
            _Log(fnName, "SVF_Control initialized")
        EndIf
    EndIf

    _Log(fnName, "end", LL_DEBUG)
EndFunction


; print version and misc debug into to the log
Function VersionInfo(bool abFull = true)
    Log("", 0, "", "Log level: " + LogLevel, -1)
    Log("", 0, "", "Starfield version: " + Debug.GetVersionNumber(), -1)
    Log("", 0, "", "Ship Vendor Framework version: " + SVFVersion, -1)
EndFunction


; does a sanity check on the vendor associations to ensure that the lists are not None and that they match in size
Function VendorMappingsSanityCheck()
    string fnName = "VendorMappingsSanityCheck" Const
    _Log(fnName, "begin", LL_DEBUG)

    bool listNoneError = false
    If Vendors == None
        _Log(fnName, "Vendors is None", LL_ERROR)
        listNoneError = true
    EndIf

    If ShipListsRandom == None
        _Log(fnName, "ShipListsRandom is None", LL_ERROR)
        listNoneError = true
    EndIf

    If ShipListsAlways == None
        _Log(fnName, "ShipListsAlways is None", LL_ERROR)
        listNoneError = true
    EndIf

    If ShipListsUnique == None
        _Log(fnName, "ShipListsUnique is None", LL_ERROR)
        listNoneError = true
    EndIf

    If RandomShipsForSaleMin == None
        _Log(fnName, "RandomShipsForSaleMin is None", LL_ERROR)
        listNoneError = true
    EndIf

    If RandomShipsForSaleMax == None
        _Log(fnName, "RandomShipsForSaleMax is None", LL_ERROR)
        listNoneError = true
    EndIf

    If !listNoneError
        int vendorCount = Vendors.GetSize()
        bool vendorCountMatches = ShipListsRandom.GetSize() == vendorCount \
            && ShipListsAlways.GetSize() == vendorCount \
            && ShipListsUnique.GetSize() == vendorCount \
            && RandomShipsForSaleMin.GetSize() == vendorCount \
            && RandomShipsForSaleMax.GetSize() == vendorCount
        if !vendorCountMatches
            _Log(fnName, "VanillaShipVendors and associated lists do not match in size", LL_ERROR)
        EndIf
    EndIf

    _Log(fnName, "end", LL_DEBUG)
EndFunction


ShipVendorDataMap Function GetShipVendorDataMap(Form akShipVendor)
    string fnName = "GetShipVendorDataMap" Const
    _Log(fnName, "begin", LL_DEBUG)

    If akShipVendor == None
        _Log(fnName, "akShipVendor is None", LL_ERROR)
        return None
    EndIf

    _Log(fnName, "searching for " + akShipVendor + " in Vendors (" + Vendors.GetArray() + ")", LL_DEBUG)
    int vendorIndex = Vendors.Find(akShipVendor)
    If vendorIndex < 0
        _Log(fnName, akShipVendor + " not found in Vendors", LL_WARNING)
        return None
    EndIf
    _Log(fnName, akShipVendor + " found at index: " + vendorIndex, LL_DEBUG)

    ShipVendorDataMap vendorDataMap
    vendorDataMap = new ShipVendorDataMap


    ; this block takes the each form list from the vendor mappings, gets the last form in the list (thereby allowing
    ; individual overrides for each variable for each vendor), and assigns it to the vendorDataMap, casting it to the
    ; appropriate type for each variable. it could be done without the intermediate tempForm variable, but the code is
    ; easier to read this way because it doesn't have to get split up into multiple lines with the editor set to 120
    ; characters per line
    vendorDataMap.Vendor = akShipVendor as ActorBase

    vendorDataMap.ListRandom = FormListGetLast(ShipListsRandom.GetAt(vendorIndex)) as FormList
    vendorDataMap.ListAlways = FormListGetLast(ShipListsAlways.GetAt(vendorIndex)) as FormList
    vendorDataMap.ListUnique = FormListGetLast(ShipListsUnique.GetAt(vendorIndex)) as FormList

    Form tempForm

    tempForm = FormListGetLast(RandomShipsForSaleMin.GetAt(vendorIndex))
    vendorDataMap.RandomShipsForSaleMin = GetValue2(tempForm, RandomShipsForSaleMinDefault) as int

    tempForm = FormListGetLast(RandomShipsForSaleMax.GetAt(vendorIndex))
    vendorDataMap.RandomShipsForSaleMax = GetValue2(tempForm, RandomShipsForSaleMaxDefault) as int


    _Log(fnName, "vendorDataMap.Vendor: " + vendorDataMap.Vendor, LL_DEBUG)
    _Log(fnName, "vendorDataMap.ListRandom: " + vendorDataMap.ListRandom, LL_DEBUG)
    _Log(fnName, "vendorDataMap.ListAlways: " + vendorDataMap.ListAlways, LL_DEBUG)
    _Log(fnName, "vendorDataMap.ListUnique: " + vendorDataMap.ListUnique, LL_DEBUG)
    _Log(fnName, "vendorDataMap.RandomShipsForSaleMin: " + vendorDataMap.RandomShipsForSaleMin, LL_DEBUG)
    _Log(fnName, "vendorDataMap.RandomShipsForSaleMax: " + vendorDataMap.RandomShipsForSaleMax, LL_DEBUG)

    _Log(fnName, "end", LL_DEBUG)
    return vendorDataMap
EndFunction
