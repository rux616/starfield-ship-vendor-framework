ScriptName ShipVendorInfoScript Extends TopicInfo Const

bool Property OpenToShipForSale = false Auto Const

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
Function _Log(string asFunctionName, string asLogMessage, int aiSeverity)
    ShipVendorFramework:SVF_Utility.Log("ShipVendorInfoScript", GetFormID(), asFunctionName, asLogMessage, aiSeverity, LogLevel)
EndFunction


Event OnEnd(ObjectReference akSpeakerRef, bool abHasBeenSaid)
	string fnName = "OnEnd"
	_Log(fnName, "begin", LL_DEBUG)

	_Log(fnName, "try to show hangar menu for speaker " + akSpeakerRef, LL_DEBUG)
	; if we're calling this on the player, grab whoever the player is talking to and show menu, otherwise just show menu
	If Utility.IsGameMenuPaused() == false
        SQ_ShipServicesActorScript theVendor
		If akSpeakerRef == Game.GetPlayer()
            theVendor = (akSpeakerRef as Actor).GetDialogueTarget() as SQ_ShipServicesActorScript
		Else
            theVendor = akSpeakerRef as SQ_ShipServicesActorScript
		EndIf
        If theVendor && theVendor.MyLandingMarker
        	_Log(fnName, "showing ship hangar menu: landing marker=" + theVendor.MyLandingMarker + ", vendor=" + theVendor, LL_DEBUG)
			; wait a second to allow the audio to finish
    	    Utility.Wait(0.2)
            ; TODO this needs to have a "please wait, initializing" message gate --->
			SpaceshipReference shipForSale = NONE
			If OpenToShipForSale
				shipForSale = theVendor.GetShipForSale()
			EndIf
			theVendor.ApplyRichShipVendorCreditAdjustment()
           	theVendor.MyLandingMarker.ShowHangarMenu(0, theVendor, shipForSale, OpenToShipForSale)
            ; TODO <--- this needs to have a "please wait, initializing" message gate
        EndIf
	EndIf

	_Log(fnName, "end", LL_DEBUG)
EndEvent
