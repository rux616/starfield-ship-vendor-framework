ScriptName ShipVendorInfoScript Extends TopicInfo Const

bool Property OpenToShipForSale = false Auto Const

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
    ShipVendorFramework:SVF_Utility.Log("ShipVendorInfoScript", GetFormID(), asFunctionName, asLogMessage, aiLogLevel, LOG_LEVEL_THRESHOLD)
EndFunction


Event OnEnd(ObjectReference akSpeakerRef, bool abHasBeenSaid)
    string fnName = "OnEnd"
    _Log(fnName, "begin", LL_DEBUG)

    _Log(fnName, "try to show hangar menu for speaker " + akSpeakerRef, LL_DEBUG)
    ; if we're calling this on the player, grab whoever the player is talking to and show menu, otherwise just show menu
    If Utility.IsGameMenuPaused() == false
        SQ_ShipServicesActorScript theVendor = None
        If akSpeakerRef == Game.GetPlayer()
            theVendor = (akSpeakerRef as Actor).GetDialogueTarget() as SQ_ShipServicesActorScript
        Else
            theVendor = akSpeakerRef as SQ_ShipServicesActorScript
        EndIf
        If theVendor && theVendor.MyLandingMarker
            _Log(fnName, "showing ship hangar menu: landing marker=" + theVendor.MyLandingMarker + ", vendor=" + theVendor, LL_DEBUG)
            ; wait a second to allow the audio to finish
            Utility.Wait(0.2)
            ; gate the menu opening on the vendor being fully initialized
            ShipVendorFramework:SVF_DataStructures:ShipVendorStatus vendorStatus = theVendor.GetStatus()
            _Log(fnName, "vendor status: " + theVendor.GetStatusText(vendorStatus), LL_INFO)
            If vendorStatus.IsReady == false
                Return
            EndIf
            theVendor.ApplyRichShipVendorCreditAdjustment()
            SpaceshipReference shipForSale = None
            If OpenToShipForSale
                shipForSale = theVendor.GetShipForSale()
            EndIf
            theVendor.MyLandingMarker.ShowHangarMenu(0, theVendor, shipForSale, OpenToShipForSale)
        EndIf
    EndIf

    _Log(fnName, "end", LL_DEBUG)
EndEvent
