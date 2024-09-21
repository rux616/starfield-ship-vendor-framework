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

ShipVendorListScript Property ShipsToSellListAlwaysDataset Auto Const
{ DEPRECATED - Use SVFShipsToSellListAlwaysDataset instead.
    Remember to set SVFUseNewDatasets to true. }

ShipVendorListScript Property ShipsToSellListRandomDataset Auto Const
{ DEPRECATED - Use SVFShipsToSellListRandomDataset instead.
    Remember to set SVFUseNewDatasets to true. }

ShipVendorListScript Property ShipsToSellListUniqueDataset Auto Const
{ DEPRECATED - Use SVFShipsToSellListUniqueDataset instead.
    Remember to set SVFUseNewDatasets to true. }

int Property ShipsForSaleMin = 4 Auto Const
{ The minimum number of random ships that can be chosen to be put on sale at any given time.
    NOTE - this does not include ships that are always for sale or unique ships.
    NOTE - this number is not guaranteed to be met if the player does not qualify for enough ships. }

int Property ShipsForSaleMax = 8 Auto Const
{ The maximum number of random ships that can be for sale at any given time. }

ObjectReference Property myLandingMarker Auto Hidden
{ landing marker, set by OnInit }

RefCollectionAlias Property PlayerShips Auto Const Mandatory
{ from SQ_PlayerShip - need to know when player sells ships }

float Property DaysUntilInventoryRefresh = 7.0 Auto Const
{ how many days until next inventory refresh? }

bool Property BuysShips = true Auto Conditional Const
bool Property SellsShips = true Auto Conditional Const

bool Property InitializeOnLoad = true Auto Const
{ if false, Initialize() needs to be called manually (e.g. for outpost ship vendor) }

ShipVendorListScript:ShipToSell[] ShipsToSellRandom
ShipVendorListScript:ShipToSell[] ShipsToSellAlways
ShipVendorListScript:ShipToSell[] ShipsToSellUnique
float lastInventoryRefreshTimestamp ; timestamp when last refresh happened

SpaceshipReference[] shipsForSale RequiresGuard(shipsForSaleGuard)
Guard shipsForSaleGuard

bool initialized = false


; additional variables and properties to support Ship Vendor Framework enhancements

FormList Property SVFShipsToSellListRandomDataset Auto Const
{ The list of random ships to sell.
    Remember to set SVFUseNewDatasets to true. }
FormList Property SVFShipsToSellListAlwaysDataset Auto Const
{ The list of ships that should always be available for sale.
    Remember to set SVFUseNewDatasets to true. }
FormList Property SVFShipsToSellListUniqueDataset Auto Const
{ The list of unique ships to make available for sale. (Never respawns.)
    Remember to set SVFUseNewDatasets to true. }

; local cache of the new FormList-based datasets
LeveledSpaceshipBase[] SVFShipsToSellRandom
LeveledSpaceshipBase[] SVFShipsToSellAlways
LeveledSpaceshipBase[] SVFShipsToSellUnique

; track the actual ships available to sell in the various established categories: random, always, unique, and
; player-sold
SpaceshipReference[] ShipsForSaleRandom RequiresGuard(shipsForSaleGuard)
SpaceshipReference[] ShipsForSaleAlways RequiresGuard(shipsForSaleGuard)
SpaceshipReference[] ShipsForSaleUnique RequiresGuard(shipsForSaleGuard)
SpaceshipReference[] ShipsForSaleSoldByPlayer RequiresGuard(shipsForSaleGuard)

bool Property SVFUseNewDatasets = false Auto Const
{ Mark vendor as using the new Ship Vendor Framework datasets. }
; this serves as an informal guard against the vendor record being overwritten by a non-SVF version
; if this flag is false, the newer SVFShipsToSellList* properties will be ignored and the original
; ShipsToSellList* properties will be used instead, albeit with some enhancements still active

FormList Property SVFExternalUniquesSoldList Auto Const
{ OPTIONAL - can be used to coordinate a list of unique ships that have been already sold between chosen vendors.
    If not filled in, the vendor will use their own local list.}
; local 'sold' lists
LeveledSpaceshipBase[] UniquesSoldListLocal
LeveledSpaceshipBase[] AlwaysSoldList

; struct to hold the mapping of a ship reference to its originating leveled list
Struct ShipRefToSpaceshipLeveledListMapping
    SpaceshipReference shipRef
    LeveledSpaceshipBase leveledShip
EndStruct
; variables to hold the ship ref to leveled list mappings to support unique ship tracking
ShipRefToSpaceshipLeveledListMapping[] ShipsForSaleMapping
ShipRefToSpaceshipLeveledListMapping[] ShipsForSaleMappingRandom
ShipRefToSpaceshipLeveledListMapping[] ShipsForSaleMappingAlways
ShipRefToSpaceshipLeveledListMapping[] ShipsForSaleMappingUnique

int Property SVFEnhancementsVersion = 2 Auto Const Hidden
{ The desired version of the Ship Vendor Framework enhancements. }

; The current version of the Ship Vendor Framework enhancements active on the vendor.
int SVFEnhancementsVersionCurrent = 0

; The player reference.
Actor PlayerRef

; guard (and dummy int) to protect against multiple initialization calls
int DummyInt RequiresGuard(LoadGuard)
guard LoadGuard

int Property LogLevel = 2 Auto Const
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
    UnregisterForRemoteEvent(PlayerRef, "OnPlayerLoadGame")

    _Log(fnName, "end", LL_DEBUG)
EndEvent


; using OnActivate is a workaround for the fact that if the player loads a save where the vendor is already loaded,
; the OnLoad event for the vendor doesn't fire again
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
        UnregisterForRemoteEvent(PlayerRef, "OnPlayerLoadGame")
        Return
    EndIf

    LockGuard LoadGuard
        HandleOnLoad()
    EndLockGuard

    _Log(fnName, "end", LL_DEBUG)
EndEvent


Function HandleOnLoad() RequiresGuard(LoadGuard)
    string fnName = "HandleOnLoad" Const
    _Log(fnName, "begin", LL_DEBUG)

    ; needed to satisfy the guard
    DummyInt = 0

    If LogLevel == LL_DEBUG
        _Log(fnName, "starting stack profiling", LL_DEBUG)
        Debug.StartStackProfiling()
        DebugDumpData()
    EndIf

    ; initialize Ship Vendor Framework enhancements if not already done
    ; needed here instead of in Initialize() for backwards compatibility
    InitializeSVFEnhancements()
    ; sync the uniques sold list with the external list if provided
    SyncUniquesSoldList()
    ; register for ship sell events
    RegisterForRemoteEvent(PlayerShips, "OnShipSold")
    If initialized == false
        If InitializeOnLoad
            myLandingMarker = GetLinkedRef(LinkShipLandingMarker01)
            Initialize(myLandingMarker)
        EndIf
    Else
        CheckForInventoryRefresh()
    EndIf

    If LogLevel == LL_DEBUG
        DebugDumpData()
        Debug.StopStackProfiling()
        _Log(fnName, "stopped stack profiling", LL_DEBUG)
    EndIf

    _Log(fnName, "end", LL_DEBUG)
EndFunction


; check if the Ship Vendor Framework enhancements have been initialized
bool Function SVFEnhancementsInitialized()
    string fnName = "SVFEnhancementsInitialized" Const
    _Log(fnName, "begin", LL_DEBUG)

    bool toReturn = SVFEnhancementsVersionCurrent == SVFEnhancementsVersion
    _Log(fnName, "returning " + toReturn, LL_DEBUG)

    _Log(fnName, "end", LL_DEBUG)
    Return toReturn
EndFunction


; initialize the Ship Vendor Framework enhancements
Function InitializeSVFEnhancements()
    string fnName = "InitializeSVFEnhancements" Const
    _Log(fnName, "begin", LL_DEBUG)

    _Log(fnName, "Log level: " + LogLevel)
    _Log(fnName, "SVF Enhancements version: current=" + SVFEnhancementsVersionCurrent + ", desired=" + SVFEnhancementsVersion)
    _Log(fnName, "Using new datasets: " + SVFUseNewDatasets)

    If SVFEnhancementsVersionCurrent < SVFEnhancementsVersion
        ; initial setup
        If SVFEnhancementsVersionCurrent < 1
            SVFEnhancementsVersion1()
        EndIf

        ; version 1 to 2 update tasks
        If SVFEnhancementsVersionCurrent < 2
            SVFEnhancementsVersion2()
        EndIf
    EndIf

    ; register for load game events - automatically unregistered when the vendor is unloaded
    _Log(fnName, "registering for player load game events", LL_DEBUG)
    RegisterForRemoteEvent(PlayerRef, "OnPlayerLoadGame")

    _Log(fnName, "end", LL_DEBUG)
EndFunction


Function SVFEnhancementsVersion1()
    string fnName = "SVFEnhancementsVersion1" Const
    _Log(fnName, "begin", LL_DEBUG)

    _Log(fnName, "Ship Vendor Framework enhancements initializing to version 1")

    ; variable initialization
    SVFShipsToSellRandom = new LeveledSpaceshipBase[0]
    SVFShipsToSellAlways = new LeveledSpaceshipBase[0]
    SVFShipsToSellUnique = new LeveledSpaceshipBase[0]
    ShipsForSaleMapping = new ShipRefToSpaceshipLeveledListMapping[0]
    ShipsForSaleMappingRandom = new ShipRefToSpaceshipLeveledListMapping[0]
    ShipsForSaleMappingAlways = new ShipRefToSpaceshipLeveledListMapping[0]
    ShipsForSaleMappingUnique = new ShipRefToSpaceshipLeveledListMapping[0]
    UniquesSoldListLocal = new LeveledSpaceshipBase[0]
    LockGuard shipsForSaleGuard
        ShipsForSaleRandom = new SpaceshipReference[0]
        ShipsForSaleAlways = new SpaceshipReference[0]
        ShipsForSaleUnique = new SpaceshipReference[0]
        ShipsForSaleSoldByPlayer = new SpaceshipReference[0]
    EndLockGuard
    PlayerRef = Game.GetPlayer()

    ; if the vendor itself is already initialized, force refresh the inventory
    If initialized == true
        _Log(fnName, "vendor already initialized, deleting existing ships and resetting timestamp to trigger inventory refresh")
        ; manually delete the ship references first
        LockGuard shipsForSaleGuard
            DeleteShips(shipsForSale)
        EndLockGuard
        ; reset timestamp so that the inventory refresh happens immediately
        lastInventoryRefreshTimestamp = 0.0
    EndIf

    SVFEnhancementsVersionCurrent = 1
    _Log(fnName, "Ship Vendor Framework enhancements initialized to version 1")

    _Log(fnName, "end", LL_DEBUG)
EndFunction


Function SVFEnhancementsVersion2()
    string fnName = "SVFEnhancementsVersion2" Const
    _Log(fnName, "begin", LL_DEBUG)

    _Log(fnName, "Ship Vendor Framework enhancements updating to version 2")
    int i = 0

    ; variable initialization
    AlwaysSoldList = new LeveledSpaceshipBase[0]

    ; purge ShipsForSale* lists of ship references that are None
    _Log(fnName, "purging ShipsForSale* lists of ship references that are None")
    LockGuard shipsForSaleGuard
        _Log(fnName, "purging ShipsForSale of None ships", LL_DEBUG)
        i = ShipsForSale.Length - 1
        While i > -1
            If ShipsForSale[i].IsBoundGameObjectAvailable() == false
                _Log(fnName, "removing None ship at position " + i + " from main list", LL_DEBUG)
                ShipsForSale.Remove(i)
            EndIf
            i += -1
        EndWhile
        _Log(fnName, "purging ShipsForSaleRandom of None ships", LL_DEBUG)
        i = ShipsForSaleRandom.Length - 1
        While i > -1
            If ShipsForSaleRandom[i].IsBoundGameObjectAvailable() == false
                _Log(fnName, "removing None ship at position " + i + " from random list", LL_DEBUG)
                ShipsForSaleRandom.Remove(i)
            EndIf
            i += -1
        EndWhile
        _Log(fnName, "purging ShipsForSaleAlways of None ships", LL_DEBUG)
        i = ShipsForSaleAlways.Length - 1
        While i > -1
            If ShipsForSaleAlways[i].IsBoundGameObjectAvailable() == false
                _Log(fnName, "removing None ship at position " + i + " from priority list", LL_DEBUG)
                ShipsForSaleAlways.Remove(i)
            EndIf
            i += -1
        EndWhile
        _Log(fnName, "purging ShipsForSaleUnique of None ships", LL_DEBUG)
        i = ShipsForSaleUnique.Length - 1
        While i > -1
            If ShipsForSaleUnique[i].IsBoundGameObjectAvailable() == false
                _Log(fnName, "removing None ship at position " + i + " from unique list", LL_DEBUG)
                ShipsForSaleUnique.Remove(i)
            EndIf
            i += -1
        EndWhile
        _Log(fnName, "purging ShipsForSaleSoldByPlayer of None ships", LL_DEBUG)
        i = ShipsForSaleSoldByPlayer.Length - 1
        While i > -1
            If ShipsForSaleSoldByPlayer[i].IsBoundGameObjectAvailable() == false
                _Log(fnName, "removing None ship at position " + i + " from player sold list", LL_DEBUG)
                ShipsForSaleSoldByPlayer.Remove(i)
            EndIf
            i += -1
        EndWhile
    EndLockGuard

    ; purge ship to leveled base ship maps of mappings that have ship references that are None
    _Log(fnName, "purging ship to leveled base ship maps of mappings that have ship references that are None")
    _Log(fnName, "purging ShipsForSaleMapping of None ships", LL_DEBUG)
    i = ShipsForSaleMapping.Length - 1
    While i > -1
        If ShipsForSaleMapping[i].shipRef.IsBoundGameObjectAvailable() == false
            _Log(fnName, "removing None ship at position " + i + " from mapping list", LL_DEBUG)
            ShipsForSaleMapping.Remove(i)
        EndIf
        i += -1
    EndWhile
    _Log(fnName, "purging ShipsForSaleMappingRandom of None ships", LL_DEBUG)
    i = ShipsForSaleMappingRandom.Length - 1
    While i > -1
        If ShipsForSaleMappingRandom[i].shipRef.IsBoundGameObjectAvailable() == false
            _Log(fnName, "removing None ship at position " + i + " from mapping list", LL_DEBUG)
            ShipsForSaleMappingRandom.Remove(i)
        EndIf
        i += -1
    EndWhile
    _Log(fnName, "purging ShipsForSaleMappingAlways of None ships", LL_DEBUG)
    i = ShipsForSaleMappingAlways.Length - 1
    While i > -1
        If ShipsForSaleMappingAlways[i].shipRef.IsBoundGameObjectAvailable() == false
            _Log(fnName, "removing None ship at position " + i + " from mapping list", LL_DEBUG)
            ShipsForSaleMappingAlways.Remove(i)
        EndIf
        i += -1
    EndWhile
    _Log(fnName, "purging ShipsForSaleMappingUnique of None ships", LL_DEBUG)
    i = ShipsForSaleMappingUnique.Length - 1
    While i > -1
        If ShipsForSaleMappingUnique[i].shipRef.IsBoundGameObjectAvailable() == false
            _Log(fnName, "removing None ship at position " + i + " from mapping list", LL_DEBUG)
            ShipsForSaleMappingUnique.Remove(i)
        EndIf
        i += -1
    EndWhile

    ; iterate through the linked ships and if the ship belongs to the vendor but isn't in the mappings and wasn't sold
    ; by the player, add it to the list of ships to purge
    If myLandingMarker != None
        _Log(fnName, "purging linked ships that are owned by the vendor but don't have mappings and weren't sold by the player")
        SpaceshipReference[] linkedShips = myLandingMarker.GetRefsLinkedToMe(SpaceshipStoredLink) as SpaceshipReference[]
        SpaceshipReference[] shipsToPurge = new SpaceshipReference[0]

        LockGuard shipsForSaleGuard
            Actor owner
            int mapping
            int playerSoldShip
            i = 0
            While i < linkedShips.Length
                owner = linkedShips[i].GetActorRefOwner()
                mapping = ShipsForSaleMapping.FindStruct("shipRef", linkedShips[i])
                playerSoldShip = ShipsForSaleSoldByPlayer.Find(linkedShips[i])
                _Log(fnName, "checks: ship=" + linkedShips[i] + ", owner=" + owner + ", ShipsForSaleMapping=" + mapping + ", ShipsForSaleSoldByPlayer=" + playerSoldShip, LL_DEBUG)
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

    SVFEnhancementsVersionCurrent = 2
    _Log(fnName, "Ship Vendor Framework enhancements updated to version 2")

    _Log(fnName, "end", LL_DEBUG)
EndFunction


Function Initialize(ObjectReference landingMarkerRef)
    string fnName = "Initialize" Const
    _Log(fnName, "begin (" + landingMarkerRef + ")", LL_DEBUG)

    If initialized == false
        ; Initialize arrays.
        ShipsToSellRandom = new ShipVendorListScript:ShipToSell[0]
        ShipsToSellAlways = new ShipVendorListScript:ShipToSell[0]
        ShipsToSellUnique = new ShipVendorListScript:ShipToSell[0]

        LockGuard shipsForSaleGuard
            myLandingMarker = landingMarkerRef
            _Log(fnName, "setting myLandingMarker=" + myLandingMarker)
            shipsForSale = new SpaceshipReference[0]
            initialized = true
        EndLockGuard
        CheckForInventoryRefresh()
    EndIf

    _Log(fnName, "end (" + landingMarkerRef + ")", LL_DEBUG)
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
    If LogLevel == LL_DEBUG && SVFEnhancementsVersionCurrent > 0
        _Log(fnName, "dumping current arrays", LL_DEBUG)
        _Log(fnName, "SVFShipsToSellRandom=" + SVFShipsToSellRandom, LL_DEBUG)
        _Log(fnName, "SVFShipsToSellAlways=" + SVFShipsToSellAlways, LL_DEBUG)
        _Log(fnName, "SVFShipsToSellUnique=" + SVFShipsToSellUnique, LL_DEBUG)
        _Log(fnName, "ShipsForSaleMapping=" + ShipsForSaleMapping, LL_DEBUG)
        _Log(fnName, "ShipsForSaleMappingRandom=" + ShipsForSaleMappingRandom, LL_DEBUG)
        _Log(fnName, "ShipsForSaleMappingAlways=" + ShipsForSaleMappingAlways, LL_DEBUG)
        _Log(fnName, "ShipsForSaleMappingUnique=" + ShipsForSaleMappingUnique, LL_DEBUG)
        _Log(fnName, "AlwaysSoldList=" + AlwaysSoldList, LL_DEBUG)
        _Log(fnName, "UniquesSoldListLocal=" + UniquesSoldListLocal, LL_DEBUG)
        LockGuard shipsForSaleGuard
            _Log(fnName, "shipsForSale=" + shipsForSale, LL_DEBUG)
            _Log(fnName, "ShipsForSaleRandom=" + ShipsForSaleRandom, LL_DEBUG)
            _Log(fnName, "ShipsForSaleAlways=" + ShipsForSaleAlways, LL_DEBUG)
            _Log(fnName, "ShipsForSaleUnique=" + ShipsForSaleUnique, LL_DEBUG)
            _Log(fnName, "ShipsForSaleSoldByPlayer=" + ShipsForSaleSoldByPlayer, LL_DEBUG)
        EndLockGuard
    EndIf

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
        While i < UniquesSoldListLocal.Length && externalUniquesSold.Length > 0
            externalUniquesSoldIndex = externalUniquesSold.Find(UniquesSoldListLocal[i])
            If externalUniquesSoldIndex < 0
                SVFExternalUniquesSoldList.AddForm(UniquesSoldListLocal[i])
                addedToExternalList = true
            EndIf
            i += 1
        EndWhile
        If addedToExternalList
            _Log(fnName, "added unique ships to external list")
            UniquesSoldListLocal = SVFExternalUniquesSoldList.GetArray() as LeveledSpaceshipBase[]
        Else
            _Log(fnName, "external list is up to date")
            UniquesSoldListLocal = externalUniquesSold
        EndIf
        _Log(fnName, "external list contents are now: " + UniquesSoldListLocal, LL_DEBUG)
    EndIf

    _Log(fnName, "end", LL_DEBUG)
EndFunction


Function TestLinkedRefChildren(ObjectReference refToCheck, Keyword theKeyword)
    debug.trace(self + " GetRefsLinkedToMe=" + refToCheck.GetRefsLinkedToMe(theKeyword))
EndFunction


Event RefCollectionAlias.OnShipSold(RefCollectionAlias akSender, ObjectReference akSenderRef)
    string fnName = "RefCollectionAlias.OnShipSold" Const
    _Log(fnName, "begin", LL_DEBUG)

    _Log(fnName, "akSender=" + akSender + ", akSenderRef=" + akSenderRef, LL_DEBUG)

    ; if this ship is linked to this landing marker, add it to vendor's list
    SpaceshipReference soldShip = akSenderRef as SpaceshipReference
    If soldShip && soldShip.GetLinkedRef(SpaceshipStoredLink) == myLandingMarker
        LockGuard shipsForSaleGuard
            shipsForSale.Add(soldShip)
            ShipsForSaleSoldByPlayer.Add(soldShip)
        EndLockGuard
    EndIf

    _Log(fnName, "end", LL_DEBUG)
EndEvent


Event SpaceshipReference.OnShipBought(SpaceshipReference akSenderRef)
    string fnName = "SpaceshipReference.OnShipBought" Const
    _Log(fnName, "begin", LL_DEBUG)

    _Log(fnName, "akSenderRef=" + akSenderRef, LL_DEBUG)
    LockGuard shipsForSaleGuard
        LeveledSpaceshipBase clearedLeveledShip = None

        ; clear the ship reference from the vendor's lists
        ClearShipReference(akSenderRef, shipsForSale, ShipsForSaleMapping)
        clearedLeveledShip = ClearShipReference(akSenderRef, shipsForSaleRandom, ShipsForSaleMappingRandom)

        If clearedLeveledShip == None
            ; ships in the "always" list are added to a local list of sold ships that resets when the vendor does
            clearedLeveledShip = ClearShipReference(akSenderRef, shipsForSaleAlways, ShipsForSaleMappingAlways)
            If clearedLeveledShip != None
                _Log(fnName, "'always' ship was bought, adding " + clearedLeveledShip + " to 'always' sold list")
                AlwaysSoldList.Add(clearedLeveledShip)
            EndIf
        EndIf

        If clearedLeveledShip == None
            ; ships in the "unique" list are added to a list of uniques sold, either local or external
            clearedLeveledShip = ClearShipReference(akSenderRef, shipsForSaleUnique, ShipsForSaleMappingUnique)
            If clearedLeveledShip != None
                _Log(fnName, "'unique' ship was bought, adding " + clearedLeveledShip + " to 'unique' sold list")
                If SVFExternalUniquesSoldList != None
                    SVFExternalUniquesSoldList.AddForm(clearedLeveledShip)
                    SyncUniquesSoldList()
                Else
                    UniquesSoldListLocal.Add(clearedLeveledShip)
                EndIf
            EndIf
        EndIf

        If clearedLeveledShip == None
            clearedLeveledShip = ClearShipReference(akSenderRef, ShipsForSaleSoldByPlayer, None)
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
            refIndex = akShipListMapping.FindStruct("shipRef", akShipRef)
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
Function CheckForInventoryRefresh(bool bForceRefresh = false)
    string fnName = "CheckForInventoryRefresh" Const
    _Log(fnName, "begin", LL_DEBUG)

    If SellsShips
        float currentGameTime = Utility.GetCurrentGameTime()
        float nextRefreshTime = lastInventoryRefreshTimestamp + DaysUntilInventoryRefresh
        _Log(fnName, "currentGameTime=" + currentGameTime + " nextRefreshTime=" + nextRefreshTime, LL_DEBUG)

        ; if the inventory has never been refreshed, or it's time to refresh, or it's being forced
        If bForceRefresh || lastInventoryRefreshTimestamp == 0 || (currentGameTime >= nextRefreshTime)
            _Log(fnName, "refreshing inventory (force=" + bForceRefresh + ")")

            ; the "always" sold list is cleared when the vendor refreshes their inventory
            AlwaysSoldList.Clear()

            RefreshShipsToSellArrays()
            LockGuard shipsForSaleGuard
                RefreshInventoryList(myLandingMarker, shipsForSale, ShipsForSaleAlways, ShipsForSaleRandom, ShipsForSaleUnique, ShipsForSaleSoldByPlayer)
                _Log(fnName, "shipsForSale=" + shipsForSale, LL_DEBUG)
            EndLockGuard
        Else
            LockGuard shipsForSaleGuard
                PurgeAlreadySoldUniques(shipsForSale, ShipsForSaleUnique)
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
    If UniqueShipsToSell() == true && UniquesSoldListLocal.Length > 0 && SVFExternalUniquesSoldList != None
        int uniqueSoldIndex = 0
        int mappingIndex = 0
        int uniquesListIndex = 0
        int i = akShipList.Length - 1
        While i > -1
            mappingIndex = ShipsForSaleMapping.FindStruct("shipRef", akShipList[i])
            If mappingIndex > -1
                uniqueSoldIndex = UniquesSoldListLocal.Find(ShipsForSaleMapping[mappingIndex].leveledShip)
                If uniqueSoldIndex > -1
                    _Log(fnName, "unique ship " + UniquesSoldListLocal[uniqueSoldIndex] + " was already bought - removing it from index " + i)
                    SpaceshipReference shipToDelete = akShipList[i]
                    ; make sure to remove the link to the landing marker, otherwise the ship will still show up until
                    ; the game gets around to actually deleting it
                    shipToDelete.SetLinkedRef(None, SpaceshipStoredLink)
                    _Log(fnName, "deleting ship " + shipToDelete)
                    debug.trace(self + " PurgeAlreadySoldUniques: deleting ship " + shipToDelete + ", ignore following error message")
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


; matches the "always" and "unique" ships to sell lists to the ships for sale lists and refreshes those lists if needed
Function CheckForNewShips()
    string fnName = "CheckForNewShips" Const
    _Log(fnName, "begin", LL_DEBUG)

    SpaceshipReference[] ShipsForSaleAlwaysCopy = None
    SpaceshipReference[] ShipsForSaleUniqueCopy = None
    LockGuard shipsForSaleGuard
        ShipsForSaleAlwaysCopy = (ShipsForSaleAlways as var[]) as SpaceshipReference[]
        ShipsForSaleUniqueCopy = (ShipsForSaleUnique as var[]) as SpaceshipReference[]
    EndLockGuard

    RefreshShipsToSellArrays()
    var[] ShipsToSellAlwaysCopy = None
    var[] ShipsToSellUniqueCopy = None
    If SVFUseNewDatasets == true
        ShipsToSellAlwaysCopy = SVFShipsToSellAlways as var[]
        ShipsToSellUniqueCopy = SVFShipsToSellUnique as var[]
    Else
        ShipsToSellAlwaysCopy = ShipsToSellAlways as var[]
        ShipsToSellUniqueCopy = ShipsToSellUnique as var[]
    EndIf

    bool refreshAlways = !ForSaleMatchesToSell(ShipsForSaleAlwaysCopy, ShipsToSellAlwaysCopy, ShipsForSaleMappingAlways)
    bool refreshUnique = !ForSaleMatchesToSell(ShipsForSaleUniqueCopy, ShipsToSellUniqueCopy, ShipsForSaleMappingUnique)

    If refreshAlways == true || refreshUnique == true
        LockGuard shipsForSaleGuard
            RefreshInventoryList(myLandingMarker, shipsForSale, ShipsForSaleAlways, ShipsForSaleRandom, ShipsForSaleUnique, ShipsForSaleSoldByPlayer)
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
        refToShipMappingIndex = akMappingList.FindStruct("shipRef", shipToCheck)
        If refToShipMappingIndex > -1
            leveledShip = akMappingList[refToShipMappingIndex].leveledShip
            If SVFUseNewDatasets == true
                leveledShipIndex = (akShipsToSellList as LeveledSpaceshipBase[]).Find(leveledShip)
            Else
                leveledShipIndex = (akShipsToSellList as ShipVendorListScript:ShipToSell[]).FindStruct("leveledShip", leveledShip)
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
    If SVFUseNewDatasets == true
        toReturn = SVFShipsToSellUnique.Length > 0
    Else
        toReturn = ShipsToSellUnique.Length > 0
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

    If SVFUseNewDatasets == true
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
    If SVFShipsToSellListRandomDataset != None
        _Log(fnName, "random ships dataset found", LL_DEBUG)
        SVFShipsToSellRandom = SVFShipsToSellListRandomDataset.GetArray() as LeveledSpaceshipBase[]
        _Log(fnName, "SVFShipsToSellRandom=" + SVFShipsToSellRandom, LL_DEBUG)
    Else
        SVFShipsToSellRandom.Clear()
    EndIf
    If SVFShipsToSellListAlwaysDataset != None
        _Log(fnName, "priority ships dataset found", LL_DEBUG)
        SVFShipsToSellAlways = SVFShipsToSellListAlwaysDataset.GetArray() as LeveledSpaceshipBase[]
        _Log(fnName, "SVFShipsToSellAlways=" + SVFShipsToSellAlways, LL_DEBUG)
    Else
        SVFShipsToSellAlways.Clear()
    EndIf
    If SVFShipsToSellListUniqueDataset != None
        _Log(fnName, "unique ships dataset found", LL_DEBUG)
        SVFShipsToSellUnique = SVFShipsToSellListUniqueDataset.GetArray() as LeveledSpaceshipBase[]
        _Log(fnName, "SVFShipsToSellUnique=" + SVFShipsToSellUnique, LL_DEBUG)
    Else
        SVFShipsToSellUnique.Clear()
    EndIf

    int i = 0

    ; remove any random ships that are already in the always or unique lists
    i = SVFShipsToSellRandom.Length - 1
    ; traverse the array from the end to the beginning so that removing elements doesn't mess up the loop
    While i > -1
        If SVFShipsToSellAlways.Find(SVFShipsToSellRandom[i]) > -1
            _Log(fnName, "random ship " + SVFShipsToSellRandom[i] + " (index " + i + ") is already in the always list - removing it")
            SVFShipsToSellRandom.Remove(i)
        EndIf
        If SVFShipsToSellUnique.Find(SVFShipsToSellRandom[i]) > -1
            _Log(fnName, "random ship " + SVFShipsToSellRandom[i] + " (index " + i + ") is already in the unique list - removing it")
            SVFShipsToSellRandom.Remove(i)
        EndIf
        i += -1
    EndWhile

    ; remove any priority ships that have already been sold this refresh cycle
    If SVFShipsToSellAlways.Length > 0 && AlwaysSoldList.Length > 0
        int alwaysIndex = 0
        i = 0
        While i < AlwaysSoldList.Length
            alwaysIndex = SVFShipsToSellAlways.Find(AlwaysSoldList[i])
            If alwaysIndex > -1
                _Log(fnName, "priority ship " + AlwaysSoldList[i] + " was already bought - removing it from refreshed priority 'to sell' list")
                SVFShipsToSellAlways.Remove(alwaysIndex)
            EndIf
            i += 1
        EndWhile
    EndIf

    ; remove any unique ships that have already been sold
    If SVFShipsToSellUnique.Length > 0 && UniquesSoldListLocal.Length > 0
        int uniqueIndex = 0
        i = 0
        While i < UniquesSoldListLocal.Length
            uniqueIndex = SVFShipsToSellUnique.Find(UniquesSoldListLocal[i])
            If uniqueIndex > -1
                _Log(fnName, "unique ship " + UniquesSoldListLocal[i] + " was already bought - removing it from refreshed uniques 'to sell' list")
                SVFShipsToSellUnique.Remove(uniqueIndex)
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
        ShipsToSellRandom = (ShipsToSellListRandomDataset.ShipList as var[]) as ShipVendorListScript:ShipToSell[]
        _Log(fnName, "ShipsToSellRandom=" + ShipsToSellRandom, LL_DEBUG)
    Else
        ShipsToSellRandom.Clear()
    EndIf
    If ShipsToSellListAlwaysDataset != None
        _Log(fnName, "priority ships dataset found", LL_DEBUG)
        ShipsToSellAlways = (ShipsToSellListAlwaysDataset.ShipList as var[]) as ShipVendorListScript:ShipToSell[]
        _Log(fnName, "ShipsToSellAlways=" + ShipsToSellAlways, LL_DEBUG)
    Else
        ShipsToSellAlways.Clear()
    EndIf
    If ShipsToSellListUniqueDataset != None
        _Log(fnName, "unique ships dataset found", LL_DEBUG)
        ShipsToSellUnique = (ShipsToSellListUniqueDataset.ShipList as var[]) as ShipVendorListScript:ShipToSell[]
        _Log(fnName, "ShipsToSellUnique=" + ShipsToSellUnique, LL_DEBUG)
    Else
        ShipsToSellUnique.Clear()
    EndIf

    int i = 0

    ; remove any random ships that are already in the always or unique lists, or that the player
    ; isn't a high enough level for; traversing the array from the end to the beginning so that
    ; removing elements doesn't mess up the loop
    int playerLevel = PlayerRef.GetLevel()
    i = ShipsToSellRandom.Length - 1
    While i > -1
        If ShipsToSellRandom[i].minLevel > playerLevel
            _Log(fnName, "player does not meet level requirements of random ship " + ShipsToSellRandom[i] + " (index " + i + ") - removing it")
            ShipsToSellRandom.Remove(i)
        EndIf
        If ShipsToSellAlways.Length > 0 && ShipsToSellAlways.FindStruct("leveledShip", ShipsToSellRandom[i].leveledShip) > -1
            _Log(fnName, "random ship " + ShipsToSellRandom[i] + " (index " + i + ") is already in the always list - removing it")
            ShipsToSellRandom.Remove(i)
        EndIf
        If ShipsToSellUnique.Length > 0 && ShipsToSellUnique.FindStruct("leveledShip", ShipsToSellRandom[i].leveledShip) > -1
            _Log(fnName, "random ship " + ShipsToSellRandom[i] + " (index " + i + ") is already in the unique list - removing it")
            ShipsToSellRandom.Remove(i)
        EndIf
        i += -1
    EndWhile

    ; remove any priority ships that have already been sold this refresh cycle
    If ShipsToSellAlways.Length > 0 && AlwaysSoldList.Length > 0
        int alwaysIndex = 0
        i = 0
        While i < AlwaysSoldList.Length
            alwaysIndex = ShipsToSellAlways.FindStruct("leveledShip", AlwaysSoldList[i])
            If alwaysIndex > -1
                _Log(fnName, "priority ship " + AlwaysSoldList[i] + " was already bought - removing it from refreshed priority 'to sell' list")
                ShipsToSellAlways.Remove(alwaysIndex)
            EndIf
            i += 1
        EndWhile
    EndIf

    ; remove any unique ships that have already been sold
    If ShipsToSellUnique.Length > 0 && UniquesSoldListLocal.Length > 0
        int uniqueIndex = 0
        i = 0
        While i < UniquesSoldListLocal.Length
            uniqueIndex = ShipsToSellUnique.FindStruct("leveledShip", UniquesSoldListLocal[i])
            If uniqueIndex > -1
                _Log(fnName, "unique ship " + UniquesSoldListLocal[i] + " was already bought - removing it from refreshed uniques 'to sell' list")
                ShipsToSellUnique.Remove(uniqueIndex)
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
        debug.trace(self + ".DeleteShips(): Attempting to delete " + theShip + ". This may throw an error, please ignore it.")
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
; - shipList: the main list of ships
; - shipListAlways: the list of priority ships
; - shipListRandom: the list of random ships
; - shipListUnique: the list of unique ships
;
; returns: None
Function RefreshInventoryList(ObjectReference akCreateMarker, SpaceshipReference[] shipList, SpaceshipReference[] shipListAlways, SpaceshipReference[] shipListRandom, SpaceshipReference[] shipListUnique, SpaceshipReference[] shipListSoldByPlayer)
    string fnName = "RefreshInventoryList" Const
    _Log(fnName, "begin", LL_DEBUG)

    If LogLevel == LL_DEBUG
        _Log(fnName, "starting stack profiling", LL_DEBUG)
        Debug.StartStackProfiling()
    EndIf

    _Log(fnName, "akCreateMarker=" + akCreateMarker + " shipList=" + shipList, LL_DEBUG)

    If akCreateMarker
        var[] vShipsToSellAlways = None
        var[] vShipsToSellRandom = None
        var[] vShipsToSellUnique = None
        If SVFUseNewDatasets == true
            vShipsToSellAlways = SVFShipsToSellAlways as var[]
            vShipsToSellRandom = SVFShipsToSellRandom as var[]
            vShipsToSellUnique = SVFShipsToSellUnique as var[]
        Else
            vShipsToSellAlways = ShipsToSellAlways as var[]
            vShipsToSellRandom = ShipsToSellRandom as var[]
            vShipsToSellUnique = ShipsToSellUnique as var[]
        EndIf

        ; clear the existing ships
        shipList.Clear()
        ; also clear the ship ref to leveled ship mapping list
        ShipsForSaleMapping.Clear()

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
        DeleteShips(shipListAlways)
        ShipsForSaleMappingAlways.Clear()
        _Log(fnName, "attempting to create " + vShipsToSellAlways.Length + " priority ships")
        CreateShipsForSale(vShipsToSellAlways, akCreateMarker, encounterLocation, shipListAlways, ShipsForSaleMappingAlways)

        ; refresh random ships
        _Log(fnName, "clearing random ships and ship ref to leveled ship mapping list")
        DeleteShips(shipListRandom)
        ShipsForSaleMappingRandom.Clear()
        int randomShipsToCreateCount = ShipVendorFramework:SVF_Utility.MinInt(vShipsToSellRandom.Length, Utility.RandomInt(ShipsForSaleMin, ShipsForSaleMax))
        _Log(fnName, "attempting to create " + randomShipsToCreateCount + " random ships (min=" + ShipsForSaleMin + ", max=" + ShipsForSaleMax + ", possible=" + vShipsToSellRandom.Length + ")")
        CreateShipsForSale(vShipsToSellRandom, akCreateMarker, encounterLocation, shipListRandom, ShipsForSaleMappingRandom, randomShipsToCreateCount, true)

        ; refresh unique ships
        _Log(fnName, "clearing unique ships and ship ref to leveled ship mapping list")
        DeleteShips(shipListUnique)
        ShipsForSaleMappingUnique.Clear()
        _Log(fnName, "attempting to create " + vShipsToSellUnique.Length + " unique ships")
        CreateShipsForSale(vShipsToSellUnique, akCreateMarker, encounterLocation, shipListUnique, ShipsForSaleMappingUnique)

        ; clear out the list of ships sold to the vendor by the player
        _Log(fnName, "clearing ships sold by player to vendor")
        DeleteShips(shipListSoldByPlayer)

        ; combine ship lists
        ; create a temporary array because when using `as var[]` on an empty array (which `shipList` would be at this
        ; point), it returns None, which causes an error when when attempting to pass it to `AppendToArray`
        SpaceshipReference[] shipListTemp
        _Log(fnName, "combining ship lists")
        _Log(fnName, "shipList=" + shipList, LL_DEBUG)
        _Log(fnName, "shipListAlways=" + shipListAlways, LL_DEBUG)
        _Log(fnName, "shipListRandom=" + shipListRandom, LL_DEBUG)
        _Log(fnName, "shipListUnique=" + shipListUnique, LL_DEBUG)
        _Log(fnName, "shipListSoldByPlayer=" + shipListSoldByPlayer, LL_DEBUG)
        shipListTemp = ShipVendorFramework:SVF_Utility.AppendToArray(shipListTemp as var[], shipListAlways as var[]) as SpaceshipReference[]
        shipListTemp = ShipVendorFramework:SVF_Utility.AppendToArray(shipListTemp as var[], shipListRandom as var[]) as SpaceshipReference[]
        shipListTemp = ShipVendorFramework:SVF_Utility.AppendToArray(shipListTemp as var[], shipListUnique as var[]) as SpaceshipReference[]
        shipListTemp = ShipVendorFramework:SVF_Utility.AppendToArray(shipListTemp as var[], shipListSoldByPlayer as var[]) as SpaceshipReference[]
        int i = 0
        While i < shipListTemp.Length
            shipList.Add(shipListTemp[i])
            i += 1
        EndWhile

        ; combine ship ref to leveled ship mappings
        ; create a temporary array because when using `as var[]` on an empty array (which `ShipsForSaleMapping` would be
        ; at this point), it returns None, which causes an error when attempting to pass it to `AppendToArray`
        ShipRefToSpaceshipLeveledListMapping[] ShipsForSaleMappingTemp
        _Log(fnName, "combining ship ref to leveled ship mappings")
        _Log(fnName, "ShipsForSaleMapping=" + ShipsForSaleMapping, LL_DEBUG)
        _Log(fnName, "ShipsForSaleMappingAlways=" + ShipsForSaleMappingAlways, LL_DEBUG)
        _Log(fnName, "ShipsForSaleMappingRandom=" + ShipsForSaleMappingRandom, LL_DEBUG)
        _Log(fnName, "ShipsForSaleMappingUnique=" + ShipsForSaleMappingUnique, LL_DEBUG)
        ShipsForSaleMapping = ShipVendorFramework:SVF_Utility.AppendToArray(ShipsForSaleMapping as var[], ShipsForSaleMappingAlways as var[]) as ShipRefToSpaceshipLeveledListMapping[]
        ShipsForSaleMapping = ShipVendorFramework:SVF_Utility.AppendToArray(ShipsForSaleMapping as var[], ShipsForSaleMappingRandom as var[]) as ShipRefToSpaceshipLeveledListMapping[]
        ShipsForSaleMapping = ShipVendorFramework:SVF_Utility.AppendToArray(ShipsForSaleMapping as var[], ShipsForSaleMappingUnique as var[]) as ShipRefToSpaceshipLeveledListMapping[]
        i = 0
        While i < ShipsForSaleMappingTemp.Length
            ShipsForSaleMapping.Add(ShipsForSaleMappingTemp[i])
            i += 1
        EndWhile

        ; update the timestamp
        lastInventoryRefreshTimestamp = Utility.GetCurrentGameTime()
    EndIf

    _Log(fnName, "DONE. shipList=" + shipList)

    If LogLevel == LL_DEBUG
        _Log(fnName, "Leveled Base Ships in shipList:", LL_DEBUG)

        _Log(fnName, "    Priority Ships:", LL_DEBUG)
        int i = 0
        While i < shipListAlways.Length
            _Log(fnName, "        " + Utility.IntToHex(shipListAlways[i].GetFormID()) + ": " + shipListAlways[i].GetBaseObject())
            i += 1
        EndWhile

        _Log(fnName, "    Random Ships:", LL_DEBUG)
        i = 0
        While i < shipListRandom.Length
            _Log(fnName, "        " + Utility.IntToHex(shipListRandom[i].GetFormID()) + ": " + shipListRandom[i].GetBaseObject())
            i += 1
        EndWhile

        _Log(fnName, "    Unique Ships:", LL_DEBUG)
        i = 0
        While i < shipListUnique.Length
            _Log(fnName, "        " + Utility.IntToHex(shipListUnique[i].GetFormID()) + ": " + shipListUnique[i].GetBaseObject())
            i += 1
        EndWhile

        _Log(fnName, "    Player-sold Ships:", LL_DEBUG)
        i = 0
        While i < shipListSoldByPlayer.Length
            _Log(fnName, "        " + Utility.IntToHex(shipListSoldByPlayer[i].GetFormID()) + ": " + shipListSoldByPlayer[i].GetBaseObject())
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
    If SVFUseNewDatasets == true
        While i < aiShipsToCreate
            CreateShipForSale(akShipToSellList[i] as LeveledSpaceshipBase, akCreateMarker, akEncLoc, akShipList, akRefToLLMap)
            i += 1
        EndWhile
    Else
        While i < aiShipsToCreate
            CreateShipForSale((akShipToSellList[i] as ShipVendorListScript:ShipToSell).leveledShip, akCreateMarker, akEncLoc, akShipList, akRefToLLMap)
            i += 1
        EndWhile
    EndIf
    _Log(fnName, "created " + akShipList.Length + " ships")
    _Log(fnName, "shipList=" + akShipList, LL_DEBUG)

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
        newShip.SetActorRefOwner(self)
        ; register for player buying event
        RegisterForRemoteEvent(newShip, "OnShipBought")
        ; clear inventory
        newShip.RemoveAllItems()
        ; create mapping for ship ref to leveled ship and add it to the list
        ShipRefToSpaceshipLeveledListMapping shipRefMap = new ShipRefToSpaceshipLeveledListMapping
        shipRefMap.shipRef = newShip
        shipRefMap.leveledShip = akShipToCreate
        akRefToLLMap.Add(shipRefMap)

        _Log(fnName, "created ship " + newShip + " from leveled ship " + akShipToCreate)
    Else
        _Log(fnName, "no ship created")
    EndIf

    _Log(fnName, "end", LL_DEBUG)
EndFunction


SpaceshipReference Function GetShipForSale(int index = 0)
    string fnName = "GetShipForSale" Const
    _Log(fnName, "begin", LL_DEBUG)

    SpaceshipReference shipForSale = NONE
    LockGuard shipsForSaleGuard
        If shipsForSale.Length > 0
            If index > -1 && index < shipsForSale.Length
                shipForSale = shipsForSale[index]
            ElseIf index >= shipsForSale.Length
                shipForSale = shipsForSale[shipsForSale.Length-1]
            Else
                shipForSale = shipsForSale[0]
            EndIf
        EndIf
    EndLockGuard
    If LogLevel == LL_DEBUG && shipForSale != None
        _Log(fnName, "returning " + shipForSale + " (" + shipForSale.GetBaseObject() + ") for index " + index, LL_DEBUG)
    EndIf

    _Log(fnName, "end", LL_DEBUG)
    Return shipForSale
EndFunction


Function TestShowHangarMenu()
    myLandingMarker.ShowHangarMenu(0, self, NONE)
EndFunction


Function TestOutputShipsForSale()
    LockGuard shipsForSaleGuard
        int i = 0
        While i < shipsForSale.Length
            SpaceshipReference theShip = shipsForSale[i]
            debug.trace(self + " i=" + i + ": " + theShip)
            i += 1
        EndWhile
    EndLockGuard
EndFunction
