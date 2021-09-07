;
;  █████╗  ██████╗████████╗ ██████╗ ██████╗     ███████╗████████╗ ██████╗ ██████╗  █████╗  ██████╗ ███████╗
; ██╔══██╗██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗    ██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗██╔══██╗██╔════╝ ██╔════╝
; ███████║██║        ██║   ██║   ██║██████╔╝    ███████╗   ██║   ██║   ██║██████╔╝███████║██║  ███╗█████╗  
; ██╔══██║██║        ██║   ██║   ██║██╔══██╗    ╚════██║   ██║   ██║   ██║██╔══██╗██╔══██║██║   ██║██╔══╝  
; ██║  ██║╚██████╗   ██║   ╚██████╔╝██║  ██║    ███████║   ██║   ╚██████╔╝██║  ██║██║  ██║╚██████╔╝███████╗
; ╚═╝  ╚═╝ ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝    ╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝
;                                                                                                          

ScriptName LactisActorStorage extends Form Hidden

string npcsKey = "LactisNpcs"
string offsetKey = "LactisNippleOffset"
string scaleKey = "LactisEmitterScale"

Function InitNpcStorage(Actor actorRef) 
	StorageUtil.FormListAdd(self, npcsKey, actorRef)
	StorageUtil.FloatListAdd(actorRef, offsetKey, 0.0)
	StorageUtil.FloatListAdd(actorRef, offsetKey, 0.0)
	StorageUtil.FloatListAdd(actorRef, offsetKey, 0.0)
	StorageUtil.SetFloatValue(actorRef, scaleKey, 1.0)
EndFunction

Function DeleteNpcStorage(Actor actorRef)
	if HasNpcStorage(actorRef)
		StorageUtil.FormListRemove(self, npcsKey, actorRef)
		StorageUtil.FloatListRemoveAt(actorRef, offsetKey, 0)
		StorageUtil.FloatListRemoveAt(actorRef, offsetKey, 1)
		StorageUtil.FloatListRemoveAt(actorRef, offsetKey, 2)
		StorageUtil.FloatListClear(actorRef, offsetKey)
		StorageUtil.UnsetFloatValue(actorRef, scaleKey)
	endif
EndFunction

Function Clear()
	int i = StorageUtil.FormListCount(self, npcsKey) - 1
	While i >= 0
		DeleteNpcStorage(GetNpcActor(i))
		i -= 1 
	EndWhile
	StorageUtil.FormListClear(self, npcsKey)
EndFunction

bool Function HasNpcStorage(Actor actorRef)
	return StorageUtil.FormListHas(self, npcsKey, actorRef)
EndFunction

float[] Function GetNpcOffset(Actor actorRef)
	float[] offset = new float[3]
	offset[0] = StorageUtil.FloatListGet(actorRef, offsetKey, 0)
	offset[1] = StorageUtil.FloatListGet(actorRef, offsetKey, 1)
	offset[2] = StorageUtil.FloatListGet(actorRef, offsetKey, 2)
	return offset
EndFunction

Function SetNpcOffset(Actor actorRef, float[] offset)
	if !HasNpcStorage(actorRef)
		InitNpcStorage(actorRef)
	endif
	StorageUtil.FloatListSet(actorRef, offsetKey, 0, offset[0])
	StorageUtil.FloatListSet(actorRef, offsetKey, 1, offset[1])
	StorageUtil.FloatListSet(actorRef, offsetKey, 2, offset[2])	
EndFunction

Function SetNpcOffsetIndex(Actor actorRef, int index, float offset)
	if !HasNpcStorage(actorRef)
		InitNpcStorage(actorRef)
	endif
	StorageUtil.FloatListSet(actorRef, offsetKey, index, offset)
EndFunction

; Emitter scale storage
Function SetNpcScale(Actor actorRef, float scale)
	if !HasNpcStorage(actorRef)
		InitNpcStorage(actorRef)
	endif
	StorageUtil.SetFloatValue(actorRef, scaleKey, scale)
EndFunction

float Function GetNpcScale(Actor actorRef)
	return StorageUtil.GetFloatValue(actorRef, scaleKey)
EndFunction

; Storage 

int Function GetNpcStorageCount()
	return StorageUtil.FormListCount(self, npcsKey)
EndFunction

Actor Function GetNpcActor(int index)
	return StorageUtil.FormListGet(self, npcsKey, index) as Actor
EndFunction