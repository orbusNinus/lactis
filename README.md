# Lactis
A simple lactating/nipple squirt mod for OStim. This is a visual effect and no milk economy style mod.

## Requirements
+ Skyrim: Special Edition (1.5.39+)
+ [SKSE64](https://skse.silverlock.org/) 
+ [SkyUI SE](https://www.nexusmods.com/skyrimspecialedition/mods/12604)
+ [OStim](https://www.nexusmods.com/skyrimspecialedition/mods/40725) and all it's requirements
+ [PapyrusUtil SE v3.9](https://www.nexusmods.com/skyrimspecialedition/mods/13048?tab=files) optional
+ [CBBE 3BA (3BBB)](https://www.nexusmods.com/skyrimspecialedition/mods/30174) optional
+ [XPMSSE](https://www.nexusmods.com/skyrimspecialedition/mods/1988?tab=files)

## Installation
Install with your favorite mod manager (developed and tested with MO2).

## Deinstallation
Reset all active nipple squirt effects via the MCM menu before deinstalling the mod. 
I consider this mod safe for the OStim effects.
When using standalone mode (key K) on various NPCs, leaving cells and saving/reloading save games, there might be issues with save game bloat which I didn't figure out yet. 

## Features

+ (Optional) CBBE nipple leak overlay. 

### Standalone
+ Press "K" with no NPC under the crosshair to toggle the effect on/off for the player.
+ Press "K" key to toggle the effect on/off for any female NPC under the crosshair. Supports up to 10 NPCs (including the player).
+ Press "Left Shift + K" to switch between three levels of squirt for the NPC under the crosshair (or the player if no NPC is under the crosshair). Nipple squirt for the actor must already be toggled on.

### OStim integration
+ If OStim is installed and integration is enabled in MCM, naked female appearing actors will nipple squirt when spanked or on orgasm.
+ Nipple squirt scale can be increased by spanking. Currently the scale applies to all actors as I have not found a way to determine which actor got spanked.
+ Nipple squirt duration can be configured via MCM for spank and orgasm squirt separately.
+ The "K" key is disabled during OStim scenes (might be changed in the future to have more control)

## Physics
Developed and works best with CBPC. With SMP nipple offset is somewhat off/delayed.
Currently you can only configure one nipple offset which will be used for the player and all NPCs (which will result in incorrect placement when NPCs dont use the player body). Even worse, one would need separate nipple offsets for CBPC and SMP. This is not implemented. 

**TLDR; Use CBPC when using this mod for OStim scenes for best results.**

## Technical details
This mod was developed using XPMSSE and the 3BA body. It was tested by a BHUNP user who confirmed that this works, too.

The nipple squirt effect is implemented as two armors for the left and the right breast). The armor nif contains particle systems which are attached to the **bones named "L Breast03" and "R Breast03"**. I'm not quite sure where these bones come from (I assume XPMSSE) but they need to be present in the skeleton for the effect to be working correctly.

The left/right armor use the **body slots 58/59**.

## Known issues
+ Particles look weird from some angles.
+ When using SMP nipple offset is somehow delayed (CBPC works better)
+ During OStim scenes: Flickering face effects when using face lights. Affects player and NPCs.
+ Not tested in 1st person mode. Might work, might be not.
+ It also might happen that you will not be able to stop the nipple squirt of an NPC by using the toggle key. As a last resort you can try to **Right Shift + Toggle Key"** on the NPC. This should remove the effect but can lead to save game bloat. (feature will be available in >v0.31)

## MCM configuration
Use MCM to configure the left and right nipple offset. You can enable a debug axis to make this step easier.
Use other parameters to adjust effect if desired.

The standalone nipple squirt effect can be toggled on/off via the key "K" (can be configured via MCM). This works for up to 10 NPCS and the player actor. The effect can be toggled on/off at any time even when your character or the NPC is not naked.

### Toggle nipple squirt key
Key for toggling nipple squirting on/off on the player. Does not work during OStim scenes.

### Nipple Offset
Offset for the nipple squirt emitter origin. Adjust to match the player's body. Note that offset will be used for both breasts, x offset will be adjusted for each side.

### Enable OStim integration
Enables OStim integration. Female actors will nipple squirt on spank and orgasm during an OStim scene.

### Spank squirt duration
Nipple squirt duration on spank (in seconds).

### Orgasm squirt duration
Nipple squirt duration on orgasm (in seconds).

### Nipple squirt when not naked
Nipple squirt even when actor is not naked. This might help with revealing armors/clothing.

### Enable nipple leak (CBBE EffectShader)
Enables an CBBE overlay texture which simulates nipple leak.

### Enable debug axis
Enables a debug axis for nipple offset adjustments.

### Global emitter scale
Global emitter scale for left and right emitters.


