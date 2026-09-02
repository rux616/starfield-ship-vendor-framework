ScriptName ShipVendorInfoScript Extends TopicInfo Const

; vanilla properties
; ------------------
Bool Property OpenToShipForSale = False Auto Const

; starvival properties
; --------------------
GlobalVariable Property GV_TechVendorCreditsRefresh Auto Const
MiscObject Property Credits Auto Const
LeveledItem Property CreditsLeveledList Auto Const
ObjectReference Property TechVendorChest01 Auto Const
ObjectReference Property TechVendorChest02 Auto Const
ObjectReference Property TechVendorChest03 Auto Const
ObjectReference Property TechVendorChest04 Auto Const
ObjectReference Property TechVendorChest05 Auto Const
ObjectReference Property TechVendorChest06 Auto Const
ObjectReference Property TechVendorChest07 Auto Const
ObjectReference Property TechVendorChest08 Auto Const
ObjectReference Property TechVendorChest09 Auto Const
ObjectReference Property TechVendorChest10 Auto Const
ObjectReference Property TechVendorChest11 Auto Const
ObjectReference Property TechVendorChest12 Auto Const
ObjectReference Property TechVendorChest13 Auto Const
ObjectReference Property TechVendorChest14 Auto Const
ObjectReference Property TechVendorChest15 Auto Const
ObjectReference Property TechVendorChest16 Auto Const

; ship vendor framework properties
; --------------------------------
; the log level threshold for the script; messages with a level less than this threshold will not be logged
; -1 = debug (all), 0 = info (default), 1 = warning, 2 = error, 3 = none (suppress)
int Property LOG_LEVEL_THRESHOLD = 0 Auto Const Hidden

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
    ShipVendorFramework:SVF_Utility.Log("ShipVendorInfoScript", Self, asFunctionName, asLogMessage, aiLogLevel, LOG_LEVEL_THRESHOLD)
EndFunction


Event OnEnd(ObjectReference akSpeakerRef, Bool abHasBeenSaid)
    string fnName = "OnEnd"
    _Log(fnName, "begin", LL_DEBUG)

    _Log(fnName, "try to show hangar menu for speaker " + akSpeakerRef, LL_DEBUG)
    ; if we're calling this on the player, grab whoever the player is talking to and show menu, otherwise just show menu
    If Utility.IsGameMenuPaused() == False
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
            _Log(fnName, "{Starvival} vendor status: " + theVendor.GetStatusText(vendorStatus), LL_INFO)
            If vendorStatus.IsReady == false
                Return
            EndIf
            ; first apply starvival's credits refresh, then apply the SVF rich ship vendor adjustment
            TechVendorCreditsRefresh()
            theVendor.ApplyRichShipVendorCreditAdjustment()
            SpaceshipReference shipForSale = None
            If OpenToShipForSale
                shipForSale = theVendor.GetShipForSale(0)
            EndIf
            theVendor.myLandingMarker.ShowHangarMenu(0, theVendor as Actor, shipForSale, OpenToShipForSale)
        EndIf
    EndIf
EndEvent


Function TechVendorCreditsRefresh()
    Int CreditsThreshold = GV_TechVendorCreditsRefresh.GetValue() As Int

    If TechVendorChest01.GetItemCount(Credits) < CreditsThreshold
        TechVendorChest01.RemoveItem(Credits, 999999999, True, None)
        TechVendorChest01.AddItem(CreditsLeveledList, 1, True)
    EndIf

    If TechVendorChest02.GetItemCount(Credits) < CreditsThreshold
        TechVendorChest02.RemoveItem(Credits, 999999999, True, None)
        TechVendorChest02.AddItem(CreditsLeveledList, 1, True)
    EndIf

    If TechVendorChest03.GetItemCount(Credits) < CreditsThreshold
        TechVendorChest03.RemoveItem(Credits, 999999999, True, None)
        TechVendorChest03.AddItem(CreditsLeveledList, 1, True)
    EndIf

    If TechVendorChest04.GetItemCount(Credits) < CreditsThreshold
        TechVendorChest04.RemoveItem(Credits, 999999999, True, None)
        TechVendorChest04.AddItem(CreditsLeveledList, 1, True)
    EndIf

    If TechVendorChest05.GetItemCount(Credits) < CreditsThreshold
        TechVendorChest05.RemoveItem(Credits, 999999999, True, None)
        TechVendorChest05.AddItem(CreditsLeveledList, 1, True)
    EndIf

    If TechVendorChest06.GetItemCount(Credits) < CreditsThreshold
        TechVendorChest06.RemoveItem(Credits, 999999999, True, None)
        TechVendorChest06.AddItem(CreditsLeveledList, 1, True)
    EndIf

    If TechVendorChest07.GetItemCount(Credits) < CreditsThreshold
        TechVendorChest07.RemoveItem(Credits, 999999999, True, None)
        TechVendorChest07.AddItem(CreditsLeveledList, 1, True)
    EndIf

    If TechVendorChest08.GetItemCount(Credits) < CreditsThreshold
        TechVendorChest08.RemoveItem(Credits, 999999999, True, None)
        TechVendorChest08.AddItem(CreditsLeveledList, 1, True)
    EndIf

    If TechVendorChest09.GetItemCount(Credits) < CreditsThreshold
        TechVendorChest09.RemoveItem(Credits, 999999999, True, None)
        TechVendorChest09.AddItem(CreditsLeveledList, 1, True)
    EndIf

    If TechVendorChest10.GetItemCount(Credits) < CreditsThreshold
        TechVendorChest10.RemoveItem(Credits, 999999999, True, None)
        TechVendorChest10.AddItem(CreditsLeveledList, 1, True)
    EndIf

    If TechVendorChest11.GetItemCount(Credits) < CreditsThreshold
        TechVendorChest11.RemoveItem(Credits, 999999999, True, None)
        TechVendorChest11.AddItem(CreditsLeveledList, 1, True)
    EndIf

    If TechVendorChest12.GetItemCount(Credits) < CreditsThreshold
        TechVendorChest12.RemoveItem(Credits, 999999999, True, None)
        TechVendorChest12.AddItem(CreditsLeveledList, 1, True)
    EndIf

    If TechVendorChest13.GetItemCount(Credits) < CreditsThreshold
        TechVendorChest13.RemoveItem(Credits, 999999999, True, None)
        TechVendorChest13.AddItem(CreditsLeveledList, 1, True)
    EndIf

    If TechVendorChest14.GetItemCount(Credits) < CreditsThreshold
        TechVendorChest14.RemoveItem(Credits, 999999999, True, None)
        TechVendorChest14.AddItem(CreditsLeveledList, 1, True)
    EndIf

    If TechVendorChest15.GetItemCount(Credits) < CreditsThreshold
        TechVendorChest15.RemoveItem(Credits, 999999999, True, None)
        TechVendorChest15.AddItem(CreditsLeveledList, 1, True)
    EndIf

    If TechVendorChest16.GetItemCount(Credits) < CreditsThreshold
        TechVendorChest16.RemoveItem(Credits, 999999999, True, None)
        TechVendorChest16.AddItem(CreditsLeveledList, 1, True)
    EndIf
EndFunction
