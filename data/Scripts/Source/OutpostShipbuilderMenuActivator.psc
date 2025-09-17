Scriptname OutpostShipbuilderMenuActivator Extends OutpostEventHandlerParent

Message Property OutpostShipbuilderMessage Auto Const Mandatory
{ message box listing options}

ActorBase Property OutpostShipbuilderVendor Auto Const Mandatory
{ vendor to create when built }

ShipVendorScript Property MyVendor Auto Hidden

; the log level threshold for the script; messages with a level less than this threshold will not be logged
; -1 = debug (all), 0 = info (default), 1 = warning, 2 = error, 3 = none (suppress)
int Property LOG_LEVEL_THRESHOLD = -1 Auto Const Hidden  ; TODO change back to 0 for release

; log levels
; "debug" log level
int Property LL_DEBUG = -1 Auto Const Hidden
; "info" log level
int Property LL_INFO = 0 Auto Const Hidden
; "warning" log level
int Property LL_WARNING = 1 Auto Const Hidden
; "error" log level
int Property LL_ERROR = 2 Auto Const Hidden


; local opinionated log function
Function _Log(string asFunctionName, string asLogMessage, int aiLogLevel)
    ShipVendorFramework:SVF_Utility.Log("OutpostShipbuilderVendor", GetFormID(), asFunctionName, asLogMessage, aiLogLevel, LOG_LEVEL_THRESHOLD)
EndFunction


; override parent function
Function HandleOnWorkshopObjectPlaced(ObjectReference akReference)
    string fnName = "HandleOnWorkshopObjectPlaced"
    _Log(fnName, "begin", LL_DEBUG)

    ; create vendor
    MyVendor = PlaceAtMe(OutpostShipbuilderVendor, abInitiallyDisabled=true) as ShipVendorScript
    ObjectReference myLandingMarker = GetLinkedRef()
    _Log(fnName, "   myLandingMarker=" + myLandingMarker, LL_DEBUG)
    ; link to landing marker and reinitialize
    MyVendor.Initialize(myLandingMarker)

    _Log(fnName, "end", LL_DEBUG)
EndFunction


; override parent function
Function HandleOnWorkshopObjectRemoved(ObjectReference akReference)
    string fnName = "HandleOnWorkshopObjectRemoved"
    _Log(fnName, "begin", LL_DEBUG)

    If MyVendor
        MyVendor.Delete()
        MyVendor = None
    EndIf

    _Log(fnName, "end", LL_DEBUG)
EndFunction


Event OnActivate(ObjectReference akActionRef)
    string fnName = "OnActivate"
    _Log(fnName, "begin", LL_DEBUG)

    _Log(fnName, "OnActivate " + akActionRef, LL_DEBUG)
    If akActionRef == Game.GetPlayer()
        ShipVendorScript theShipServicesActor = MyVendor as ShipVendorScript
        If theShipServicesActor
            ; fix if the landing marker is not set
            If theShipServicesActor.MyLandingMarker == None
                theShipServicesActor.MyLandingMarker = GetLinkedRef()
            EndIf

            int messageIndex = OutpostShipbuilderMessage.Show()
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
                theShipServicesActor.ApplyRichShipVendorCreditAdjustment()
                theShipServicesActor.MyLandingMarker.ShowHangarMenu(0, theShipServicesActor, abOpenToAvailableTab=true)
            ElseIf messageIndex == 2
                theShipServicesActor.MyLandingMarker.ShowHangarMenu(1, theShipServicesActor)
            EndIf
        EndIf
    EndIf

    _Log(fnName, "end", LL_DEBUG)
EndEvent
