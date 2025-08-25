Scriptname ShipbuilderMenuActivator Extends ObjectReference
{ script for buying ships via a kiosk activator
    NOTE: kiosk should either be linked to a landing marker, OR be linked to another kiosk which is linked to the landing marker.ShipVendorScript
    So, if you have multiple kiosks, only link one to the landing marker, link the others to that kiosk.
}

ActorBase Property ShipbuilderVendor Auto Const Mandatory
{ vendor to create when built - needs to have ShipVendorScript }

ShipVendorScript Property MyVendor Auto Hidden
{ holds the ship vendor for the "master" kiosk }

ShipbuilderMenuActivator Property MyLinkedParent Auto Hidden
{ linked kiosk that holds the vendor to use }

Message Property ShipBuilderVendorMessage Auto Const
{the message that pops up on activation}

bool initialized = false

Event OnLoad()
    If initialized == false
        Debug.Trace(Self + " OnLoad: initializing...")
        If MyVendor == None && MyLinkedParent == NONE
            ; get vendor from linked kiosk, or create a new one
            MyLinkedParent = GetLinkedRef() as ShipbuilderMenuActivator
            Debug.Trace(Self + " MyLinkedParent=" + MyLinkedParent)
            If MyLinkedParent == NONE
                ; not linked to another kiosk
                ; create vendor
                MyVendor = PlaceAtMe(ShipbuilderVendor, abInitiallyDisabled=true) as ShipVendorScript
                ; link to landing marker and reinitialize
                Debug.Trace(Self + " MyVendor=" + MyVendor)
                MyVendor.Initialize(GetLinkedRef())
            EndIf
        EndIf
        initialized = true
    EndIf
EndEvent

Event OnActivate(ObjectReference akActionRef)
    Debug.Trace(Self + " OnActivate " + akActionRef)
    If akActionRef == Game.GetPlayer()
        ShipVendorScript theShipServicesActor = MyVendor
        If theShipServicesActor == None
            Debug.Trace(Self + " trying to get my vendor from linked parent")
            ; get it from my linked kiosk
            theShipServicesActor = MyLinkedParent.MyVendor
        EndIf
        Debug.Trace(Self + " theShipServicesActor=" + theShipServicesActor)
        If theShipServicesActor
            int messageIndex = ShipBuilderVendorMessage.Show()
            If messageIndex == 0
                theShipServicesActor.MyLandingMarker.ShowHangarMenu(0, theShipServicesActor, abOpenToAvailableTab=false)
            ElseIf messageIndex == 1
                If theShipServicesActor.SVFEnhancementsInitialized() == false
                    ; TODO add a "please wait, initializing" message
                    ; calling Initialize() again is a workaround for the fact that if the player loads a save where the
                    ; vendor is already loaded, the OnLoad event for the vendor does not fire again and thus the SVF
                    ; enhancements do not get initialized automatically
                    theShipServicesActor.Initialize(theShipServicesActor.MyLandingMarker)
                EndIf
                ; TODO add a "please wait, initializing" message
                theShipServicesActor.MyLandingMarker.ShowHangarMenu(0, theShipServicesActor, abOpenToAvailableTab=true)
            EndIf
        EndIf
    EndIf
EndEvent
