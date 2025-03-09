class GGForkLift extends GGRealCarContent;

simulated event Tick( float deltaTime )
{
	super.Tick( deltaTime );

	UpdateAirRotation();

	//DrawDebugWheels();
}

function UpdateAirRotation()
{
	local vector angVel, tmpVel;
	local array<name> boneNames;
	local name boneName;
	local RB_BodyInstance bodyInst;

	if(!HasWheelsOnGround())
	{
		mesh.GetBoneNames(boneNames);
		foreach boneNames(boneName)
		{
			bodyInst=mesh.FindBodyInstanceNamed(boneName);
			if(bodyInst != none)
			{
				tmpVel=bodyInst.GetUnrealWorldAngularVelocity();
				if(VSize(tmpVel) > VSize(angVel))
				{
					angVel=tmpVel;
				}
			}
		}
		if(VSize(angVel) < 0.1f)
		{
			mesh.SetRBAngularVelocity(vect(0, 0, 0));
		}
		else
		{
			mesh.SetRBAngularVelocity(angVel * 0.9f);
		}
	}
}
/*
function DrawDebugWheels()
{
	local int i;

	for (i = 0; i < Wheels.Length ; i++)
	{
		DrawDebugSphere(Location + (Wheels[i].WheelPosition >> Rotation), Wheels[i].WheelRadius, 100, i <= 1 ? 255 : 0, i >= 0 ? 255 : 0, 50, false);
	}
}
*/
function bool DriverEnter( Pawn userPawn )
{
	local bool driverCouldEnter;
	local vector sitLoc;
	local rotator sitRot;

	driverCouldEnter = super.DriverEnter( userPawn );

	if( driverCouldEnter )
	{
		userPawn.SetPhysics( PHYS_None );
		sitLoc=mesh.GetBoneLocation(mDriverSocketName);
		sitRot=QuatToRotator(mesh.GetBoneQuaternion(mDriverSocketName));
		userPawn.SetLocation(sitLoc);
		userPawn.SetRotation(sitRot);
		userPawn.SetBase( self );
		userPawn.SetPhysics( PHYS_Interpolating );// if driver is knocked out of vehicle it won't teleport back to spawn loc
	}

	return driverCouldEnter;
}

/**
 * Take care of the new passenger
 */
function bool PassengerEnter( Pawn userPawn )
{
	local bool passengerEntered;
	local int i;
	local name passengerSeatBoneName;
	local vector sitLoc;
	local rotator sitRot;

	passengerEntered = super.PassengerEnter( userPawn );
	if( passengerEntered )
	{
		for( i = 0; i < mPassengerSeats.Length; i++ )
		{
			if( mPassengerSeats[i].PassengerPawn == userPawn )
			{
				passengerSeatBoneName=mPassengerSocketNames[ mPassengerSeats[i].VehiclePassengerSeat.mVehicleSeatIndex ];
				break;
			}
		}

		userPawn.SetPhysics( PHYS_None );
		sitLoc=mesh.GetBoneLocation(passengerSeatBoneName);
		sitRot=QuatToRotator(mesh.GetBoneQuaternion(passengerSeatBoneName));
		userPawn.SetLocation(sitLoc);
		userPawn.SetRotation(sitRot);
		userPawn.SetBase( self );
		userPawn.SetPhysics( PHYS_Interpolating );// if driver is knocked out of vehicle it won't teleport back to spawn loc
	}

	return passengerEntered;
}

DefaultProperties
{
	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'Heist_Vehicles_01.mesh.Forklift_01'
		PhysicsAsset=PhysicsAsset'Heist_Vehicles_01.mesh.Forklift_Physics_01'
		LightEnvironment=CarLightEnvironment
		bHasPhysicsAssetInstance=true
		RBChannel=RBCC_Vehicle
		bNotifyRigidBodyCollision=true
		ScriptRigidBodyCollisionThreshold=1
	  	AnimTreeTemplate=AnimTree'Heist_Vehicles_01.Anim.Forklift_Animtree_01'
	End Object
	mExplosionMesh=StaticMesh'Heist_Vehicles_01.mesh.Forklift_Destroyed_01'

	COMOffset=(x=0.0f,y=0.0f,z=-200.0f)

	mNumberOfSeats=3

	mDriverSocketName="Seat_01"

	mPassengerSocketNames(0)="Seat_02"

	mPassengerSocketNames(1)="Seat_03"

	mPassengerSocketNames(2)="Seat_04"

	mBoostForce=1000
	mJumpForce=30000
	mAirControlForce=10.0f

	Begin Object name=SimulationObject

		//Torque based on typical engine torque data
		//TorqueVSpeedCurve=(Points=((InVal=-1000.0,OutVal=0.0),(InVal=-500.0,OutVal=600.0),(InVal=0.0,OutVal=250.0),(InVal=500.0,OutVal=600.0),(InVal=1000.0,OutVal=650.0),(InVal=2000.0,OutVal=725.0),(InVal=3000.0,OutVal=780.0),(InVal=4000.0,OutVal=800.0),(InVal=5000.0,OutVal=750.0),(InVal=6000.0,OutVal=650.0),(InVal=7000.0,OutVal=0.0)))//,(InVal=3500.0,OutVal=1500.0),(InVal=5000.0,OutVal=1000.0),(InVal=14000.0,OutVal=1000.0),(InVal=15000.0,OutVal=0.0)))

		WheelSuspensionStiffness=40000.0f
		WheelSuspensionDamping=300.0f
		WheelSuspensionBias=0f
	End Object
	SimObj=SimulationObject

	Begin Object name=BackWheelL
		BoneName="Wheel_Back"
		BoneOffset=(X=0.0,Y=-60.0,Z=0.0)
		bPoweredWheel=true
	  	SkelControlName="Wheel_B_Control"
		WheelRadius=30
	End Object
	Wheels(0)=BackWheelL

	Begin Object name=BackWheelR
		BoneName="Wheel_Back"
		BoneOffset=(X=0.0,Y=60.0,Z=0.0)
		bPoweredWheel=true
	  	SkelControlName="Wheel_B_Control"
		WheelRadius=30
	End Object
	Wheels(1)=BackWheelR

	Begin Object name=FrontWheelL
		BoneName="Wheel_Front_L"
		SteerFactor=1.0
		BoneOffset=(X=0.0,Y=0.0,Z=0.0)
		bPoweredWheel=false
	  	SkelControlName="Wheel_F_Control"
		WheelRadius=43
	End Object
	Wheels(2)=FrontWheelL

	Begin Object name=FrontWheelR
		BoneName="Wheel_Front_R"
		SteerFactor=1.0
		BoneOffset=(X=0.0,Y=0.0,Z=0.0)
		bPoweredWheel=false
	  	SkelControlName="Wheel_F_Control"
		WheelRadius=43
	End Object
	Wheels(3)=FrontWheelR

	EnterVehicleSound=SoundCue'Heist_Audio.Vehicle.Vehicle_Buggy_Ignition_Mono_Cue'
	Begin Object Name=EngineSoundComponent
		SoundCue=SoundCue'Heist_Audio.Vehicle.Vehicle_Buggy_Idle_Loop_Mono_Cue'
	End Object
	EngineStartOffsetSecs=0.5
}