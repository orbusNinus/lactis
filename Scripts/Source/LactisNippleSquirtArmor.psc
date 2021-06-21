Scriptname LactisNippleSquirtArmor extends ObjectReference  
 
Actor Property ActorRef Auto
Armor Property ArmorSelf Auto
Float[] Property NippleOffset Auto
Float Property GlobalEmitterScale Auto
Bool Property DebugAxisEnabled Auto
Bool Property UseRandomYRotation Auto
Bool Property UseRandomEmitterScale Auto
Bool Property UseRandomEmitterDeactivation Auto
String[] Property LevelNifs Auto

String Property LactisGroupName Auto
String Property LactisAxisName Auto
String Property LactisEmitter1Name Auto
String Property LactisEmitter2Name Auto
String Property LactisEmitter3Name Auto

Float[] rot 

Event OnInit()
    Console("OnInit:")   
    RegisterForSingleUpdate(0.02)
    rot = new Float[3]
EndEvent

Event OnGameLoad()    
    Console("OnGameLoad")    
    rot = new Float[3]
EndEvent

Event OnUnload()
    Console("OnUnload")
    ; UnregisterForUpdate()
    ; Debug.Trace("This object has been unloaded, animations can't be played on it anymore")
EndEvent

Event OnUnequipped(Actor akActor)
    Console("OnUnequipped: " + self)
EndEvent

Event OnEquipped(Actor akActor)     
    Console("OnEquipped: ") 
EndEvent

Event OnContainerChanged(ObjectReference akNewContainer, ObjectReference akOldContainer)        
    Console("OnContainerChanged: ") 
    If akNewContainer == ActorRef
        ; Console("OnContainerChanged: new container is ActorRef")        
        float ftimeStart = Utility.GetCurrentRealTime() 
        ActorRef.EquipItem(self.GetBaseObject(), false, true)
        float ftimeEnd  = Utility.GetCurrentRealTime() 
        
        ; Utility.Wait(0.05)
        UpdateNodeProperties()
        float ftimeEnd2  = Utility.GetCurrentRealTime() 
        ; Console("## Equipping took " + (ftimeEnd - ftimeStart) + "s. Updating node props took " + (ftimeEnd2-ftimeStart) + "s, " + ", total=" + (ftimeEnd-ftimeStart))
                
        ; RegisterForSingleUpdate(0.01)
        ; ActorRef.QueueNiNodeUpdate()        
        ; Utility.Wait(0.05)
    Else
        Console("OnContainerChanged: new container is " + akNewContainer)       
        ; armor was unequipped (isnt acually called?!)
    EndIf
EndEvent

Event OnUpdate()
    Console("OnUpdate")
    RegisterForSingleUpdate(3.0)
    
    if (UseRandomYRotation == true)
        ; Console("OnUpdate: UseRandomYRotation=" + UseRandomYRotation)
        NetImmerse.GetNodeLocalRotationEuler(ActorRef, LactisGroupName, rot, false)
        rot[2] = Utility.RandomFloat(-10, 10)
        NetImmerse.SetNodeLocalRotationEuler(ActorRef, LactisGroupName, rot, false)
       
    Else
        ; NetImmerse.SetNodeLocalRotationEuler(ActorRef, LactisGroupName, rot, false)
    EndIf
    
    ; Global emitter scale    
    Console("Applying globalEmitterScale " + GlobalEmitterScale + " to " + LactisGroupName + " node.")
    NetImmerse.SetNodeScale(ActorRef, LactisGroupName, GlobalEmitterScale, false)

    if (UseRandomEmitterScale)
        ; Console("OnUpdate: UseRandomEmitterScale=" + UseRandomEmitterScale)
        ; emitter wide scale        
        bool emitterOn = true
        float emitterScale = Utility.RandomFloat(0.5, 1.0)
        if (UseRandomEmitterDeactivation)
            emitterOn = Utility.RandomInt(0,1)
            if (emitterOn==0)
                emitterScale = 0.01
            endif
        endif
        NetImmerse.SetNodeScale(ActorRef, LactisEmitter1Name, emitterScale, false)

        emitterScale = Utility.RandomFloat(0.5, 1.0)
        if (UseRandomEmitterDeactivation)
            emitterOn = Utility.RandomInt(0,1)
            if (emitterOn==0)
                emitterScale = 0.01
            endif
        endif
        NetImmerse.SetNodeScale(ActorRef, LactisEmitter2Name, emitterScale, false)
        
        emitterScale = Utility.RandomFloat(0.5, 1.0)
        if (UseRandomEmitterDeactivation)
            emitterOn = Utility.RandomInt(0,1)
            if (emitterOn==0)
                emitterScale = 0.01
            endif
        endif
        NetImmerse.SetNodeScale(ActorRef, LactisEmitter3Name, emitterScale, false)
    EndIf

    
EndEvent

Function SetLevel(int index)
    Console("index=" + index)
    ArmorAddon aal = (self.GetBaseObject() as Armor).GetNthArmorAddon(0)
    aal.SetModelPath(levelNifs[index], false, true)
    ; ActorRef.QueueNiNodeUpdate()

    ; it seems that QueueNiNodeUpdate() does NOT force the new nif to be shown/loaded.
    ; unfortunately we have to do an UnequipItem/EquipItem cycle
    ; NiSwitchNode support would be gold here
    ActorRef.UnequipItem(self.GetBaseObject(), true, true)
    Utility.Wait(0.05)
    ActorRef.EquipItem(self.GetBaseObject(), true, true)
    Utility.Wait(0.05)
    UpdateNodeProperties()    
EndFunction


; Updates the offset of the left nipple squirt effect based on 'NippleOffset' which
; can be adjusted via MCM
; function UpdateNippleOffset()
; 	NetImmerse.SetNodeLocalPosition(ActorRef, LactisGroupName, NippleOffset, false)
;     ActorRef.QueueNiNodeUpdate()
; endfunction


; ; Updates the left debug axis. Changes it's scale depending on whether it is enabled
; ; in MCM or not. If disabled, scale will be set to 0 to make the axis invisible.
; Function UpdateDebugAxis() 
; 	if (DebugAxisEnabled==true)
; 		NetImmerse.SetNodeScale(ActorRef, LactisAxisName, 0.25, false)
; 	else
; 		NetImmerse.SetNodeScale(ActorRef, LactisAxisName, 0, false)
; 	endif
;     ActorRef.QueueNiNodeUpdate()
; EndFunction

; Updates the left debug axis. Changes it's scale depending on whether it is enabled
; in MCM or not. If disabled, scale will be set to 0 to make the axis invisible.
Function UpdateNodeProperties() 
	if (DebugAxisEnabled==true)
		NetImmerse.SetNodeScale(ActorRef, LactisAxisName, 0.25, false)
	else
		NetImmerse.SetNodeScale(ActorRef, LactisAxisName, 0, false)
	endif
    NetImmerse.SetNodeLocalPosition(ActorRef, LactisGroupName, NippleOffset, false)
    NetImmerse.SetNodeScale(ActorRef, LactisGroupName, GlobalEmitterScale, false)
    ActorRef.QueueNiNodeUpdate()
EndFunction


Function Console(String msg) 
	MiscUtil.PrintConsole("LactisNippleSquirtArmor: " + msg)
    Debug.Trace("LactisNippleSquirtArmor: " + msg)
EndFunction
