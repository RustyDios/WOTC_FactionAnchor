//---------------------------------------------------------------------------------------
//  FILE:   X2Effect_UnkillableAnchor.uc                                    
//
//	CREATED BY RustyDios
//           
//	File created	26/03/21	04:00
//	LAST UPDATED    27/03/21	01:00
//
//	THIS EFFECT REFRESHES A UNITS HEALTH UNLESS THE CHECK VALUE IS SET BY SOMETHING
//	IN THE CASE HERE IT SHOULD BE SET BY THE MANAGE ANCHOR LISTENER TO 1.0 WHEN 'DEATH' IS READY
//	OR SET TO 1.0 BY THE REVEAL MANUAL OVERRIDE SKILLS
//
//---------------------------------------------------------------------------------------
class X2Effect_UnkillableAnchor extends X2Effect_Persistent;

delegate AddAdditionalEffects( XComGameState NewGameState, XComGameState_Unit UnitState );

function bool PreDeathCheck(XComGameState NewGameState, XComGameState_Unit UnitState, XComGameState_Effect EffectState)
{
	local UnitValue CheckValue;

	//check for unit value set to 1.0 in death event listener 
	UnitState.GetUnitValue('Anchor', CheckValue);

	//if not set yet yet, and we're going to die.. reset health
	if (CheckValue.fValue == 0.0)
	{
		UnitState.SetCurrentStat(eStat_HP, 42);

		return true;
	}
	else
	{
		return false;
	}
}

function bool PreBleedoutCheck(XComGameState NewGameState, XComGameState_Unit UnitState, XComGameState_Effect EffectState)
{
	return PreDeathCheck(NewGameState, UnitState, EffectState);
}

defaultproperties
{
	EffectName="UnkillableEffectAnchor"
}
