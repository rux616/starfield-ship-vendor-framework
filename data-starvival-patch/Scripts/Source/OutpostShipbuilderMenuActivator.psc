; this script is modified to maintain compatibility between Ship Vendor Framework and Starvival

Scriptname OutpostShipbuilderMenuActivator extends OutpostEventHandlerParent

Message Property OutpostShipbuilderMessage auto const mandatory
{ message box listing options}

ActorBase property OutpostShipbuilderVendor auto const mandatory
{ vendor to create when built }

ShipVendorScript property myVendor auto hidden

; Starvival Properties

ObjectReference Property TechVendorChest Auto Const
GlobalVariable Property GV_TechVendorCreditsRefresh Auto Const
MiscObject Property Credits Auto Const
LeveledItem Property CreditsLeveledList Auto Const

; override parent function
Function HandleOnWorkshopObjectPlaced(ObjectReference akReference)
    debug.trace(self + " OnWorkshopObjectPlaced")
    ; create vendor
    myVendor = PlaceAtMe(OutpostShipbuilderVendor, abInitiallyDisabled=true) as ShipVendorScript
    ObjectReference myLandingMarker = GetLinkedRef()
    debug.trace(self + "   myLandingMarker=" + myLandingMarker)
    ; link to landing marker and reinitialize
    myVendor.Initialize(myLandingMarker)
EndFunction


; override parent function
Function HandleOnWorkshopObjectRemoved(ObjectReference akReference)
    debug.trace(self + " OnWorkshopObjectRemoved")
    if myVendor
        myVendor.Delete()
        myVendor = NONE
    EndIf
EndFunction


Event OnActivate(ObjectReference akActionRef)
    debug.trace(self + " OnActivate " + akActionRef)
    if akActionRef == Game.GetPlayer()
        ShipVendorScript theShipServicesActor = myVendor as ShipVendorScript
        if theShipServicesActor
            int messageIndex = OutpostShipbuilderMessage.Show()
            if messageIndex == 0
                TechVendorCreditsRefresh()
                theShipServicesActor.myLandingMarker.ShowHangarMenu(0, theShipServicesActor, abOpenToAvailableTab = false)
            elseif messageIndex == 1
                TechVendorCreditsRefresh()
                ; calling OnLoad() is a workaround for the fact that if the player loads a save where the vendor is
                ; already loaded, the OnLoad event for the vendor does not fire again
                If theShipServicesActor.SVFEnhancementsInitialized() == false
                    ; TODO this needs to have a "please wait, initializing" message
                    theShipServicesActor.OnLoad()
                EndIf
                ; TODO this needs to have a "please wait, initializing" message
                theShipServicesActor.myLandingMarker.ShowHangarMenu(0, theShipServicesActor, abOpenToAvailableTab = true)
            elseif messageIndex == 2
                TechVendorCreditsRefresh()
                theShipServicesActor.myLandingMarker.ShowHangarMenu(1, theShipServicesActor)
            endif
        endif
    endif
EndEvent


Function TechVendorCreditsRefresh()
    Int CreditsThreshold = GV_TechVendorCreditsRefresh.GetValue() As Int
    If TechVendorChest.GetItemCount(Credits) < CreditsThreshold
        TechVendorChest.RemoveItem(Credits, 999999999, True, None)
        TechVendorChest.AddItem(CreditsLeveledList, 1, True)
    EndIf
EndFunction
