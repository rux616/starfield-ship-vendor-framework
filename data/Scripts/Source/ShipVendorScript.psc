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
SpaceshipReference[] shipsForSaleRandom RequiresGuard(shipsForSaleGuard)
SpaceshipReference[] shipsForSaleAlways RequiresGuard(shipsForSaleGuard)
SpaceshipReference[] shipsForSaleUnique RequiresGuard(shipsForSaleGuard)
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

LeveledSpaceshipBase[] SVFShipsToSellRandom
LeveledSpaceshipBase[] SVFShipsToSellAlways
LeveledSpaceshipBase[] SVFShipsToSellUnique

ShipVendorListScript:ShipToSell[] ShipsToSellAlwaysMaster
ShipVendorListScript:ShipToSell[] ShipsToSellUniqueMaster
LeveledSpaceshipBase[] SVFShipsToSellAlwaysMaster
LeveledSpaceshipBase[] SVFShipsToSellUniqueMaster

bool Property SVFUseNewDatasets = false Auto Const
{ Mark vendor as using the new Ship Vendor Framework datasets. }
; this serves as an informal guard against the vendor record being overwritten by a non-SVF version
; if this flag is false, the newer SVFShipsToSellList* properties will be ignored and the original
; ShipsToSellList* properties will be used instead, albeit with some enhancements still active

FormList Property SVFExternalUniquesSoldList Auto Const
{ OPTIONAL - can be used to coordinate a list of unique ships that have been already sold between chosen vendors.
    If not filled in, the vendor will use their own local list.}
LeveledSpaceshipBase[] UniquesSoldListLocal

Struct ShipRefToSpaceshipLeveledListMapping
    SpaceshipReference shipRef
    LeveledSpaceshipBase leveledShip
    int shipReferenceList
EndStruct
ShipRefToSpaceshipLeveledListMapping[] ShipsForSaleMapping
int SHIP_REF_LIST_RANDOM = 0 Const
int SHIP_REF_LIST_ALWAYS = 1 Const
int SHIP_REF_LIST_UNIQUE = 2 Const

int Property SVFEnhancementsVersion = 1 Auto Const Hidden
{ The desired version of the Ship Vendor Framework enhancements. }

; The current version of the Ship Vendor Framework enhancements active on the vendor.
int SVFEnhancementsVersionCurrent = 0

; The player reference.
Actor playerRef

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
    HandleOnLoad()
    _Log(fnName, "end", LL_DEBUG)
EndEvent


Event OnActivate(ObjectReference akActionRef)
    string fnName = "OnActivate" Const
    ; calling HandleOnLoad() is a workaround for the fact that if the player loads a save where the vendor is already
    ; loaded, the OnLoad event for the vendor does not fire again
    _Log(fnName, "begin (" + akActionRef + ")", LL_DEBUG)
    If SVFEnhancementsInitialized() == false
        _Log(fnName, "SVF enhancements not initialized - initializing now")
        HandleOnLoad()
    EndIf
    _Log(fnName, "end (" + akActionRef + ")", LL_DEBUG)
EndEvent


Function HandleOnLoad()
    string fnName = "HandleOnLoad" Const
    _Log(fnName, "begin", LL_DEBUG)
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

    If SVFEnhancementsVersionCurrent != SVFEnhancementsVersion
        If SVFEnhancementsVersionCurrent == 0
            ; initial setup
            _Log(fnName, "Ship Vendor Framework enhancements initializing")
            SVFShipsToSellRandom = new LeveledSpaceshipBase[0]
            SVFShipsToSellAlways = new LeveledSpaceshipBase[0]
            SVFShipsToSellUnique = new LeveledSpaceshipBase[0]
            ShipsToSellAlwaysMaster = new ShipVendorListScript:ShipToSell[0]
            ShipsToSellUniqueMaster = new ShipVendorListScript:ShipToSell[0]
            SVFShipsToSellAlwaysMaster = new LeveledSpaceshipBase[0]
            SVFShipsToSellUniqueMaster = new LeveledSpaceshipBase[0]
            ShipsForSaleMapping = new ShipRefToSpaceshipLeveledListMapping[0]
            UniquesSoldListLocal = new LeveledSpaceshipBase[0]
            playerRef = Game.GetPlayer()
            SVFEnhancementsVersionCurrent = SVFEnhancementsVersion
            _Log(fnName, "Ship Vendor Framework enhancements initialized")
            ; if the vendor itself is already initialized, force refresh the inventory
            If initialized
                _Log(fnName, "main vendor already initialized - forcing inventory refresh")
                CheckForInventoryRefresh(true)
            EndIf
        EndIf
    EndIf
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


; copy a ShipToSell array
ShipVendorListScript:ShipToSell[] Function CopyShipToSellArray(ShipVendorListScript:ShipToSell[] arrayToCopy)
    string fnName = "CopyShipToSellArray" Const
    _Log(fnName, "begin", LL_DEBUG)
    ShipVendorListScript:ShipToSell[] myShipsToSell = new ShipVendorListScript:ShipToSell[arrayToCopy.Length]
    int i = 0
    While (i < arrayToCopy.Length)
        myShipsToSell[i] = arrayToCopy[i]
        i += 1
    EndWhile
    _Log(fnName, "returning " + myShipsToSell, LL_DEBUG)
    _Log(fnName, "end", LL_DEBUG)
    Return myShipsToSell
EndFunction


; copy a ShipToSell array in place, without creating a new one
Function CopyShipToSellArrayInPlace(ShipVendorListScript:ShipToSell[] arrayFrom, ShipVendorListScript:ShipToSell[] arrayTo)
    string fnName = "CopyShipToSellArrayInPlace" Const
    _Log(fnName, "begin", LL_DEBUG)
    arrayTo.Clear()
    int i = 0
    While (i < arrayFrom.Length)
        arrayTo.Add(arrayFrom[i])
        i += 1
    EndWhile
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
        EndLockGuard
    EndIf
    _Log(fnName, "end", LL_DEBUG)
EndEvent


Event SpaceshipReference.OnShipBought(SpaceshipReference akSenderRef)
    string fnName = "SpaceshipReference.OnShipBought" Const
    _Log(fnName, "begin", LL_DEBUG)
    _Log(fnName, "akSenderRef=" + akSenderRef, LL_DEBUG)
    LockGuard shipsForSaleGuard
        int shipsForSaleIndex = shipsForSale.Find(akSenderRef)
        If shipsForSaleIndex > -1
            shipsForSale.Remove(shipsForSaleIndex)
            int shipRefMapIndex = ShipsForSaleMapping.FindStruct("shipRef", akSenderRef)
            If shipRefMapIndex > -1
                ; remove from unique list if it exists
                If ShipsToSellUnique.Length > 0
                    LeveledSpaceshipBase soldLeveledSpaceshipBase = ShipsForSaleMapping[shipRefMapIndex].leveledShip
                    _Log(fnName, "soldLeveledSpaceshipBase=" + soldLeveledSpaceshipBase, LL_DEBUG)
                    int uniqueIndex = ShipsToSellUnique.FindStruct("leveledShip", soldLeveledSpaceshipBase)
                    If uniqueIndex > -1
                        _Log(fnName, "unique ship was bought - add it to uniques 'sold list' and remove it from uniques 'to sell' list")
                        UniquesSoldListLocal.Add(soldLeveledSpaceshipBase)
                        ShipsToSellUnique.Remove(uniqueIndex)
                    EndIf
                EndIf
                ShipsForSaleMapping.Remove(shipRefMapIndex)
            EndIf
        EndIf
    EndLockGuard
    _Log(fnName, "end", LL_DEBUG)
EndEvent


; checks if it's time to refresh the inventory (can be forced) and kicks it off if needed
Function CheckForInventoryRefresh(bool bForceRefresh = false)
    string fnName = "CheckForInventoryRefresh" Const
    _Log(fnName, "begin", LL_DEBUG)
    If SellsShips
        float currentGameTime = Utility.GetCurrentGameTime()
        float nextRefreshTime = lastInventoryRefreshTimestamp + DaysUntilInventoryRefresh
        _Log(fnName, "currentGameTime=" + currentGameTime + " nextRefreshTime=" + nextRefreshTime, LL_DEBUG)
        RefreshMasterListsWrapper()


        ; if the inventory has never been refreshed, or it's time to refresh, or it's being forced
        If bForceRefresh || lastInventoryRefreshTimestamp == 0 || (currentGameTime >= nextRefreshTime)
            _Log(fnName, "time to refresh inventory (force=" + bForceRefresh + ")")

            RefreshShipsToSellArraysWrapper()
            LockGuard shipsForSaleGuard
                RefreshInventoryList(myLandingMarker, shipsForSale)
                _Log(fnName, "shipsForSale=" + shipsForSale, LL_DEBUG)
            EndLockGuard
        Else
            LockGuard shipsForSaleGuard
                PurgeAlreadySoldUniques(shipsForSale)
            EndLockGuard
        EndIf
    EndIf
    _Log(fnName, "end", LL_DEBUG)
EndFunction


; remove any unique ships that have already been purchased by the player
Function PurgeAlreadySoldUniques(SpaceshipReference[] akShipList)
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
                    akShipList.Remove(i)
                EndIf
            EndIf
            i += -1
        EndWhile
    EndIf
    _Log(fnName, "end", LL_DEBUG)
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


; refresh the master lists - accounts for new datasets
Function RefreshMasterListsWrapper(bool abAlwaysList = true, bool abUniqueList = true)
    string fnName = "RefreshMasterListsWrapper" Const
    _Log(fnName, "begin", LL_DEBUG)
    If SVFUseNewDatasets == true
        RefreshMasterListsSVF(abAlwaysList, abUniqueList)
    Else
        RefreshMasterLists(abAlwaysList, abUniqueList)
    EndIf
    _Log(fnName, "end", LL_DEBUG)
EndFunction


; refresh the master lists - new FormList-based datasets
Function RefreshMasterListsSVF(bool abAlwaysList = true, bool abUniqueList = true)
    string fnName = "RefreshMasterListsSVF" Const
    _Log(fnName, "begin", LL_DEBUG)
    ; fill arrays using datasets
    If abAlwaysList == true
        If SVFShipsToSellListAlwaysDataset != None
            SVFShipsToSellAlwaysMaster = SVFShipsToSellListAlwaysDataset.GetArray() as LeveledSpaceshipBase[]
        Else
            SVFShipsToSellAlwaysMaster = new LeveledSpaceshipBase[0]
        EndIf
    EndIf
    If abUniqueList == true
        If SVFShipsToSellListUniqueDataset != None
            SVFShipsToSellUniqueMaster = SVFShipsToSellListUniqueDataset.GetArray() as LeveledSpaceshipBase[]
        Else
            SVFShipsToSellUniqueMaster = new LeveledSpaceshipBase[0]
        EndIf
    EndIf
    _Log(fnName, "end", LL_DEBUG)
EndFunction


; refresh the master lists - original activator-based datasets
Function RefreshMasterLists(bool abAlwaysList = true, bool abUniqueList = true)
    string fnName = "RefreshMasterLists" Const
    _Log(fnName, "begin", LL_DEBUG)
    ; fill arrays using datasets
    If abAlwaysList == true
        If ShipsToSellListAlwaysDataset != None
            CopyShipToSellArrayInPlace(ShipsToSellListAlwaysDataset.ShipList, ShipsToSellAlwaysMaster)
        Else
            ShipsToSellAlwaysMaster.Clear()
        EndIf
    EndIf
    If abUniqueList == true
        If ShipsToSellListUniqueDataset != None
            CopyShipToSellArrayInPlace(ShipsToSellListUniqueDataset.ShipList, ShipsToSellUniqueMaster)
        Else
            ShipsToSellUniqueMaster.Clear()
        EndIf
    EndIf
    _Log(fnName, "end", LL_DEBUG)
EndFunction


bool Function CompareLists()
; TODO implement this function
EndFunction


; wrapper around the RefreshShipsToSellArrays/RefreshShipsToSellArraysSVF functions to account for new datasets
Function RefreshShipsToSellArraysWrapper()
    string fnName = "RefreshShipsToSellArraysWrapper" Const
    _Log(fnName, "begin", LL_DEBUG)
    If SVFUseNewDatasets == true
        RefreshShipsToSellArraysSVF()
    Else
        RefreshShipsToSellArrays()
    EndIf
    _Log(fnName, "end", LL_DEBUG)
EndFunction


; refresh the ships to sell arrays - new FormList-based datasets
Function RefreshShipsToSellArraysSVF()
    string fnName = "RefreshShipsToSellArraysSVF" Const
    _Log(fnName, "begin", LL_DEBUG)
    ; fill arrays using datasets
    If SVFShipsToSellListRandomDataset != None
        SVFShipsToSellRandom = SVFShipsToSellListRandomDataset.GetArray() as LeveledSpaceshipBase[]
    Else
        SVFShipsToSellRandom = new LeveledSpaceshipBase[0]
    EndIf
    If SVFShipsToSellListAlwaysDataset != None
        SVFShipsToSellAlways = SVFShipsToSellListAlwaysDataset.GetArray() as LeveledSpaceshipBase[]
    Else
        SVFShipsToSellAlways = new LeveledSpaceshipBase[0]
    EndIf
    If SVFShipsToSellListUniqueDataset != None
        SVFShipsToSellUnique = SVFShipsToSellListUniqueDataset.GetArray() as LeveledSpaceshipBase[]
    Else
        SVFShipsToSellUnique = new LeveledSpaceshipBase[0]
    EndIf

    ; remove any random ships that are already in the always or unique lists
    int randomIndex = SVFShipsToSellRandom.Length - 1
    While randomIndex > -1
        If SVFShipsToSellAlways.Find(SVFShipsToSellRandom[randomIndex]) > -1
            _Log(fnName, "random ship " + SVFShipsToSellRandom[randomIndex] + " (index " + randomIndex + ") is already in the always list - removing it")
            SVFShipsToSellRandom.Remove(randomIndex)
        EndIf
        If SVFShipsToSellUnique.Find(SVFShipsToSellRandom[randomIndex]) > -1
            _Log(fnName, "random ship " + SVFShipsToSellRandom[randomIndex] + " (index " + randomIndex + ") is already in the unique list - removing it")
            SVFShipsToSellRandom.Remove(randomIndex)
        EndIf
        randomIndex += -1
    EndWhile

    ; remove any unique ships that have already been sold
    If SVFShipsToSellUnique.Length > 0 && UniquesSoldListLocal.Length > 0
        int uniqueSoldIndex = 0
        int uniqueIndex = 0
        While uniqueSoldIndex < UniquesSoldListLocal.Length
            uniqueIndex = SVFShipsToSellUnique.Find(UniquesSoldListLocal[uniqueSoldIndex])
            If uniqueIndex > -1
                _Log(fnName, "unique ship " + UniquesSoldListLocal[uniqueSoldIndex] + " was already bought - removing it from refreshed uniques 'to sell' list")
                SVFShipsToSellUnique.Remove(uniqueIndex)
            EndIf
            uniqueSoldIndex += 1
        EndWhile
    EndIf
    _Log(fnName, "end", LL_DEBUG)
EndFunction


; refresh the ships to sell arrays - original activator-based datasets
Function RefreshShipsToSellArrays()
    string fnName = "RefreshShipsToSellArrays" Const
    _Log(fnName, "begin", LL_DEBUG)
    ; fill arrays using datasets
    If ShipsToSellListRandomDataset != None
        CopyShipToSellArrayInPlace(ShipsToSellListRandomDataset.ShipList, ShipsToSellRandom)
    Else
        ShipsToSellRandom.Clear()
    EndIf
    If ShipsToSellListAlwaysDataset != None
        CopyShipToSellArrayInPlace(ShipsToSellListAlwaysDataset.ShipList, ShipsToSellAlways)
    Else
        ShipsToSellAlways.Clear()
    EndIf
    If ShipsToSellListUniqueDataset != None
        CopyShipToSellArrayInPlace(ShipsToSellListUniqueDataset.ShipList, ShipsToSellUnique)
    Else
        ShipsToSellUnique.Clear()
    EndIf

    ; remove any random ships that are already in the always or unique lists, or that the player
    ; isn't a high enough level for
    int randomIndex = ShipsToSellRandom.Length - 1
    int playerLevel = playerRef.GetLevel()
    While randomIndex > -1
        If ShipsToSellRandom[randomIndex].minLevel > playerLevel
            _Log(fnName, "player does not meet level requirements of random ship " + ShipsToSellRandom[randomIndex] + " (index " + randomIndex + ") - removing it")
            ShipsToSellRandom.Remove(randomIndex)
        EndIf
        If ShipsToSellAlways.Length > 0 && ShipsToSellAlways.FindStruct("leveledShip", ShipsToSellRandom[randomIndex].leveledShip) > -1
            _Log(fnName, "random ship " + ShipsToSellRandom[randomIndex] + " (index " + randomIndex + ") is already in the always list - removing it")
            ShipsToSellRandom.Remove(randomIndex)
        EndIf
        If ShipsToSellUnique.Length > 0 && ShipsToSellUnique.FindStruct("leveledShip", ShipsToSellRandom[randomIndex].leveledShip) > -1
            _Log(fnName, "random ship " + ShipsToSellRandom[randomIndex] + " (index " + randomIndex + ") is already in the unique list - removing it")
            ShipsToSellRandom.Remove(randomIndex)
        EndIf
        randomIndex += -1
    EndWhile

    ; remove any unique ships that have already been sold
    If ShipsToSellUnique.Length > 0 && UniquesSoldListLocal.Length > 0
        int uniqueSoldIndex = 0
        int uniqueIndex = 0
        While uniqueSoldIndex < UniquesSoldListLocal.Length
            uniqueIndex = ShipsToSellUnique.FindStruct("leveledShip", UniquesSoldListLocal[uniqueSoldIndex])
            If uniqueIndex > -1
                _Log(fnName, "unique ship " + UniquesSoldListLocal[uniqueSoldIndex] + " was already bought - removing it from refreshed uniques 'to sell' list")
                ShipsToSellUnique.Remove(uniqueIndex)
            EndIf
            uniqueSoldIndex += 1
        EndWhile
    EndIf
    _Log(fnName, "begin", LL_DEBUG)
EndFunction


Function RefreshInventoryList(ObjectReference createMarker, SpaceshipReference[] shipList, bool abRefreshRandom = true, bool abRefreshAlways = true, bool abRefreshUnique = true)
    string fnName = "RefreshInventoryList" Const
    _Log(fnName, "begin", LL_DEBUG)
    _Log(fnName, "createMarker=" + createMarker + " shipList=" + shipList, LL_DEBUG)
    If createMarker
        ; clear existing list
        int i = shipList.Length - 1
        While i > -1
            SpaceshipReference theShip = shipList[i]
            ; attempting to use Delete() on the ship reference throws an error in the papyrus log stating that spaceships cannot be deleted and the reference will be disabled instead. in the probably unfounded hope that this will eventually be fixed, just make a note before the error is thrown.
            _Log(fnName, "attempting to delete " + theShip)
            debug.trace(self + " RefreshInventoryList: attempting to delete " + theShip + ". this may throw an error, please ignore it.")
            theShip.Delete()
            i += -1
        EndWhile
        shipList.Clear()

        ; also clear the ship ref to leveled ship mapping list
        _Log(fnName, "clearing ship ref to leveled ship mapping list")
        ShipsForSaleMapping.Clear()
        _Log(fnName, "RefreshInventoryList: ship ref to leveled ship mapping list cleared", LL_DEBUG)

        ; how many ships do I want in my list?
        int randomShipsPossible = 0
        int priorityShipsToCreateCount = 0
        int uniqueShipsToCreateCount = 0
        If SVFUseNewDatasets == true
            priorityShipsToCreateCount = SVFShipsToSellAlways.Length
            randomShipsPossible = SVFShipsToSellRandom.Length
            uniqueShipsToCreateCount = SVFShipsToSellUnique.Length
        Else
            priorityShipsToCreateCount = ShipsToSellAlways.Length
            randomShipsPossible = ShipsToSellRandom.Length
            uniqueShipsToCreateCount = ShipsToSellUnique.Length
        EndIf
        ; limit the number of random ships to create to be at most the number of ships available
        int randomShipsToCreateCount = ShipVendorFramework:SVF_Utility.MinInt(randomShipsPossible, Utility.RandomInt(ShipsForSaleMin, ShipsForSaleMax))

        int totalShipsToCreateCount = priorityShipsToCreateCount + randomShipsToCreateCount + uniqueShipsToCreateCount
        _Log(fnName, "attempting to create " + totalShipsToCreateCount + " ships at landing marker " + createMarker + ": " + priorityShipsToCreateCount + " priority, " + randomShipsToCreateCount + " random (out of " + randomShipsPossible + " possible), " + uniqueShipsToCreateCount + " unique")

        ; create priority ships
        _Log(fnName, "creating " + priorityShipsToCreateCount + " (max) priority ships")
        If SVFUseNewDatasets == true
            CreateShipsForSaleSVF(SVFShipsToSellAlways, createMarker, shipList)
        Else
            CreateShipsForSale(ShipsToSellAlways, createMarker, shipList)
        EndIf

        _Log(fnName, "creating " + randomShipsToCreateCount + " (max) random ships")
        If randomShipsToCreateCount > 0 && randomShipsToCreateCount < randomShipsPossible
            ; generate randomness
            int seedMin = 0x00000000
            int seedMax = 0x7ffffffe
            _Log(fnName, "creating random seed between " + seedMin + " and " + seedMax, LL_DEBUG)
            int randomSeed = Utility.RandomInt(seedMin, seedMax)
            _Log(fnName, "randomSeed=" + randomSeed, LL_DEBUG)
            ; generate a list of random indices using ship count * 2 to try and get more coverage once the array is
            ; deduplicated, but limit things to a size of 128 because that's the limit that RandomIntsFromSeed() uses
            ; (going over 128 generates a warning in the papyrus log). this may result in fewer random ships being
            ; created than the maximum, but that's acceptable: randy giveth, and randy taketh away
            int randomArraySize = ShipVendorFramework:SVF_Utility.MinInt(randomShipsToCreateCount * 2, 128)
            int[] randomIndices = Utility.RandomIntsFromSeed(randomSeed, randomArraySize, 0, randomShipsPossible - 1)
            _Log(fnName, "randomIndices=" + randomIndices + " (length " + randomIndices.Length + ")", LL_DEBUG)
            ShipVendorFramework:SVF_Utility.DeduplicateIntArray(randomIndices)
            _Log(fnName, "deduplicated randomIndices=" + randomIndices + " (length " + randomIndices.Length + ")", LL_DEBUG)
            randomShipsToCreateCount = ShipVendorFramework:SVF_Utility.MinInt(randomShipsToCreateCount, randomIndices.Length)
            _Log(fnName, "randomShipsToCreateCount=" + randomShipsToCreateCount)

            ; create the random ships
            i = 0
            While i < randomShipsToCreateCount
                If SVFUseNewDatasets == true
                    _Log(fnName, "attempting to create random ship from " + SVFShipsToSellRandom[randomIndices[i]] + " (index " + randomIndices[i] + ")")
                    CreateShipForSale(SVFShipsToSellRandom[randomIndices[i]], createMarker, shipList, true)
                Else
                    _Log(fnName, "attempting to create random ship from " + ShipsToSellRandom[randomIndices[i]].leveledShip + " (index " + randomIndices[i] + ")")
                    CreateShipForSale(ShipsToSellRandom[randomIndices[i]].leveledShip, createMarker, shipList, true)
                EndIf
                i += 1
            EndWhile

        ; while having randomShipsToCreateCount be equal to randomShipsPossible is possible, having
        ; randomShipsToCreateCount be greater than randomShipsPossible shouldn't be; that being said, include it as a
        ; case to avoid simply creating no random ships at all
        ElseIf randomShipsToCreateCount >= randomShipsPossible
            _Log(fnName, "creating all random ships (" + randomShipsPossible + ")")
            If SVFUseNewDatasets == true
                CreateShipsForSaleSVF(SVFShipsToSellRandom, createMarker, shipList)
            Else
                CreateShipsForSale(ShipsToSellRandom, createMarker, shipList)
            EndIf
        EndIf

        ; Lastly, create unique ships that appear at the end of the list
        _Log(fnName, "creating " + uniqueShipsToCreateCount + " (max) unique ships")
        If SVFUseNewDatasets == true
            CreateShipsForSaleSVF(SVFShipsToSellUnique, createMarker, shipList, true)
        Else
            CreateShipsForSale(ShipsToSellUnique, createMarker, shipList, true)
        EndIf

        lastInventoryRefreshTimestamp = Utility.GetCurrentGameTime()
    EndIf

    _Log(fnName, "DONE. shipList=" + shipList)
    _Log(fnName, "Leveled Base Ships in shipList:")
    int i = 0
    While i < shipList.Length
        _Log(fnName, "  " + shipList[i].GetBaseObject())
        i += 1
    EndWhile
    _Log(fnName, "end", LL_DEBUG)
EndFunction


; create ships for sale - accounts for new datasets
; Function CreateShipsForSaleWrapper(var[] akShipToSellList, ObjectReference akCreateMarker, SpaceshipReference[] akShipList, int aiShipsToCreate = -1, bool abRandomize = false, bool abAddToRefLLMap = false)
;     string fnName = "CreateShipsForSaleWrapper" Const
Function CreateShipsForSale(var[] akShipToSellList, ObjectReference akCreateMarker, SpaceshipReference[] akShipList, int aiShipsToCreate = -1, bool abRandomize = false, bool abAddToRefLLMap = false)
    string fnName = "CreateShipsForSale" Const
    _Log(fnName, "begin", LL_DEBUG)

    If aiShipsToCreate == 0
        _Log(fnName, "no ships to create")
        Return
    EndIf
    If aiShipsToCreate == -1 || aiShipsToCreate > akShipToSellList.Length
        aiShipsToCreate = akShipToSellList.Length
    EndIf
    If abRandomize == true
        akShipToSellList = ShipVendorFramework.SVF_Utility.ShuffleArray(akShipToSellList, aiShipsToCreate)
    EndIf

    int i = 0
    If SVFUseNewDatasets == true
        While i < aiShipsToCreate
            CreateShipForSale(akShipToSellList[i] as LeveledSpaceshipBase, akCreateMarker, akShipList, abAddToRefLLMap)
            i += 1
        EndWhile
        ; CreateShipsForSaleSVF(akShipToSellList as LeveledSpaceshipBase[], akCreateMarker, akShipList, abAddToRefLLMap)
    Else
        While i < aiShipsToCreate
            CreateShipForSale((akShipToSellList[i] as ShipVendorListScript:ShipToSell).leveledShip, akCreateMarker, akShipList, abAddToRefLLMap)
            i += 1
        EndWhile
        ; CreateShipsForSale(akShipToSellList as ShipVendorListScript:ShipToSell[], akCreateMarker, akShipList, abAddToRefLLMap)
    EndIf
    _Log(fnName, "shipList=" + akShipList, LL_DEBUG)
    _Log(fnName, "end", LL_DEBUG)
EndFunction


; ; create ships for sale - new FormList-based datasets
; Function CreateShipsForSaleSVF(LeveledSpaceshipBase[] shipToSellList, ObjectReference createMarker, SpaceshipReference[] shipList, bool abAddToRefLLMap = false)
;     string fnName = "CreateShipsForSaleSVF" Const
;     _Log(fnName, "begin", LL_DEBUG)
;     int i = 0
;     While i < shipToSellList.Length
;         CreateShipForSale(shipToSellList[i], createMarker, shipList, abAddToRefLLMap)
;         i += 1
;     EndWhile
;     _Log(fnName, "shipList=" + shipList, LL_DEBUG)
;     _Log(fnName, "end", LL_DEBUG)
; EndFunction


; ; create ships for sale - original activator-based datasets
; Function CreateShipsForSale(ShipVendorListScript:ShipToSell[] shipToSellList, ObjectReference createMarker, SpaceshipReference[] shipList, bool abAddToRefLLMap = false)
;     string fnName = "CreateShipsForSale" Const
;     _Log(fnName, "begin", LL_DEBUG)
;     int i = 0
;     While i < shipToSellList.Length
;         CreateShipForSale(shipToSellList[i].leveledShip, createMarker, shipList, abAddToRefLLMap)
;         i += 1
;     EndWhile
;     _Log(fnName, "shipList=" + shipList, LL_DEBUG)
;     _Log(fnName, "end", LL_DEBUG)
; EndFunction


; create a ship for sale
Function CreateShipForSale(LeveledSpaceshipBase leveledShipToCreate, ObjectReference landingMarker, SpaceshipReference[] shipList, bool abAddToRefLLMap = false)
    string fnName = "CreateShipForSale" Const
    _Log(fnName, "begin", LL_DEBUG)
    _Log(fnName, "landingMarker=" + landingMarker, LL_DEBUG)
    ObjectReference createMarker = landingMarker

    SpaceshipReference landingMarkerShipRef = landingMarker.GetCurrentShipRef()
    If landingMarkerShipRef
        ; create new ship at my ship rather than the landing marker to avoid issues with creating a ship inside a ship
        createMarker = landingMarkerShipRef
       _Log(fnName, "landingMarker is in a ship; create new ship at the shipRef=" + landingMarkerShipRef)
    EndIf

    Location encounterLocation = ShipVendorLocation
    If encounterLocation == None
        encounterLocation = GetCurrentLocation()
    EndIf
    SpaceshipReference newShip = createMarker.PlaceShipAtMe(leveledShipToCreate, aiLevelMod = 2, abInitiallyDisabled = true, akEncLoc = encounterLocation)
    If newShip
        shipList.Add(newShip)
        ; link to landing pad
        newShip.SetLinkedRef(landingMarker, SpaceshipStoredLink)
        ; assign vendor ownership
        newShip.SetActorRefOwner(self)
        ; register for player buying event
        RegisterForRemoteEvent(newShip, "OnShipBought")
        ; clear inventory
        newShip.RemoveAllItems()
        ; if specified, create mapping for ship ref to leveled ship and add it to the list
        if abAddToRefLLMap
            ShipRefToSpaceshipLeveledListMapping shipRefMap = new ShipRefToSpaceshipLeveledListMapping
            shipRefMap.shipRef = newShip
            shipRefMap.leveledShip = leveledShipToCreate
            ShipsForSaleMapping.Add(shipRefMap)
        EndIf

        _Log(fnName, "ship created: " + newShip)
    Else
        _Log(fnName, "ship not created")
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
    _Log(fnName, "returning " + shipForSale + " for index " + index, LL_DEBUG)
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
