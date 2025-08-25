ScriptName ShipVendorScript Extends Actor Conditional

Keyword Property LinkShipLandingMarker01 Auto Const Mandatory
{ link vendor to landing marker }

Keyword Property SpaceshipStoredLink Auto Const Mandatory
{ link ships to landing marker }

SQ_PlayerShipScript Property SQ_PlayerShip Auto Const Mandatory
{ The main Player Ship system quest }

Location Property ShipVendorLocation Auto Const
{ OPTIONAL - The location used to spawn vendor ships at for leveling purposes.
    If not filled in, script will use vendor's current location }

ShipVendorListScript Property ShipsToSellListRandomDataset Auto Const
{ DEPRECATED - Use SVFShipsToSellListRandomDataset or the vendor data map instead. }

ShipVendorListScript Property ShipsToSellListAlwaysDataset Auto Const
{ DEPRECATED - Use SVFShipsToSellListAlwaysDataset or the vendor data map instead. }

ShipVendorListScript Property ShipsToSellListUniqueDataset Auto Const
{ DEPRECATED - Use SVFShipsToSellListUniqueDataset or the vendor data map instead. }

int Property ShipsForSaleMin = 4 Auto Const
{ The minimum number of ships from the "random" dataset for sale. Note that the vendor data map supersedes this value. }

int Property ShipsForSaleMax = 8 Auto Const
{ The maximum number of ships from the "random" dataset for sale. Note that the vendor data map supersedes this value. }

ObjectReference Property MyLandingMarker Auto Hidden
{ landing marker, set by OnInit }

RefCollectionAlias Property PlayerShips Auto Const Mandatory
{ from SQ_PlayerShip - need to know when player sells ships }

float Property DaysUntilInventoryRefresh = 7.0 Auto Const
{ how many days until next inventory refresh? }

bool Property BuysShips = true Auto Conditional
bool Property SellsShips = true Auto Conditional

bool Property InitializeOnLoad = true Auto Const
{ if false, Initialize() needs to be called manually (e.g. for outpost ship vendor) }

ShipVendorListScript:ShipToSell[] shipsToSellRandom
ShipVendorListScript:ShipToSell[] shipsToSellAlways
ShipVendorListScript:ShipToSell[] shipsToSellUnique
float lastInventoryRefreshTimestamp ; timestamp when last refresh happened

SpaceshipReference[] shipsForSale RequiresGuard(ShipsForSaleGuard)
Guard ShipsForSaleGuard

bool initialized = false


; additional variables and properties to support Ship Vendor Framework enhancements

Group ShipVendorFramework
    FormList Property SVFShipsToSellListRandomDataset Auto Const
    { The list of random ships to sell. }
    FormList Property SVFShipsToSellListAlwaysDataset Auto Const
    { The list of ships that should always be available for sale. }
    FormList Property SVFShipsToSellListUniqueDataset Auto Const
    { The list of unique ships to make available for sale. (Never respawns.) }

    bool Property SVFUseNewDatasets = false Auto Const  ; DEPRECATED
    { !!!DEPRECATED!!! Mark vendor as using the new Ship Vendor Framework datasets. !!!DEPRECATED!!! }

    FormList Property SVFExternalUniquesSoldList Auto Const  ; DEPRECATED
    { !!!DEPRECATED!!! OPTIONAL - can be used to coordinate a list of unique ships that have been already sold between chosen vendors. If not filled in, the vendor will use their own local list. !!!DEPRECATED!!! }
EndGroup

; local clones of various properties
FormList svfShipsToSellListRandomDatasetLocal
FormList svfShipsToSellListAlwaysDatasetLocal
FormList svfShipsToSellListUniqueDatasetLocal
int shipsForSaleMinLocal
int shipsForSaleMaxLocal

; local cache of the contents of the new FormList-based datasets
LeveledSpaceshipBase[] svfShipsToSellRandom
LeveledSpaceshipBase[] svfShipsToSellAlways
LeveledSpaceshipBase[] svfShipsToSellUnique

; track the actual ships available to sell in the various established categories: random, always, unique, and
; player-sold
SpaceshipReference[] shipsForSaleRandom RequiresGuard(ShipsForSaleGuard)
SpaceshipReference[] shipsForSaleAlways RequiresGuard(ShipsForSaleGuard)
SpaceshipReference[] shipsForSaleUnique RequiresGuard(ShipsForSaleGuard)
SpaceshipReference[] shipsForSaleSoldByPlayer RequiresGuard(ShipsForSaleGuard)

; flag to indicate whether the vendor should use SVF datasets; updated every load (replaces SVFUseNewDatasets property)
bool useSVFDatasets = false

; unique ships that have been sold to the player and thus should not be available for sale again
; TODO determine whether to store the form list ref locally or whether to use svf_control directly
FormList svfUniqueShipsSoldToPlayerListLVLB
FormList svfUniqueShipsSoldToPlayerListREF
; local 'sold' lists
LeveledSpaceshipBase[] uniquesSoldListLocal ; TODO this is probably not needed in v3
LeveledSpaceshipBase[] alwaysSoldList

; struct to hold the mapping of a ship reference to its originating leveled list
Struct ShipRefToSpaceshipLeveledListMapping
    LeveledSpaceshipBase LeveledShip
    SpaceshipReference ShipRef
EndStruct
; variables to hold the ship ref to leveled list mappings to support ship tracking
ShipRefToSpaceshipLeveledListMapping[] shipsForSaleMapping
ShipRefToSpaceshipLeveledListMapping[] shipsForSaleMappingRandom
ShipRefToSpaceshipLeveledListMapping[] shipsForSaleMappingAlways
ShipRefToSpaceshipLeveledListMapping[] shipsForSaleMappingUnique

; the desired version of the Ship Vendor Framework enhancements
int Property SVFEnhancementsVersion = 3 Auto Const Hidden

; the current version of the Ship Vendor Framework enhancements active on the vendor
int svfEnhancementsVersionCurrent = 0

; the control script for the Ship Vendor Framework
ShipVendorFramework:SVF_Control svfControlScript

; the player reference
Actor playerRef

; guard (and dummy int) to protect against multiple initialization calls
int dummyInt RequiresGuard(LoadGuard)
Guard LoadGuard

; the log level for the script
; -1=none, 0=info, 1=warning, 2=error, 3=debug
int Property LogLevel = 3 Auto Const Hidden  ; DEPRECATED ; TODO convert log levels to new format

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
    ShipVendorFramework:SVF_Utility.Log("ShipVendorScript", GetFormID(), asFunctionName, asLogMessage, aiSeverity, LogLevel)
EndFunction


Event OnLoad()
    string fnName = "OnLoad" Const
    _Log(fnName, "begin", LL_DEBUG)

    LockGuard LoadGuard
        HandleOnLoad()
    EndLockGuard

    _Log(fnName, "end", LL_DEBUG)
EndEvent


Event OnUnload()
    string fnName = "OnUnload" Const
    _Log(fnName, "begin", LL_DEBUG)

    _Log(fnName, "unregistering for player load game events")
    UnregisterForRemoteEvent(playerRef, "OnPlayerLoadGame")

    _Log(fnName, "end", LL_DEBUG)
EndEvent


; using OnActivate is a workaround for the fact that if the player installs SVF for the first time and loads a save
; where the vendor is already loaded, the OnPlayerLoadGame event hasn't yet been registered, so it won't fire, and
; neither will the OnLoad event for the vendor
Event OnActivate(ObjectReference akActionRef)
    string fnName = "OnActivate" Const
    _Log(fnName, "begin (" + akActionRef + ")", LL_DEBUG)

    ; only do something if the SVF enhancements haven't been initialized
    LockGuard LoadGuard
        If SVFEnhancementsInitialized() == false
            _Log(fnName, "SVF enhancements not initialized - initializing now")
            HandleOnLoad()
        EndIf
    EndLockGuard

    _Log(fnName, "end (" + akActionRef + ")", LL_DEBUG)
EndEvent


; utilize OnPlayerLoadGame as another workaround for the fact that if the player loads a save where the vendor is
; already loaded, the OnLoad event for the vendor doesn't fire again. this is preferred over the OnActivate event
; because it potentially gives more time between running the HandleOnLoad() function and the player actually
; interacting with the vendor
Event Actor.OnPlayerLoadGame(Actor akPlayer)
    string fnName = "Actor.OnPlayerLoadGame" Const
    _Log(fnName, "begin", LL_DEBUG)

    ; if the 3D isn't loaded, check in 1 second intervals for a number of seconds and then unregister for the event
    int i = 3
    bool loaded3D = Is3DLoaded()
    While i > 0 && loaded3D == false
        If loaded3D == false
            _Log(fnName, "3D not loaded, waiting 1 second", LL_DEBUG)
            Utility.WaitMenuPause(1.0)
            loaded3D = Is3DLoaded()
        EndIf
        i += -1
    EndWhile
    If loaded3D == false
        _Log(fnName, "3D not loaded, unregistering for OnPlayerLoadGame event", LL_WARNING)
        UnregisterForRemoteEvent(playerRef, "OnPlayerLoadGame")
    Else
        _Log(fnName, "3D loaded; continuing", LL_DEBUG)
        LockGuard LoadGuard
            HandleOnLoad()
        EndLockGuard
    EndIf

    _Log(fnName, "end", LL_DEBUG)
EndEvent


Function HandleOnLoad() RequiresGuard(LoadGuard)
    string fnName = "HandleOnLoad" Const
    _Log(fnName, "begin", LL_DEBUG)

    ; needed to satisfy the guard
    dummyInt = 0

    If LogLevel == LL_DEBUG
        _Log(fnName, "starting stack profiling", LL_DEBUG)
        Debug.StartStackProfiling()
        DebugDumpData()
    EndIf

    If initialized == false || SVFEnhancementsInitialized() == false
        If initialized == true
            ; if initialized == true, the vendor has already been initialized, but because of the prior logic statement,
            ; SVFEnhancementsInitialized() _must_ have returned false, which means the SVF enhancements still need to be
            ; initialized
            _Log(fnName, "initializing SVF enhancements on load", LL_DEBUG)
            Initialize(myLandingMarker)
        ElseIf InitializeOnLoad == true
            If myLandingMarker == None
                myLandingMarker = GetLinkedRef(LinkShipLandingMarker01)
            EndIf
            _Log(fnName, "initializing on load, landing marker is " + myLandingMarker, LL_DEBUG)
            Initialize(myLandingMarker)
        EndIf
    Else
        ; sync the uniques sold list with the external list if provided
        SyncUniquesSoldList()

        PopulateLocals()
        UseSVFDatasetsCheck()

        CheckForInventoryRefresh()
    EndIf

    RegisterForPermanentRemoteEvents()

    If LogLevel == LL_DEBUG
        DebugDumpData()
        Debug.StopStackProfiling()
        _Log(fnName, "stopped stack profiling", LL_DEBUG)
    EndIf

    _Log(fnName, "end", LL_DEBUG)
EndFunction


Function Initialize(ObjectReference akLandingMarkerRef)
    string fnName = "Initialize" Const
    _Log(fnName, "begin (" + akLandingMarkerRef + ")", LL_DEBUG)

    bool doRefreshCheck = false

    _Log(fnName, "Log level: " + LogLevel)
    _Log(fnName, "Primary initialization done: " + initialized)
    _Log(fnName, "SVF Enhancements version: current=" + svfEnhancementsVersionCurrent + ", desired=" + SVFEnhancementsVersion)

    If akLandingMarkerRef != None
        myLandingMarker = akLandingMarkerRef
        _Log(fnName, "setting myLandingMarker to " + myLandingMarker)
    Else
        _Log(fnName, "CRITICAL: no landing marker provided; aborting", LL_ERROR)
        Return
    EndIf

    If initialized == false
        ; Initialize arrays.
        shipsToSellRandom = new ShipVendorListScript:ShipToSell[0]
        shipsToSellAlways = new ShipVendorListScript:ShipToSell[0]
        shipsToSellUnique = new ShipVendorListScript:ShipToSell[0]

        LockGuard ShipsForSaleGuard
            shipsForSale = new SpaceshipReference[0]
        EndLockGuard

        doRefreshCheck = true
    EndIf

    ; SVF initial setup
    If svfEnhancementsVersionCurrent < 1
        InitializeSVFEnhancementsVersion1()
        doRefreshCheck = true
    EndIf

    ; SVF version 1 to 2 update tasks
    If svfEnhancementsVersionCurrent < 2
        InitializeSVFEnhancementsVersion2()
        doRefreshCheck = true
    EndIf

    ; SVF version 2 to 3 update tasks
    If svfEnhancementsVersionCurrent < 3
        InitializeSVFEnhancementsVersion3()
        doRefreshCheck = true
    EndIf

    RegisterForPermanentRemoteEvents()

    initialized = true

    If doRefreshCheck == true
        CheckForInventoryRefresh()
    EndIf

    _Log(fnName, "end (" + akLandingMarkerRef + ")", LL_DEBUG)
EndFunction


; register for the permanent remote events that the vendor needs to listen to
Function RegisterForPermanentRemoteEvents()
    string fnName = "RegisterForPermanentRemoteEvents" Const
    _Log(fnName, "begin", LL_DEBUG)

    ; register for ship sell events
    _Log(fnName, "registering for ship sell events", LL_DEBUG)
    RegisterForRemoteEvent(PlayerShips, "OnShipSold")

    ; register for load game events - automatically unregistered when the vendor is unloaded
    _Log(fnName, "registering for player load game events", LL_DEBUG)
    RegisterForRemoteEvent(playerRef, "OnPlayerLoadGame")

    _Log(fnName, "end", LL_DEBUG)
EndFunction


; check if the Ship Vendor Framework enhancements have been initialized
bool Function SVFEnhancementsInitialized()
    string fnName = "SVFEnhancementsInitialized" Const
    _Log(fnName, "begin", LL_DEBUG)

    bool toReturn = svfEnhancementsVersionCurrent == SVFEnhancementsVersion
    _Log(fnName, "returning " + toReturn, LL_DEBUG)

    _Log(fnName, "end", LL_DEBUG)
    Return toReturn
EndFunction


Function InitializeSVFEnhancementsVersion1()
    int updatingToVersion = 1 Const
    string fnName = "InitializeSVFEnhancementsVersion" + updatingToVersion Const
    _Log(fnName, "begin", LL_DEBUG)

    _Log(fnName, "Ship Vendor Framework enhancements initializing to version " + updatingToVersion)

    ; variable initialization
    svfShipsToSellRandom = new LeveledSpaceshipBase[0]
    svfShipsToSellAlways = new LeveledSpaceshipBase[0]
    svfShipsToSellUnique = new LeveledSpaceshipBase[0]
    shipsForSaleMapping = new ShipRefToSpaceshipLeveledListMapping[0]
    shipsForSaleMappingRandom = new ShipRefToSpaceshipLeveledListMapping[0]
    shipsForSaleMappingAlways = new ShipRefToSpaceshipLeveledListMapping[0]
    shipsForSaleMappingUnique = new ShipRefToSpaceshipLeveledListMapping[0]
    uniquesSoldListLocal = new LeveledSpaceshipBase[0]
    LockGuard ShipsForSaleGuard
        shipsForSaleRandom = new SpaceshipReference[0]
        shipsForSaleAlways = new SpaceshipReference[0]
        shipsForSaleUnique = new SpaceshipReference[0]
        shipsForSaleSoldByPlayer = new SpaceshipReference[0]
    EndLockGuard
    playerRef = Game.GetPlayer()

    ; if the vendor itself is already initialized, force refresh the inventory
    If initialized == true
        _Log(fnName, "vendor already initialized, deleting existing ships and resetting timestamp to trigger inventory refresh")
        ; manually delete the ship references first
        LockGuard ShipsForSaleGuard
            DeleteShips(shipsForSale)
        EndLockGuard
        ; reset timestamp so that the inventory refresh happens immediately
        lastInventoryRefreshTimestamp = 0.0
    EndIf

    svfEnhancementsVersionCurrent = updatingToVersion
    _Log(fnName, "Ship Vendor Framework enhancements updated to version " + updatingToVersion)

    _Log(fnName, "end", LL_DEBUG)
EndFunction


Function InitializeSVFEnhancementsVersion2()
    int updatingToVersion = 2 Const
    string fnName = "InitializeSVFEnhancementsVersion" + updatingToVersion Const
    _Log(fnName, "begin", LL_DEBUG)

    _Log(fnName, "Ship Vendor Framework enhancements updating to version " + updatingToVersion)
    int i = 0

    ; variable initialization
    alwaysSoldList = new LeveledSpaceshipBase[0]

    ; purge ShipsForSale* lists of ship references that are None
    _Log(fnName, "purging ShipsForSale* lists of ship references that are None")
    LockGuard ShipsForSaleGuard
        _Log(fnName, "purging ShipsForSale of None ships", LL_DEBUG)
        i = ShipsForSale.Length - 1
        While i > -1
            If ShipsForSale[i].IsBoundGameObjectAvailable() == false
                _Log(fnName, "removing None ship at position " + i + " from main list", LL_DEBUG)
                ShipsForSale.Remove(i)
            EndIf
            i += -1
        EndWhile
        _Log(fnName, "purging shipsForSaleRandom of None ships", LL_DEBUG)
        i = shipsForSaleRandom.Length - 1
        While i > -1
            If shipsForSaleRandom[i].IsBoundGameObjectAvailable() == false
                _Log(fnName, "removing None ship at position " + i + " from random list", LL_DEBUG)
                shipsForSaleRandom.Remove(i)
            EndIf
            i += -1
        EndWhile
        _Log(fnName, "purging shipsForSaleAlways of None ships", LL_DEBUG)
        i = shipsForSaleAlways.Length - 1
        While i > -1
            If shipsForSaleAlways[i].IsBoundGameObjectAvailable() == false
                _Log(fnName, "removing None ship at position " + i + " from priority list", LL_DEBUG)
                shipsForSaleAlways.Remove(i)
            EndIf
            i += -1
        EndWhile
        _Log(fnName, "purging shipsForSaleUnique of None ships", LL_DEBUG)
        i = shipsForSaleUnique.Length - 1
        While i > -1
            If shipsForSaleUnique[i].IsBoundGameObjectAvailable() == false
                _Log(fnName, "removing None ship at position " + i + " from unique list", LL_DEBUG)
                shipsForSaleUnique.Remove(i)
            EndIf
            i += -1
        EndWhile
        _Log(fnName, "purging shipsForSaleSoldByPlayer of None ships", LL_DEBUG)
        i = shipsForSaleSoldByPlayer.Length - 1
        While i > -1
            If shipsForSaleSoldByPlayer[i].IsBoundGameObjectAvailable() == false
                _Log(fnName, "removing None ship at position " + i + " from player sold list", LL_DEBUG)
                shipsForSaleSoldByPlayer.Remove(i)
            EndIf
            i += -1
        EndWhile
    EndLockGuard

    ; purge ship to leveled base ship maps of mappings that have ship references that are None
    _Log(fnName, "purging ship to leveled base ship maps of mappings that have ship references that are None")
    _Log(fnName, "purging shipsForSaleMapping of None ships", LL_DEBUG)
    i = shipsForSaleMapping.Length - 1
    While i > -1
        If shipsForSaleMapping[i].ShipRef.IsBoundGameObjectAvailable() == false
            _Log(fnName, "removing None ship at position " + i + " from mapping list", LL_DEBUG)
            shipsForSaleMapping.Remove(i)
        EndIf
        i += -1
    EndWhile
    _Log(fnName, "purging shipsForSaleMappingRandom of None ships", LL_DEBUG)
    i = shipsForSaleMappingRandom.Length - 1
    While i > -1
        If shipsForSaleMappingRandom[i].ShipRef.IsBoundGameObjectAvailable() == false
            _Log(fnName, "removing None ship at position " + i + " from mapping list", LL_DEBUG)
            shipsForSaleMappingRandom.Remove(i)
        EndIf
        i += -1
    EndWhile
    _Log(fnName, "purging shipsForSaleMappingAlways of None ships", LL_DEBUG)
    i = shipsForSaleMappingAlways.Length - 1
    While i > -1
        If shipsForSaleMappingAlways[i].ShipRef.IsBoundGameObjectAvailable() == false
            _Log(fnName, "removing None ship at position " + i + " from mapping list", LL_DEBUG)
            shipsForSaleMappingAlways.Remove(i)
        EndIf
        i += -1
    EndWhile
    _Log(fnName, "purging shipsForSaleMappingUnique of None ships", LL_DEBUG)
    i = shipsForSaleMappingUnique.Length - 1
    While i > -1
        If shipsForSaleMappingUnique[i].ShipRef.IsBoundGameObjectAvailable() == false
            _Log(fnName, "removing None ship at position " + i + " from mapping list", LL_DEBUG)
            shipsForSaleMappingUnique.Remove(i)
        EndIf
        i += -1
    EndWhile

    ; iterate through the linked ships and if the ship belongs to the vendor but isn't in the mappings and wasn't sold
    ; by the player, add it to the list of ships to purge
    If myLandingMarker != None
        _Log(fnName, "purging linked ships that are owned by the vendor but don't have mappings and weren't sold by the player")
        SpaceshipReference[] linkedShips = myLandingMarker.GetRefsLinkedToMe(SpaceshipStoredLink) as SpaceshipReference[]
        SpaceshipReference[] shipsToPurge = new SpaceshipReference[0]

        LockGuard ShipsForSaleGuard
            Actor owner
            int mapping
            int playerSoldShip
            i = 0
            While i < linkedShips.Length
                owner = linkedShips[i].GetActorRefOwner()
                mapping = shipsForSaleMapping.FindStruct("ShipRef", linkedShips[i])
                playerSoldShip = shipsForSaleSoldByPlayer.Find(linkedShips[i])
                _Log(fnName, "checks: ship=" + linkedShips[i] + ", owner=" + owner + ", shipsForSaleMapping=" + mapping + ", shipsForSaleSoldByPlayer=" + playerSoldShip, LL_DEBUG)
                If owner == Self && mapping < 0 && playerSoldShip < 0
                    _Log(fnName, "adding " + linkedShips[i] + " to purge list", LL_DEBUG)
                    shipsToPurge.Add(linkedShips[i])
                EndIf
                i += 1
            EndWhile
        EndLockGuard

        _Log(fnName, "found " + shipsToPurge.Length + " linked ships to purge", LL_WARNING)
        DeleteShips(shipsToPurge)
    EndIf

    ; if the vendor itself is already initialized and isn't already slated to be refreshed, force it
    If initialized == true && lastInventoryRefreshTimestamp > 0.0
        _Log(fnName, "resetting timestamp to trigger inventory refresh")
        ; reset timestamp so that the inventory refresh happens immediately
        lastInventoryRefreshTimestamp = 0.0
    EndIf

    svfEnhancementsVersionCurrent = updatingToVersion
    _Log(fnName, "Ship Vendor Framework enhancements updated to version " + updatingToVersion)

    _Log(fnName, "end", LL_DEBUG)
EndFunction


Function InitializeSVFEnhancementsVersion3()
    int updatingToVersion = 3 Const
    string fnName = "InitializeSVFEnhancementsVersion" + updatingToVersion Const
    _Log(fnName, "begin", LL_DEBUG)

    _Log(fnName, "Ship Vendor Framework enhancements updating to version " + updatingToVersion)

    ; init control script variable
    svfControlScript = Game.GetFormFromFile(0x000810, "ShipVendorFramework.esm") as ShipVendorFramework:SVF_Control

    ; TODO convert uniques sold list

    ; process vendor data map
    PopulateLocals()

    ; check whether to actually utilize the SVF datasets
    UseSVFDatasetsCheck()

    svfEnhancementsVersionCurrent = updatingToVersion
    _Log(fnName, "Ship Vendor Framework enhancements updated to version " + updatingToVersion)

    _Log(fnName, "end", LL_DEBUG)
EndFunction


Function DebugDumpData()
    string fnName = "DebugDumpData" Const
    _Log(fnName, "begin", LL_DEBUG)

    ; if in debug mode dump linked ref info (again)
    If LogLevel == LL_DEBUG && myLandingMarker != None
        ObjectReference[] linkedRefs = myLandingMarker.GetRefsLinkedToMe(SpaceshipStoredLink)
        _Log(fnName, "dumping linked ref info", LL_DEBUG)
        _Log(fnName, "GetRefsLinkedToMe(" + linkedRefs.Length + ")=" + linkedRefs, LL_DEBUG)
        int i = 0
        While i < linkedRefs.Length
            _Log(fnName, "linked ref " + i + ": " + linkedRefs[i] + ", owner: " + linkedRefs[i].GetActorRefOwner() + ", base object: " + linkedRefs[i].GetBaseObject(), LL_DEBUG)
            i += 1
        EndWhile
    EndIf

    ; if in debug mode and SVFEnhancements is already initialized, dump the current arrays
    If LogLevel == LL_DEBUG && svfEnhancementsVersionCurrent > 0
        _Log(fnName, "dumping current arrays", LL_DEBUG)
        _Log(fnName, "svfShipsToSellRandom=" + svfShipsToSellRandom, LL_DEBUG)
        _Log(fnName, "svfShipsToSellAlways=" + svfShipsToSellAlways, LL_DEBUG)
        _Log(fnName, "svfShipsToSellUnique=" + svfShipsToSellUnique, LL_DEBUG)
        _Log(fnName, "shipsForSaleMapping=" + shipsForSaleMapping, LL_DEBUG)
        _Log(fnName, "shipsForSaleMappingRandom=" + shipsForSaleMappingRandom, LL_DEBUG)
        _Log(fnName, "shipsForSaleMappingAlways=" + shipsForSaleMappingAlways, LL_DEBUG)
        _Log(fnName, "shipsForSaleMappingUnique=" + shipsForSaleMappingUnique, LL_DEBUG)
        _Log(fnName, "alwaysSoldList=" + alwaysSoldList, LL_DEBUG)
        _Log(fnName, "uniquesSoldListLocal=" + uniquesSoldListLocal, LL_DEBUG)
        _Log(fnName, "svfShipsToSellListRandomDatasetLocal=" + svfShipsToSellListRandomDatasetLocal, LL_DEBUG)
        _Log(fnName, "svfShipsToSellListAlwaysDatasetLocal=" + svfShipsToSellListAlwaysDatasetLocal, LL_DEBUG)
        _Log(fnName, "svfShipsToSellListUniqueDatasetLocal=" + svfShipsToSellListUniqueDatasetLocal, LL_DEBUG)
        _Log(fnName, "shipsForSaleMinLocal=" + shipsForSaleMinLocal, LL_DEBUG)
        _Log(fnName, "shipsForSaleMaxLocal=" + shipsForSaleMaxLocal, LL_DEBUG)
        LockGuard ShipsForSaleGuard
            _Log(fnName, "shipsForSale=" + shipsForSale, LL_DEBUG)
            _Log(fnName, "shipsForSaleRandom=" + shipsForSaleRandom, LL_DEBUG)
            _Log(fnName, "shipsForSaleAlways=" + shipsForSaleAlways, LL_DEBUG)
            _Log(fnName, "shipsForSaleUnique=" + shipsForSaleUnique, LL_DEBUG)
            _Log(fnName, "shipsForSaleSoldByPlayer=" + shipsForSaleSoldByPlayer, LL_DEBUG)
        EndLockGuard
    EndIf

    _Log(fnName, "end", LL_DEBUG)
EndFunction


; populate the local variables with data from the vendor data map or SVF dataset properties
Function PopulateLocals()
    string fnName = "PopulateLocals" Const
    _Log(fnName, "begin", LL_DEBUG)

    Form baseSelf = Self.GetBaseObject()
    _Log(fnName, "getting vendor data map for " + Self + " (base: " + (baseSelf as ActorBase) + ")")
    ShipVendorFramework:SVF_DataStructures:ShipVendorDataMap vendorDataMap
    vendorDataMap = svfControlScript.GetShipVendorDataMap(baseSelf)
    If vendorDataMap != None
        _Log(fnName, "vendor data map found")
        svfShipsToSellListRandomDatasetLocal = vendorDataMap.ListRandom
        svfShipsToSellListAlwaysDatasetLocal = vendorDataMap.ListAlways
        svfShipsToSellListUniqueDatasetLocal = vendorDataMap.ListUnique
        shipsForSaleMinLocal = vendorDataMap.RandomShipsForSaleMin
        shipsForSaleMaxLocal = vendorDataMap.RandomShipsForSaleMax
    Else
        _Log(fnName, "vendor data map not found")
        svfShipsToSellListRandomDatasetLocal = SVFShipsToSellListRandomDataset
        svfShipsToSellListAlwaysDatasetLocal = SVFShipsToSellListAlwaysDataset
        svfShipsToSellListUniqueDatasetLocal = SVFShipsToSellListUniqueDataset
        shipsForSaleMinLocal = ShipsForSaleMin
        shipsForSaleMaxLocal = ShipsForSaleMax
    EndIf

    ; sanity check the min/max random ships for sale values, switching if needed
    If shipsForSaleMaxLocal < shipsForSaleMinLocal
        _Log(fnName, "random ships for sale values need to be reversed. min=" + shipsForSaleMinLocal + ", max=" + shipsForSaleMaxLocal, LL_WARNING)
        ; swap the values
        int temp = shipsForSaleMinLocal
        shipsForSaleMinLocal = shipsForSaleMaxLocal
        shipsForSaleMaxLocal = temp
    EndIf

    _Log(fnName, "end", LL_DEBUG)
EndFunction


; check to see if this script should use the SVF datasets (replacement for 'SVFUseNewDatasets' property)
Function UseSVFDatasetsCheck()
    string fnName = "UseSVFDatasetsCheck" Const
    _Log(fnName, "begin", LL_DEBUG)

    useSVFDatasets = svfShipsToSellListAlwaysDatasetLocal != None \
        && svfShipsToSellListRandomDatasetLocal != None \
        && svfShipsToSellListUniqueDatasetLocal != None
    _Log(fnName, "Using SVF datasets: " + useSVFDatasets)

    _Log(fnName, "end", LL_DEBUG)
EndFunction


; sync an uniques sold form list with the local list
Function SyncUniquesSoldList()
    string fnName = "SyncUniquesSoldList" Const
    _Log(fnName, "begin", LL_DEBUG)

    If SVFExternalUniquesSoldList != None
        _Log(fnName, "external uniques sold list provided, syncing uniques sold list")
        LeveledSpaceshipBase[] externalUniquesSold = SVFExternalUniquesSoldList.GetArray() as LeveledSpaceshipBase[]
        int i = 0
        int externalUniquesSoldIndex = 0
        bool addedToExternalList = false
        While i < uniquesSoldListLocal.Length && externalUniquesSold.Length > 0
            externalUniquesSoldIndex = externalUniquesSold.Find(uniquesSoldListLocal[i])
            If externalUniquesSoldIndex < 0
                SVFExternalUniquesSoldList.AddForm(uniquesSoldListLocal[i])
                addedToExternalList = true
            EndIf
            i += 1
        EndWhile
        If addedToExternalList
            _Log(fnName, "added unique ships to external list")
            uniquesSoldListLocal = SVFExternalUniquesSoldList.GetArray() as LeveledSpaceshipBase[]
        Else
            _Log(fnName, "external list is up to date")
            uniquesSoldListLocal = externalUniquesSold
        EndIf
        _Log(fnName, "external list contents are now: " + uniquesSoldListLocal, LL_DEBUG)
    EndIf

    _Log(fnName, "end", LL_DEBUG)
EndFunction


Function TestLinkedRefChildren(ObjectReference akRefToCheck, Keyword akKeyword)
    Debug.Trace(Self + " GetRefsLinkedToMe=" + akRefToCheck.GetRefsLinkedToMe(akKeyword))
EndFunction


Event RefCollectionAlias.OnShipSold(RefCollectionAlias akSender, ObjectReference akSenderRef)
    string fnName = "RefCollectionAlias.OnShipSold" Const
    _Log(fnName, "begin", LL_DEBUG)

    _Log(fnName, "akSender=" + akSender + ", akSenderRef=" + akSenderRef, LL_DEBUG)

    ; if this ship is linked to this landing marker, add it to vendor's list
    SpaceshipReference soldShip = akSenderRef as SpaceshipReference
    If soldShip && soldShip.GetLinkedRef(SpaceshipStoredLink) == myLandingMarker
        LockGuard ShipsForSaleGuard
            shipsForSale.Add(soldShip)
            shipsForSaleSoldByPlayer.Add(soldShip)
        EndLockGuard
    EndIf
    ; TODO add support for taking uniques off the unique purchased list if sold by the player

    _Log(fnName, "end", LL_DEBUG)
EndEvent


Event SpaceshipReference.OnShipBought(SpaceshipReference akSenderRef)
    string fnName = "SpaceshipReference.OnShipBought" Const
    _Log(fnName, "begin", LL_DEBUG)

    _Log(fnName, "akSenderRef=" + akSenderRef, LL_DEBUG)
    LockGuard ShipsForSaleGuard
        LeveledSpaceshipBase clearedLeveledShip = None

        ; clear the ship reference from the vendor's lists
        _Log(fnName, "clearing ship reference from shipsForSale list", LL_DEBUG)
        ClearShipReference(akSenderRef, shipsForSale, shipsForSaleMapping)
        _Log(fnName, "clearing ship reference from shipsForSaleRandom list", LL_DEBUG)
        clearedLeveledShip = ClearShipReference(akSenderRef, shipsForSaleRandom, shipsForSaleMappingRandom)

        If clearedLeveledShip == None
            ; ships in the "always" list are added to a local list of sold ships that resets when the vendor does
            _Log(fnName, "clearing ship reference from shipsForSaleAlways list", LL_DEBUG)
            clearedLeveledShip = ClearShipReference(akSenderRef, shipsForSaleAlways, shipsForSaleMappingAlways)
            If clearedLeveledShip != None
                _Log(fnName, "'always' ship was bought, adding " + clearedLeveledShip + " to 'always' sold list")
                alwaysSoldList.Add(clearedLeveledShip)
            EndIf
        EndIf

        If clearedLeveledShip == None
            ; ships in the "unique" list are added to a list of uniques sold, either local or external
            _Log(fnName, "clearing ship reference from shipsForSaleUnique list", LL_DEBUG)
            clearedLeveledShip = ClearShipReference(akSenderRef, shipsForSaleUnique, shipsForSaleMappingUnique)
            If clearedLeveledShip != None
                _Log(fnName, "'unique' ship was bought, adding " + clearedLeveledShip + " to 'unique' sold list")
                If SVFExternalUniquesSoldList != None
                    SVFExternalUniquesSoldList.AddForm(clearedLeveledShip)
                    SyncUniquesSoldList()
                Else
                    uniquesSoldListLocal.Add(clearedLeveledShip)
                EndIf
            EndIf
        EndIf

        If clearedLeveledShip == None
            clearedLeveledShip = ClearShipReference(akSenderRef, shipsForSaleSoldByPlayer, None)
        EndIf
    EndLockGuard

    _Log(fnName, "end", LL_DEBUG)
EndEvent


; clear a ship reference from the vendor's list
LeveledSpaceshipBase Function ClearShipReference(SpaceshipReference akShipRef, SpaceshipReference[] akShipList, ShipRefToSpaceshipLeveledListMapping[] akShipListMapping)
    string fnName = "ClearShipReference" Const
    _Log(fnName, "begin", LL_DEBUG)

    LeveledSpaceshipBase toReturn = None
    If akShipRef
        int refIndex = akShipList.Find(akShipRef)
        If refIndex > -1
            akShipList.Remove(refIndex)
        EndIf
        ; clear the ship reference from the mapping list, but check if the mapping isn't None first, as that can happen
        ; in the case of player-sold ships
        If akShipListMapping != None
            refIndex = akShipListMapping.FindStruct("ShipRef", akShipRef)
            If refIndex > -1
                toReturn = akShipListMapping[refIndex].leveledShip
                akShipListMapping.Remove(refIndex)
            EndIf
        EndIf
    EndIf

    _Log(fnName, "returning " + toReturn, LL_DEBUG)
    _Log(fnName, "end", LL_DEBUG)
    Return toReturn
EndFunction


; checks if it's time to refresh the inventory (can be forced) and kicks it off if needed
Function CheckForInventoryRefresh(bool abForceRefresh = false)
    string fnName = "CheckForInventoryRefresh" Const
    _Log(fnName, "begin", LL_DEBUG)

    If SellsShips
        float currentGameTime = Utility.GetCurrentGameTime()
        float nextRefreshTime = lastInventoryRefreshTimestamp + DaysUntilInventoryRefresh
        _Log(fnName, "currentGameTime=" + currentGameTime + " || nextRefreshTime=" + nextRefreshTime, LL_DEBUG)

        ; if the inventory has never been refreshed, or it's time to refresh, or it's being forced
        If abForceRefresh || lastInventoryRefreshTimestamp == 0 || (currentGameTime >= nextRefreshTime)
            _Log(fnName, "refreshing inventory (force=" + abForceRefresh + ")")

            ; the "always" sold list is cleared when the vendor refreshes their inventory
            alwaysSoldList.Clear()

            RefreshShipsToSellArrays()
            LockGuard ShipsForSaleGuard
                RefreshInventoryList(myLandingMarker, shipsForSale, shipsForSaleAlways, shipsForSaleRandom, shipsForSaleUnique, shipsForSaleSoldByPlayer)
                _Log(fnName, "shipsForSale=" + shipsForSale, LL_DEBUG)
            EndLockGuard
        Else
            LockGuard ShipsForSaleGuard
                PurgeAlreadySoldUniques(shipsForSale, shipsForSaleUnique)
            EndLockGuard
            CheckForNewShips()
        EndIf
    EndIf

    _Log(fnName, "end", LL_DEBUG)
EndFunction


; remove any unique ships that have already been purchased by the player
Function PurgeAlreadySoldUniques(SpaceshipReference[] akShipList, SpaceshipReference[] akShipListUniques)
    string fnName = "PurgeAlreadySoldUniques" Const
    _Log(fnName, "begin", LL_DEBUG)

    ; only needs to run under the following circumstances:
    ;   - there are unique ships to sell
    ;   - there are unique ships that have already been sold
    ;   - there is an external list to sync with
    ; (if there is no external list, the local list is used and will always be up to date)
    If UniqueShipsToSell() == true && uniquesSoldListLocal.Length > 0 && SVFExternalUniquesSoldList != None
        int uniqueSoldIndex = 0
        int mappingIndex = 0
        int uniquesListIndex = 0
        int i = akShipList.Length - 1
        While i > -1
            mappingIndex = shipsForSaleMapping.FindStruct("ShipRef", akShipList[i])
            If mappingIndex > -1
                uniqueSoldIndex = uniquesSoldListLocal.Find(shipsForSaleMapping[mappingIndex].LeveledShip)
                If uniqueSoldIndex > -1
                    _Log(fnName, "unique ship " + uniquesSoldListLocal[uniqueSoldIndex] + " was already bought - removing it from index " + i)
                    SpaceshipReference shipToDelete = akShipList[i]
                    ; make sure to remove the link to the landing marker, otherwise the ship will still show up until
                    ; the game gets around to actually deleting it
                    shipToDelete.SetLinkedRef(None, SpaceshipStoredLink)
                    _Log(fnName, "deleting ship " + shipToDelete)
                    Debug.Trace(Self + " PurgeAlreadySoldUniques: deleting ship " + shipToDelete + ", ignore following error message")
                    shipToDelete.Delete()
                    uniquesListIndex = akShipListUniques.Find(akShipList[i])
                    If uniquesListIndex > -1
                        _Log(fnName, "ship " + akShipList[i] + " also found at uniques index " + uniquesListIndex, LL_DEBUG)
                        akShipListUniques.Remove(akShipListUniques.Find(akShipList[i]))
                    Else
                        _Log(fnName, "ship " + akShipList[i] + " not found in uniques ships for sale", LL_ERROR)
                    EndIf
                    akShipList.Remove(i)
                EndIf
            EndIf
            i += -1
        EndWhile
    EndIf

    _Log(fnName, "end", LL_DEBUG)
EndFunction


; matches the "always" and "unique" ships-to-sell lists to the ships-for-sale lists and refreshes those lists if needed
Function CheckForNewShips()
    string fnName = "CheckForNewShips" Const
    _Log(fnName, "begin", LL_DEBUG)

    SpaceshipReference[] ShipsForSaleAlwaysCopy = None
    SpaceshipReference[] ShipsForSaleUniqueCopy = None
    LockGuard ShipsForSaleGuard
        ShipsForSaleAlwaysCopy = (shipsForSaleAlways as var[]) as SpaceshipReference[]
        ShipsForSaleUniqueCopy = (shipsForSaleUnique as var[]) as SpaceshipReference[]
    EndLockGuard

    RefreshShipsToSellArrays()
    var[] ShipsToSellAlwaysCopy = None
    var[] ShipsToSellUniqueCopy = None
    If useSVFDatasets == true
        ShipsToSellAlwaysCopy = svfShipsToSellAlways as var[]
        ShipsToSellUniqueCopy = svfShipsToSellUnique as var[]
    Else
        ShipsToSellAlwaysCopy = shipsToSellAlways as var[]
        ShipsToSellUniqueCopy = shipsToSellUnique as var[]
    EndIf

    bool refreshAlways = !ForSaleMatchesToSell(ShipsForSaleAlwaysCopy, ShipsToSellAlwaysCopy, shipsForSaleMappingAlways)
    bool refreshUnique = !ForSaleMatchesToSell(ShipsForSaleUniqueCopy, ShipsToSellUniqueCopy, shipsForSaleMappingUnique)

    If refreshAlways == true || refreshUnique == true
        LockGuard ShipsForSaleGuard
            RefreshInventoryList(myLandingMarker, shipsForSale, shipsForSaleAlways, shipsForSaleRandom, shipsForSaleUnique, shipsForSaleSoldByPlayer)
        EndLockGuard
    EndIf

    _Log(fnName, "end", LL_DEBUG)
EndFunction


; check to see if the spaceship references are in the "for sale" list and that it matches the "to sell" list
bool Function ForSaleMatchesToSell(SpaceshipReference[] akShipsForSaleList, var[] akShipsToSellList, ShipRefToSpaceshipLeveledListMapping[] akMappingList)
    string fnName = "ForSaleMatchesToSell" Const
    _Log(fnName, "begin", LL_DEBUG)

    bool toReturn = true

    SpaceshipReference shipToCheck = None
    int refToShipMappingIndex = 0
    LeveledSpaceshipBase leveledShip = None
    int leveledShipIndex = 0
    int i = akShipsForSaleList.Length - 1
    While i > -1 && toReturn == true
        shipToCheck = akShipsForSaleList[i]
        refToShipMappingIndex = akMappingList.FindStruct("ShipRef", shipToCheck)
        If refToShipMappingIndex > -1
            leveledShip = akMappingList[refToShipMappingIndex].LeveledShip
            If useSVFDatasets == true
                leveledShipIndex = (akShipsToSellList as LeveledSpaceshipBase[]).Find(leveledShip)
            Else
                leveledShipIndex = (akShipsToSellList as ShipVendorListScript:ShipToSell[]).FindStruct("LeveledShip", leveledShip)
            EndIf
            If leveledShipIndex > -1
                akShipsForSaleList.Remove(i)
                akShipsToSellList.Remove(leveledShipIndex)
            Else
                toReturn = false
            EndIf
        EndIf
        i += -1
    EndWhile
    If toReturn == true && (akShipsForSaleList.Length > 0 || akShipsToSellList.Length > 0)
        toReturn = false
    EndIf

    _Log(fnName, "returning " + toReturn, LL_DEBUG)
    _Log(fnName, "end", LL_DEBUG)
    Return toReturn
EndFunction


; returns true if there are unique ships to sell - accounts for new datasets
bool Function UniqueShipsToSell()
    string fnName = "UniqueShipsToSell" Const
    _Log(fnName, "begin", LL_DEBUG)
    bool toReturn
    If useSVFDatasets == true
        toReturn = svfShipsToSellUnique.Length > 0
    Else
        toReturn = shipsToSellUnique.Length > 0
    EndIf
    _Log(fnName, "returning " + toReturn, LL_DEBUG)
    _Log(fnName, "end", LL_DEBUG)
    Return toReturn
EndFunction


; wrapper around the RefreshShipsToSellArraysShipToSell/RefreshShipsToSellArraysLVLB functions to
; account for new datasets
Function RefreshShipsToSellArrays()
    string fnName = "RefreshShipsToSellArrays" Const
    _Log(fnName, "begin", LL_DEBUG)

    If useSVFDatasets == true
        RefreshShipsToSellArraysLVLB()
    Else
        RefreshShipsToSellArraysShipToSell()
    EndIf

    _Log(fnName, "end", LL_DEBUG)
EndFunction


; refresh the ships to sell arrays - new FormList-based datasets
Function RefreshShipsToSellArraysLVLB()
    string fnName = "RefreshShipsToSellArraysLVLB" Const
    _Log(fnName, "begin", LL_DEBUG)

    ; fill arrays using datasets
    If svfShipsToSellListRandomDatasetLocal != None
        _Log(fnName, "random ships dataset found", LL_DEBUG)
        svfShipsToSellRandom = svfShipsToSellListRandomDatasetLocal.GetArray() as LeveledSpaceshipBase[]
        _Log(fnName, "svfShipsToSellRandom=" + svfShipsToSellRandom, LL_DEBUG)
    Else
        svfShipsToSellRandom.Clear()
    EndIf
    If svfShipsToSellListAlwaysDatasetLocal != None
        _Log(fnName, "priority ships dataset found", LL_DEBUG)
        svfShipsToSellAlways = svfShipsToSellListAlwaysDatasetLocal.GetArray() as LeveledSpaceshipBase[]
        _Log(fnName, "svfShipsToSellAlways=" + svfShipsToSellAlways, LL_DEBUG)
    Else
        svfShipsToSellAlways.Clear()
    EndIf
    If svfShipsToSellListUniqueDatasetLocal != None
        _Log(fnName, "unique ships dataset found", LL_DEBUG)
        svfShipsToSellUnique = svfShipsToSellListUniqueDatasetLocal.GetArray() as LeveledSpaceshipBase[]
        _Log(fnName, "svfShipsToSellUnique=" + svfShipsToSellUnique, LL_DEBUG)
    Else
        svfShipsToSellUnique.Clear()
    EndIf

    ; variable to keep track of various list indices
    int i = 0

    ; remove any random ships that are already in the always or unique lists
    i = svfShipsToSellRandom.Length - 1
    ; traverse the array from the end to the beginning so that removing elements doesn't mess up the loop
    While i > -1
        If svfShipsToSellAlways.Find(svfShipsToSellRandom[i]) > -1
            _Log(fnName, "random ship " + svfShipsToSellRandom[i] + " (index " + i + ") is already in the always list - removing it")
            svfShipsToSellRandom.Remove(i)
        EndIf
        If svfShipsToSellUnique.Find(svfShipsToSellRandom[i]) > -1
            _Log(fnName, "random ship " + svfShipsToSellRandom[i] + " (index " + i + ") is already in the unique list - removing it")
            svfShipsToSellRandom.Remove(i)
        EndIf
        i += -1
    EndWhile

    ; remove any priority ships that have already been sold this refresh cycle
    If svfShipsToSellAlways.Length > 0 && alwaysSoldList.Length > 0
        int alwaysIndex = 0
        i = 0
        While i < alwaysSoldList.Length
            alwaysIndex = svfShipsToSellAlways.Find(alwaysSoldList[i])
            If alwaysIndex > -1
                _Log(fnName, "priority ship " + alwaysSoldList[i] + " was already bought - removing it from refreshed priority 'to sell' list")
                svfShipsToSellAlways.Remove(alwaysIndex)
            EndIf
            i += 1
        EndWhile
    EndIf

    ; remove any unique ships that have already been sold
    If svfShipsToSellUnique.Length > 0 && uniquesSoldListLocal.Length > 0
        int uniqueIndex = 0
        i = 0
        While i < uniquesSoldListLocal.Length
            uniqueIndex = svfShipsToSellUnique.Find(uniquesSoldListLocal[i])
            If uniqueIndex > -1
                _Log(fnName, "unique ship " + uniquesSoldListLocal[i] + " was already bought - removing it from refreshed uniques 'to sell' list")
                svfShipsToSellUnique.Remove(uniqueIndex)
            EndIf
            i += 1
        EndWhile
    EndIf

    _Log(fnName, "end", LL_DEBUG)
EndFunction


; refresh the ships to sell arrays - original activator-based datasets
Function RefreshShipsToSellArraysShipToSell()
    string fnName = "RefreshShipsToSellArraysShipToSell" Const
    _Log(fnName, "begin", LL_DEBUG)

    ; fill arrays using datasets using `(... as var[]) as ...[]` to copy the array to get it done faster
    If ShipsToSellListRandomDataset != None
        _Log(fnName, "random ships dataset found", LL_DEBUG)
        shipsToSellRandom = (ShipsToSellListRandomDataset.ShipList as var[]) as ShipVendorListScript:ShipToSell[]
        _Log(fnName, "shipsToSellRandom=" + shipsToSellRandom, LL_DEBUG)
    Else
        shipsToSellRandom.Clear()
    EndIf
    If ShipsToSellListAlwaysDataset != None
        _Log(fnName, "priority ships dataset found", LL_DEBUG)
        shipsToSellAlways = (ShipsToSellListAlwaysDataset.ShipList as var[]) as ShipVendorListScript:ShipToSell[]
        _Log(fnName, "shipsToSellAlways=" + shipsToSellAlways, LL_DEBUG)
    Else
        shipsToSellAlways.Clear()
    EndIf
    If ShipsToSellListUniqueDataset != None
        _Log(fnName, "unique ships dataset found", LL_DEBUG)
        shipsToSellUnique = (ShipsToSellListUniqueDataset.ShipList as var[]) as ShipVendorListScript:ShipToSell[]
        _Log(fnName, "shipsToSellUnique=" + shipsToSellUnique, LL_DEBUG)
    Else
        shipsToSellUnique.Clear()
    EndIf

    int i = 0

    ; remove any random ships that are already in the always or unique lists, or that the player
    ; isn't a high enough level for; traversing the array from the end to the beginning so that
    ; removing elements doesn't mess up the loop
    int playerLevel = playerRef.GetLevel()
    i = shipsToSellRandom.Length - 1
    While i > -1
        If shipsToSellRandom[i].minLevel > playerLevel
            _Log(fnName, "player does not meet level requirements of random ship " + shipsToSellRandom[i] + " (index " + i + ") - removing it")
            shipsToSellRandom.Remove(i)
        EndIf
        If shipsToSellAlways.Length > 0 && shipsToSellAlways.FindStruct("LeveledShip", shipsToSellRandom[i].LeveledShip) > -1
            _Log(fnName, "random ship " + shipsToSellRandom[i] + " (index " + i + ") is already in the always list - removing it")
            shipsToSellRandom.Remove(i)
        EndIf
        If shipsToSellUnique.Length > 0 && shipsToSellUnique.FindStruct("LeveledShip", shipsToSellRandom[i].LeveledShip) > -1
            _Log(fnName, "random ship " + shipsToSellRandom[i] + " (index " + i + ") is already in the unique list - removing it")
            shipsToSellRandom.Remove(i)
        EndIf
        i += -1
    EndWhile

    ; remove any priority ships that have already been sold this refresh cycle
    If shipsToSellAlways.Length > 0 && alwaysSoldList.Length > 0
        int alwaysIndex = 0
        i = 0
        While i < alwaysSoldList.Length
            alwaysIndex = shipsToSellAlways.FindStruct("LeveledShip", alwaysSoldList[i])
            If alwaysIndex > -1
                _Log(fnName, "priority ship " + alwaysSoldList[i] + " was already bought - removing it from refreshed priority 'to sell' list")
                shipsToSellAlways.Remove(alwaysIndex)
            EndIf
            i += 1
        EndWhile
    EndIf

    ; remove any unique ships that have already been sold
    If shipsToSellUnique.Length > 0 && uniquesSoldListLocal.Length > 0
        int uniqueIndex = 0
        i = 0
        While i < uniquesSoldListLocal.Length
            uniqueIndex = shipsToSellUnique.FindStruct("LeveledShip", uniquesSoldListLocal[i])
            If uniqueIndex > -1
                _Log(fnName, "unique ship " + uniquesSoldListLocal[i] + " was already bought - removing it from refreshed uniques 'to sell' list")
                shipsToSellUnique.Remove(uniqueIndex)
            EndIf
            i += 1
        EndWhile
    EndIf

    _Log(fnName, "begin", LL_DEBUG)
EndFunction


Function DeleteShips(SpaceshipReference[] akShipList)
    string fnName = "DeleteShips" Const
    _Log(fnName, "begin", LL_DEBUG)

    int i = akShipList.Length - 1
    While i > -1
        SpaceshipReference theShip = akShipList[i]
        ; unlink the ship from the landing marker
        _Log(fnName, "unlinking " + theShip + " from its landing marker, nullifying ownership, and disabling", LL_DEBUG)
        theShip.SetLinkedRef(None, SpaceshipStoredLink)
        theShip.SetActorRefOwner(None)
        theShip.DisableNoWait()
        ; attempting to use Delete() on a ship reference throws an error in the papyrus log stating that spaceships
        ; cannot be deleted and the reference will be disabled instead. in the probably unfounded hope that this will
        ; eventually be fixed, make a note before the error is thrown.
        _Log(fnName, "attempting to delete " + theShip, LL_DEBUG)
        Debug.Trace(Self + ".DeleteShips(): Attempting to delete " + theShip + ". This may throw an error, please ignore it.")
        theShip.Delete()
        i += -1
    EndWhile
    akShipList.Clear()

    _Log(fnName, "end", LL_DEBUG)
EndFunction


; refresh the inventory list
;
; arguments:
; - akCreateMarker: the marker to create the ships at
; - akShipList: the main list of ships
; - akShipListAlways: the list of priority ships
; - akShipListRandom: the list of random ships
; - akShipListUnique: the list of unique ships
;
; returns: None
Function RefreshInventoryList(ObjectReference akCreateMarker, SpaceshipReference[] akShipList, SpaceshipReference[] akShipListAlways, SpaceshipReference[] akShipListRandom, SpaceshipReference[] akShipListUnique, SpaceshipReference[] akShipListSoldByPlayer)
    string fnName = "RefreshInventoryList" Const
    _Log(fnName, "begin", LL_DEBUG)

    If LogLevel == LL_DEBUG
        _Log(fnName, "starting stack profiling", LL_DEBUG)
        Debug.StartStackProfiling()
    EndIf

    _Log(fnName, "akCreateMarker=" + akCreateMarker + " akShipList=" + akShipList, LL_DEBUG)

    If akCreateMarker
        var[] vShipsToSellAlways = None
        var[] vShipsToSellRandom = None
        var[] vShipsToSellUnique = None
        If useSVFDatasets == true
            vShipsToSellAlways = svfShipsToSellAlways as var[]
            vShipsToSellRandom = svfShipsToSellRandom as var[]
            vShipsToSellUnique = svfShipsToSellUnique as var[]
        Else
            vShipsToSellAlways = shipsToSellAlways as var[]
            vShipsToSellRandom = shipsToSellRandom as var[]
            vShipsToSellUnique = shipsToSellUnique as var[]
        EndIf

        ; clear the existing ships
        akShipList.Clear()
        ; also clear the ship ref to leveled ship mapping list
        shipsForSaleMapping.Clear()

        ; check whether to create new ship at the current ship rather than the landing marker to avoid issues with
        ; creating a ship inside a ship
        SpaceshipReference landingMarkerShipRef = akCreateMarker.GetCurrentShipRef()
        If landingMarkerShipRef
            akCreateMarker = landingMarkerShipRef
        _Log(fnName, "landing marker is in a ship, so new ships will be created at ship ref " + landingMarkerShipRef)
        EndIf

        ; get the encounter location
        Location encounterLocation = ShipVendorLocation
        If encounterLocation == None
            encounterLocation = GetCurrentLocation()
        EndIf

        ; refresh priority ships
        _Log(fnName, "clearing priority ships and ship ref to leveled ship mapping list")
        DeleteShips(akShipListAlways)
        shipsForSaleMappingAlways.Clear()
        _Log(fnName, "attempting to create " + vShipsToSellAlways.Length + " priority ships")
        CreateShipsForSale(vShipsToSellAlways, akCreateMarker, encounterLocation, akShipListAlways, shipsForSaleMappingAlways)

        ; refresh random ships
        _Log(fnName, "clearing random ships and ship ref to leveled ship mapping list")
        DeleteShips(akShipListRandom)
        shipsForSaleMappingRandom.Clear()
        int randomShipsToCreateCount = ShipVendorFramework:SVF_Utility.MinInt(vShipsToSellRandom.Length, Utility.RandomInt(ShipsForSaleMin, ShipsForSaleMax))
        _Log(fnName, "attempting to create " + randomShipsToCreateCount + " random ships (min=" + ShipsForSaleMin + ", max=" + ShipsForSaleMax + ", possible=" + vShipsToSellRandom.Length + ")")
        CreateShipsForSale(vShipsToSellRandom, akCreateMarker, encounterLocation, akShipListRandom, shipsForSaleMappingRandom, randomShipsToCreateCount, true)

        ; refresh unique ships
        _Log(fnName, "clearing unique ships and ship ref to leveled ship mapping list")
        DeleteShips(akShipListUnique)
        shipsForSaleMappingUnique.Clear()
        _Log(fnName, "attempting to create " + vShipsToSellUnique.Length + " unique ships")
        CreateShipsForSale(vShipsToSellUnique, akCreateMarker, encounterLocation, akShipListUnique, shipsForSaleMappingUnique)

        ; clear out the list of ships sold to the vendor by the player
        _Log(fnName, "clearing ships sold by player to vendor")
        DeleteShips(akShipListSoldByPlayer)

        ; combine ship lists
        ; create a temporary array because when using `as var[]` on an empty array (which `akShipList` would be at this
        ; point), it returns None, which causes an error when when attempting to pass it to `AppendToArray`
        SpaceshipReference[] shipListTemp
        _Log(fnName, "combining ship lists")
        _Log(fnName, "akShipList=" + akShipList, LL_DEBUG)
        _Log(fnName, "akShipListAlways=" + akShipListAlways, LL_DEBUG)
        _Log(fnName, "akShipListRandom=" + akShipListRandom, LL_DEBUG)
        _Log(fnName, "akShipListUnique=" + akShipListUnique, LL_DEBUG)
        _Log(fnName, "akShipListSoldByPlayer=" + akShipListSoldByPlayer, LL_DEBUG)
        shipListTemp = ShipVendorFramework:SVF_Utility.AppendToArray(shipListTemp as var[], akShipListAlways as var[]) as SpaceshipReference[]
        shipListTemp = ShipVendorFramework:SVF_Utility.AppendToArray(shipListTemp as var[], akShipListRandom as var[]) as SpaceshipReference[]
        shipListTemp = ShipVendorFramework:SVF_Utility.AppendToArray(shipListTemp as var[], akShipListUnique as var[]) as SpaceshipReference[]
        shipListTemp = ShipVendorFramework:SVF_Utility.AppendToArray(shipListTemp as var[], akShipListSoldByPlayer as var[]) as SpaceshipReference[]
        int i = 0
        While i < shipListTemp.Length
            akShipList.Add(shipListTemp[i])
            i += 1
        EndWhile

        ; combine ship ref to leveled ship mappings
        ; create a temporary array because when using `as var[]` on an empty array (which `shipsForSaleMapping` would be
        ; at this point), it returns None, which causes an error when attempting to pass it to `AppendToArray`
        ShipRefToSpaceshipLeveledListMapping[] ShipsForSaleMappingTemp
        _Log(fnName, "combining ship ref to leveled ship mappings")
        _Log(fnName, "shipsForSaleMapping=" + shipsForSaleMapping, LL_DEBUG)
        _Log(fnName, "shipsForSaleMappingAlways=" + shipsForSaleMappingAlways, LL_DEBUG)
        _Log(fnName, "shipsForSaleMappingRandom=" + shipsForSaleMappingRandom, LL_DEBUG)
        _Log(fnName, "shipsForSaleMappingUnique=" + shipsForSaleMappingUnique, LL_DEBUG)
        shipsForSaleMapping = ShipVendorFramework:SVF_Utility.AppendToArray(shipsForSaleMapping as var[], shipsForSaleMappingAlways as var[]) as ShipRefToSpaceshipLeveledListMapping[]
        shipsForSaleMapping = ShipVendorFramework:SVF_Utility.AppendToArray(shipsForSaleMapping as var[], shipsForSaleMappingRandom as var[]) as ShipRefToSpaceshipLeveledListMapping[]
        shipsForSaleMapping = ShipVendorFramework:SVF_Utility.AppendToArray(shipsForSaleMapping as var[], shipsForSaleMappingUnique as var[]) as ShipRefToSpaceshipLeveledListMapping[]
        i = 0
        While i < ShipsForSaleMappingTemp.Length
            shipsForSaleMapping.Add(ShipsForSaleMappingTemp[i])
            i += 1
        EndWhile

        ; update the timestamp
        lastInventoryRefreshTimestamp = Utility.GetCurrentGameTime()
    EndIf

    _Log(fnName, "DONE. akShipList=" + akShipList)

    If LogLevel == LL_DEBUG
        _Log(fnName, "Leveled Base Ships in akShipList:", LL_DEBUG)

        _Log(fnName, "    Priority Ships:", LL_DEBUG)
        int i = 0
        While i < akShipListAlways.Length
            _Log(fnName, "        " + Utility.IntToHex(akShipListAlways[i].GetFormID()) + ": " + akShipListAlways[i].GetBaseObject())
            i += 1
        EndWhile

        _Log(fnName, "    Random Ships:", LL_DEBUG)
        i = 0
        While i < akShipListRandom.Length
            _Log(fnName, "        " + Utility.IntToHex(akShipListRandom[i].GetFormID()) + ": " + akShipListRandom[i].GetBaseObject())
            i += 1
        EndWhile

        _Log(fnName, "    Unique Ships:", LL_DEBUG)
        i = 0
        While i < akShipListUnique.Length
            _Log(fnName, "        " + Utility.IntToHex(akShipListUnique[i].GetFormID()) + ": " + akShipListUnique[i].GetBaseObject())
            i += 1
        EndWhile

        _Log(fnName, "    Player-sold Ships:", LL_DEBUG)
        i = 0
        While i < akShipListSoldByPlayer.Length
            _Log(fnName, "        " + Utility.IntToHex(akShipListSoldByPlayer[i].GetFormID()) + ": " + akShipListSoldByPlayer[i].GetBaseObject())
            i += 1
        EndWhile
    EndIf

    If LogLevel == LL_DEBUG
        Debug.StopStackProfiling()
        _Log(fnName, "stopped stack profiling", LL_DEBUG)
    EndIf


    _Log(fnName, "end", LL_DEBUG)
EndFunction


; create ships for sale
Function CreateShipsForSale(var[] akShipToSellList, ObjectReference akCreateMarker, Location akEncLoc, SpaceshipReference[] akShipList, ShipRefToSpaceshipLeveledListMapping[] akRefToLLMap, int aiShipsToCreate = -1, bool abRandomize = false)
    string fnName = "CreateShipsForSale" Const
    _Log(fnName, "begin", LL_DEBUG)

    ; early exit if there's no ships to create
    If aiShipsToCreate == 0
        _Log(fnName, "no ships to create")
        Return
    EndIf

    ; if the number of ships to create is outside the bounds of the list, set it to the list length
    If aiShipsToCreate < 0 || aiShipsToCreate > akShipToSellList.Length
        aiShipsToCreate = akShipToSellList.Length
    EndIf

    ; randomize the list if requested
    If abRandomize == true
        _Log(fnName, "randomizing ship list")
        akShipToSellList = ShipVendorFramework:SVF_Utility.ShuffleArray(akShipToSellList, aiShipsToCreate)
    EndIf

    ; create the ships
    _Log(fnName, "attempting to create " + aiShipsToCreate + " ships (out of " + akShipToSellList.Length + " possible) at " + akCreateMarker + " (landing marker " + myLandingMarker + ")")
    int i = 0
    If useSVFDatasets == true
        While i < aiShipsToCreate
            CreateShipForSale(akShipToSellList[i] as LeveledSpaceshipBase, akCreateMarker, akEncLoc, akShipList, akRefToLLMap)
            i += 1
        EndWhile
    Else
        While i < aiShipsToCreate
            CreateShipForSale((akShipToSellList[i] as ShipVendorListScript:ShipToSell).LeveledShip, akCreateMarker, akEncLoc, akShipList, akRefToLLMap)
            i += 1
        EndWhile
    EndIf
    _Log(fnName, "created " + akShipList.Length + " ships")
    _Log(fnName, "ship list=" + akShipList, LL_DEBUG)

    _Log(fnName, "end", LL_DEBUG)
EndFunction


; create a ship for sale
Function CreateShipForSale(LeveledSpaceshipBase akShipToCreate, ObjectReference akCreateMarker, Location akEncLoc, SpaceshipReference[] akShipList, ShipRefToSpaceshipLeveledListMapping[] akRefToLLMap)
    string fnName = "CreateShipForSale" Const
    _Log(fnName, "begin", LL_DEBUG)

    _Log(fnName, "attempting to create new ship reference from leveled ship " + akShipToCreate)
    SpaceshipReference newShip = akCreateMarker.PlaceShipAtMe(akShipToCreate, aiLevelMod = 2, abInitiallyDisabled = true, akEncLoc = akEncLoc)
    _Log(fnName, "new ship: " + newShip, LL_DEBUG)
    If newShip != None && newShip.IsBoundGameObjectAvailable()
        akShipList.Add(newShip)
        ; link to landing pad
        newShip.SetLinkedRef(myLandingMarker, SpaceshipStoredLink)
        ; assign vendor ownership
        newShip.SetActorRefOwner(Self)
        ; register for player buying event
        RegisterForRemoteEvent(newShip, "OnShipBought")
        ; clear inventory
        newShip.RemoveAllItems()
        ; create mapping for ship ref to leveled ship and add it to the list
        ShipRefToSpaceshipLeveledListMapping shipRefMap = new ShipRefToSpaceshipLeveledListMapping
        shipRefMap.ShipRef = newShip
        shipRefMap.LeveledShip = akShipToCreate
        akRefToLLMap.Add(shipRefMap)

        _Log(fnName, "created ship " + newShip + " from leveled ship " + akShipToCreate)
    Else
        _Log(fnName, "no ship created")
    EndIf

    _Log(fnName, "end", LL_DEBUG)
EndFunction


SpaceshipReference Function GetShipForSale(int aiIndex = 0)
    string fnName = "GetShipForSale" Const
    _Log(fnName, "begin", LL_DEBUG)

    SpaceshipReference shipForSale = None
    LockGuard ShipsForSaleGuard
        If shipsForSale.Length > 0
            If aiIndex > -1 && aiIndex < shipsForSale.Length
                shipForSale = shipsForSale[aiIndex]
            ElseIf aiIndex >= shipsForSale.Length
                shipForSale = shipsForSale[shipsForSale.Length-1]
            Else
                shipForSale = shipsForSale[0]
            EndIf
        EndIf
    EndLockGuard
    If LogLevel == LL_DEBUG && shipForSale != None
        _Log(fnName, "returning " + shipForSale + " (" + shipForSale.GetBaseObject() + ") for aiIndex " + aiIndex, LL_DEBUG)
    EndIf

    _Log(fnName, "end", LL_DEBUG)
    Return shipForSale
EndFunction


Function TestShowHangarMenu()
    myLandingMarker.ShowHangarMenu(0, Self, None)
EndFunction


Function TestOutputShipsForSale()
    LockGuard ShipsForSaleGuard
        int i = 0
        While i < shipsForSale.Length
            SpaceshipReference theShip = shipsForSale[i]
            Debug.Trace(Self + " i=" + i + ": " + theShip)
            i += 1
        EndWhile
    EndLockGuard
EndFunction
