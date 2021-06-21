Scriptname OninusLactisMilkSquirtEffect extends ActiveMagicEffect
; ;PC self milking spell, npcs uses HentaiP.NpcMilking()

; Event OnEffectStart(Actor Target, Actor Caster)
; 	OninusLactis HentaiP = Quest.GetQuest("OninusLactisQuest") as OninusLactis
	
; 	If (!Caster.IsInCombat() && !Caster.IsOnMount())
; 		if (Caster.IsWeaponDrawn())
; 			Caster.SheatheWeapon()
; 		endIf
; 		If HentaiP.PlayerREF == Caster
; 			Game.DisablePlayerControls()
; 		Else
; 			;disable npc moving
; 			Caster.Setunconscious(true)
; 		EndIf

; 		;prevent other mods form interrupting milking		
; 		Debug.SendAnimationEvent(Caster,"hentaipregnancyZaZAPCHorFC")
		
; 		if Caster.GetFactionRank(HentaiP.HentaiLactatingFaction) > 0
; 			if(Utility.RandomInt(0, 1) == 1)	
; 				HentaiP.playLeftMilkEffect(Caster)
; 			else
; 				HentaiP.playRightMilkEffect(Caster)
; 			endif
			
; 			int howmuchtomilk = 1
; 			if HentaiP.config.MilkAllPC
; 				howmuchtomilk = Caster.GetFactionRank(HentaiP.HentaiLactatingFaction)
; 			endif
			
; 			Caster.ModFactionRank(HentaiP.HentaiLactatingFaction, -howmuchtomilk)
			
; 			if self.GetBaseObject() != HentaiP.HentaiMilkSquirtSpellEffect && Game.GetModbyName("HearthFires.esm") != 255 
; 				If HentaiP.PlayerREF == Caster
; 					if HentaiP.config.EnableMessages
; 						Debug.Notification(HentaiP.Strings.ShowHentaiMilkSquirtEffectStrings(0))
; 					EndIf
; 				EndIf
; 				Caster.AddItem(Game.GetFormFromFile(0x3534, "HearthFires.esm"), howmuchtomilk)
; 			else
; 				If HentaiP.PlayerREF == Caster
; 					if HentaiP.config.EnableMessages
; 						Debug.Notification(HentaiP.Strings.ShowHentaiMilkSquirtEffectStrings(1))
; 					EndIf
; 				EndIf
; 			endif
; 		else
; 			If HentaiP.PlayerREF == Caster
; 				if HentaiP.config.EnableMessages
; 					Debug.Notification(HentaiP.Strings.ShowHentaiMilkSquirtEffectStrings(2))
; 				EndIf
; 			EndIf
; 			HentaiP.playNoMilkEffect(Caster)
; 		endIf
; 		if Caster.GetFactionRank(HentaiP.HentaiLactatingFaction) > 0
; 			if HentaiP.PlayerREF == Caster && HentaiP.config.EnableMessages
; 				Debug.Notification(HentaiP.Strings.ShowHentaiMilkSquirtEffectStrings(3))
; 			EndIf
; 		EndIf
		
; 		int i = 0
; 		while i < HentaiP.PregnantActors.Length
; 				if HentaiP.PregnantActors[i].GetActorRef() == Caster
; 					HentaiP.PregnantActors[i].setMilk(HentaiP.PregnantActors[i].getMilk())
; 					i = HentaiP.PregnantActors.Length
; 				endIf
; 			i += 1
; 		endWhile
		
; 		Debug.SendAnimationEvent(Caster, "IdleForceDefaultState")
		
; 		;allow other mods to animate actor
; 		HentaiP.SexLab.ClearMFG(Caster)
; 		HentaiP.SexLab.AllowActor(Caster)
; 		Caster.RemoveFromFaction(HentaiP.SexLab.AnimatingFaction)

; 		If HentaiP.PlayerREF == Caster
; 			Game.EnablePlayerControls()
; 		Else
; 			;enable npc moving
; 			Caster.Setunconscious(false)
; 		EndIf
; 	EndIf
; endEvent