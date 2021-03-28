//---------------------------------------------------------------------------------------
//  FILE:   X2EventListener_CreateFactionAnchor.uc                                    
//
//	CREATED BY RustyDios
//           
//	File created	02/02/21	23:45
//	LAST UPDATED    11/02/21	04:40
//
//	HEAVILY ADAPTED FROM IRIDARS DENMOTHER CODE - CREATE AN ANCHOR UNIT IN EVERY MISSION
//
//---------------------------------------------------------------------------------------
class X2EventListener_CreateFactionAnchor extends X2EventListener config (Game);

//////////////////////////////////////////////////
//  CREATE TEMPLATES
/////////////////////////////////////////////////

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(Create_FactionAnchor_DROP());

	return Templates;
}

/////////////////////////////////////////////////////////////
//  LISTENER TEMPLATES 'POST ALIEN SPAWNED' IS ONCE/MISSION
/////////////////////////////////////////////////////////////

//deploy the anchor into every mission
static function CHEventListenerTemplate Create_FactionAnchor_DROP()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'FactionAnchor_DROP');

	Template.RegisterInStrategy = false;
	Template.RegisterInTactical = true;

	Template.AddCHEvent('PostAliensSpawned', FactionAnchor_Deploy, ELD_Immediate);

	return Template;
}

//////////////////////////////////////////////////
//  ELR - CREATE AND DEPLOY AN ANCHOR
//////////////////////////////////////////////////

static function EventListenerReturn FactionAnchor_Deploy(Object EventData, Object EventSource, XComGameState NewGameState, Name Event, Object CallbackData)
{
	local XComGameState_Unit				UnitState;
	local vector							Position;

   	`LOG("========================= ANCHOR AWAY ==============================================", class'X2DownloadableContentInfo_WOTC_FactionAnchor'.default.bEnableFactionAnchorLog ,'FactionAnchor');

	`LOG("Post Aliens Spawned Listener EventFunction triggered.", class'X2DownloadableContentInfo_WOTC_FactionAnchor'.default.bEnableFactionAnchorLog ,'FactionAnchor');
	`LOG("This is the first round, creating the faction anchor.", class'X2DownloadableContentInfo_WOTC_FactionAnchor'.default.bEnableFactionAnchorLog ,'FactionAnchor');

	//	CREATE THE ANCHOR
	UnitState = DropAnchor(NewGameState);

	//	DEPLOY THE ANCHOR TO THIS POSITION
	Position = GetAnchorDropPosition();
	
	//Position.x = 0;
	//Position.y = 0;
	//Position.z = 0;

	`LOG("Old position:" @ `XWORLD.GetPositionFromTileCoordinates(UnitState.TileLocation), class'X2DownloadableContentInfo_WOTC_FactionAnchor'.default.bEnableFactionAnchorLog ,'FactionAnchor');
	`LOG("New position:" @ Position, class'X2DownloadableContentInfo_WOTC_FactionAnchor'.default.bEnableFactionAnchorLog ,'FactionAnchor');

	//	Teleport the unit - this clamps the unit to a valid position, stops log spam with 'out of bounds' unit
	UnitState.SetVisibilityLocationFromVector(Position);
	UnitState.bRequiresVisibilityUpdate = true;

	//	ENSURE THE ANCHOR HAS A TEAM AND GROUP - SO IT REGISTERS AS ADVENT WITH KISMET
	AddStrategyUnitToBoard(UnitState, NewGameState);

	//	ADJUST ALL THE STATS TO OVERWRITE ANY CONFIGS
	AdjustAnchorStats(UnitState);

	//done by post-unit-begin-play-ability
	//MakeAnchorImmune(UnitState, NewGameState);
	//MakeAnchorVanish(UnitState, NewGameState);

    `LOG("ANCHOR UNIT :: "$UnitState.GetMyTemplateName() @":: IS ON TEAM :: " $GetTeamString(UnitState.GetTeam() ), class'X2DownloadableContentInfo_WOTC_FactionAnchor'.default.bEnableFactionAnchorLog ,'FactionAnchor');
   	`LOG("========================= ANCHOR DROPPED ==============================================", class'X2DownloadableContentInfo_WOTC_FactionAnchor'.default.bEnableFactionAnchorLog ,'FactionAnchor');

	return ELR_NoInterrupt;
}

//spawns a new anchor if one doesn't exist
static function XComGameState_Unit DropAnchor(XComGameState GameState)
{
	local XComGameState_Unit		NewUnitState;

	NewUnitState = CreateSoldier(GameState);

	//set the appearance, this blanks out any appearance it might of had from creation
	SetAnchorAppearance(NewUnitState);

	NewUnitState.SetXPForRank(0);
	NewUnitState.StartingRank = 0;

	return NewUnitState;
}

//actually create the unit
static private function XComGameState_Unit CreateSoldier(XComGameState NewGameState)
{
	local X2CharacterTemplateManager	CharTemplateMgr;	
	local X2CharacterTemplate			CharacterTemplate;
	local XGCharacterGenerator			CharacterGenerator;
	local TSoldier						CharacterGeneratorResult;
	local XComGameState_Unit			SoldierState;
	
	CharTemplateMgr = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();
	CharacterTemplate = CharTemplateMgr.FindCharacterTemplate('FactionAnchorMX');
	SoldierState = CharacterTemplate.CreateInstanceFromTemplate(NewGameState);
	
	//	Probably not gonna end up using any part of the generated appearance, but let's go through the motions just in case
	CharacterGenerator = `XCOMGRI.Spawn(CharacterTemplate.CharacterGeneratorClass);
	CharacterGeneratorResult = CharacterGenerator.CreateTSoldier('FactionAnchorMX');
	SoldierState.SetTAppearance(CharacterGeneratorResult.kAppearance);

	return SoldierState;
}

//change the appearance to a blank slate ... really don't care, we're hiding it anyway
static private function SetAnchorAppearance(XComGameState_Unit UnitState)
{
	UnitState.kAppearance.iGender			= eGender_Male;
	UnitState.kAppearance.nmPawn			= 'ARC_GameUnit_Anchor';
	UnitState.kAppearance.nmTorso			= 'ARC_GameUnit_Anchor';
	UnitState.kAppearance.nmTorsoDeco		= '';
	UnitState.kAppearance.nmTorso_Underlay	= '';
	
	UnitState.kAppearance.nmArms			= '';
	UnitState.kAppearance.nmLeftArm			= '';
	UnitState.kAppearance.nmRightArm		= '';
	UnitState.kAppearance.nmArms_Underlay	= '';
	UnitState.kAppearance.nmLeftArmDeco		= '';
	UnitState.kAppearance.nmRightArmDeco	= '';
	UnitState.kAppearance.nmLeftForearm		= '';
	UnitState.kAppearance.nmRightForearm	= '';
	UnitState.kAppearance.nmTattoo_LeftArm	= '';
	UnitState.kAppearance.nmTattoo_RightArm = '';

	UnitState.kAppearance.nmLegs			= '';
	UnitState.kAppearance.nmLegs_Underlay	= '';
	UnitState.kAppearance.nmThighs			= '';
	UnitState.kAppearance.nmShins			= '';

	UnitState.kAppearance.nmHead			= '';
	UnitState.kAppearance.nmHelmet			= '';
	UnitState.kAppearance.nmHaircut			= '';
	UnitState.kAppearance.nmFacePropUpper	= '';
	UnitState.kAppearance.nmFacePropLower	= ''; 
	UnitState.kAppearance.nmBeard			= '';
	UnitState.kAppearance.nmEye				= '';
	UnitState.kAppearance.nmTeeth			= '';
	UnitState.kAppearance.nmScars			= '';
	UnitState.kAppearance.nmFacePaint		= '';

	UnitState.kAppearance.nmVoice			= '';
	UnitState.kAppearance.iAttitude			= 0;
	UnitState.kAppearance.iRace				= 0;
	UnitState.kAppearance.iSkinColor		= 0;
	UnitState.kAppearance.iEyeColor			= 0; 
	UnitState.kAppearance.iHairColor		= 0; 
	
	UnitState.kAppearance.nmPatterns		= '';
	UnitState.kAppearance.nmWeaponPattern	= '';
	UnitState.kAppearance.iWeaponTint		= 0;
	UnitState.kAppearance.iArmorTint		= 0;
	UnitState.kAppearance.iArmorTintSecondary = 0;

	UnitState.kAppearance.nmFlag			 = 'Country_UK';

	UnitState.SetCountry(UnitState.kAppearance.nmFlag);
	UnitState.SetCharacterName("FACTION","ANCHOR","");
	
	UnitState.StoreAppearance(); 
}

//find a 'good' spawn location
static private function vector GetAnchorDropPosition()
{
	local XComGameState_Unit	UnitState;
	local vector				Position;
	local TTile					Tile;
	local int					i;

	i = 1;	//make i 1 here so we don't end up with a divide by 0 error below...

	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Unit', UnitState)
	{	
		//	Cycle through all Soldiers currently present on the mission, so in the xcom spawn location
		//	Unit is auto-hidden, and has no vision, so doesn't break concealment for xcom
		if (UnitState.IsSoldier() && !UnitState.bRemovedFromPlay)
		{
			Position += `XWORLD.GetPositionFromTileCoordinates(UnitState.TileLocation);
			i++;
		}
	}

	`LOG("Found this many Soldiers in the GameState:" @ i - 1, class'X2DownloadableContentInfo_WOTC_FactionAnchor'.default.bEnableFactionAnchorLog ,'FactionAnchor');
	Position /= i;

	`LOG("Avg position:" @ Position, class'X2DownloadableContentInfo_WOTC_FactionAnchor'.default.bEnableFactionAnchorLog ,'FactionAnchor');
	//	At this point in time, Position will hold coordinates of a center point between all xcom

	//	FindClosestValidLocation(Position, bAllowFlying, bPrioritizeZLevel, bAvoidNoSpawnZones=false); 
	Position = `XWORLD.FindClosestValidLocation(Position, false, false, true); 

	`LOG("Valid posit :" @ Position, class'X2DownloadableContentInfo_WOTC_FactionAnchor'.default.bEnableFactionAnchorLog ,'FactionAnchor');

	`XWORLD.GetFloorTileForPosition(Position, Tile);
	Position = `XWORLD.GetPositionFromTileCoordinates(Tile);

	`LOG("Floor posit :" @ Position, class'X2DownloadableContentInfo_WOTC_FactionAnchor'.default.bEnableFactionAnchorLog ,'FactionAnchor');

	return Position;
}

// set up the unit correctly to a team and group
static private function AddStrategyUnitToBoard(XComGameState_Unit Unit, XComGameState NewGameState)
{
	local StateObjectReference			ItemReference;
	local XComGameState_Item			ItemState;

	SetGroupAndPlayer(Unit, eTeam_Alien, NewGameState);

	// add item states. This needs to be done so that the visualizer sync picks up the IDs and creates their visualizers -Leader Enemy Boss
	foreach Unit.InventoryItems(ItemReference)
	{
		ItemState = XComGameState_Item(NewGameState.ModifyStateObject(class'XComGameState_Item', ItemReference.ObjectID));
		ItemState.BeginTacticalPlay(NewGameState);   // this needs to be called explicitly since we're adding an existing state directly into tactical
		NewGameState.AddStateObject(ItemState);

		// add any cosmetic items that might exists
		ItemState.CreateCosmeticItemUnit(NewGameState);
	}

	//	This triggers the unit's abilities that activate at "UnitPostBeginPlay"
	Unit.BeginTacticalPlay(NewGameState); 

}

static function SetGroupAndPlayer(XComGameState_Unit UnitState, ETeam SetTeam, XComGameState NewGameState)
{
	local XComGameState_Player			PlayerState;
	local XComGameState_AIGroup			Group, PreviousGroupState;
	local array <XComGameState_AIGroup>	Groups;

	// assign the new unit to the given team -LeaderEnemyBoss !!
	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Player', PlayerState)
	{
		if(PlayerState.GetTeam() == SetTeam)
		{
			`LOG("Assigned player :" @GetTeamString(SetTeam), class'X2DownloadableContentInfo_WOTC_FactionAnchor'.default.bEnableFactionAnchorLog ,'FactionAnchor');
			UnitState.SetControllingPlayer(PlayerState.GetReference());
			break;
		}
	}

	// just in case reset groups array
	Groups.length = 0;

	//	set AI Group for the new unit so it can be controlled by the player properly
	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_AIGroup', Group)
	{
		if (Group.TeamName == SetTeam)
		{
			Groups.AddItem(Group);
			//break;
		}
	}

	`LOG("Total Groups for Team :" @Groups.length -1, class'X2DownloadableContentInfo_WOTC_FactionAnchor'.default.bEnableFactionAnchorLog ,'FactionAnchor');

	//grab the LAST group, this fixes an issue on retailiation missions where the first group needs to all die for the resistance team to move on... 
	Group = Groups[Groups.Length -1];

	if( UnitState != none && Group != none )
	{
		PreviousGroupState = UnitState.GetGroupMembership(NewGameState);

		if( PreviousGroupState != none )
		{
			PreviousGroupState.RemoveUnitFromGroup(UnitState.ObjectID, NewGameState);
		}

		`LOG("Assigned group :" @Group, class'X2DownloadableContentInfo_WOTC_FactionAnchor'.default.bEnableFactionAnchorLog ,'FactionAnchor');

		Group = XComGameState_AIGroup(NewGameState.ModifyStateObject(class'XComGameState_AIGroup', Group.ObjectID));
		Group.AddUnitToGroup(UnitState.ObjectID, NewGameState);
	}
}

// adjust all the units stats, except HP, ShieldHP and Will, as it breaks without them!
static function AdjustAnchorStats (XComGameState_Unit UnitState)
{
	UnitState.SetCurrentStat(eStat_AlertLevel, 0);
	UnitState.SetCurrentStat(eStat_Strength, 0);

	UnitState.SetBaseMaxStat(eStat_HP, 42);
	UnitState.SetCurrentStat(eStat_HP, 42);

	UnitState.SetBaseMaxStat(eStat_ShieldHP, 69);
	UnitState.SetCurrentStat(eStat_ShieldHP, 69);
	
	UnitState.SetCurrentStat(eStat_ArmorChance, 0);
	UnitState.SetCurrentStat(eStat_ArmorMitigation, 0);
	UnitState.SetCurrentStat(eStat_ArmorPiercing, 0);

	UnitState.SetCurrentStat(eStat_Offense, 0);	//aim
	UnitState.SetCurrentStat(eStat_Defense, 0);
	UnitState.SetCurrentStat(eStat_Dodge, 0);
	UnitState.SetCurrentStat(eStat_Mobility, 0);
	UnitState.SetCurrentStat(eStat_PsiOffense, 0);
	UnitState.SetCurrentStat(eStat_HackDefense, 0);

	UnitState.SetBaseMaxStat(eStat_Will, 69);
	UnitState.SetCurrentStat(eStat_Will, 69);

	UnitState.SetCurrentStat(eStat_CritChance, 0);
	UnitState.SetCurrentStat(eStat_FlankingCritChance, 0);
	UnitState.SetCurrentStat(eStat_FlankingAimBonus, 0);

	//UnitState.SetCurrentStat(eStat_ReserveActionPoints, 0);	//this isn't recognised by the code despite being in -every- default character stats ?!
	UnitState.SetCurrentStat(eStat_SightRadius, 0);
	UnitState.SetCurrentStat(eStat_DetectionRadius, 0);
	UnitState.SetCurrentStat(eStat_UtilityItems, 0);

	`LOG("FA Stats Flatlined", class'X2DownloadableContentInfo_WOTC_FactionAnchor'.default.bEnableFactionAnchorLog ,'FactionAnchor');
}

//////////////////////////////////////////////////
//  HELPER FUNCS - MAINLY FOR THE LOGGING
/////////////////////////////////////////////////

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
