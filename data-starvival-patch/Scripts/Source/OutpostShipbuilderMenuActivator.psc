ScriptName OutpostShipbuilderMenuActivator Extends OutpostEventHandlerParent

Quest Property QuestSpaceshipSystems Auto Const
Actor Property PlayerRef Auto Const
ActorBase Property OutpostShipbuilderVendor Auto Const mandatory
ActorValue Property SpaceshipTotalFuelAmountBase Auto Const
ActorValue Property AV_RoverFuel Auto Const
ActorValue Property AV_RoverMaintenance Auto Const
ActorValue Property SpaceshipHealth Auto Const
ActorValue Property SpaceshipWeaponHealth Auto Const
ActorValue Property SpaceshipWeaponHealth02 Auto Const
ActorValue Property SpaceshipWeaponHealth03 Auto Const
ActorValue Property SpaceshipShieldHealth Auto Const
ActorValue Property SpaceshipSystemEngineHealth Auto Const
ActorValue Property SpaceshipSystemGravdriveHealth Auto Const
Message Property OutpostShipbuilderMessage Auto Const mandatory
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
Conditionform Property ConditionFormFuelDiscount01 Auto Const Mandatory
Conditionform Property ConditionFormFuelDiscount02 Auto Const Mandatory
Conditionform Property ConditionFormFuelDiscount03 Auto Const Mandatory
Conditionform Property ConditionFormFuelDiscount04 Auto Const Mandatory
MiscObject Property Credits Auto Const
MiscObject Property MiscObj_RoverFuel Auto Const
MiscObject Property MiscObj_RoverMaintenanceKit Auto Const
Potion Property Pot_AdditionalTriggersRefuel Auto Const
Potion Property Pot_AdditionalTriggersRepair Auto Const
LeveledItem Property CreditsLeveledList Auto Const
shipvendorscript Property myVendor Auto hidden
ObjectReference Property TechVendorChest Auto Const
sq_playershipscript Property SQ_PlayerShip Auto Const mandatory

Function HandleOnWorkshopObjectPlaced(ObjectReference akReference)
  myVendor = Self.PlaceAtMe(OutpostShipbuilderVendor as Form, 1, False, True, True, None, None, True) as shipvendorscript
  ObjectReference myLandingMarker = Self.GetLinkedRef(None)
  myVendor.Initialize(myLandingMarker)
EndFunction

Function HandleOnWorkshopObjectRemoved(ObjectReference akReference)
  If myVendor
    myVendor.Delete()
    myVendor = None
  EndIf
EndFunction

Event OnActivate(ObjectReference akActionRef)
  If akActionRef == Game.GetPlayer() as ObjectReference
    shipvendorscript theShipServicesActor = myVendor
    If theShipServicesActor
      If theShipServicesActor.myLandingMarker == NONE
        theShipServicesActor.myLandingMarker = GetLinkedRef()
      EndIf
      Int messageIndex = OutpostShipbuilderMessage.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
      If messageIndex == 0
        TechVendorCreditsRefresh()
		theShipServicesActor.myLandingMarker.ShowHangarMenu(0, theShipServicesActor as Actor, None, False)
      ElseIf messageIndex == 1
           TechVendorCreditsRefresh()
           If theShipServicesActor.SVFEnhancementsInitialized() == False
              theShipServicesActor.Initialize(theShipServicesActor.myLandingMarker)
        EndIf
		   theShipServicesActor.myLandingMarker.ShowHangarMenu(0, theShipServicesActor as Actor, None, True)
      ElseIf messageIndex == 2
        theShipServicesActor.myLandingMarker.ShowHangarMenu(1, theShipServicesActor)
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
       endif
    EndIf
  EndIf
EndEvent

Function ShipTechnicianMenuRefuel(Int MenuType = 0, Int Button = 0, Bool MenuOpened = True)
  
  While MenuOpened		 			 
		 
		 If Button == -1		 

                 
	 ElseIf MenuType == 0
		    
			SpaceShipReference akShip = SQ_PlayerShip.PlayerShip.GetShipRef()			
			
			(QuestSpaceshipSystems as SISA_SpaceshipFuel).CalculateFuelCost()			   		
			Utility.Wait(0.01)
			Button = MSG_SpaceshipMenuRefuel.Show(ShipServicesFuelCost.GetValueInt(), akShip.GetValue(SpaceshipTotalFuelAmountBase), akShip.GetBaseValue(SpaceshipTotalFuelAmountBase), 0.0, 0.0, 0.0, 0.0, 0.0)	 
                   
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
                      ; Empty			   
                         			   	   			   
			   ElseIf Button == 2 
				      ; Exit
				      MenuOpened = False
				EndIf
      EndIf

EndWhile
EndFunction

Function ShipTechnicianMenuRepair(Int MenuType = 0, Int Button = 0, Bool MenuOpened = True)
  
  While MenuOpened		 			 
		 
		 If Button == -1		 

                 
	 ElseIf MenuType == 0
		    
			ActorValue CheckMaintenanceClass = (QuestSpaceshipSystems as SISA_SpaceshipFuel).SetProperMaitenanceClass()
			SpaceShipReference ShipValuesCheck = (QuestSpaceshipSystems as SISA_SpaceshipFuel).SetProperShipReferenceForDataView()
			Float MaintenanceValues = PlayerRef.GetValue(CheckMaintenanceClass)
            Float MaintenanceValuesMax = PlayerRef.GetBaseValue(CheckMaintenanceClass)			
			Float CalculateMaintenance = MaintenanceValues / MaintenanceValuesMax * 100
			Float CalculateHull = ShipValuesCheck.GetValue(SpaceshipHealth) / ShipValuesCheck.GetBaseValue(SpaceshipHealth) * 100
			Float CalculateWeaponHealthInPercent01 = ShipValuesCheck.GetValue(SpaceshipWeaponHealth) / ShipValuesCheck.GetBaseValue(SpaceshipWeaponHealth) * 100
            Float CalculateWeaponHealthInPercent02 = ShipValuesCheck.GetValue(SpaceshipWeaponHealth02) / ShipValuesCheck.GetBaseValue(SpaceshipWeaponHealth02) * 100
            Float CalculateWeaponHealthInPercent03 = ShipValuesCheck.GetValue(SpaceshipWeaponHealth03) / ShipValuesCheck.GetBaseValue(SpaceshipWeaponHealth03) * 100
            Float CalculateEngineHealthInPercent = ShipValuesCheck.GetValue(SpaceshipSystemEngineHealth) / ShipValuesCheck.GetBaseValue(SpaceshipSystemEngineHealth) * 100
            Float CalculateShieldHealthInPercent = ShipValuesCheck.GetValue(SpaceshipShieldHealth) / ShipValuesCheck.GetBaseValue(SpaceshipShieldHealth) * 100
            Float CalculateGravDriveHealthInPercent = ShipValuesCheck.GetValue(SpaceshipSystemGravdriveHealth) / ShipValuesCheck.GetBaseValue(SpaceshipSystemGravdriveHealth) * 100
						   
            (QuestSpaceshipSystems as SISA_SpaceshipFuel).CalculateRepairCost()			
			Utility.Wait(0.01)
			Button = MSG_SpaceshipMenuRepair.Show(ShipServicesRepairCost.GetValueInt(), CalculateMaintenance, CalculateHull, CalculateWeaponHealthInPercent01, CalculateWeaponHealthInPercent02, CalculateWeaponHealthInPercent03, CalculateEngineHealthInPercent, CalculateShieldHealthInPercent, CalculateGravDriveHealthInPercent)	 
                   
				   If Button == 0
	                  
					       If PlayerRef.GetItemCount(Credits) >= ShipServicesRepairCost.GetValueInt()
					          PlayerRef.RemoveItem(Credits, ShipServicesRepairCost.GetValueInt(), False, None) 				
                              ShipServicesMaintenanceAtWork.SetValue(1)
							  (QuestSpaceshipSystems as SISA_SpaceshipFuel).MaintenanceAtShipService()
				              MenuOpened = False
					   Else
				              MSG_SpaceshipTechnicianMenuNotEnoughCredits.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0)
				        EndIf				   

			   ElseIf Button == 1 
                      ; Empty			   
                         			   	   			   
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
     
	 ElseIf MenuType == 0

	               Float DiscountCalculate = DiscountCost() 	      
	               
				   Float fuelCostPerUnit = MiscObj_RoverFuel.GetGoldValue() * GV_RoverFuelPriceMult.GetValue()
	               Float FuelAmount = 0.0
                   Float FinalCostFuel = 0.0					  					                   
			       FuelAmount = PlayerRef.GetBaseValue(AV_RoverFuel) - PlayerRef.GetValue(AV_RoverFuel)   
	               FinalCostFuel = Math.Round(FuelAmount * fuelCostPerUnit / DiscountCalculate) as Float		    			
			       
				   Button = MSG_VehicleMenuRefuel.Show(FinalCostFuel, PlayerRef.GetValue(AV_RoverFuel), PlayerRef.GetBaseValue(AV_RoverFuel), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)	                    				   
				   
				   If Button == 0
                                   
								If PlayerRef.GetItemCount(Credits) >= FinalCostFuel
						           PlayerRef.RemoveItem(Credits, FinalCostFuel as int, False, None)
								   PlayerRef.EquipItem(Pot_AdditionalTriggersRefuel, False, True)					       		      
                                   MenuOpened = False
							Else
					               MSG_RoverFuelNotEnoughCredits.show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)	
			                 EndIf
			   		   			   
			   ElseIf Button == 1 
                      ; Empty			   			   
			   ElseIf Button == 2 
				      ; Exit						 
				        MenuOpened = False
				EndIf
      EndIf

EndWhile
EndFunction

Function VehicleMenuRepair(Int MenuType = 0, Int Button = 0, Bool MenuOpened = True)
  
  While MenuOpened		 			 
		 
		 If Button == -1		 
     
	 ElseIf MenuType == 0

	               Float DiscountCalculate = DiscountCost() 	      
	    				      
	               Float MaintenanceCostPerUnit = MiscObj_RoverMaintenanceKit.GetGoldValue() / 25 * GV_RoverRepairPriceMult.GetValue()
	               Float RepairAmount = 0.0
                   Float FinalCostRepair = 0.0					  			
			       RepairAmount = PlayerRef.GetBaseValue(AV_RoverMaintenance) - PlayerRef.GetValue(AV_RoverMaintenance)   
	               FinalCostRepair = Math.Round(RepairAmount * MaintenanceCostPerUnit / DiscountCalculate) as Float
			       
				   Button = MSG_VehicleMenuRepair.Show(FinalCostRepair, PlayerRef.GetValue(AV_RoverMaintenance), PlayerRef.GetBaseValue(AV_RoverMaintenance), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)	                    				   
				   
				   If Button == 0
                                   
								If PlayerRef.GetItemCount(Credits) >= FinalCostRepair
						           PlayerRef.RemoveItem(Credits, FinalCostRepair as int, False, None)
								   PlayerRef.EquipItem(Pot_AdditionalTriggersRepair, False, True)				       		      
                                   MenuOpened = False
							Else
					               MSG_RoverRepairNotEnoughCredits.show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)	
			                 EndIf
        			  
			   ElseIf Button == 1 
                      ; Empty			   			   
			   ElseIf Button == 2 
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
					TechVendorChest.Removeitem(Credits, 999999999, True, None)
					TechVendorChest.Additem(CreditsLeveledList, 1, True)
			  EndIf

EndFunction