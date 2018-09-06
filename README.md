# lost_pilots
Pilot mod for Into the Breach

ABOUT

This mod aims to increase the variety of faces you see and dialogue you read with extra unlockable pilots.
Currently, this mod contains 11 new pilots, each with their own unique, original ability and a combined total of a few thousand lines of dialogue.

ACKNOWLEDGEMENTS

Lost pilots is drawn, written, designed, and programmed by Mezzelo.  Check out my other stuff at https://mezzelo.itch.io/.
Huge thanks to Lemonymous for bugtesting, providing the ReplaceRepair utility and to him and KartoFlane for additional help with some minor code snippets!

This mod utilizes the following modding utilities created by these kind community members:
Cyberboy2000: Original modloader
KartoFlane: Updated modloader, modding API and mod utils - https://github.com/kartoFlane/ITB-ModLoader, https://github.com/kartoFlane/ITB-ModUtils
Lemonymous: ReplaceRepair - http://www.subsetgames.com/forum/viewtopic.php?f=26&t=33470

INSTALLATION
After installing the modloader, just drop the "mezzpilots" folder under (root directory)/mods and you should be set.

If you'd like to unlock these pilots immediately, dive into your profile.lua and add
"Pilot_Physicist", "Pilot_Law", "Pilot_Veteran", "Pilot_Orphan", "Pilot_Scavenger", "Pilot_Widow", "Pilot_Alchemist", "Pilot_Ace", "Pilot_Climate", "Pilot_Angel", "Pilot_Sniper"
in the list ["Pilots"] surrounded by brackets on line 11.

Known ISSUES:
- This mod will not work with an existing timeline. You must finish or restart your current timeline to use it.
- This mod will likely be incompatible with most mods that affect pawn movespeed.  If any release in the future I'll make compatibility patches.
- This mod probably has some weird behaviors when combined with modded overwatch/reflexive fire abilities (i.e. evolved vek), I haven't been able to test this yet.
- There are several minor visual bugs I'm aware of.  Most of these are necessary and intentional compromises I've made due to the constraints of the utilities I've used in this mod.

CHANGELOG

Lastest Build: Build 5.6
- Fixed a bug breaking Ezel's ability.
- Fixed a bug throwing errors caused by Arvin's weapon tooltips.
- Refactored internal code
Latest Build: Build 5.52
- Slight visual revisions to some pilot portraits.
- Some dialogue revisions.
- Fixed a bug where A.C.I.D. immunity would not apply to Arvin.
- CTD finally fixed!
Build 5.4
- Slight visual revisions to some pilots
- Akemi and Aisa can no longer use their abilities while frozen.
- Masao's repair buffed back to 2 health.
- Some dialogue revisions.
Build 5.3
- Fixed one or two cases of CTD, hopefully I find the rest eventually.
- Slight visual revisions to some pilot portraits.
Build 5.2
- Fixed a bug where repositioning Arvin after shifting tiles using certain skills would duplicate status effects.
Build 5.1
- Fixed a minor movespeed bug I didn't know I could fix.

Lost Pilots Build 5 - 8/20/2018
- Five new pilots!
- Eleven new abilities total, one for each new pilot and six replacing abilities previously re-used from vanilla pilots.
	- Abilities shuffled around to accommodate these changes
	- Dialogue changed on certain pilots to reflect these changes
- Changed internal code to utilize newer modding APIs.
- Polished dialogue for existing pilots, typo/grammar fixes and general cringe reduction.
- Cleaned up/revised existing portraits, modified color scheme to better fit in with vanilla portraits.
- config.lua removed given support provided by modding APIs.

(six month hiatus)

Lost Pilots Build 3 - 3/11/2018 (12 days after release :U)
- Three new pilots added
- Three pilots now utilize unimplemented abilities, pilot abilities shifted around.
- Code dependencies changed to reduce duplicate republished code.
- Internal code modified to allow for configuration.
- config.lua added with instructions and configuration options
- Release!

PILOT INFORMATION

Victoria Swift
Command: -1 move, all other allied mechs gain +1 move.
An Archive commander, and a veteran of wars with and without the Vek.  Her advanced age does little to hamper her prowess, as she's proven time and time again.

Akemi Kobayashi
Return Fire: Fires a 2 damage ranged attack towards any enemy that attacks when aligned with this mech.
Known as the Angel of Archive for her incredible results on the field.  Some say the nickname is ironic, though few care to say why, and fewer are capable.

Knox Mandaba
Jetstream: +3 move, but must move a minimum of 4 tiles to move at all.
A seasoned pilot of Archive's ancient machinery, promoted to the field for her quick wits and her quicker operation of anything her superiors throw at her.

Solomon Renfield
Inertial Engines: -1 move, mech gains 1 movement per turn.
Esteemed scientist of R.S.T. known for his war-time innovations, on the field through some inane turn of events and bringing his knowledge of the world to battle.

Grizzly Saeki
Focus Shot: Instead of repairing, fires a 5 damage attack only damaging units exactly 5 tiles away.
A covert agent working for the R.S.T.  Doubts about her motives are quickly assuaged by her sharp aim and seemingly unfaltering loyalty.

Masao Sy
Ranged Repair: Repair friendly mechs for 2 health with a projectile, cannot repair self.
An operative under R.S.T. command.  His dubious origins are left unquestioned in the wake of his technical and tactical prowess.

Arvin Sanjrani
Status Shift: Swaps fire, smoke and A.C.I.D. of destination with current tile when manually moving between land tiles.
A Pinnacle climatologist, who understands the repercussions of the Vek intrusion on Earth and seeks to go above and beyond in preserving life.

Leta Narvaez
Preemptive Shield: Shields on repair instead of repairing.	
Once a retired veteran from Pinnacle, separated from her children through several timelines' worth of destruction and seeking to repay the Vek in kind.

Justyn Attlee
Flash Freeze: If injured, alive, and unfrozen when the player turn ends, mech automatically freezes and heals.
A Pinnacle laborer turned pilot for his sharp perception and his impressive ability to dig himself out of any bad situation, taking his fate into his own hands.

Aisa Minh
Reflex: Launches a 1 damage melee attack each time an enemy moves adjacent to this mech.
Detritus ex-law student.  Her career-ending disability was augmented by mech sensors and now lends itself to her rapid response against any threat.

Ezel Sinai
Azoth: Enemies lose 1 move a turn, enemies with over 3 move lose 2 move once.
Last seen serving under Vikram's direct employ for some unknown purpose, following unknown orders.  His torpid stare does little to divulge the intense knowledge he holds.
