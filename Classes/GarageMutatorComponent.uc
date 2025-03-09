class GarageMutatorComponent extends GGMutatorComponent;

var GGGoat gMe;
var GGMutator myMut;

var class<GGSVehicle> mCurrClass;
var array<GGSVehicle> mVehicles;

var bool mRagdollPressed;

/**
 * See super.
 */
function AttachToPlayer( GGGoat goat, optional GGMutator owningMutator )
{
	super.AttachToPlayer(goat, owningMutator);

	if(mGoat != none)
	{
		gMe=goat;
		myMut=owningMutator;
	}
}

function KeyState( name newKey, EKeyState keyState, PlayerController PCOwner )
{
	local GGPlayerInputGame localInput;

	if(PCOwner != gMe.Controller && PCOwner != gMe.DrivenVehicle.Controller)
		return;

	localInput = GGPlayerInputGame( PCOwner.PlayerInput );

	if( keyState == KS_Down )
	{
		if(newKey == 'LEFTCONTROL' || newKey == 'XboxTypeS_DPad_Down')
		{
			if(mRagdollPressed || gMe.mIsRagdoll)
			{
				SwitchVehicle();// Ctrl + Ragdoll Key or is Ragdoll
			}

		}

		if(localInput.IsKeyIsPressed("RightMouseButton", string( newKey ))|| newKey == 'XboxTypeS_LeftTrigger')
		{
			SetVehicle();// Lick + Right Click
		}

		if(localInput.IsKeyIsPressed("GBA_Special", string( newKey )))
		{
			if(gMe.Controller != none
			&& GGPlayerControllerGame( gMe.Controller ).mFreeLook
			&& IsZero(gMe.Velocity)
			&& !gMe.mIsRagdoll)
			{
				GetVehicle();// Right Click + R + Immobil + Not Ragdoll
			}
		}

		if((!GGLocalPlayer(PCOwner.Player).mIsUsingGamePad && localInput.IsKeyIsPressed("GBA_ToggleRagdoll", string( newKey )))
		|| newKey == 'XboxTypeS_RightShoulder')
		{
			if(gMe.DrivenVehicle != none)
			{
				SwitchVehicleColor();
			}
		}

		if(localInput.IsKeyIsPressed("GBA_ToggleRagdoll", string( newKey )))
		{
			mRagdollPressed = true;
		}
	}
	if( keyState == KS_Up )
	{
		if(localInput.IsKeyIsPressed("GBA_ToggleRagdoll", string( newKey )))
		{
			mRagdollPressed = false;
		}
	}
}

function NotifyOnPossess( Controller C, Pawn P )
{
	if( gMe == P || gMe.DrivenVehicle == P)
	{
		if(gMe == P) ModifyCameraZoom( mGoat );
		TryRegisterInput( PlayerController( C ) );
	}
}

function NotifyOnUnpossess( Controller C, Pawn P )
{
	if( mGoat == P || gMe.DrivenVehicle == P)
	{
		if(gMe == P) ResetCameraZoom( C );
		TryUnregisterInput( PlayerController( C ) );
	}
}

function SetVehicle()
{
	local GGSVehicle newVehicle;

	if(gMe.DrivenVehicle != none)
		return;

	newVehicle=GGSVehicle(gMe.mGrabbedItem);
	if(newVehicle != none)
	{
		AddVehicleByClass(newVehicle.class, newVehicle);
		myMut.WorldInfo.Game.Broadcast(myMut, GetVehicleName(newVehicle.class) @ "added to the Garage");
	}
}

function SwitchVehicle()
{
	if(gMe.DrivenVehicle != none)
		return;

	mCurrClass=GetNextVehicleClass(mCurrClass);
	myMut.WorldInfo.Game.Broadcast(myMut, GetVehicleName(mCurrClass));
}

function class<GGSVehicle> GetNextVehicleClass(class<GGSVehicle> vehicleClass)
{
	switch(vehicleClass)
	{
		case class'GGWreckingBall':
			return class'GGBicycleContent';
		case class'GGBicycleContent':
			return class'GGBuggy';
		case class'GGBuggy':
			return class'GGBumpercar';
		case class'GGBumpercar':
			return class'GGCompactCar';
		case class'GGCompactCar':
			return class'GGCrossoverCar';
		case class'GGCrossoverCar':
			return class'GGDualWheeler';
		case class'GGDualWheeler':
			return class'GGForkLift';
		case class'GGForkLift':
			return class'GGHoverVehicle';
		case class'GGHoverVehicle':
			return class'GGLongboardContent';
		case class'GGLongboardContent':
			return class'GGModernSedan';
		case class'GGModernSedan':
			return class'GGModernSedan2';
		case class'GGModernSedan2':
			return class'GGPickupTruck';
		case class'GGPickupTruck':
			return class'GGPoliceCarContent';
		case class'GGPoliceCarContent':
			return class'GGRocketLeagueCar';
		case class'GGRocketLeagueCar':
			return class'GGSedan2';
		case class'GGSedan2':
			return class'GGStretcher';
		case class'GGStretcher':
			return class'GGSUV';
		case class'GGSUV':
			return class'GGTruck';
		case class'GGTruck':
			return class'GGTukTuk';
		case class'GGTukTuk':
			return class'GGGetawayVan';
		case class'GGGetawayVan':
			return class'GGWreckingBall';
		default:
			return class'GGBicycleContent';
	}
}

function string GetVehicleName(class<GGSVehicle> vehicleClass)
{
	switch(vehicleClass)
	{
		case class'GGBicycleContent':
			return "Bicycle";
		case class'GGLongboardContent':
			return "Longboard";
		case class'GGBumpercar':
			return "Bumper Car";
		case class'GGWreckingBall':
			return "Wrecking Ball";
		case class'GGStretcher':
			return "Stretcher";
		case class'GGBuggy':
			return "Buggy";
		case class'GGCompactCar':
			return "Compact";
		case class'GGCrossoverCar':
			return "Crossover";
		case class'GGGetawayVan':
			return "Van";
		case class'GGSedan2':
			return "Sedan";
		case class'GGModernSedan':
			return "Modern Sedan";
		case class'GGModernSedan2':
			return "Modern Sedan 2";
		case class'GGPickupTruck':
			return "Pickup";
		case class'GGSUV':
			return "SUV";
		case class'GGTruck':
			return "Truck";
		case class'GGTukTuk':
			return "Tuk Tuk";
		case class'GGPoliceCarContent':
			return "Police Car";
		case class'GGRocketLeagueCar':
			return "Racing Car";
		case class'GGForkLift':
			return "Fork Lift";
		case class'GGDualWheeler':
			return "Dual Wheeler";
		case class'GGHoverVehicle':
			return "Hoverbike";
		default:
			return "";
	}
}

function GetVehicle()
{
	local GGSVehicle currVehicle;
	local vector pos;

	if(gMe.DrivenVehicle != none)
		return;

	// Spawn vehicle if needed, and place it in front of the player
	currVehicle=AddVehicleByClass(mCurrClass);
	if(PlayerController(currVehicle.Controller) != none)
		return;// Don't teleport vehicle if controlled by another player

	pos=GetSpawnLocationForVehicle(currVehicle);
	currVehicle.SetLocation(pos);
	currVehicle.SetRotation(gMe.Rotation);
	currVehicle.mesh.SetRBPosition(pos);
	currVehicle.mesh.SetRBRotation(gMe.Rotation);
	currVehicle.Velocity=vect(0, 0, 0);
	currVehicle.mesh.SetRBLinearVelocity(vect(0, 0, 0));
	currVehicle.mesh.SetRBAngularVelocity(vect(0, 0, 0));
}

function vector GetSpawnLocationForVehicle( GGSVehicle vehicle )
{
	local GGGoat goat;
	local Actor itemActor, hitActor;
	local vector spawnLocation, spawnDir, itemExtent, itemExtentOffset, traceStart, traceEnd, traceExtent, hitLocation, hitNormal;
	local float itemExtentCylinderRadius;
	local box itemBoundingBox;

	spawnLocation = vect( 0, 0, 0 );

	goat = gMe;
	itemActor = vehicle;
	if( goat != none && itemActor != none )
	{
		if( goat.Mesh.GetSocketByName( 'headSocket' ) != none )
		{
			goat.mesh.GetSocketWorldLocationAndRotation( 'headSocket', spawnLocation  );
		}
		else
		{
			// Avoid putting the stuff in origo.
			spawnLocation = goat.Location;
		}

		spawnDir = vector( goat.Rotation );

		itemActor.GetComponentsBoundingBox( itemBoundingBox );

		itemExtent = ( itemBoundingBox.Max - itemBoundingBox.Min ) * 0.5f;
		itemExtentOffset = itemBoundingBox.Min + ( itemBoundingBox.Max - itemBoundingBox.Min ) * 0.5f - itemActor.Location;
		itemExtentCylinderRadius = Sqrt( itemExtent.X * itemExtent.X + itemExtent.Y * itemExtent.Y );

		// Now try fit the thingy into the world.
		// Trace forward.
		traceStart = spawnLocation;
		traceEnd = spawnLocation + spawnDir * itemExtentCylinderRadius * 2.0f;

		hitActor = myMut.Trace( hitLocation, hitNormal, traceEnd, traceStart, false );
		if( hitActor == none )
		{
			hitLocation = traceEnd;
		}

		spawnLocation = hitLocation - spawnDir * itemExtentCylinderRadius;

		//DrawDebugLine( traceStart, traceEnd, 255, 0, 0, true );
		//DrawDebugSphere( hitLocation, 10.0f, 16, 255, 0, 0, true );
		//DrawDebugBox( spawnLocation, vect( 10, 10, 10 ), 255, 0, 0, true );

		// Trace downward.
		traceStart = spawnLocation + vect( 0, 0, 1 ) * itemExtent.Z * 2.0f;
		traceEnd = spawnLocation - vect( 0, 0, 1 ) * itemExtent.Z;
		traceExtent = itemExtent;

		hitActor = myMut.Trace( hitLocation, hitNormal, traceEnd, traceStart, false, traceExtent );
		if( hitActor == none )
		{
			hitLocation = traceEnd;
		}

		// The bounding box's location is not the same as the actors location so we need an offset.
		spawnLocation = hitLocation - itemExtentOffset;

		//DrawDebugLine( traceStart, traceEnd, 255, 255, 0, true );
		//DrawDebugSphere( hitLocation, 10.0f, 16, 255, 255, 0, true );
		//DrawDebugBox( spawnLocation, vect( 10, 10, 10 ), 255, 255, 0, true );
		//DrawDebugBox( hitLocation, traceExtent, 255, 255, 255, true );
	}
	else
	{
		`Log( "Garage failed to find spawn point for vehicle " $ vehicle );
	}

	return spawnLocation;
}

function GGSVehicle GetVehicleByClass(class<GGSVehicle> vehicleClass)
{
	local int i;

	for(i=0 ; i<mVehicles.Length ; i=i)
	{
		if(mVehicles[i] == none || mVehicles[i].bPendingDelete)
		{
			mVehicles.Remove(i, 1);
			continue;
		}

		if(mVehicles[i].class == vehicleClass)
		{
			return mVehicles[i];
		}
		i++;
	}

	return none;
}

function SetVehicleByClass(class<GGSVehicle> vehicleClass, GGSVehicle newVehicle)
{
	local int i;

	for(i=0 ; i<mVehicles.Length ; i++)
	{
		if(mVehicles[i].class == vehicleClass)
		{
			mVehicles[i]=newVehicle;
			break;
		}
	}
}

function GGSVehicle AddVehicleByClass(class<GGSVehicle> vehicleClass, optional GGSVehicle newVehicle)
{
	local GGSVehicle oldVehicle;

	oldVehicle=GetVehicleByClass(vehicleClass);
	if(oldVehicle == none)
	{
		if(newVehicle == none)
		{
			newVehicle=gMe.Spawn(vehicleClass);
			newVehicle.CollisionComponent.WakeRigidBody();
		}
		mVehicles.AddItem(newVehicle);
	}
	else if(newVehicle != none)
	{
		SetVehicleByClass(vehicleClass, newVehicle);
	}
	else
	{
		newVehicle=oldVehicle;
	}

	return newVehicle;
}

function SwitchVehicleColor()
{
	local int i;
	local array<MaterialInterface> currMats, newMats;

	currMats=gMe.DrivenVehicle.mesh.Materials;
	if(GGBicycleContent(gMe.DrivenVehicle) != none)
	{
		if(currMats.Length > 0)
		{
			switch(currMats[0])
			{
				case Material'Props_01.Materials.Bicycle_Yellow_Mat':
					newMats.AddItem(Material'Props_01.Materials.Bicycle_Black_Mat_01');
					break;
				case Material'Props_01.Materials.Bicycle_Black_Mat_01':
					newMats.AddItem(Material'Props_01.Materials.Bicycle_Green');
					break;
				case Material'Props_01.Materials.Bicycle_Green':
					newMats.AddItem(Material'Props_01.Materials.Bicycle_Red');
					break;
				case Material'Props_01.Materials.Bicycle_Red':
					newMats.AddItem(Material'Props_01.Materials.Bicycle_Silver');
					break;
				case Material'Props_01.Materials.Bicycle_Silver':
					newMats.AddItem(Material'Props_01.Materials.Bicycle_Yellow_Mat');
					break;
				default:
					return;
			}
		}
		if(newMats.Length == 0)
		{
			newMats.AddItem(Material'Props_01.Materials.Bicycle_Black_Mat_01');
		}
	}
	else if(GGBumpercar(gMe.DrivenVehicle) != none)
	{
		newMats.AddItem(Material'Mall.Textures.Underside_df_Mat');
		newMats.AddItem(Material'Mall.Materials.escalator_Rubber_Mat');
		newMats.AddItem(MaterialInstanceConstant'Studio_Lot.Materials.Studio_Light_INST');
		newMats.AddItem(Material'Mall.Materials.BumperCar_Bling_Mat');
		if(currMats.Length > 0)
		{
			switch(currMats[4])
			{
				case MaterialInstanceConstant'Mall.Materials.Bumper_Car_Mat_3_INST':
					newMats.AddItem(Material'Mall.Materials.Bumper_Car_Mat');
					break;
				case Material'Mall.Materials.Bumper_Car_Mat':
					newMats.AddItem(MaterialInstanceConstant'Mall.Materials.Bumper_Car_Mat_INST');
					break;
				case MaterialInstanceConstant'Mall.Materials.Bumper_Car_Mat_INST':
					newMats.AddItem(MaterialInstanceConstant'Mall.Materials.Bumper_Car_Mat_2_INST');
					break;
				case MaterialInstanceConstant'Mall.Materials.Bumper_Car_Mat_2_INST':
					newMats.AddItem(MaterialInstanceConstant'Mall.Materials.Bumper_Car_Mat_3_INST');
					break;
				default:
					return;
			}
		}
		if(newMats.Length == 4)
		{
			newMats.AddItem(Material'Mall.Materials.Bumper_Car_Mat');
		}
	}
	else if(GGCompactCar(gMe.DrivenVehicle) != none)
	{
		newMats.AddItem(MaterialInstanceConstant'Heist_Vehicles_01.Materials.Compact.Compact_Glass_Mat_INST');
		if(currMats.Length > 0)
		{
			switch(currMats[1])
			{
				case MaterialInstanceConstant'Heist_Vehicles_01.Materials.Compact.Compact_Mat_02':
					newMats.AddItem(MaterialInstanceConstant'Heist_Vehicles_01.Materials.Compact.Compact_MAT_01');
					break;
				case MaterialInstanceConstant'Heist_Vehicles_01.Materials.Compact.Compact_MAT_01':
					newMats.AddItem(MaterialInstanceConstant'Heist_Vehicles_01.Materials.Compact.Compact_Mat_02');
					break;
				default:
					return;
			}
		}
		if(newMats.Length == 1)
		{
			newMats.AddItem(MaterialInstanceConstant'Heist_Vehicles_01.Materials.Compact.Compact_MAT_01');
		}
	}
	else if(GGCrossoverCar(gMe.DrivenVehicle) != none)
	{
		newMats.AddItem(MaterialInstanceConstant'Heist_Vehicles_01.Materials.Crossover.Crossover_Glass_Mat_INST');
		if(currMats.Length > 0)
		{
			switch(currMats[1])
			{
				case MaterialInstanceConstant'Heist_Vehicles_01.Materials.Crossover.Crossover_Mat_02':
					newMats.AddItem(MaterialInstanceConstant'Heist_Vehicles_01.Materials.Crossover.Crossover_MAT_01');
					break;
				case MaterialInstanceConstant'Heist_Vehicles_01.Materials.Crossover.Crossover_MAT_01':
					newMats.AddItem(MaterialInstanceConstant'Heist_Vehicles_01.Materials.Crossover.Crossover_Mat_02');
					break;
				default:
					return;
			}
		}
		if(newMats.Length == 1)
		{
			newMats.AddItem(MaterialInstanceConstant'Heist_Vehicles_01.Materials.Crossover.Crossover_MAT_01');
		}
	}
	else if(GGModernSedan2(gMe.DrivenVehicle) != none)
	{
		if(currMats.Length > 0)
		{
			switch(currMats[0])
			{
				case MaterialInstanceConstant'Heist_Vehicles_01.Materials.ModernSedan2.ModernSedan2_Mat_03':
					newMats.AddItem(MaterialInstanceConstant'Heist_Vehicles_01.Materials.ModernSedan2.ModernSedan2_MAT_01');
					break;
				case MaterialInstanceConstant'Heist_Vehicles_01.Materials.ModernSedan2.ModernSedan2_MAT_01':
					newMats.AddItem(MaterialInstanceConstant'Heist_Vehicles_01.Materials.ModernSedan2.ModernSedan2_Mat_02');
					break;
				case MaterialInstanceConstant'Heist_Vehicles_01.Materials.ModernSedan2.ModernSedan2_Mat_02':
					newMats.AddItem(MaterialInstanceConstant'Heist_Vehicles_01.Materials.ModernSedan2.ModernSedan2_Mat_03');
					break;
				default:
					return;
			}
		}
		if(newMats.Length == 0)
		{
			newMats.AddItem(MaterialInstanceConstant'Heist_Vehicles_01.Materials.ModernSedan2.ModernSedan2_MAT_01');
		}
	}
	else if(GGPickupTruck(gMe.DrivenVehicle) != none)
	{
		if(currMats.Length > 0)
		{
			switch(currMats[0])
			{
				case MaterialInstanceConstant'Heist_Vehicles_01.Materials.PickupTruck.PickupTruck_Mat_04':
					newMats.AddItem(MaterialInstanceConstant'Heist_Vehicles_01.Materials.PickupTruck.PickupTruck_Mat_01');
					break;
				case MaterialInstanceConstant'Heist_Vehicles_01.Materials.PickupTruck.PickupTruck_Mat_01':
					newMats.AddItem(MaterialInstanceConstant'Heist_Vehicles_01.Materials.PickupTruck.PickupTruck_Mat_02');
					break;
				case MaterialInstanceConstant'Heist_Vehicles_01.Materials.PickupTruck.PickupTruck_Mat_02':
					newMats.AddItem(MaterialInstanceConstant'Heist_Vehicles_01.Materials.PickupTruck.PickupTruck_Mat_03');
					break;
				case MaterialInstanceConstant'Heist_Vehicles_01.Materials.PickupTruck.PickupTruck_Mat_03':
					newMats.AddItem(MaterialInstanceConstant'Heist_Vehicles_01.Materials.PickupTruck.PickupTruck_Mat_04');
					break;
				default:
					return;
			}
		}
		if(newMats.Length == 0)
		{
			newMats.AddItem(MaterialInstanceConstant'Heist_Vehicles_01.Materials.PickupTruck.PickupTruck_Mat_01');
		}
	}
	else if(GGRocketLeagueCar(gMe.DrivenVehicle) != none)
	{
		newMats.AddItem(Material'Heist_Psyonix.mesh.Car_Mat_01');
		if(currMats.Length > 0)
		{
			switch(currMats[1])
			{
				case Material'Circus.Materials.Golden_Mat':
					newMats.AddItem(Material'Heist_Psyonix.Mesh.Car_Mat_02');
					break;
				case Material'Heist_Psyonix.Mesh.Car_Mat_02':
					newMats.AddItem(MaterialInstanceConstant'Heist_Psyonix.Mesh.Car_Mat_02_INST');
					break;
				case MaterialInstanceConstant'Heist_Psyonix.Mesh.Car_Mat_02_INST':
					newMats.AddItem(Material'Circus.Materials.Golden_Mat');
					break;
				default:
					return;
			}
		}
		if(newMats.Length == 1)
		{
			newMats.AddItem(Material'Heist_Psyonix.Mesh.Car_Mat_02');
		}
	}
	else if(GGSedan2(gMe.DrivenVehicle) != none)
	{
		newMats.AddItem(MaterialInstanceConstant'Heist_Vehicles_01.Materials.ModernSedan.Sedan_Glass_Mat_INST');
		if(currMats.Length > 0)
		{
			switch(currMats[1])
			{
				case MaterialInstanceConstant'Heist_Vehicles_01.Materials.Sedan2.Sedan_02_Mat_03':
					newMats.AddItem(MaterialInstanceConstant'Heist_Vehicles_01.Materials.Sedan2.Sedan_02_MAT_01');
					break;
				case MaterialInstanceConstant'Heist_Vehicles_01.Materials.Sedan2.Sedan_02_Mat_01':
					newMats.AddItem(MaterialInstanceConstant'Heist_Vehicles_01.Materials.Sedan2.Sedan_02_Mat_02');
					break;
				case MaterialInstanceConstant'Heist_Vehicles_01.Materials.Sedan2.Sedan_02_Mat_02':
					newMats.AddItem(MaterialInstanceConstant'Heist_Vehicles_01.Materials.Sedan2.Sedan_02_Mat_03');
					break;
				default:
					return;
			}
		}
		if(newMats.Length == 1)
		{
			newMats.AddItem(MaterialInstanceConstant'Heist_Vehicles_01.Materials.Sedan2.Sedan_02_MAT_01');
		}
	}
	else if(GGSUV(gMe.DrivenVehicle) != none)
	{
		newMats.AddItem(MaterialInstanceConstant'Heist_Vehicles_01.Materials.SUV.SUV_Glass_Mat_INST');
		if(currMats.Length > 0)
		{
			switch(currMats[1])
			{
				case MaterialInstanceConstant'Heist_Vehicles_01.Materials.SUV.SUV_MAT_03':
					newMats.AddItem(MaterialInstanceConstant'Heist_Vehicles_01.Materials.SUV.SUV_MAT_01');
					break;
				case MaterialInstanceConstant'Heist_Vehicles_01.Materials.SUV.SUV_MAT_01':
					newMats.AddItem(MaterialInstanceConstant'Heist_Vehicles_01.Materials.SUV.SUV_MAT_02');
					break;
				case MaterialInstanceConstant'Heist_Vehicles_01.Materials.SUV.SUV_MAT_02':
					newMats.AddItem(MaterialInstanceConstant'Heist_Vehicles_01.Materials.SUV.SUV_MAT_03');
					break;
				default:
					return;
			}
		}
		if(newMats.Length == 1)
		{
			newMats.AddItem(MaterialInstanceConstant'Heist_Vehicles_01.Materials.SUV.SUV_MAT_01');
		}
	}
	else if(GGTruck(gMe.DrivenVehicle) != none)
	{
		if(currMats.Length > 0)
		{
			switch(currMats[0])
			{
				case MaterialInstanceConstant'Heist_Vehicles_01.Materials.Truck.Truck_Mat_02':
					newMats.AddItem(MaterialInstanceConstant'Heist_Vehicles_01.Materials.Truck.Truck_Mat_01');
					break;
				case MaterialInstanceConstant'Heist_Vehicles_01.Materials.Truck.Truck_Mat_01':
					newMats.AddItem(MaterialInstanceConstant'Heist_Vehicles_01.Materials.Truck.Truck_Mat_02');
					break;
				default:
					return;
			}
		}
		if(newMats.Length == 0)
		{
			newMats.AddItem(MaterialInstanceConstant'Heist_Vehicles_01.Materials.Truck.Truck_Mat_01');
		}
	}
	for(i=0 ; i<newMats.Length ; i++)
	{
		gMe.DrivenVehicle.mesh.SetMaterial(i, newMats[i]);
	}
}

defaultproperties
{
	mCurrClass=class'GGBicycleContent'
}