//---------------------------------------------------------------------------------------
//  FILE:   X2Ability_FactionAnchor.uc                                    
//
//	CREATED BY RustyDios
//           
//	File created	04/02/21	15:15
//	LAST UPDATED    27/03/21	01:00
//
//	THIS ABILITY MAKES A UNIT IMMUNE TO ALL FORMS OF DAMAGE AND INVISIBLE AND UNKILLABLE
//	DEBUG ABILITIES ARE SET UP TO HELP KILL THE ANCHOR IF NEEDED
//
//---------------------------------------------------------------------------------------
class X2Ability_FactionAnchor extends X2Ability	config(GameData_SoldierSkills);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(Create_FactionAnchorAbility());
	Templates.AddItem(Create_FactionAnchorAbility_Debug_Reveal());
	Templates.AddItem(Create_FactionAnchorAbility_Debug_Kill());

	return Templates;
}

static function X2AbilityTemplate Create_FactionAnchorAbility()
{
	local X2AbilityTemplate					Template;
	local X2AbilityTrigger_EventListener	Trigger;

	local X2Effect_RemoveEffects			RemoveEffects;
	local X2Effect_Vanish					VanishEffect;

	local X2Effect_DamageImmunity			DamageImmunity;
	local X2Effect_UnkillableAnchor			UnkillableEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'FactionAnchor');

    //setup 
	Template.IconImage = "img:///UILibrary_FactionAnchor.UI_PerkAnchor";
	Template.AbilitySourceName = 'eAbilitySource_Commander';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.ConcealmentRule = eConceal_Always;
	//Template.bIsPassive = true;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	//triggers
	// APPLY ON UNITS FIRST TURN
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	// This ability refreshes every turn
	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = 'PlayerTurnBegun';
	Trigger.ListenerData.Filter = eFilter_Player;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Template.AbilityTriggers.AddItem(Trigger);

	// This ability fires can when the unit gets hit by a scan
	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = class'X2Effect_ScanningProtocol'.default.ScanningProtocolTriggeredEventName;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Trigger.ListenerData.Filter = eFilter_Unit;
	Template.AbilityTriggers.AddItem(Trigger);

		// Remove the effect
		RemoveEffects = new class'X2Effect_RemoveEffects';
		RemoveEffects.EffectNamesToRemove.AddItem(class'X2Effect_ScanningProtocol'.default.EffectName);
		Template.AddShooterEffect(RemoveEffects);

	// This ability fires can when the unit gets hit by target definition
	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = class'X2Effect_TargetDefinition'.default.TargetDefinitionTriggeredEventName;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Trigger.ListenerData.Filter = eFilter_Unit;
	Template.AbilityTriggers.AddItem(Trigger);

		// Remove the effect
		RemoveEffects = new class'X2Effect_RemoveEffects';
		RemoveEffects.EffectNamesToRemove.AddItem(class'X2Effect_TargetDefinition'.default.EffectName);
		Template.AddShooterEffect(RemoveEffects);

	// This ability fires when the unit is damaged, this is to 'revanish' after an AoE attack ?
	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = 'UnitTakeEffectDamage';
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Trigger.ListenerData.Filter = eFilter_Unit;
	Template.AbilityTriggers.AddItem(Trigger);

	//I THINK THIS COVERS EVERYTHING ?
	DamageImmunity = new class'X2Effect_DamageImmunity';
	DamageImmunity.BuildPersistentEffect(1, true, false, true);
	DamageImmunity.ImmuneTypes.AddItem('Unconscious');
	DamageImmunity.ImmuneTypes.AddItem('DefaultProjectile');
	DamageImmunity.ImmuneTypes.AddItem('Projectile_Conventional');
	DamageImmunity.ImmuneTypes.AddItem('Projectile_MagXCom');
	DamageImmunity.ImmuneTypes.AddItem('Projectile_MagAdvent');
	DamageImmunity.ImmuneTypes.AddItem('Projectile_BeamXCom');
	DamageImmunity.ImmuneTypes.AddItem('Projectile_BeamAlien');
	DamageImmunity.ImmuneTypes.AddItem('Projectile_BeamAvatar');
	DamageImmunity.ImmuneTypes.AddItem(class'X2Item_DefaultDamageTypes'.default.KnockbackDamageType);
	DamageImmunity.ImmuneTypes.AddItem(class'X2Item_DefaultDamageTypes'.default.ParthenogenicPoisonType);
	DamageImmunity.ImmuneTypes.AddItem(class'X2Item_DefaultDamageTypes'.default.DisorientDamageType);
	DamageImmunity.ImmuneTypes.AddItem('Heavy');
	DamageImmunity.ImmuneTypes.AddItem('Explosion');
	DamageImmunity.ImmuneTypes.AddItem('NoFireExplosion');
	DamageImmunity.ImmuneTypes.AddItem('BlazingPinions');
	DamageImmunity.ImmuneTypes.AddItem('Fire');
	DamageImmunity.ImmuneTypes.AddItem('Acid');
	DamageImmunity.ImmuneTypes.AddItem('Poison');
	DamageImmunity.ImmuneTypes.AddItem('Electrical');
	DamageImmunity.ImmuneTypes.AddItem('Psi');
	DamageImmunity.ImmuneTypes.AddItem('Melee');
	DamageImmunity.ImmuneTypes.AddItem('ViperCrush');
	DamageImmunity.ImmuneTypes.AddItem('Stun');
	DamageImmunity.ImmuneTypes.AddItem('Mental');
	DamageImmunity.ImmuneTypes.AddItem('Panic');
	DamageImmunity.ImmuneTypes.AddItem('Falling');
	DamageImmunity.ImmuneTypes.AddItem('Bleeding');
	DamageImmunity.ImmuneTypes.AddItem('Frost');				// DLC ADDED
	DamageImmunity.ImmuneTypes.AddItem('EleriumPoisoning');		// MOD ADDED
	DamageImmunity.bDisplayInUI = false;						// Effect will appear in UI flyovers mode if this is true
	DamageImmunity.bSourceDisplayInUI = false;					// Effect will appear in UI flyovers mode if this is true
	DamageImmunity.bDisplayInSpecialDamageMessageUI = false;	// If true, this effect FriendlyName will be displayed in the damage feedback ui as a special damage source
    DamageImmunity.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName $" IMMUNITY", Template.LocLongDescription, Template.IconImage, true, , Template.AbilitySourceName);
	DamageImmunity.DuplicateResponse = eDupe_Refresh;
	Template.AddTargetEffect(DamageImmunity);

    VanishEffect = new class'X2Effect_Vanish';
	VanishEffect.BuildPersistentEffect(1, true, false, true);
	VanishEffect.EffectName = 'Anchor';
	VanishEffect.ReasonNotVisible = 'Anchor';
	VanishEffect.VanishRevealAnimName = 'HL_Vanish_Stop';
	VanishEffect.VanishSyncAnimName = 'ADD_Vanish_Restart';
    VanishEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName $" INVISIBILITY", Template.LocLongDescription, Template.IconImage, true, , Template.AbilitySourceName);
	VanishEffect.DuplicateResponse = eDupe_Refresh;
	Template.AddTargetEffect(VanishEffect);

	UnkillableEffect = new class'X2Effect_UnkillableAnchor';
	UnkillableEffect.BuildPersistentEffect(1, true, false, true);
	UnkillableEffect.DuplicateResponse = eDupe_Refresh;
	Template.AddTargetEffect(UnkillableEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;	//I'd like to say no buildVis, but I think I need it for the vanish stuffs	
	Template.bSkipExitCoverWhenFiring = true;
	Template.bSkipFireAction = true;
	Template.bShowActivation = false;

	//Template.CinescriptCameraType = "VanishAbility";
	Template.CustomFireAnim = 'HL_Vanish_Start';

	return Template;
}

static function X2AbilityTemplate Create_FactionAnchorAbility_Debug_Reveal()
{
	local X2AbilityTemplate			Template;
	local X2Condition_UnitEffects	UnitEffectsCondition;
	local X2Effect_SetUnitValue     SetUpToDie;

	local X2Effect_RemoveEffects	RemoveEffects;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'FA_Debug_Show');

    //setup 
	Template.IconImage = "img:///UILibrary_FactionAnchor.UI_PerkAnchor";
	Template.AbilitySourceName = 'eAbilitySource_Commander';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;
	Template.Hostility = eHostility_Neutral;
	Template.ConcealmentRule = eConceal_Always;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	// The shooter must have the Vanish Effect
	UnitEffectsCondition = new class'X2Condition_UnitEffects';
	UnitEffectsCondition.AddRequireEffect('Anchor', 'AA_MissingRequiredEffect');
	Template.AbilityShooterConditions.AddItem(UnitEffectsCondition);

	// Setup to bypass the Unkillable Effect
	SetUpToDie = new class'X2Effect_SetUnitValue';
	SetUpToDie.UnitName = 'Anchor';
	SetUpToDie.CleanupType = eCleanup_BeginTurn;
	SetUpToDie.NewValueToSet = 1;
	Template.AddTargetEffect(SetUpToDie);

	// Remove the reveal
	RemoveEffects = new class'X2Effect_RemoveEffects';
	RemoveEffects.EffectNamesToRemove.AddItem('Anchor');
	Template.AddShooterEffect(RemoveEffects);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	//Template.MergeVisualizationFn = class'X2Ability_ChosenAssassin'.static.VanishingWindReveal_MergeVisualization;

	Template.bSkipFireAction = true;
	Template.bShowActivation = false;

	Template.bSkipExitCoverWhenFiring = true;

	return Template;
}

static function X2AbilityTemplate Create_FactionAnchorAbility_Debug_Kill()
{
	local X2AbilityTemplate Template;
	local X2Condition_UnitEffects UnitEffectsCondition;
	local X2Effect_KillUnit KillEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'FA_Debug_Kill');

    //setup 
	Template.IconImage = "img:///UILibrary_FactionAnchor.UI_PerkAnchor";
	Template.AbilitySourceName = 'eAbilitySource_Debuff';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;
	Template.Hostility = eHostility_Neutral;
	Template.ConcealmentRule = eConceal_Always;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	// The shooter must NOT have the Vanish Effect
	UnitEffectsCondition = new class'X2Condition_UnitEffects';
	UnitEffectsCondition.AddExcludeEffect('Anchor', 'AA_UnitHasNotBeenRevealed');
	Template.AbilityShooterConditions.AddItem(UnitEffectsCondition);

	// Kill the unit
	KillEffect = new class'X2Effect_KillUnit';
	KillEffect.bHideDeathWorldMessage = true;
	Template.AddShooterEffect(KillEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	Template.bSkipFireAction = true;
	Template.bShowActivation = false;

	Template.bSkipExitCoverWhenFiring = true;

	return Template;
}
