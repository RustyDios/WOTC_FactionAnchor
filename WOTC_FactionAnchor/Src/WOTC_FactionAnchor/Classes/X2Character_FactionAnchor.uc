//---------------------------------------------------------------------------------------
//  FILE:   X2Character_FactionAnchor.uc                                    
//
//	CREATED BY RustyDios
//           
//	File created	02/02/21	23:45
//	LAST UPDATED    06/02/21	11:45
//
//	Basically an 'empty' unit
//
//---------------------------------------------------------------------------------------
class X2Character_FactionAnchor extends X2Character config(XComGameData_CharacterStats);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateTemplate_FactionAnchor());

	return Templates;
}

static function X2CharacterTemplate CreateTemplate_FactionAnchor()
{
	local X2CharacterTemplate CharTemplate;

	`CREATE_X2CHARACTER_TEMPLATE(CharTemplate, 'FactionAnchorMX');

	CharTemplate.CharacterGroupName = 'FactionAnchor';

	//CharTemplate.DefaultLoadout='AdvTrooperM1_Loadout';	//no loadout, just in case it tries to use a wepon?
	CharTemplate.BehaviorClass		= class'XGAIBehavior';
	CharTemplate.strBehaviorTree	= "FactionAnchorMX::CharacterRoot";
	CharTemplate.strPanicBT			= "PanickedRoot_FactionAnchorMX";
	CharTemplate.strScamperBT		= "ScamperRoot_FactionAnchorMX";

	CharTemplate.bNeverShowFirstSighted = true;

	//new enemy unit made from the spectre with ObelixDK's help, completely invisible.
	CharTemplate.strPawnArchetypes.AddItem("GameUnit_Anchor.ARC_GameUnit_Anchor");
	CharTemplate.bSetGenderAlways = true;

	CharTemplate.UnitSize = 1;

	// Traversal Rules - standard profile just in case
	CharTemplate.bCanUse_eTraversal_Normal 		= true;
	CharTemplate.bCanUse_eTraversal_ClimbOver 	= true;
	CharTemplate.bCanUse_eTraversal_ClimbOnto 	= true;
	CharTemplate.bCanUse_eTraversal_ClimbLadder	= true;
	CharTemplate.bCanUse_eTraversal_DropDown 	= true;
	CharTemplate.bCanUse_eTraversal_Landing 	= true;
	CharTemplate.bCanUse_eTraversal_Grapple 	= false;
	CharTemplate.bCanUse_eTraversal_BreakWindow	= false;
	CharTemplate.bCanUse_eTraversal_KickDoor 	= false;
	CharTemplate.bCanUse_eTraversal_JumpUp 		= false;
	CharTemplate.bCanUse_eTraversal_WallClimb 	= false;
	CharTemplate.bCanUse_eTraversal_BreakWall 	= false;

	CharTemplate.bAppearanceDefinesPawn = false;// If true, the appearance information assembles a unit pawn. True for soldiers & civilians, false for Aliens & Advent (they're are all one piece)
	CharTemplate.bCanTakeCover = false;			// by default should be true, but certain large units, like mecs and andromedons, etc, don't take cover, so set to false.
	CharTemplate.bDoesNotScamper = true;		// Unit will not scamper when encountering the enemy.

	CharTemplate.bSkipDefaultAbilities = true;	// Will not add the default ability set (Move, Dash, Fire, Hunker Down).

	CharTemplate.bIsAdvent = false;				// used by targeting 
	CharTemplate.bIsCivilian = false;			// used by targeting 
	CharTemplate.bIsSoldier = false;			// used by targeting 

	CharTemplate.bIsAlien = false;				// used by targeting 
	CharTemplate.bIsPsionic = false;			// used by targeting 
	CharTemplate.bIsRobotic = false;			// used by targeting 
	CharTemplate.bIsMeleeOnly = false;			// true if this unit has no ranged attacks. Used primarily for flank checks

	CharTemplate.bCanBeTerrorist = true;		// Is it applicable to use this unit on a terror mission? (eu/ew carryover)
	CharTemplate.bIsAfraidOfFire = false;		// will panic when set on fire - only applies to flamethrower
	CharTemplate.bCanBeCriticallyWounded = false;

	CharTemplate.bAllowSpawnFromATT = false;	// If true, this unit can be spawned from an Advent Troop Transport

	CharTemplate.bHideInShadowChamber = true;	// If true, do not display this enemy in pre-mission Shadow Chamber lists
	CharTemplate.bDisplayUIUnitFlag = true;		// used by UnitFlag - overriden by vanish ability
	CharTemplate.bNeverSelectable = false;	 	// Somewhat special-case handling Mimic Beacons, which need (for gameplay) to appear alive and relevant
	CharTemplate.bIsCosmetic = false;			// true if this unit is visual only, and has no effect on game play or has a separate game state for game play ( such as the gremlin )

	CharTemplate.bShouldCreateDifficultyVariants = false;

	CharTemplate.strHackIconImage = "UILibrary_Common.TargetIcons.Hack_captain_icon";
	CharTemplate.strTargetIconImage = "UILibrary_FactionAnchor.UI_HUDIcon_Anchor"; //class'UIUtilities_Image'.const.TargetIcon_Advent;

	CharTemplate.CharacterGeneratorClass = class'XGCharacterGenerator';

	CharTemplate.Abilities.AddItem('FactionAnchor');
	CharTemplate.Abilities.AddItem('FA_Debug_Show');
	CharTemplate.Abilities.AddItem('FA_Debug_Kill');

	//CharTemplate.AdditionalAnimSets.AddItem('')

	return CharTemplate;
}
