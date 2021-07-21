Scriptname OninusLactisMCM extends SKI_ConfigBase

OninusLactis Main

; option references
Int optionKeyStartLactating
Int optionOffsetLeftX
Int optionOffsetLeftY
Int optionOffsetLeftZ
; Int optionOffsetRightX
; Int optionOffsetRightY
; Int optionOffsetRightZ
Int optionGlobalEmitterScale
Int optionOStimIntegrationEnabled
Int optionOStimSpankSquirtDuration
Int optionOStimOrgasmSquirtDuration
Int optionOStimNonNakedSquirtEnabled
Int optionNippleLeakEnabled
Int optionDebugAxisEnabled
Int optionRandomYRotEnabled
Int optionRandomEmitterScaleEnabled
Int optionRandomEmitterDeactivationEnabled
Int optionResetAll

Event OnInit()
	Init()
EndEvent

Function Init()
    Parent.OnGameReload()
    Main = (Self as Quest) as OninusLactis
EndFunction

Event OnPageReset(string page)
    If (Page == "")
    ElseIf Page == ("Settings")		
        SetCursorFillMode(TOP_TO_BOTTOM)
        AddHeaderOption("Keyboard (Manual mode)")        
        optionKeyStartLactating = AddKeyMapOption("Toggle nipple squirt key", Main.StartLactatingKey)
		AddHeaderOption("Nipple Offset")
        optionOffsetLeftX = AddSliderOption("Left / Right", Main.NippleOffsetL[0], "{2}")        
        optionOffsetLeftY = AddSliderOption("Up / Down", Main.NippleOffsetL[2], "{2}")
        optionOffsetLeftZ = AddSliderOption("Back / Forth", Main.NippleOffsetL[1], "{2}")
		; AddHeaderOption("Nipple Offset Right")
        ; optionOffsetRightX = AddSliderOption("Left / Right", Main.NippleOffsetR[0], "{2}")        
        ; optionOffsetRightY = AddSliderOption("Up / Down", Main.NippleOffsetR[2], "{2}")
        ; optionOffsetRightZ = AddSliderOption("Back / Forth", Main.NippleOffsetR[1], "{2}")
		if Main.HasOStim()
			AddHeaderOption("OStim integration")
			optionOStimIntegrationEnabled = AddToggleOption("Enable OStim integration", Main.OStimIntegrationEnabled)
			optionOStimSpankSquirtDuration = AddSliderOption("Spank squirt duration", Main.OStimSpankSquirtDuration, "{2}")        
			optionOStimOrgasmSquirtDuration = AddSliderOption("Orgasm squirt duration", Main.OStimOrgasmSquirtDuration, "{2}")        
			optionOStimNonNakedSquirtEnabled = AddToggleOption("Nipple squirt when not naked", Main.OStimNonNakedSquirtEnabled)
		endif		
		optionNippleLeakEnabled = AddToggleOption("Enable nipple leak (CBBE EffectShader)", Main.NippleLeakEnabled)
		AddHeaderOption("Debug")
		optionDebugAxisEnabled = AddToggleOption("Enable debug axis", Main.DebugAxisEnabled)
		optionGlobalEmitterScale = AddSliderOption("Global emitter scale", Main.GlobalEmitterScale, "{2}") 		        
		; AddHeaderOption("Experimental")
		; optionRandomYRotEnabled = AddToggleOption("Enable random Y rotation", Main.UseRandomYRotation)
		; optionRandomEmitterScaleEnabled = AddToggleOption("Enable random emitter scale", Main.UseRandomEmitterScale)
		; optionRandomEmitterDeactivationEnabled = AddToggleOption("Enable random emitter deactivation", Main.UseRandomEmitterDeactivation)
		SetCursorPosition(1)
		AddTextOption("Active nipple squirts", Main.GetArmoredActorsCount() )
		optionResetAll = AddTextOption("Reset all", "Click")
    EndIF
EndEvent

event OnOptionSelect(int option)
	if (option == optionOStimIntegrationEnabled)
		Main.OStimIntegrationEnabled = !Main.OStimIntegrationEnabled
		SetToggleOptionValue(optionOStimIntegrationEnabled, Main.OStimIntegrationEnabled)
	elseif (option == optionOStimNonNakedSquirtEnabled)
		Main.OStimNonNakedSquirtEnabled = !Main.OStimNonNakedSquirtEnabled
		SetToggleOptionValue(optionOStimNonNakedSquirtEnabled, Main.OStimNonNakedSquirtEnabled)
	elseif (option == optionNippleLeakEnabled)
		Main.NippleLeakEnabled = !Main.NippleLeakEnabled
		SetToggleOptionValue(optionNippleLeakEnabled, Main.NippleLeakEnabled)		
	elseif (option == optionDebugAxisEnabled)
		Main.DebugAxisEnabled = !Main.DebugAxisEnabled
		SetToggleOptionValue(optionDebugAxisEnabled, Main.DebugAxisEnabled)
	elseif (option == optionRandomYRotEnabled)		
		Main.UseRandomYRotation = !Main.UseRandomYRotation
		SetToggleOptionValue(optionRandomYRotEnabled, Main.UseRandomYRotation)		
	elseif (option == optionRandomEmitterScaleEnabled)		
		Main.UseRandomEmitterScale = !Main.UseRandomEmitterScale
		SetToggleOptionValue(optionRandomEmitterScaleEnabled, Main.UseRandomEmitterScale)
	elseif (option == optionRandomEmitterDeactivationEnabled)		
		Main.UseRandomEmitterDeactivation = !Main.UseRandomEmitterDeactivation
		SetToggleOptionValue(optionRandomEmitterDeactivationEnabled, Main.UseRandomEmitterDeactivation)
	ElseIf (option == optionResetAll)
		Main.StopAllNippleSquirts()
	endIf
endEvent

event OnOptionSliderOpen(int option)
	if (option == optionOffsetLeftX)
		SetSliderDialogStartValue(Main.NippleOffsetL[0])
		SetSliderDialogDefaultValue(0.0)
		SetSliderDialogRange(-7, 7)
		SetSliderDialogInterval(0.1)
	elseIf (option == optionOffsetLeftY)
		SetSliderDialogStartValue(Main.NippleOffsetL[2])
		SetSliderDialogDefaultValue(0.0)
		SetSliderDialogRange(-7, 7)
		SetSliderDialogInterval(0.1)
	elseIf (option == optionOffsetLeftZ)
		SetSliderDialogStartValue(Main.NippleOffsetL[1])
		SetSliderDialogDefaultValue(0.0)
		SetSliderDialogRange(-7, 7)
		SetSliderDialogInterval(0.1)
	; elseif (option == optionOffsetRightX)
	; 	SetSliderDialogStartValue(Main.NippleOffsetR[0])
	; 	SetSliderDialogDefaultValue(0.0)
	; 	SetSliderDialogRange(-7, 7)
	; 	SetSliderDialogInterval(0.1)
	; elseIf (option == optionOffsetRightY)
	; 	SetSliderDialogStartValue(Main.NippleOffsetR[2])
	; 	SetSliderDialogDefaultValue(0.0)
	; 	SetSliderDialogRange(-7, 7)
	; 	SetSliderDialogInterval(0.1)
	; elseIf (option == optionOffsetRightZ)
	; 	SetSliderDialogStartValue(Main.NippleOffsetR[1])
	; 	SetSliderDialogDefaultValue(0.0)
	; 	SetSliderDialogRange(-7, 7)
	; 	SetSliderDialogInterval(0.1)
	elseIf (option == optionGlobalEmitterScale)
		SetSliderDialogStartValue(Main.GlobalEmitterScale)
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogRange(0.1, 4)
		SetSliderDialogInterval(0.1)
	elseIf (option == optionOStimSpankSquirtDuration)
		SetSliderDialogStartValue(Main.OStimSpankSquirtDuration)
		SetSliderDialogDefaultValue(1.5)
		SetSliderDialogRange(0.2, 5)
		SetSliderDialogInterval(0.05)
	elseIf (option == optionOStimOrgasmSquirtDuration)
		SetSliderDialogStartValue(Main.OStimOrgasmSquirtDuration)
		SetSliderDialogDefaultValue(3)
		SetSliderDialogRange(1, 15)
		SetSliderDialogInterval(1)
	endIf
endEvent

event OnOptionSliderAccept(int option, float value)
	if (option == optionOffsetLeftX)
		Main.NippleOffsetL[0] = value
		Main.NippleOffsetR[0] = -value
		SetSliderOptionValue(optionOffsetLeftX, Main.NippleOffsetL[0], "{2}")
	elseIf (option == optionOffsetLeftY)
		Main.NippleOffsetL[2] = value
		Main.NippleOffsetR[2] = value
		SetSliderOptionValue(optionOffsetLeftY, Main.NippleOffsetL[2], "{2}")
	elseIf (option == optionOffsetLeftZ)
		Main.NippleOffsetL[1] = value
		Main.NippleOffsetR[1] = value
		SetSliderOptionValue(optionOffsetLeftZ, Main.NippleOffsetL[1], "{2}")        		
	; elseif (option == optionOffsetRightX)
	; 	Main.NippleOffsetR[0] = value
	; 	SetSliderOptionValue(optionOffsetRightX, Main.NippleOffsetR[0], "{2}")        
	; 	; Main.UpdateArmorRightProperties()
	; elseIf (option == optionOffsetRightY)
	; 	Main.NippleOffsetR[2] = value
	; 	SetSliderOptionValue(optionOffsetRightY, Main.NippleOffsetR[2], "{2}")        
	; elseIf (option == optionOffsetRightZ)
	; 	Main.NippleOffsetR[1] = value
	; 	SetSliderOptionValue(optionOffsetRightZ, Main.NippleOffsetR[1], "{2}")        		
	elseIf (option == optionGlobalEmitterScale)
		Main.GlobalEmitterScale = value
		SetSliderOptionValue(optionGlobalEmitterScale, Main.GlobalEmitterScale, "{2}")        		
	elseIf (option == optionOStimSpankSquirtDuration)
		Main.OStimSpankSquirtDuration = value
		SetSliderOptionValue(optionOStimSpankSquirtDuration, Main.OStimSpankSquirtDuration, "{2}")        		
	elseIf (option == optionOStimOrgasmSquirtDuration)
		Main.OStimOrgasmSquirtDuration = value
		SetSliderOptionValue(optionOStimOrgasmSquirtDuration, Main.OStimOrgasmSquirtDuration, "{2}")        				
	endIf	
endEvent

Event OnOptionKeyMapChange(Int Option, Int KeyCode, String ConflictControl, String ConflictName)
	; Main.PlayTickBig()
    MiscUtil.PrintConsole("KeyMap Option: "+ Option + ", KeyCode: " + KeyCode + ", optionKeyStartLactating: " + optionKeyStartLactating)
	If (Option == optionKeyStartLactating)		
        Main.RemapStartLactatingKey(KeyCode)
		SetKeyMapOptionValue(Option, KeyCode)
    Else
        MiscUtil.PrintConsole("KeyMap Option: Unknown/unsupported/niy option " + Option + " changed.")
    EndIf
EndEvent

event OnOptionHighlight(int option)
	{Called when the user highlights an option}
	
	if option == optionKeyStartLactating
		SetInfoText("Key for toggling nipple squirting on/off on the player. Does not work during OStim scenes.")
	elseIf option == optionOffsetLeftX || option == optionOffsetLeftY || option == optionOffsetLeftZ
		SetInfoText("Offset for the nipple squirt emitter origin. Adjust to match the player's body. Note that offset will be used for both breasts, x offset will be adjusted for each side.")
	; elseIf option == optionOffsetRightX || option == optionOffsetRightY || option == optionOffsetRightZ
	; 	SetInfoText("Offset for the right nipple squirt emitter origin. Adjust to match the player's body.")
	elseif option == optionGlobalEmitterScale
		SetInfoText("Global emitter scale for left and right emitters.")
	elseif option == optionOStimIntegrationEnabled
		SetInfoText("Enables OStim integration. Female actors will nipple squirt on spank and orgasm during an OStim scene.")
	elseif option == optionOStimSpankSquirtDuration
		SetInfoText("Nipple squirt duration on spank (in seconds).")
	elseif option == optionOStimOrgasmSquirtDuration
		SetInfoText("Nipple squirt duration on orgasm (in seconds).")
	elseif option == optionOStimNonNakedSquirtEnabled
		SetInfoText("Nipple squirt even when actor is not naked. This might help with revealing armors/clothing.")
	elseif option == optionNippleLeakEnabled
		SetInfoText("Enables an CBBE overlay texture which simulates nipple leak.")
	elseif option == optionDebugAxisEnabled
		SetInfoText("Enables a debug axis for nipple offset adjustments.")
	elseif option == optionRandomYRotEnabled || option == optionRandomEmitterScaleEnabled || option == optionRandomEmitterDeactivationEnabled
		SetInfoText("Experimental feature which may result in unpredictable behaviour. Dont't use it.")
	elseif option == optionResetAll
		SetInfoText("Removes nipple squirt effect from all actors.")
	else 
		SetInfoText("")
	endIf
endEvent