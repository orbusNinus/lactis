# Lactis
A simple lactating/nipple squirt mod for OStim. Supports individual player and 
NPC effect offset and scaling. 
It can be used without OStim in a non-lore friendly and non-immersive 
standalone mode using hotkeys.
This is a visual effect and no milk economy style mod. 

## Requirements
+ Skyrim: Special Edition (1.5.39+)
+ [SKSE64](https://skse.silverlock.org/) 
+ [OStim](https://www.nexusmods.com/skyrimspecialedition/mods/40725) and all 
  it's requirements (only if you want to use OStim integration)
+ [PapyrusUtil SE v3.9](https://www.nexusmods.com/skyrimspecialedition/mods/13048?tab=files) 
+ [CBBE 3BA (3BBB)](https://www.nexusmods.com/skyrimspecialedition/mods/30174) optional
+ [XPMSSE](https://www.nexusmods.com/skyrimspecialedition/mods/1988?tab=files)

## Features

### General
+ Useable with OStim and standalone
+ Customizable player and NPC nipple squirt offset and scaling.
+ (Optional) CBBE nipple leak overlay. 
+ For mod authors: Public API to integrate the effect into other mods.

### Standalone mode
+ Press "K" with no NPC under the crosshair to toggle the effect on/off for
  the player.
+ Press "K" key to toggle the effect on/off for any female NPC under the 
  crosshair. Supports up to 10 NPCs (including the player).
+ Press "Left Shift + K" to switch between three levels of squirt for the NPC
  under the crosshair (or the player if no NPC is under the crosshair). Effect
  for the actor must already be toggled on.
+ Press "Right Shift + Toggle Key" to force switch off the effect on the NPC
  under the crosshair. This should only be used as a last resort when the key
  "K" does not work as intended.

### OStim integration mode
+ If OStim is installed and integration is enabled in MCM, naked female 
  appearing actors will nipple squirt when spanked or on orgasm.
+ Nipple squirt scale can be increased by spanking (currently this resets the
  configured NPC effect scaling and uses the same scaling range for every 
  actor)
+ Nipple squirt duration can be configured via MCM for spank and orgasm squirt
  separately.
+ The "K" key is disabled during OStim scenes (might be changed in the future
  to have more control)


## Installation
Install with your favorite mod manager (developed and tested with MO2).

## Deinstallation
Click the uninstall option in the MCM menu. This will stop all running effects
and delete all stored actor settings and prepare the mod for deinstallation. 

After clicking the option you need to exit MCM, then save and exit the 
game. Deactivate the Lactis mod and restart the game again. Load your save, 
play for a little while, change cell, save and exit game again.
Use Resaver or similiar tools to clean your save. Done.

I consider this mod safe for the OStim effects.

When using standalone mode (key K) on various NPCs, leaving cells and 
saving/reloading save games, there might be issues with save game bloat which 
I didn't figure out yet. 

## Updating versions
From my personal experience it is safe to update existing saves with a new 
version by simply replacing the old version - as long as you ensured to stop
all active nipple squirt effects via the MCM "Reset all" option before the
update. After resetting, save!, exit the game and update the mod.

### Updating from <=v1.1 to v2.0
As v2.0 changes some internals of the mod, simply replacing the old version
might result in a minimal save game bloat, so if you are a keep-it-clean person
you should completely uninstall the old version before installing the new one.


## MCM settings export
The MCM setting can be exported to and imported from a file. Choose the option
"Export MCM settings" in the MCM menu and find the file in your Data folder at
'SKSE/Plugins/Lactis/MCM_Settings.json'.

Choose "Import MCM settings" to import from the file at the location mentioned
above.

Note that NPC offsets are NOT exported for now. This feature will be added in a
future release.

## Physics
Developed and works best with CBPC. With SMP nipple offset is somewhat 
off/delayed.

**TLDR; Use CBPC when using this mod for OStim scenes for best results.**

## Technical details
This mod was developed using XPMSSE and the 3BA body. It was tested by a BHUNP
user who confirmed that this works, too.

The left/right armor use the **body slots 58/59**.

### v0.4 - v1.1
The nipple squirt effect is implemented as two armors for the left and the 
right breast. The armor nif contains particle systems which are attached to 
the **bones named "L Breast03" and "R Breast03"**. I'm not quite sure where 
these bones come from (I assume XPMSSE) but **they need to be present** in the 
skeleton for the effect to be working correctly.

### v2.0
The nipple squirt effect is now implemented as one single armor which contains
the two armatures for the left and right nipple squirt effect. This results in 
faster equipping times and much simpler code.

## Known issues
+ Particles look weird from some angles.
+ When using SMP nipple offset is somehow delayed (CBPC works better)
+ During OStim scenes: Flickering face effects when using face lights. 
  Affects player and NPCs.
+ Not tested in 1st person mode. Might work, might be not.
+ It also might happen that you will not be able to stop the nipple squirt of 
  an NPC by using the toggle key. As a last resort you can try to 
  **Right Shift + Toggle Key"** on the NPC. This should remove the effect but can
  lead to save game bloat. (feature will be available in >v0.31)

## MCM configuration
Use MCM to configure nipple offset and scale for the player and NPCs. You can 
enable a debug axis to make this step easier.
Use other parameters to adjust effect if desired.

The standalone nipple squirt effect can be toggled on/off via the key "K" (can
be configured via MCM). This works for up to 10 NPCS and the player actor. The
effect can be toggled on/off at any time even when your character or the NPC is
not naked.

### Settings page

#### Toggle nipple squirt key
Key for toggling nipple squirting on/off on the player. Does not work during 
OStim scenes.

#### Player Nipple Offset
Player offset for the nipple squirt emitter origin. Adjust to match the 
player's body. Note that offset will be used for both breasts, x offset will
be adjusted for each side.

#### Enable OStim integration
Enables OStim integration. Female actors will nipple squirt on spank and orgasm
during an OStim scene.

#### Spank squirt duration
Nipple squirt duration on spank (in seconds).

#### Orgasm squirt duration
Nipple squirt duration on orgasm (in seconds).

#### Nipple squirt when not naked
Nipple squirt even when actor is not naked. This might help with revealing 
armors/clothing.

#### Enable nipple leak (CBBE EffectShader)
Enables an CBBE overlay texture which simulates nipple leak.

#### Enable debug axis
Enables a debug axis for nipple offset adjustments. Applies to player and NPCs.

#### Global emitter scale
Global emitter scale for left and right emitters. Applies to player and NPCs.

### Actor offsets page

Select an actor from *Stored actor offset* or *Nearby actors*.

Configure the offset and scale, all changes are automatically saved. You have 
to exit MCM and re-toggle the effect to have the new values applied.

## Thanks & asset contributors
Uses some textures textures from 
https://www.loverslab.com/topic/98782-sexlab-hentai-pregnancy-special-edition/ 
with permission.
