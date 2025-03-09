class NitroEngineMutator extends GGMutator;

var array< NitroEngineMutatorComponent > mComponents;

/**
 * See super.
 */
function ModifyPlayer(Pawn Other)
{
	local GGGoat goat;
	local NitroEngineMutatorComponent nitroComp;

	super.ModifyPlayer( other );

	goat = GGGoat( other );
	if( goat != none )
	{
		nitroComp=NitroEngineMutatorComponent(GGGameInfo( class'WorldInfo'.static.GetWorldInfo().Game ).FindMutatorComponent(class'NitroEngineMutatorComponent', goat.mCachedSlotNr));
		if(nitroComp != none && mComponents.Find(nitroComp) == INDEX_NONE)
		{
			mComponents.AddItem(nitroComp);
		}
	}
}

/**
 * Called when a player respawns
 */
function OnPlayerRespawn( PlayerController respawnController, bool died )
{
	local GGSVehicle respawnVehicle;
	local GGGoat goatDriver;
	// Fix respawn when in vehicle
	respawnVehicle = GGSVehicle(respawnController.Pawn.DrivenVehicle);
	if(respawnVehicle != none)
	{
		goatDriver = GGGoat( respawnVehicle.Driver );

		if( goatDriver != none )
		{
			respawnVehicle.DriverLeave( true );
			goatDriver.Respawn();
		}
	}

	super.OnPlayerRespawn(respawnController, died);
}

simulated event Tick( float delta )
{
	local int i;

	for( i = 0; i < mComponents.Length; i++ )
	{
		mComponents[ i ].Tick( delta );
	}
	super.Tick( delta );
}

DefaultProperties
{
	mMutatorComponentClass=class'NitroEngineMutatorComponent'
}