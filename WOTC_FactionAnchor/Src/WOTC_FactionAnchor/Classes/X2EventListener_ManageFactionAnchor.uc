//---------------------------------------------------------------------------------------
//  FILE:   X2EventListener_ManageFactionAnchor.uc                                    
//
//	CREATED BY RustyDios
//           
//	File created	02/02/21	23:45
//	LAST UPDATED    27/03/21	05:00
//  
//	FOR MANAGING THE ANCHOR WITH HELP FROM IRIDAR and SHADOWCX
//
//---------------------------------------------------------------------------------------
class X2EventListener_ManageFactionAnchor extends X2EventListener config (Game);

var config array<name> NotAValidEnemy_TemplateName;

//////////////////////////////////////////////////
//  CREATE TEMPLATES
/////////////////////////////////////////////////

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(Create_FactionAnchor_MANAGE());

	return Templates;
}

/////////////////////////////////////////////////////////////
//  LISTENER TEMPLATES 'PLAYER TURN BEGUN' IS EVERY TURN
////////////////////////////////////////////////////////////

//manage the anchor each round
static function CHEventListenerTemplate Create_FactionAnchor_MANAGE()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'FactionAnchor_MANAGE');

	Template.RegisterInStrategy = false;
	Template.RegisterInTactical = true;

	//deffered to 'after' other stuff, so mind control swaps can be figured out etc ...
	//not that it should matter for ELD_OSS 
	Template.AddCHEvent('PlayerTurnBegun', FactionAnchor_Manage, ELD_OnStateSubmitted, 42);	 

	return Template;
}

//////////////////////////////////////////////////
//  ELR - MANAGE THE ANCHOR
/////////////////////////////////////////////////

static function EventListenerReturn FactionAnchor_Manage(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameState			NewGameState;
	local XComGameState_Unit	UnitState, AnchorState;
	local XComGameState_Player	PlayerState;
	local XComGameState_AIReinforcementSpawner AISPawnerState;
	local int SkippedUnits, EnemyUnitsInPlay, ExcludedUnitsInPlay, ReinforcementsInbound, KillAmount;

	local X2Effect_KillUnit			KillEffect;
	local EffectAppliedData			ApplyData;

   	`LOG("========================= ANCHOR MANAGER ==============================================", class'X2DownloadableContentInfo_WOTC_FactionAnchor'.default.bEnableFactionAnchorLog ,'FactionAnchor');

	// reset the units in play
	SkippedUnits = 0;
	EnemyUnitsInPlay = 0;
	ExcludedUnitsInPlay = 0;
	ReinforcementsInbound = 0;

	PlayerState = XComGameState_Player(EventData); //Data and Source are both the same for this event, so if we have one should have both... 

	if (PlayerState != none)
	{
		`LOG("Player Turn is ::" @GetTeamString(PlayerState.TeamFlag) @":: Turn Count ::" @PlayerState.PlayerTurnCount, class'X2DownloadableContentInfo_WOTC_FactionAnchor'.default.bEnableFactionAnchorLog ,'FactionAnchor');
	}
	else
	{
		//exit we have no player state !! ABORT ABORT !!
		`LOG("*** ERROR *** :: NO PLAYERSTATE :: *** ERROR ***", class'X2DownloadableContentInfo_WOTC_FactionAnchor'.default.bEnableFactionAnchorLog ,'FactionAnchor');
	   	`LOG("========================= ANCHOR MANAGER ==============================================", class'X2DownloadableContentInfo_WOTC_FactionAnchor'.default.bEnableFactionAnchorLog ,'FactionAnchor');

		return ELR_NoInterrupt;
	}

	//  CREATE A NEW GAMESTATE AS ELD_OSS PER IRIDARS INSTRUCTIONS
    NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Managing the Anchor");

	//cycle all units on the field
	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Unit', UnitState)
    {
		//skip removed units (evac'ed), non-selectable (mimic beacon) and cosmectic (gremlin) and strategy unit templates (MOCX)
		if (UnitState.bRemovedFromPlay || UnitState.GetMyTemplate().bNeverSelectable || UnitState.GetMyTemplate().bIsCosmetic
			|| UnitState.ControllingPlayer.ObjectID <= 0 )
		{
			//enable the unit log only on xcoms turn to cut down on log spam... OH THE SPAMMMMMMMM, EVERY CIVVIE, EVERY XCOM CREW, GREMLIN, DEAD UNIT... 
			if (PlayerState.TeamFlag == eTeam_XCom)	
			{
				`LOG("FOUND UNIT TO SKIP:: " $UnitState.GetMyTemplateName() , class'X2DownloadableContentInfo_WOTC_FactionAnchor'.default.bEnableFactionAnchorLog ,'FactionAnchor');
			}

			SkippedUnits++;
			continue;
		}

		//unit is alive and in play
        if (UnitState.IsAlive() && !UnitState.bRemovedFromPlay)
        {
			//on an enemy team and is not the anchor
			if( (UnitState.GetTeam() == eTeam_None || UnitState.GetTeam() == eTeam_Alien || UnitState.GetTeam() == eTeam_TheLost || UnitState.GetTeam() == eTeam_One || UnitState.GetTeam() == eTeam_Two) 
				&& UnitState.GetMyTemplateName() != 'FactionAnchorMX')	
			{
				// increase the enemy unit count or exclusion count
				if (default.NotAValidEnemy_TemplateName.Find(UnitState.GetMyTemplateName()) != INDEX_NONE)
				{
					//enable the unit log only on xcoms turn to cut down on log spam... 
					if (PlayerState.TeamFlag == eTeam_XCom)	
					{
						`LOG("FOUND UNIT EXCLUDE:: " $UnitState.GetMyTemplateName() @":: IS ON TEAM :: " $GetTeamString(UnitState.GetTeam() ), class'X2DownloadableContentInfo_WOTC_FactionAnchor'.default.bEnableFactionAnchorLog ,'FactionAnchor');
					}

					ExcludedUnitsInPlay++;	//found on exclusion list
					continue;
				}
				else
				{
					//enable the unit log only on xcoms turn to cut down on log spam... 
					if (PlayerState.TeamFlag == eTeam_XCom)	
					{
						`LOG("FOUND UNIT IN PLAY:: " $UnitState.GetMyTemplateName() @":: IS ON TEAM :: " $GetTeamString(UnitState.GetTeam() ), class'X2DownloadableContentInfo_WOTC_FactionAnchor'.default.bEnableFactionAnchorLog ,'FactionAnchor');
					}
					
					EnemyUnitsInPlay++;		//not found on exclusion list
					continue;
				}

			}

			//unit is the anchor
            if(UnitState.GetMyTemplateName() == 'FactionAnchorMX')
			{
				//enable the unit log only on xcoms turn to cut down on log spam...
			    if (PlayerState.TeamFlag == eTeam_XCom) 
				{
				    `LOG("FOUND UNIT ANCHOR :: " $UnitState.GetMyTemplateName() @":: IS ON TEAM :: " $GetTeamString(UnitState.GetTeam() ), class'X2DownloadableContentInfo_WOTC_FactionAnchor'.default.bEnableFactionAnchorLog ,'FactionAnchor');
				}

				// grab the anchor
				AnchorState = UnitState;
				continue;	
			}
        }
    }//end unit loop

	//cycle checking for re-inforcements, no team lockout, we just wanna know if there are any, from any team ... to decide if to keep the anchor alive or not ...
	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_AIReinforcementSpawner', AISPawnerState)
    {
		`LOG("REINFORCEMENTS IN :: " $AISPawnerState.Countdown @"TURN(S) :: FOR TEAM :: " $GetTeamString(AISPawnerState.SpawnInfo.Team), class'X2DownloadableContentInfo_WOTC_FactionAnchor'.default.bEnableFactionAnchorLog ,'FactionAnchor');
		ReinforcementsInbound++;
	}

	//print the counts to the log
   	`LOG("Skipped units on mission for everyone:" @SkippedUnits, class'X2DownloadableContentInfo_WOTC_FactionAnchor'.default.bEnableFactionAnchorLog ,'FactionAnchor');
   	`LOG("Excluded units in play for all teams :" @ExcludedUnitsInPlay, class'X2DownloadableContentInfo_WOTC_FactionAnchor'.default.bEnableFactionAnchorLog ,'FactionAnchor');
   	`LOG("Enemy units in play across all teams :" @EnemyUnitsInPlay, class'X2DownloadableContentInfo_WOTC_FactionAnchor'.default.bEnableFactionAnchorLog ,'FactionAnchor');
   	`LOG("Number of Team Reinforcements Inbound:" @ReinforcementsInbound, class'X2DownloadableContentInfo_WOTC_FactionAnchor'.default.bEnableFactionAnchorLog ,'FactionAnchor');

	if (AnchorState == none)
	{
		//maybe some code here to spawn an anchor ? this would effect it legit killing itself ?
		//decided it best to leave as an error for the log... for now ...
		//class'X2EventListener_CreateFactionAnchor'.static.DropAnchor(NewGameState);

		`LOG("*** ERROR *** :: NO ANCHOR FOUND :: *** ERROR ***", class'X2DownloadableContentInfo_WOTC_FactionAnchor'.default.bEnableFactionAnchorLog ,'FactionAnchor');
	}

	//if we have the anchor and it is the last unit in play and no reinforcements inbound ... kill it for the sweep objective
	if (AnchorState != none && EnemyUnitsInPlay <= 0 && ReinforcementsInbound <= 0)
	{
		//ADD The Anchor to the current gamestate... as we're changing stuff for it
    	AnchorState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', AnchorState.ObjectID));

		//remove anti-death effect by setting unit value to 0
		AnchorState.SetUnitFloatValue('Anchor', 1.0, eCleanup_BeginTactical);

		//solution provided by Iridar :) ... create a dummy effect to hide the death message... 
		KillEffect = new class'X2Effect_KillUnit';
		KillEffect.bHideDeathWorldMessage = true;

		//ApplyData.PlayerStateObjectRef.ObjectID = AnchorState.GetAssociatedPlayerID();
		ApplyData.PlayerStateObjectRef = PlayerState.GetReference();
		ApplyData.SourceStateObjectRef = AnchorState.GetReference();
		ApplyData.TargetStateObjectRef = AnchorState.GetReference();
		ApplyData.EffectRef.LookupType = TELT_AbilityTargetEffects;

		KillEffect.ApplyEffect(ApplyData, AnchorState, NewGameState);

		/*
			function TakeEffectDamage( const X2Effect DmgEffect, const int DamageAmount, const int MitigationAmount, const int ShredAmount, const out EffectAppliedData EffectData,
				XComGameState NewGameState, optional bool bForceBleedOut = false, optional bool bAllowBleedout = true, optional bool bIgnoreShields = false,
				optional array<Name> AppliedDamageTypes, optional array<DamageModifierInfo> SpecialDamageMessages)
 		*/

		//backup kill effect, was needed -- but I'm not sure 'why' iridars method above only worked 2/3 of the time ??
		KillAmount = AnchorState.GetCurrentStat(eStat_HP) + AnchorState.GetCurrentStat(eStat_ShieldHP) + 42 ;
		AnchorState.TakeEffectDamage(KillEffect, KillAmount, 0, 0, ApplyData, NewGameState, false, false, true);

	   	`LOG("Anchor Was Last Unit, killed ::" @KillEffect.ApplyEffect(ApplyData, AnchorState, NewGameState), class'X2DownloadableContentInfo_WOTC_FactionAnchor'.default.bEnableFactionAnchorLog ,'FactionAnchor');
	}

   	`LOG("========================= ANCHOR MANAGER ==============================================", class'X2DownloadableContentInfo_WOTC_FactionAnchor'.default.bEnableFactionAnchorLog ,'FactionAnchor');

  	//  Submit the Game State so our changes take effect.
    `XCOMGAME.GameRuleset.SubmitGameState(NewGameState);

	return ELR_NoInterrupt;
}

//////////////////////////////////////////////////
//  HELPER FUNCS - MAINLY FOR THE LOGGING
/////////////////////////////////////////////////

/*
121     TELT_AbilityTargetEffects,
122     TELT_AbilityMultiTargetEffects,
123     TELT_AbilityShooterEffects,
124     TELT_AmmoTargetEffects,
125     TELT_BleedOutEffect,
126     TELT_UnspottedEffect,
127     TELT_WorldEffect,
128     TELT_PersistantEffect,
129     TELT_ThrownGrenadeEffects,
130     TELT_LaunchedGrenadeEffects,
131     TELT_WeaponEffects,
*/

static function String GetTeamString(ETeam TeamToConvert)
{
	switch( TeamToConvert )
	{
		case eTeam_None:		return "NONE, RULER or CHOSEN";
		case eTeam_All:			return "ALL";
        case eTeam_XCom:		return "XCOM";
        case eTeam_Alien:		return "ADVENT";
        case eTeam_TheLost:		return "LOST";
        case eTeam_Neutral:		return "CIVS";
        case eTeam_Resistance:  return "RESISTANCE";
        case eTeam_One:         return "FACTION ONE";
        case eTeam_Two:         return "FACTION TWO";
        default:        		return "UNKNOWN :: ENUM :: " $TeamToConvert ;
            break;
	}
}
