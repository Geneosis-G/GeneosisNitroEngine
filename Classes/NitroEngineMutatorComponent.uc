class NitroEngineMutatorComponent extends GGMutatorComponent;

var GGGoat gMe;
var GGMutator myMut;

var GGSVehicle currVehicle;

var ParticleSystemComponent mNitroParticle;
var vector mBoostPSOffset;
var bool mIsRLBoostButtonPressed;
var float mBoostTime_t;
var float mBoostStayTime;
var float mBoostFadeTime;
var float mBoostForce;
var ForceFeedbackWaveform mBoostForceFeedback;
var bool mIsForceFeedbacking;
var AudioComponent mBoostSound;
var AudioComponent mBoostSoundEnd;
var  AudioComponent mJumpSound;

var float mAirControlForce;
var vector mSmoothedAirControlTorque;
var float mAirDampTimer;
var PhysicalMaterial mAirPhysMat;
var float mAirPhysMatDamping_t;
var float mInitialAirAngularDamping;
var bool isForwardPressed;
var bool isBackPressed;
var bool isLeftPressed;
var bool isRightPressed;

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

		if( mAirPhysMat != none )
		{
			mInitialAirAngularDamping = mAirPhysMat.AngularDamping;
		}

		if(mNitroParticle.bIsActive)
		{
			mNitroParticle.DeactivateSystem();
			mNitroParticle.KillParticlesForced();
		}
	}
}

function bool ShouldIgnoreVehicle(Vehicle vehicleToTest)
{
	return GGRealCar(vehicleToTest) != none || GGHoverVehicle(currVehicle) != none || GGPodracer(currVehicle) != none;
}

function KeyState( name newKey, EKeyState keyState, PlayerController PCOwner )
{
	local GGPlayerInputGame localInput;

	if(gMe.DrivenVehicle == none || PCOwner != gMe.DrivenVehicle.Controller || ShouldIgnoreVehicle(gMe.DrivenVehicle))
		return;

	localInput = GGPlayerInputGame( PCOwner.PlayerInput );

	if( keyState == KS_Down )
	{
		if((!GGLocalPlayer(PCOwner.Player).mIsUsingGamePad && localInput.IsKeyIsPressed("GBA_Sprint", string( newKey )))
		|| newKey == 'XboxTypeS_B')
		{
			mIsRLBoostButtonPressed=true;
		}

		if(localInput.IsKeyIsPressed("GBA_Forward", string(newKey)))
		{
			isForwardPressed = true;
		}
		if(localInput.IsKeyIsPressed("GBA_Back", string(newKey)))
		{
			isBackPressed = true;
		}
		if(localInput.IsKeyIsPressed("GBA_Left", string(newKey)))
		{
			isLeftPressed = true;
		}
		if(localInput.IsKeyIsPressed("GBA_Right", string(newKey)))
		{
			isRightPressed = true;
		}
	}
	else if( keyState == KS_Up )
	{
		if((!GGLocalPlayer(PCOwner.Player).mIsUsingGamePad && localInput.IsKeyIsPressed("GBA_Sprint", string( newKey )))
		|| newKey == 'XboxTypeS_B')
		{
			mIsRLBoostButtonPressed=false;
		}

		if(localInput.IsKeyIsPressed("GBA_Forward", string(newKey)))
		{
			isForwardPressed = false;
		}
		if(localInput.IsKeyIsPressed("GBA_Back", string(newKey)))
		{
			isBackPressed = false;
		}
		if(localInput.IsKeyIsPressed("GBA_Left", string(newKey)))
		{
			isLeftPressed = false;
		}
		if(localInput.IsKeyIsPressed("GBA_Right", string(newKey)))
		{
			isRightPressed = false;
		}
	}
}


////////////////////////////////////////////////////////////
// Stuff from GGRealCar
////////////////////////////////////////////////////////////

function DoBoost(GGSVehicle vehicle, float delta)
{
	local float force;
	local float boostFadeTime;
	local vector X, Y, Z;

	if(vehicle == none)
		return;

	force = delta * currVehicle.mGentlePushForceSize * mBoostForce * (GGStretcher(vehicle)==none?1.f:10.f);
	boostFadeTime = FMax( mBoostFadeTime, 0.1 );

	if( mBoostTime_t <= mBoostFadeTime )
	{
		force *= mBoostTime_t / boostFadeTime;
	}

	vehicle.GetAxes( vehicle.Rotation, X, Y, Z );
	vehicle.AddForce( force * (X + Z * 0.3) );
}

function BeginBoost(GGSVehicle vehicle)
{
	if(vehicle == none)
		return;

	if( mBoostTime_t == 0 && mBoostSound != none )
	{
		mBoostSound.Stop();
		mBoostSound.Play();
	}
	mBoostTime_t = mBoostStayTime + mBoostFadeTime;

	StartControllerRumble( vehicle.Controller );
}

function StopBoost(Controller c)
{
	if(!mBoostSound.IsPlaying())
		return;

	mBoostSound.FadeOut( 0.25f, 0 );

	if( mBoostSoundEnd != none )
	{
		mBoostSoundEnd.Stop();
		mBoostSoundEnd.Play();
	}

	StopControllerRumble( c );
}

function StartControllerRumble( Controller c )
{
	if( PlayerController( c ) != none && !mIsForceFeedbacking )
	{
		mIsForceFeedbacking = true;
		PlayerController( c ).ForceFeedbackManager.PlayForceFeedbackWaveform( mBoostForceFeedback, currVehicle );
	}
}

function StopControllerRumble( Controller c )
{
	if( PlayerController( c ) != none && mIsForceFeedbacking )
	{
		mIsForceFeedbacking = false;
		PlayerController( c ).ForceFeedbackManager.PlayForceFeedbackWaveform( none, none );
	}
}

function bool IsBoosting()
{
	return currVehicle != none && mIsRLBoostButtonPressed && mBoostTime_t > 0;
}

function DoAirControl( float DeltaTime )
{
	local GGPlayerControllerGame c;
	local GGPlayerInputGame pinput;
	local Vector torque;
	local Vector X,Y,Z;
	local float newBaseY, newStrafe;

	if(currVehicle == none)
		return;

	if( currVehicle.HasWheelsOnGround() )
	{
		mSmoothedAirControlTorque *= 0.1f;
		return;
	}

	c = GGPlayerControllerGame( currVehicle.Controller );
	pinput = GGPlayerInputGame( c.PlayerInput );

	if( c != none && pinput != none )
	{
		newBaseY=pinput.aBaseY;
		newStrafe=pinput.aStrafe;
		if(!GGLocalPlayer(c.Player).mIsUsingGamePad)
		{
			if(isForwardPressed)
			{
				newBaseY=1.0f;
			}
			if(isBackPressed)
			{
				newBaseY=-1.0f;
			}
			if(isLeftPressed)
			{
				newStrafe=-1.f;
			}
			if(isRightPressed)
			{
				newStrafe=1.f;
			}
		}
		//myMut.WorldInfo.Game.Broadcast(myMut, "newBaseY=" $ newBaseY $ ", newStrafe=" $ newStrafe);
		currVehicle.GetAxes( currVehicle.Rotation, X, Y, Z );

		torque = Y * newBaseY * mAirControlForce * 5.f;
		torque += Z * newStrafe * mAirControlForce  * 5.f;

		mSmoothedAirControlTorque.X = Lerp( mSmoothedAirControlTorque.X, torque.X, 0.03f );
		mSmoothedAirControlTorque.Y = Lerp( mSmoothedAirControlTorque.Y, torque.Y, 0.03f );
		mSmoothedAirControlTorque.Z = Lerp( mSmoothedAirControlTorque.Z, torque.Z, 0.03f );

		currVehicle.AddTorque( mSmoothedAirControlTorque );
	}
}

function Tick( float DeltaTime )
{
	local GGSVehicle oldVehicle;

	if(currVehicle != none && currVehicle.bPendingDelete)
	{
		currVehicle=none;
	}
	oldVehicle = currVehicle;
	currVehicle = GGSVehicle(gMe.DrivenVehicle);

	if(currVehicle != none && oldVehicle == none)
	{
		OnEnterVehicle(currVehicle);
	}
	if(currVehicle == none && oldVehicle != none)
	{
		OnExitVehicle(oldVehicle);
	}

	if(currVehicle == none || ShouldIgnoreVehicle(currVehicle))
		return;

	mNitroParticle.SetActive( IsBoosting() );

	currVehicle.bOutputHandbrake = true;

	if( mAirPhysMatDamping_t > 0 )
	{
		mAirPhysMatDamping_t -= DeltaTime;

		if( mAirPhysMatDamping_t < 0 )
		{
			mAirPhysMatDamping_t = 0;
		}

		if( currVehicle.Mesh.PhysMaterialOverride != none )
		{
			currVehicle.mesh.PhysMaterialOverride.AngularDamping = mInitialAirAngularDamping + mInitialAirAngularDamping * 10 *(mAirPhysMatDamping_t/mAirDampTimer);
		}
	}

	//only use the air physmat when a player is driving the car and is in the air
	if( currVehicle.HasWheelsOnGround() )
	{
		currVehicle.mesh.SetPhysMaterialOverride( none );
	}
	else
	{
		currVehicle.mesh.SetPhysMaterialOverride( mAirPhysMat );
	}

	if( mBoostTime_t > 0 )
	{
		DoBoost(currVehicle, deltaTime);

		mBoostTime_t -= DeltaTime;

		if( mBoostTime_t <= 0 )
		{
			mBoostTime_t = 0;
			StopBoost(currVehicle.Controller);
		}
	}

	if( mIsRLBoostButtonPressed )
	{
		BeginBoost(currVehicle);
	}

	DoAirControl( DeltaTime );
}

////////////////////////////////////////////////////////////
// End stuff from GGRealCar
////////////////////////////////////////////////////////////

function OnEnterVehicle(GGSVehicle newVehicle)
{
	//myMut.WorldInfo.Game.Broadcast(myMut, "OnEnterVehicle(" $ newVehicle $ ")");
	TryRegisterInput( PlayerController( newVehicle.Controller ) );
	AttachEngine(newVehicle);
	OnEnterCar(GGRealCar(newVehicle));
}

function OnExitVehicle(GGSVehicle oldVehicle)
{
	//myMut.WorldInfo.Game.Broadcast(myMut, "OnExitVehicle(" $ oldVehicle $ ")");
	TryUnregisterInput( PlayerController( gMe.Controller ) );
	DetachEngine(oldVehicle);
	OnExitCar(GGRealCar(oldVehicle));
}

function OnEnterCar(GGRealCar newCar)
{
	if(newCar == none)
		return;

	newCar.mCanRLJump=true;
	newCar.mCanBoost=true;
	newCar.mCanExplode=false;
	if(newCar.mBoostSound.SoundCue == none) newCar.mBoostSound.SoundCue=mBoostSound.SoundCue;
	if(newCar.mBoostSoundEnd.SoundCue == none) newCar.mBoostSoundEnd.SoundCue=mBoostSoundEnd.SoundCue;
	if(newCar.mJumpSound.SoundCue == none) newCar.mJumpSound.SoundCue=mJumpSound.SoundCue;
	if(newCar.mAirPhysMat == none)
	{
		newCar.mAirPhysMat=mAirPhysMat;
		newCar.mInitialAirAngularDamping=mInitialAirAngularDamping;
	}
	if(newCar.mBoostPSComps[0].Template == none)
	{
		newCar.mBoostPSComps[0].SetTemplate(mNitroParticle.Template);
	}
	if(newCar.mesh.GetSocketByName( 'EffectSocket' ) == none)
	{
		newCar.mBoostPSComps[0].SetTranslation(mBoostPSOffset);
		newCar.AttachComponent(newCar.mBoostPSComps[0]);
	}
}

function OnExitCar(GGRealCar oldCar)
{
	if(oldCar == none)
		return;

	if(oldCar.mBoostSound.IsPlaying())
	{
		oldCar.StopBoost();
		oldCar.StopControllerRumble( gMe.Controller );
	}
	oldCar.mCanRLJump=oldCar.default.mCanRLJump;
	oldCar.mCanBoost=oldCar.default.mCanBoost;
	oldCar.mCanExplode=oldCar.default.mCanExplode;
	oldCar.mBoostSound.SoundCue=oldCar.default.mBoostSound.SoundCue;
	oldCar.mBoostSoundEnd.SoundCue=oldCar.default.mBoostSoundEnd.SoundCue;
	oldCar.mJumpSound.SoundCue=oldCar.default.mJumpSound.SoundCue;
	oldCar.mAirPhysMat=oldCar.default.mAirPhysMat;
	oldCar.mInitialAirAngularDamping=oldCar.default.mInitialAirAngularDamping;
	if(oldCar.mBoostPSComps[0] == mNitroParticle)
	{
		mNitroParticle.SetTranslation(mNitroParticle.default.Translation);
		oldCar.DetachComponent(mNitroParticle);
	}
	oldCar.mBoostPSComps[0].SetTemplate(oldCar.default.mBoostPSComps[0].Template);
}

function AttachEngine(GGSVehicle newVehicle)
{
	if(ShouldIgnoreVehicle(newVehicle))
		return;

	if(newVehicle.mDriverSocketName != '')
	{
		newVehicle.mesh.AttachComponentToSocket(mNitroParticle, newVehicle.mDriverSocketName);
	}
	else
	{
		newVehicle.AttachComponent(mNitroParticle);
	}
	newVehicle.AttachComponent(mBoostSound);
	newVehicle.AttachComponent(mBoostSoundEnd);
	newVehicle.AttachComponent(mJumpSound);
	newVehicle.MaxSpeed = newVehicle.MaxSpeed * 2.f;
}

function DetachEngine(GGSVehicle oldVehicle)
{
	oldVehicle.mesh.SetPhysMaterialOverride( none );

	if(ShouldIgnoreVehicle(oldVehicle))
		return;

	if(mNitroParticle.bIsActive)
	{
		mNitroParticle.DeactivateSystem();
		mNitroParticle.KillParticlesForced();
	}
	if(oldVehicle.mDriverSocketName != '')
	{
		oldVehicle.mesh.DetachComponent(mNitroParticle);
	}
	else
	{
		oldVehicle.DetachComponent(mNitroParticle);
	}
	oldVehicle.DetachComponent(mBoostSound);
	oldVehicle.DetachComponent(mBoostSoundEnd);
	oldVehicle.DetachComponent(mJumpSound);
	oldVehicle.MaxSpeed = oldVehicle.default.MaxSpeed;
	StopBoost(gMe.Controller);
	mIsRLBoostButtonPressed=false;
}

defaultproperties
{
	Begin Object class=AudioComponent Name=BoostSound
		SoundCue=SoundCue'Heist_Audio.Cue.Vehicle_Rocket_Boost_Startup_Cue'
	End Object
	mBoostSound=BoostSound

	Begin Object class=AudioComponent Name=BoostSoundEnd
		SoundCue=SoundCue'Heist_Audio.Cue.Vehicle_Rocket_Boost_End_Cue'
	End Object
	mBoostSoundEnd=BoostSoundEnd

	Begin Object class=AudioComponent Name=JumpSound
		SoundCue=SoundCue'Heist_Audio.Cue.Vehicle_Rocket_Boost_End_Cue'
	End Object
	mJumpSound=JumpSound

	//force feedback
	Begin Object class=ForceFeedbackWaveform Name=RumbleFeedback
		Samples(0)=(LeftAmplitude=120, RightAmplitude=120, LeftFunction=WF_Constant, RightFunction=WF_Constant, Duration=0.900)
		bIsLooping = true;
	End Object
	mBoostForceFeedback=RumbleFeedback
	mIsForceFeedbacking=false

	mAirControlForce=110.0f
	mAirDampTimer=0.5f

	Begin Object class=ParticleSystemComponent Name=ParticleSystemComponent0
        Template=ParticleSystem'Heist_Vehicles_01.Particles.VehicleBoost_ParticleSystem'
        Translation=(X=-100)
		bResetOnDetach=true
		bAutoActivate=true
	End Object
	mNitroParticle=ParticleSystemComponent0

	mBoostStayTime=0.1
	mBoostFadeTime=0.1
	mBoostForce=20.f
	mBoostPSOffset=(X=-300.f, Z=-50.f)
}