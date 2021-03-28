You created an XCOM 2 Mod Project!
 Yes, yes I did.... 

==========================================================================================================================
STEAM DESC          https://steamcommunity.com/sharedfiles/filedetails/?id=2387956032
==========================================================================================================================
[h1]What is this?[/h1]
This mod is a slightly unorthodox solution to a bug/issue that has been on my mind since the [url=https://steamcommunity.com/sharedfiles/filedetails/?id=1918499687] HIVE [/url] released back in 2019 !!

So the issue is this; when a mission has the 'sweep' objective (kill all remaining enemies) and the mission contains units from the CHL Faction Teams, they don't count towards this objective.
What this means in practice is that you could be having an epic 4-way battle and suddenly 'the last Lost' dies to an overwatch and boom, mission ends. To be honest this didn't bother me with any of the normal faction teams.
But HIVE changed my view on this when I lost a chance to kill the Queen by the above example.

I have spent time since that mission trying to find a solution, using MCO's, CHL notes and in discussion with some very talented modders. Nothing short of editing [i]every[/i] map/mission and kismet seemed to work (which is a highly incompatible solution).
The Kismet action just did not want to acknowledge the extra Faction Teams.
[b] -- until NOW! [/b]

[h1]Wha?.. you fixed this! How?[/h1]
Well, here's the unorthodox part. 'Kismet' is what the mission code runs on, it's kind of half-baked into the actual maps. The kismet only cares about units on the Advent or Lost teams. 
So... I give it an extra unit on the Advent team. Spawned post-mission start, this extra unit is immune to all damage and completely invisible to the player.
The kismet sweep objective correctly ID's this unit as an 'alive advent' and won't end the mission! 
... Now some code magic; each turn I have an event that checks on [b]ALL the alive units[/b], from every enemy team. Adds them all up. As long as the count is higher than 1 nothing happens.
But when the count gets to my special little hidden Faction Anchor unit being the last enemy unit alive, it kills it through code. Kismet sees 'the last enemy unit' has died. Mission ends.

[h3]Huzzah! No more abrupt mission endings with faction units in play![/h3]

As well as making you kill all faction units to complete the 'sweep' objective the mod also makes you correctly wait for (and kill) any faction team reinforcements that might be inbound. 

[h1]Known Issues[/h1]
Yeah, nothing is perfect, so here's what goes 'slightly' wrong;[olist]
[*]At mission start the camera pans to where the hidden unit is spawned.
[*]Flyovers for some effects may play on the unit, like 'Scanned' or 'Tactical Analysis'.
Mostly noticeable with larger AoE stuff ... and ... 
[*]I had some issues with odd targeting errors if the Anchor was within an AoE hit radius, it is still visibly hidden but can be aimed at by squadsight. Unable to reliably reproduce.
[*][url=https://steamcommunity.com/sharedfiles/filedetails/?id=749138678] Tactical UI Kill Counter [/url] reports the unit in its numbers. As does the end of mission report.
[*]The unit has some odd behaviour in correlation to the [i]X2AllowSelectAll[/i] console command. As it becomes selectable, duh!.
[*][b]Sometimes it will take an extra turn for the unit to notice it is the last unit and kill itself.[/b]
This means you may need to manually end your turn, to trigger the end of mission.
The code runs on 'turn order processed'...
[*]Sometimes the unit refuses to die by the event listener code ...
[/olist]
Woah, hold UP! That last issue could create never-ending missions! That's a huge bug reversal! [b]Yes[/b]. Although it IS rare. 5/100 test cases. AND here's what you can do about it;
Open the console and use the [i]X2AllowSelectAll true[/i] command. Tab to the unit, and it has a player-only-use ability to force it to die. Spam it to end the mission. This fallback method seemed to work, every time. You can also use the console command [i]KillAllAis[/i].

[h1]Compatibility[/h1]
Due to how some faction team units are actually 'expecting' the old rules and head into an infinite bleedout state ([url=https://steamcommunity.com/sharedfiles/filedetails/?id=1434693497]Rogue XCOM[/url], [url=https://steamcommunity.com/sharedfiles/filedetails/?id=1368992836]Rebellious MOCX[/url], [url=https://steamcommunity.com/sharedfiles/filedetails/?id=1129661000]MOCX[/url] ) you may need [b]Udaya's[/b] [url=https://steamcommunity.com/sharedfiles/filedetails/?id=1519721906] Execution[/url] ability to finish them off and end the mission [b]!![/b]

[h1]BETA Tag ?[/h1]
BETA tag is purely because this system needs widespread testing with multiple mod setups.
I can only test it so much by myself, and I'd love for feedback that it's working okay for others.

Could you please enable logging (in this mods configs) and send me a copy of your launch.log by either pastebin or discord for a mission that you softlock in and I will try to come up with a solution :)

[h1]Credits And Thanks[/h1]
[b]Massive Thanks[/b] to everyone that helped me over the last year with this mod project. From all my random questions on the xcom2 modders discord!
[b]MrShadowCX[/b] for the Ai behaviour tree pointers.
[b]ObelixDK[/b] for the 'make an invisible unit' help.
[b]Iridar[/b] and [b]Leader Enemy Boss[/b] for the Denmother mods unit spawning code.
[b]Iridar[/b] again for the solution to hide the death message pop-up.
[b]MrCloista[/b], [b]TeslaRage[/b] and [b]Flashstriker[/b] for helping me beta-test this solution to death.

~ Enjoy [b]!![/b] and please buy me a [url=https://www.buymeacoffee.com/RustyDios] Cuppa Tea [/url]
==========================================================================================================================
FACTION MODS DISCUSSION
==========================================================================================================================
This is a small list of the 'faction mods', that I have gathered;
[hr][/hr]
[h3]Faction Related Mods[/h3]
[url=https://steamcommunity.com/sharedfiles/filedetails/?id=1601260788]Raider Faction Bases[/url] - by RealityMachina
[url=https://steamcommunity.com/sharedfiles/filedetails/?id=2139432337]Raiders and Resistance Strategic Spawning[/url] - by RedDobe
[url=https://steamcommunity.com/sharedfiles/filedetails/?id=2157967646]AI to AI Activations[/url] - by RedDobe
[url=https://steamcommunity.com/sharedfiles/filedetails/?id=2294234510]Raider Unit Manager[/url] - by NightNinja54
[url=https://steamcommunity.com/sharedfiles/filedetails/?id=2219643198]Raider Uniform Manager[/url] - by RustyDios

[h3]by CreativeXenos[/h3]
[url=https://steamcommunity.com/sharedfiles/filedetails/?id=1918499687]HIVE[/url]
[url=https://steamcommunity.com/sharedfiles/filedetails/?id=1582632067]Black Legion[/url]

[h3]by RealityMachina[/h3]
[url=https://steamcommunity.com/sharedfiles/filedetails/?id=1129661000]MOCX[/url] (Technically doesn't count as on ADVENT Team) [b][i]See below[/i][/b]
[url=https://steamcommunity.com/sharedfiles/filedetails/?id=1961059683]Heretic Geth[/url]
[url=https://steamcommunity.com/sharedfiles/filedetails/?id=1368589567]Phantoms[/url] (Reapers)
[url=https://steamcommunity.com/sharedfiles/filedetails/?id=1368608233]Marauders[/url] (Skirmishers)
[url=https://steamcommunity.com/sharedfiles/filedetails/?id=1368626625]Cult of Jariah[/url] (Templars)
[url=https://steamcommunity.com/sharedfiles/filedetails/?id=1368613369]Bandits[/url] (Resistance)
[url=https://steamcommunity.com/sharedfiles/filedetails/?id=1434693497]Rogue XCOM[/url] (Some other organisation) [b][i]See below[/i][/b]
[url=https://steamcommunity.com/sharedfiles/filedetails/?id=1368992836]Rebellious MOCX[/url] (MOCX on Faction Team One) [b][i]See below[/i][/b]
[url=https://steamcommunity.com/sharedfiles/filedetails/?id=1369405598]Renegade Rulers[/url] (Technically as they become Faction Team One)

[h3]by Puma[/h3]
[url=https://steamcommunity.com/sharedfiles/filedetails/?id=1774066942]SCP Foundation MTF[/url]
[url=https://steamcommunity.com/sharedfiles/filedetails/?id=1781154099]Chaos Insurgency[/url]
[url=https://steamcommunity.com/sharedfiles/filedetails/?id=1930344321]Global Occult Coalition[/url]
[url=https://steamcommunity.com/sharedfiles/filedetails/?id=1961980059]Resistance Heroes Incursion[/url] (Technically doesn't count as on Resistance Team)

[h3]by Roland3710[/h3]
[url=https://steamcommunity.com/sharedfiles/filedetails/?id=1976289979]DarkEldar[/url]

[h3]by NightNinja54[/h3]
[url=https://steamcommunity.com/sharedfiles/filedetails/?id=2023889178]Mass Effect Terminus Mercs[/url]
[url=https://steamcommunity.com/sharedfiles/filedetails/?id=2023889038]Mass Effect Collectors[/url]
[url=https://steamcommunity.com/sharedfiles/filedetails/?id=1962940506]Mass Effect Cerberus[/url]
==========================================================================================================================

Texture2D       UILibrary_FactionAnchor.UI_PerkAnchor
Texture2D       UILibrary_FactionAnchor.UI_HUDIcon_Anchor
Texture2D       UILibrary_FactionAnchor.UI_HUDIcon_Anchor_bg
XComAlienPawn   GameUnit_Anchor.ARC_GameUnit_Anchor
SkeletalMesh    GameUnit_Anchor.Meshes.SM_Anchor
MITV            GameUnit_Anchor.Materials.M_Invisible_MITV_Anchor

==========================================================================================================================

@Iridar just throwing an idea your way and you can tell me if you think it is something worth pursuing or if I'm just going to waste my time (as it's not possible)?
So you know the bug where 'Faction Units' don't count towards the enemy units in play... and a mission will end if all advent/alien/lost die ... but you could have several, say HIVE units still in play ?
I have this idea that I'm trying to implement. When the mission loads I want to spawn an invisible unit on the alien team. this unit has 1hp, but can't be targeted by xcom/anything.... so an enemy unit 'always exists'....
now I want to bump this units health by 1 for each faction unit in play... and again for any faction unit spawned in during the mission....
... and then reduce it's health by 1 for any faction unit that has died...
effectively this units health should always equal number-faction units +1 .... 
....
now, I want this unit to have an 'on turn begun' ability, that checks for any remaining faction units && I'm the last advent ... if it gets to the point where it is the last advent, and there are no faction units
.. it does self damage of 1hp (which will kill it, if it's health has been tracking correctly).. and thus the mission now ends 'after all alien units have died' .... 
=================================
This is an interesting way to approach this issue, though you needlessly complicate it. You can simply listen to the 'OnUnitDied' and 'OnPlayerTurnEnded' events and check if the mission has any enemy units left, and if not,
then kill your dummy unit, HP tracking is unnecessary
Actually, even simpler, add a self target ability with OnPlayerTurnBegun ability trigger that kills the unit when the unit's turn begins, and add an X2Condition with your custom condition code
No need for additional listeners
That way the mission will end naturally in all the same circumstances where it would end if the player killed the last remaining advent unit
Though it will happen on the next advent turn,
I have a very basic understanding of how teams work, so I can't help you there. Spawning a unit is easy, though.
Since the unit doesn't need to be visualized in any way, you can simply create a new instance of XComGameState_Unit object
================================
well, I think I can manage the team checking... I'm struggling with the spawn unit though... and getting it to trigger
================================
Check out my Denmother mod, it does both create a unit and spawn it on the map
You can just throw away 95% of the code
Particularly the one that deals with visualizers
================================
