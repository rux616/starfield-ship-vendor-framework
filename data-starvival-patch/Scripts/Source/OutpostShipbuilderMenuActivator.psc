ScriptName OutpostShipbuilderMenuActivator Extends OutpostEventHandlerParent

; vanilla properties
; ------------------
Message Property OutpostShipbuilderMessage Auto Const Mandatory
{ message box listing options}

ActorBase Property OutpostShipbuilderVendor Auto Const Mandatory
{ vendor to create when built }

ShipVendorScript Property MyVendor Auto Hidden

; starvival properties
; --------------------
Quest Property QuestSpaceshipSystems Auto Const
Actor Property PlayerRef Auto Const
ActorValue Property SpaceshipTotalFuelAmountBase Auto Const
ActorValue Property AV_RoverFuel Auto Const
ActorValue Property AV_RoverMaintenance Auto Const
ActorValue Property SpaceshipHealth Auto Const
ActorValue Property SpaceshipWeaponHealth Auto Const
ActorValue Property SpaceshipWeaponHealth02 Auto Const
ActorValue Property SpaceshipWeaponHealth03 Auto Const
ActorValue Property SpaceshipShieldHealth Auto Const
ActorValue Property SpaceshipSystemEngineHealth Auto Const
ActorValue Property SpaceshipSystemGravDriveHealth Auto Const
Message Property MSG_SpaceshipMenuRefuel Auto Const
Message Property MSG_SpaceshipMenuRepair Auto Const
Message Property MSG_SpaceshipTechnicianMenuNotEnoughCredits Auto Const
Message Property MSG_VehicleMenuRefuel Auto Const
Message Property MSG_VehicleMenuRepair Auto Const
Message Property MSG_RoverFuelNotEnoughCredits Auto Const
Message Property MSG_RoverRepairNotEnoughCredits Auto Const
GlobalVariable Property GV_TechVendorCreditsRefresh Auto Const
GlobalVariable Property ShipServicesFuelCost Auto Const
GlobalVariable Property ShipServicesRepairCost Auto Const
GlobalVariable Property ShipServicesFuelStandby Auto Const
GlobalVariable Property ShipServicesMaintenanceAtWork Auto Const
GlobalVariable Property GV_RoverFuelPriceMult Auto Const
GlobalVariable Property GV_RoverRepairPriceMult Auto Const
ConditionForm Property ConditionFormFuelDiscount01 Auto Const Mandatory
ConditionForm Property ConditionFormFuelDiscount02 Auto Const Mandatory
ConditionForm Property ConditionFormFuelDiscount03 Auto Const Mandatory
ConditionForm Property ConditionFormFuelDiscount04 Auto Const Mandatory
MiscObject Property Credits Auto Const
MiscObject Property MaintenanceKit Auto Const
Weapon Property MiscObj_RoverFuel Auto Const
Weapon Property MiscObj_RoverMaintenanceKit Auto Const
Potion Property Pot_AdditionalTriggersRefuel Auto Const
Potion Property Pot_AdditionalTriggersRepair Auto Const
LeveledItem Property CreditsLeveledList Auto Const
ObjectReference Property TechVendorChest Auto Const
ObjectReference Property TechnicianTerminalRef Auto Const
SQ_PlayerShipScript Property SQ_PlayerShip Auto Const Mandatory

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
    ShipVendorFramework:SVF_Utility.Log("OutpostShipbuilderMenuActivator", Self, asFunctionName, asLogMessage, aiLogLevel, LOG_LEVEL_THRESHOLD)
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
            ShipVendorFramework:SVF_DataStructures:ShipVendorStatus vendorStatus
            int messageIndex = OutpostShipbuilderMessage.Show()
            If messageIndex == 0
                ; gate the menu opening on the vendor being fully initialized
                vendorStatus = theShipServicesActor.GetStatus()
                _Log(fnName, "vendor status: " + theShipServicesActor.GetStatusText(vendorStatus), LL_INFO)
                If vendorStatus.IsReady == false
                    If vendorStatus.IsFullyInitialized == false && vendorStatus.IsFunctionRunning == false
                        theShipServicesActor.Initialize(theShipServicesActor.MyLandingMarker)
                    EndIf
                    Return
                EndIf
                ; first apply starvival's credits refresh, then apply the SVF rich ship vendor adjustment
                TechVendorCreditsRefresh()
                theShipServicesActor.ApplyRichShipVendorCreditAdjustment()
                theShipServicesActor.MyLandingMarker.ShowHangarMenu(0, theShipServicesActor, abOpenToAvailableTab=false)
            ElseIf messageIndex == 1
                ; gate the menu opening on the vendor being fully initialized
                vendorStatus = theShipServicesActor.GetStatus()
                _Log(fnName, "vendor status: " + theShipServicesActor.GetStatusText(vendorStatus), LL_INFO)
                If vendorStatus.IsReady == false
                    If vendorStatus.IsFullyInitialized == false && vendorStatus.IsFunctionRunning == false
                        theShipServicesActor.Initialize(theShipServicesActor.MyLandingMarker)
                    EndIf
                    Return
                EndIf
                ; first apply starvival's credits refresh, then apply the SVF rich ship vendor adjustment
                TechVendorCreditsRefresh()
                theShipServicesActor.ApplyRichShipVendorCreditAdjustment()
                theShipServicesActor.MyLandingMarker.ShowHangarMenu(0, theShipServicesActor, abOpenToAvailableTab=true)
            ElseIf messageIndex == 2
                theShipServicesActor.MyLandingMarker.ShowHangarMenu(1, theShipServicesActor)
            ElseIf messageIndex == 3
                ShipTechnicianMenuRefuel()
            ElseIf messageIndex == 4
                ShipTechnicianMenuRepair()
            ElseIf messageIndex == 5
                VehicleMenuRefuel()
            ElseIf messageIndex == 6
                VehicleMenuRepair()
            ElseIf messageIndex == 7
                theShipServicesActor.ShowBarterMenu()
            EndIf
        EndIf
    EndIf

    _Log(fnName, "end", LL_DEBUG)
EndEvent


Function ShipTechnicianMenuRefuel(Int MenuType = 0, Int Button = 0, Bool MenuOpened = True)
    While MenuOpened
        If Button == -1
            ; do nothing
	    ElseIf MenuType == 0
			SpaceShipReference akShip = SQ_PlayerShip.PlayerShip.GetShipRef()
			Float FuelTankAmount = akShip.GetBaseValue(SpaceshipTotalFuelAmountBase)
			Float TotalFuelInTheTank = akShip.GetValue(SpaceshipTotalFuelAmountBase)
			Float CalculateFuel = TotalFuelInTheTank / FuelTankAmount * 100
			(QuestSpaceshipSystems as SISA_SpaceshipFuel).CalculateFuelCost()
			Utility.Wait(0.01)

			Button = MSG_SpaceshipMenuRefuel.Show(ShipServicesFuelCost.GetValueInt(), CalculateFuel, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
            If Button == 0
                If PlayerRef.GetItemCount(Credits) >= ShipServicesFuelCost.GetValueInt()
                    PlayerRef.RemoveItem(Credits, ShipServicesFuelCost.GetValueInt(), False, None)
                    ShipServicesFuelStandby.SetValue(1)
                    MenuOpened = False
                    (QuestSpaceshipSystems as SISA_SpaceshipFuel).RefuelAtShipService()
                Else
                    MSG_SpaceshipTechnicianMenuNotEnoughCredits.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0)
                EndIf
            ElseIf Button == 1
                ; Exit
                MenuOpened = False
            EndIf
        EndIf
    EndWhile
EndFunction


Function ShipTechnicianMenuRepair(Int MenuType = 0, Int Button = 0, Bool MenuOpened = True)
    While MenuOpened
        If Button == -1
            ; do nothing
        ElseIf MenuType == 0
            ActorValue CheckMaintenanceClass = (QuestSpaceshipSystems as SISA_SpaceshipFuel).SetProperMaitenanceClass()
            SpaceShipReference akShip = SQ_PlayerShip.PlayerShip.GetShipRef()
            Float MaintenanceValues = PlayerRef.GetValue(CheckMaintenanceClass)
            Float MaintenanceValuesMax = PlayerRef.GetBaseValue(CheckMaintenanceClass)
            Float CalculateMaintenance = MaintenanceValues / MaintenanceValuesMax * 100
            Float CalculateHull = akShip.GetValue(SpaceshipHealth) / akShip.GetBaseValue(SpaceshipHealth) * 100
            Float CalculateWeaponHealthInPercent01 = akShip.GetValue(SpaceshipWeaponHealth) / akShip.GetBaseValue(SpaceshipWeaponHealth) * 100
            Float CalculateWeaponHealthInPercent02 = akShip.GetValue(SpaceshipWeaponHealth02) / akShip.GetBaseValue(SpaceshipWeaponHealth02) * 100
            Float CalculateWeaponHealthInPercent03 = akShip.GetValue(SpaceshipWeaponHealth03) / akShip.GetBaseValue(SpaceshipWeaponHealth03) * 100
            Float CalculateEngineHealthInPercent = akShip.GetValue(SpaceshipSystemEngineHealth) / akShip.GetBaseValue(SpaceshipSystemEngineHealth) * 100
            Float CalculateShieldHealthInPercent = akShip.GetValue(SpaceshipShieldHealth) / akShip.GetBaseValue(SpaceshipShieldHealth) * 100
            Float CalculateGravDriveHealthInPercent = akShip.GetValue(SpaceshipSystemGravDriveHealth) / akShip.GetBaseValue(SpaceshipSystemGravDriveHealth) * 100

            (QuestSpaceshipSystems as SISA_SpaceshipFuel).CalculateRepairCost()
            Utility.Wait(0.01)

            Button = MSG_SpaceshipMenuRepair.Show(ShipServicesRepairCost.GetValueInt(), CalculateMaintenance, CalculateHull, CalculateWeaponHealthInPercent01, CalculateWeaponHealthInPercent02, CalculateWeaponHealthInPercent03, CalculateEngineHealthInPercent, CalculateShieldHealthInPercent, CalculateGravDriveHealthInPercent)
            If Button == 0
                If PlayerRef.GetItemCount(Credits) >= ShipServicesRepairCost.GetValueInt()
                    PlayerRef.RemoveItem(Credits, ShipServicesRepairCost.GetValueInt(), False, None)
                    If akShip.GetItemCount(MaintenanceKit) > 0
                        akShip.RemoveItem(MaintenanceKit, 1, False, None)
                    EndIf
                    ShipServicesMaintenanceAtWork.SetValue(1)
                    (QuestSpaceshipSystems as SISA_SpaceshipFuel).MaintenanceAtShipService()
                    MenuOpened = False
                Else
                    MSG_SpaceshipTechnicianMenuNotEnoughCredits.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0)
                EndIf
            ElseIf Button == 1
                TechnicianTerminalRef.Activate(PlayerRef, False)
            ElseIf Button == 2
                ; Exit
                MenuOpened = False
            EndIf
        EndIf
    EndWhile
EndFunction


Function VehicleMenuRefuel(Int MenuType = 0, Int Button = 0, Bool MenuOpened = True)
    While MenuOpened
        If Button == -1
            ; do nothing
        ElseIf MenuType == 0
            Float DiscountCalculate = DiscountCost()
            Float fuelCostPerUnit = MiscObj_RoverFuel.GetGoldValue() * GV_RoverFuelPriceMult.GetValue()
            Float FuelAmount = 0.0
            Float FinalCostFuel = 0.0
            FuelAmount = PlayerRef.GetBaseValue(AV_RoverFuel) - PlayerRef.GetValue(AV_RoverFuel)
            FinalCostFuel = Math.Round(FuelAmount * fuelCostPerUnit / DiscountCalculate) as Float
            Float FuelTankVehicleAmount = PlayerRef.GetBaseValue(AV_RoverFuel)
            Float TotalFuelInTheVehicleTank = PlayerRef.GetValue(AV_RoverFuel)
            Float CalculateVehicleFuel = TotalFuelInTheVehicleTank / FuelTankVehicleAmount * 100

            Button = MSG_VehicleMenuRefuel.Show(FinalCostFuel, CalculateVehicleFuel, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
            If Button == 0
                If PlayerRef.GetItemCount(Credits) >= FinalCostFuel
                    PlayerRef.RemoveItem(Credits, FinalCostFuel as int, False, None)
                    PlayerRef.EquipItem(Pot_AdditionalTriggersRefuel, False, True)
                    MenuOpened = False
                Else
                    MSG_RoverFuelNotEnoughCredits.show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
                EndIf
            ElseIf Button == 1
                ; Exit
                MenuOpened = False
            EndIf
        EndIf
    EndWhile
EndFunction


Function VehicleMenuRepair(Int MenuType = 0, Int Button = 0, Bool MenuOpened = True)
    While MenuOpened
        If Button == -1
            ; do nothing
        ElseIf MenuType == 0
            Float DiscountCalculate = DiscountCost()
            Float MaintenanceCostPerUnit = MiscObj_RoverMaintenanceKit.GetGoldValue() / 25 * GV_RoverRepairPriceMult.GetValue()
            Float RepairAmount = 0.0
            Float FinalCostRepair = 0.0
            RepairAmount = PlayerRef.GetBaseValue(AV_RoverMaintenance) - PlayerRef.GetValue(AV_RoverMaintenance)
            FinalCostRepair = Math.Round(RepairAmount * MaintenanceCostPerUnit / DiscountCalculate) as Float
            Float MaintenanceVehicleAmount = PlayerRef.GetBaseValue(AV_RoverMaintenance)
            Float TotalVehicleMaintenanceAvailable = PlayerRef.GetValue(AV_RoverMaintenance)
            Float CalculateVehicleMaintenance = TotalVehicleMaintenanceAvailable / MaintenanceVehicleAmount * 100

            Button = MSG_VehicleMenuRepair.Show(FinalCostRepair, CalculateVehicleMaintenance, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
            If Button == 0
                If PlayerRef.GetItemCount(Credits) >= FinalCostRepair
                    PlayerRef.RemoveItem(Credits, FinalCostRepair as int, False, None)
                    PlayerRef.EquipItem(Pot_AdditionalTriggersRepair, False, True)
                    MenuOpened = False
                Else
                    MSG_RoverRepairNotEnoughCredits.show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
                EndIf
            ElseIf Button == 1
                ; Exit
                MenuOpened = False
            EndIf
        EndIf
    EndWhile
EndFunction


Float Function DiscountCost()
    Float DiscountPercent00 = 1.00
    Float DiscountPercent01 = 1.15
    Float DiscountPercent02 = 1.25
    Float DiscountPercent03 = 1.35
    Float DiscountPercent04 = 1.50

    If ConditionFormFuelDiscount04.IsTrue(PlayerRef, None)
        Return DiscountPercent04
    ElseIf ConditionFormFuelDiscount03.IsTrue(PlayerRef, None)
        Return DiscountPercent03
    ElseIf ConditionFormFuelDiscount02.IsTrue(PlayerRef, None)
        Return DiscountPercent02
    ElseIf ConditionFormFuelDiscount01.IsTrue(PlayerRef, None)
        Return DiscountPercent01
    Else
        Return DiscountPercent00
    EndIf
EndFunction


Function TechVendorCreditsRefresh()
    Int CreditsThreshold = GV_TechVendorCreditsRefresh.GetValue() As Int

    If TechVendorChest.GetItemCount(Credits) < CreditsThreshold
        TechVendorChest.RemoveItem(Credits, 999999999, True, None)
        TechVendorChest.AddItem(CreditsLeveledList, 1, True)
    EndIf
EndFunction
