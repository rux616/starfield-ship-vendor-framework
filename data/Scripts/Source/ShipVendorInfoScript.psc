ScriptName ShipVendorInfoScript Extends TopicInfo Const

bool Property OpenToShipForSale = false Auto Const

Event OnEnd(ObjectReference akSpeakerRef, bool abHasBeenSaid)
	Debug.Trace(Self + "try to show hangar menu for speaker " + akSpeakerRef)
	; if we're calling this on the player, grab whoever the player is talking to and show menu, otherwise just show menu
	If Utility.IsGameMenuPaused() == false
        SQ_ShipServicesActorScript theVendor
		If akSpeakerRef == Game.GetPlayer()
            theVendor = (akSpeakerRef as Actor).GetDialogueTarget() as SQ_ShipServicesActorScript
		Else
            theVendor = akSpeakerRef as SQ_ShipServicesActorScript
		EndIf
        If theVendor && theVendor.MyLandingMarker
        	Debug.Trace(Self + "showing ship hangar menu: landing marker=" + theVendor.MyLandingMarker + ", vendor=" + theVendor)
			; wait a second to allow the audio to finish
    	    Utility.Wait(0.2)
            ; TODO this needs to have a "please wait, initializing" message gate --->
			SpaceshipReference shipForSale = NONE
			if OpenToShipForSale
				shipForSale = theVendor.GetShipForSale()
			endif
           	theVendor.MyLandingMarker.ShowHangarMenu(0, theVendor, shipForSale, OpenToShipForSale)
            ; TODO <--- this needs to have a "please wait, initializing" message gate
        endif
	endif
endEvent
