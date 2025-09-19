ScriptName ShipVendorInfoScript Extends TopicInfo Const

Bool Property OpenToShipForSale = False Auto Const
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


Event OnEnd(ObjectReference akSpeakerRef, Bool abHasBeenSaid)
    If Utility.IsGameMenuPaused() == False
        sq_shipservicesactorscript theVendor = None

        If akSpeakerRef == Game.GetPlayer() as ObjectReference
            theVendor = (akSpeakerRef as Actor).GetDialogueTarget() as sq_shipservicesactorscript
        Else
            theVendor = akSpeakerRef as sq_shipservicesactorscript
            TechVendorCreditsRefresh()
        EndIf

        If theVendor as Bool && theVendor.myLandingMarker as Bool
            Utility.Wait(0.200000003)
            ; SVF addition -->
            ; gate the menu opening on the vendor being fully initialized
            ShipVendorFramework:SVF_DataStructures:ShipVendorStatus vendorStatus = theVendor.GetStatus()
            ShipVendorFramework:SVF_Utility.Log("ShipVendorInfoScript", GetFormID(), "OnEnd", "{Starvival} vendor status: " + theVendor.GetStatusText(vendorStatus), aiLogLevel=0)
            If vendorStatus.IsReady == false
                Return
            EndIf
            theVendor.ApplyRichShipVendorCreditAdjustment()
            ; SVF addition <--
            spaceshipreference shipForSale = None
            If OpenToShipForSale
                ; SVF change -->
                ; commenting out the credits refresh as that's taken care of via the rich ship vendor adjustment
                ; TechVendorCreditsRefresh()
                ; SVF change <--
                shipForSale = theVendor.GetShipForSale(0)
            EndIf
            theVendor.myLandingMarker.ShowHangarMenu(0, theVendor as Actor, shipForSale, OpenToShipForSale)
        EndIf
    EndIf
EndEvent


Function TechVendorCreditsRefresh()
    Int CreditsThreshold = GV_TechVendorCreditsRefresh.GetValue() As Int

    If TechVendorChest01.GetItemCount(Credits) < CreditsThreshold
        TechVendorChest01.Removeitem(Credits, 999999999, True, None)
        TechVendorChest01.Additem(CreditsLeveledList, 1, True)
    EndIf

    If TechVendorChest02.GetItemCount(Credits) < CreditsThreshold
        TechVendorChest02.Removeitem(Credits, 999999999, True, None)
        TechVendorChest02.Additem(CreditsLeveledList, 1, True)
    EndIf

    If TechVendorChest03.GetItemCount(Credits) < CreditsThreshold
        TechVendorChest03.Removeitem(Credits, 999999999, True, None)
        TechVendorChest03.Additem(CreditsLeveledList, 1, True)
    EndIf

    If TechVendorChest04.GetItemCount(Credits) < CreditsThreshold
        TechVendorChest04.Removeitem(Credits, 999999999, True, None)
        TechVendorChest04.Additem(CreditsLeveledList, 1, True)
    EndIf

    If TechVendorChest05.GetItemCount(Credits) < CreditsThreshold
        TechVendorChest05.Removeitem(Credits, 999999999, True, None)
        TechVendorChest05.Additem(CreditsLeveledList, 1, True)
    EndIf

    If TechVendorChest06.GetItemCount(Credits) < CreditsThreshold
        TechVendorChest06.Removeitem(Credits, 999999999, True, None)
        TechVendorChest06.Additem(CreditsLeveledList, 1, True)
    EndIf

    If TechVendorChest07.GetItemCount(Credits) < CreditsThreshold
        TechVendorChest07.Removeitem(Credits, 999999999, True, None)
        TechVendorChest07.Additem(CreditsLeveledList, 1, True)
    EndIf

    If TechVendorChest08.GetItemCount(Credits) < CreditsThreshold
        TechVendorChest08.Removeitem(Credits, 999999999, True, None)
        TechVendorChest08.Additem(CreditsLeveledList, 1, True)
    EndIf

    If TechVendorChest09.GetItemCount(Credits) < CreditsThreshold
        TechVendorChest09.Removeitem(Credits, 999999999, True, None)
        TechVendorChest09.Additem(CreditsLeveledList, 1, True)
    EndIf

    If TechVendorChest10.GetItemCount(Credits) < CreditsThreshold
        TechVendorChest10.Removeitem(Credits, 999999999, True, None)
        TechVendorChest10.Additem(CreditsLeveledList, 1, True)
    EndIf

    If TechVendorChest11.GetItemCount(Credits) < CreditsThreshold
        TechVendorChest11.Removeitem(Credits, 999999999, True, None)
        TechVendorChest11.Additem(CreditsLeveledList, 1, True)
    EndIf

    If TechVendorChest12.GetItemCount(Credits) < CreditsThreshold
        TechVendorChest12.Removeitem(Credits, 999999999, True, None)
        TechVendorChest12.Additem(CreditsLeveledList, 1, True)
    EndIf

    If TechVendorChest13.GetItemCount(Credits) < CreditsThreshold
        TechVendorChest13.Removeitem(Credits, 999999999, True, None)
        TechVendorChest13.Additem(CreditsLeveledList, 1, True)
    EndIf

    If TechVendorChest14.GetItemCount(Credits) < CreditsThreshold
        TechVendorChest14.Removeitem(Credits, 999999999, True, None)
        TechVendorChest14.Additem(CreditsLeveledList, 1, True)
    EndIf

    If TechVendorChest15.GetItemCount(Credits) < CreditsThreshold
        TechVendorChest15.Removeitem(Credits, 999999999, True, None)
        TechVendorChest15.Additem(CreditsLeveledList, 1, True)
    EndIf

    If TechVendorChest16.GetItemCount(Credits) < CreditsThreshold
        TechVendorChest16.Removeitem(Credits, 999999999, True, None)
        TechVendorChest16.Additem(CreditsLeveledList, 1, True)
    EndIf
EndFunction
