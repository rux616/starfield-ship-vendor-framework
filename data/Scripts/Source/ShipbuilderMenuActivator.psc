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
    ShipVendorFramework:SVF_Utility.Log("ShipbuilderMenuActivator", GetFormID(), asFunctionName, asLogMessage, aiSeverity, LogLevel)
EndFunction


Event OnLoad()
    string fnName = "OnLoad"
    _Log(fnName, "begin", LL_DEBUG)

    If initialized == false
        _Log(fnName, "OnLoad: initializing...", LL_DEBUG)
        If MyVendor == None && MyLinkedParent == None
            ; get vendor from linked kiosk, or create a new one
            MyLinkedParent = GetLinkedRef() as ShipbuilderMenuActivator
            _Log(fnName, "MyLinkedParent=" + MyLinkedParent, LL_DEBUG)
            If MyLinkedParent == None
                ; not linked to another kiosk
                ; create vendor
                MyVendor = PlaceAtMe(ShipbuilderVendor, abInitiallyDisabled=true) as ShipVendorScript
                ; link to landing marker and reinitialize
                _Log(fnName, "MyVendor=" + MyVendor, LL_DEBUG)
                MyVendor.Initialize(GetLinkedRef())
            EndIf
        EndIf
        initialized = true
    EndIf

    _Log(fnName, "end", LL_DEBUG)
EndEvent


Event OnActivate(ObjectReference akActionRef)
    string fnName = "OnActivate"
    _Log(fnName, "begin", LL_DEBUG)
    _Log(fnName, "action ref " + akActionRef, LL_DEBUG)

    If akActionRef == Game.GetPlayer()
        ShipVendorScript theShipServicesActor = MyVendor
        If theShipServicesActor == None
            _Log(fnName, "trying to get my vendor from linked parent", LL_DEBUG)
            ; get it from my linked kiosk
            theShipServicesActor = MyLinkedParent.MyVendor
        EndIf
        _Log(fnName, "theShipServicesActor=" + theShipServicesActor, LL_DEBUG)
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

    _Log(fnName, "end", LL_DEBUG)
EndEvent
