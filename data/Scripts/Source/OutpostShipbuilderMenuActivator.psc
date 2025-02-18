Scriptname OutpostShipbuilderMenuActivator extends OutpostEventHandlerParent

Message Property OutpostShipbuilderMessage auto const mandatory
{ message box listing options}

ActorBase property OutpostShipbuilderVendor auto const mandatory
{ vendor to create when built }

ShipVendorScript property myVendor auto hidden


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
            ; fix if the landing marker is not set
            If theShipServicesActor.myLandingMarker == NONE
                theShipServicesActor.myLandingMarker = GetLinkedRef()
            EndIf

            int messageIndex = OutpostShipbuilderMessage.Show()
            if messageIndex == 0
                theShipServicesActor.myLandingMarker.ShowHangarMenu(0, theShipServicesActor, abOpenToAvailableTab = false)
            elseif messageIndex == 1
                If theShipServicesActor.SVFEnhancementsInitialized() == false
                    ; TODO add a "please wait, initializing" message
                    ; calling Initialize() again is a workaround for the fact that if the player loads a save where the
                    ; vendor is already loaded, the OnLoad event for the vendor does not fire again and thus the SVF
                    ; enhancements do not get initialized automatically
                    theShipServicesActor.Initialize(theShipServicesActor.myLandingMarker)
                EndIf
                ; TODO add a "please wait, initializing" message
                theShipServicesActor.myLandingMarker.ShowHangarMenu(0, theShipServicesActor, abOpenToAvailableTab = true)
            elseif messageIndex == 2
                theShipServicesActor.myLandingMarker.ShowHangarMenu(1, theShipServicesActor)
            endif
        endif
    endif
EndEvent
