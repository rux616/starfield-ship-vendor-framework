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
Import ShipVendorFramework:SVF_DataStructures
Import ShipVendorFramework:SVF_Utility


; The desired version of the SVF_Control script.
int Property SVFControlVersion = 1 Auto Const Hidden

; The current version of the SVF_Control script.
int SVFControlVersionCurrent = 0

; The Ship Vendor Framework version.
string Property SVFVersion = "1.6.0" Auto Const Hidden

Actor Property PlayerRef Auto Hidden ; hide this for now since the CK can't assign actors to script properties
{ The player reference. }

FormList Property UniqueShipsSold Auto Const
{ Form List that keeps track of unique ships sold to the player. }

Group GameplayOptions
    GameplayOption Property RegenerateUniqueShipsOption Auto Const
    { Gameplay option to control whether unique ships sold to the player can be regenerated. }

    GameplayOption Property RichShipVendorsOption Auto Const
    { Gameplay option to control whether ship vendors have more credits and auto-replenish said credits. }
EndGroup

; default values for the vendor mappings
int Property RandomShipsForSaleMinDefault = 4 Auto Const Hidden
int Property RandomShipsForSaleMaxDefault = 8 Auto Const Hidden

Group ShipVendorMappings
    FormList Property Vendors Auto Const                ; list of type Actor
    { The list of vendors to build the data mappings from. }
    FormList Property ShipListsRandom Auto Const        ; list of type FormList
    { The list of random ship lists that correspond to each vendor. }
    FormList Property ShipListsAlways Auto Const        ; list of type FormList
    { The list of always available ship lists that correspond to each vendor. }
    FormList Property ShipListsUnique Auto Const        ; list of type FormList
    { The list of unique ship lists that correspond to each vendor. }
    FormList Property RandomShipsForSaleMin Auto Const  ; list of type GameplayOption/GlobalVariable
    { The list containing the gameplay option or global variable controlling the minimum number of
      random ships for sale for each vendor. }
    FormList Property RandomShipsForSaleMax Auto Const  ; list of type GameplayOption/GlobalVariable
    { The list containing the gameplay option or global variable controlling the maximum number of
      random ships for sale for each vendor. }
EndGroup

; cached vendor mappings
Form[] vendorsCache
Form[] shipListsRandomCache
Form[] shipListsAlwaysCache
Form[] shipListsUniqueCache
Form[] randomShipsForSaleMinCache
Form[] randomShipsForSaleMaxCache

; the log level for the script
; -1=none, 0=info, 1=warning, 2=error, 3=debug
int Property LogLevel = 3 Auto Const Hidden  ; TODO change back to 0 for release

; log levels
; "info" log level
int Property LL_INFO = 0 Auto Const Hidden
; "warning" log level
int Property LL_WARNING = 1 Auto Const Hidden
; "error" log level
int Property LL_ERROR = 2 Auto Const Hidden
; "debug" log level
int Property LL_DEBUG = 3 Auto Const Hidden


; local opinionated log function
Function _Log(string asFunctionName, string asLogMessage, int aiSeverity = 0)
    Log("SVF_Control", GetFormID(), asFunctionName, asLogMessage, aiSeverity, LogLevel)
EndFunction


Event OnInit()
    string fnName = "OnInit" Const
    _Log(fnName, "begin", LL_DEBUG)
    Log("SVF_Control", 0, "Init", "begin_direct", -1)
    VersionInfo()
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
    Log("SVF_Control", 0, "Actor.OnPlayerLoadGame", "end_direct", -1)
    _Log(fnName, "end", LL_DEBUG)
EndEvent


Function Initialize()
    string fnName = "Initialize" Const
    _Log(fnName, "begin", LL_DEBUG)
    _Log(fnName, "SVF Control version: current=" + SVFControlVersionCurrent + ", desired=" + SVFControlVersion)

    If SVFControlVersionCurrent < 1
        InitializeSVFControlVersion1()
    EndIf

    ; perform sanity checks
    bool mappingsNotNone = VendorMappingsNotNone()
    bool mappingsSizesMatch = true
    If mappingsNotNone == true
        CacheVendorMappings()
        mappingsSizesMatch = VendorMappingsSizesMatch()
    EndIf

    ; show error messages if needed
    If mappingsNotNone == false
        ; TODO show an error message in game
    ElseIf mappingsSizesMatch == false
        ; TODO show an error message in game
    EndIf

    _Log(fnName, "end", LL_DEBUG)
EndFunction


bool Function SVFControlInitialized()
    string fnName = "SVFControlInitialized" Const
    _Log(fnName, "begin", LL_DEBUG)

    bool toReturn = SVFControlVersionCurrent == SVFControlVersion
    _Log(fnName, "returning " + toReturn, LL_DEBUG)

    _Log(fnName, "end", LL_DEBUG)
    Return toReturn
EndFunction


Function InitializeSVFControlVersion1()
    int updatingToVersion = 1 Const
    string fnName = "InitializeSVFControlVersion" + updatingToVersion Const
    _Log(fnName, "begin", LL_DEBUG)

    _Log(fnName, "SVF Control initializing to version " + updatingToVersion)

    ; because the CK (still) can't assign actors to script properties, we have to do this manually
    PlayerRef = Game.GetPlayer()
    RegisterForRemoteEvent(PlayerRef, "OnPlayerLoadGame")

    SVFControlVersionCurrent = updatingToVersion
    _Log(fnName, "SVF Control initialized to version " + updatingToVersion)

    _Log(fnName, "end", LL_DEBUG)
EndFunction


; print version and misc debug into to the log
Function VersionInfo()
    Log("", 0, "", "Log level: " + LogLevel, -1)
    Log("", 0, "", "Starfield version: " + Debug.GetVersionNumber(), -1)
    Log("", 0, "", "Ship Vendor Framework version: " + SVFVersion, -1)
EndFunction


; performs a sanity check on the vendor mappings to ensure that the lists are not None
bool Function VendorMappingsNotNone()
    string fnName = "VendorMappingsNotNone" Const
    _Log(fnName, "begin", LL_DEBUG)

    bool listNone = false
    If Vendors == None
        _Log(fnName, "Vendors is None", LL_ERROR)
        listNone = true
    EndIf

    If ShipListsRandom == None
        _Log(fnName, "ShipListsRandom is None", LL_ERROR)
        listNone = true
    EndIf

    If ShipListsAlways == None
        _Log(fnName, "ShipListsAlways is None", LL_ERROR)
        listNone = true
    EndIf

    If ShipListsUnique == None
        _Log(fnName, "ShipListsUnique is None", LL_ERROR)
        listNone = true
    EndIf

    If RandomShipsForSaleMin == None
        _Log(fnName, "RandomShipsForSaleMin is None", LL_ERROR)
        listNone = true
    EndIf

    If RandomShipsForSaleMax == None
        _Log(fnName, "RandomShipsForSaleMax is None", LL_ERROR)
        listNone = true
    EndIf

    _Log(fnName, "end", LL_DEBUG)
    Return !listNone
EndFunction


; performs a sanity check on the vendor mappings to ensure that the sizes match
bool Function VendorMappingsSizesMatch()
    string fnName = "VendorMappingsSizesMatch" Const
    _Log(fnName, "begin", LL_DEBUG)

    bool listSizesMatch = vendorsCache.Length == shipListsRandomCache.Length       \
                       && vendorsCache.Length == shipListsAlwaysCache.Length       \
                       && vendorsCache.Length == shipListsUniqueCache.Length       \
                       && vendorsCache.Length == randomShipsForSaleMinCache.Length \
                       && vendorsCache.Length == randomShipsForSaleMaxCache.Length
    if !listSizesMatch
        _Log(fnName, "The vendor mappings lists do not match in size", LL_ERROR)
        _Log(fnName, "    Vendors: " + vendorsCache.Length, LL_ERROR)
        _Log(fnName, "    ShipListsRandom: " + shipListsRandomCache.Length, LL_ERROR)
        _Log(fnName, "    ShipListsAlways: " + shipListsAlwaysCache.Length, LL_ERROR)
        _Log(fnName, "    ShipListsUnique: " + shipListsUniqueCache.Length, LL_ERROR)
        _Log(fnName, "    RandomShipsForSaleMin: " + randomShipsForSaleMinCache.Length, LL_ERROR)
        _Log(fnName, "    RandomShipsForSaleMax: " + randomShipsForSaleMaxCache.Length, LL_ERROR)
    EndIf

    _Log(fnName, "end", LL_DEBUG)
    Return listSizesMatch
EndFunction


; caches the vendor mappings into local arrays for faster access
Function CacheVendorMappings()
    string fnName = "CacheVendorMappings" Const
    _Log(fnName, "begin", LL_DEBUG)

    vendorsCache = Vendors.GetArray()
    shipListsRandomCache = ShipListsRandom.GetArray()
    shipListsAlwaysCache = ShipListsAlways.GetArray()
    shipListsUniqueCache = ShipListsUnique.GetArray()
    randomShipsForSaleMinCache = RandomShipsForSaleMin.GetArray()
    randomShipsForSaleMaxCache = RandomShipsForSaleMax.GetArray()

    _Log(fnName, "end", LL_DEBUG)
EndFunction


ShipVendorDataMap Function GetShipVendorDataMap(Form akShipVendor)
    string fnName = "GetShipVendorDataMap" Const
    _Log(fnName, "begin", LL_DEBUG)

    If akShipVendor == None
        _Log(fnName, "akShipVendor is None", LL_ERROR)
        Return None
    EndIf

    _Log(fnName, "searching for " + akShipVendor + " in Vendors (" + vendorsCache + ")", LL_DEBUG)
    int vendorIndex = vendorsCache.Find(akShipVendor)
    If vendorIndex < 0
        _Log(fnName, akShipVendor + " not found in Vendors", LL_WARNING)
        Return None
    EndIf
    _Log(fnName, akShipVendor + " found at index " + vendorIndex, LL_DEBUG)

    ShipVendorDataMap vendorDataMap
    vendorDataMap = new ShipVendorDataMap


    ; this block takes the each form list from the vendor mappings, gets the last form in the list (thereby allowing
    ; individual overrides for each variable for each vendor), and assigns it to the vendorDataMap, casting it to the
    ; appropriate type for each variable. it could be done without the intermediate tempForm variable, but the code is
    ; easier to read this way because it doesn't have to get split up into multiple lines with the editor set to 120
    ; characters per line
    vendorDataMap.Vendor = akShipVendor as ActorBase

    vendorDataMap.ListRandom = FormListGetLast(shipListsRandomCache[vendorIndex]) as FormList
    vendorDataMap.ListAlways = FormListGetLast(shipListsAlwaysCache[vendorIndex]) as FormList
    vendorDataMap.ListUnique = FormListGetLast(shipListsUniqueCache[vendorIndex]) as FormList

    Form tempForm

    tempForm = FormListGetLast(randomShipsForSaleMinCache[vendorIndex])
    vendorDataMap.RandomShipsForSaleMin = GetValue2(tempForm, RandomShipsForSaleMinDefault) as int

    tempForm = FormListGetLast(randomShipsForSaleMaxCache[vendorIndex])
    vendorDataMap.RandomShipsForSaleMax = GetValue2(tempForm, RandomShipsForSaleMaxDefault) as int


    _Log(fnName, "vendorDataMap.Vendor: " + vendorDataMap.Vendor, LL_INFO)
    _Log(fnName, "vendorDataMap.ListRandom: " + vendorDataMap.ListRandom, LL_INFO)
    _Log(fnName, "vendorDataMap.ListAlways: " + vendorDataMap.ListAlways, LL_INFO)
    _Log(fnName, "vendorDataMap.ListUnique: " + vendorDataMap.ListUnique, LL_INFO)
    _Log(fnName, "vendorDataMap.RandomShipsForSaleMin: " + vendorDataMap.RandomShipsForSaleMin, LL_INFO)
    _Log(fnName, "vendorDataMap.RandomShipsForSaleMax: " + vendorDataMap.RandomShipsForSaleMax, LL_INFO)

    _Log(fnName, "end", LL_DEBUG)
    Return vendorDataMap
EndFunction
