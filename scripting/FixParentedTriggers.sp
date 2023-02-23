#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <dhooks>

public Plugin myinfo =
{
	name 			= "Fix parented triggers",
	author 			= "xen",
	description 	= "Fixes parented triggers firing every frame while touched",
	version 		= "1.0",
	url 			= ""
};

Handle g_hPhysicsTouchTriggers;

public void OnPluginStart()
{
	Handle hGameConf = LoadGameConfigFile("FixParentedTriggers.games");

	if(hGameConf == INVALID_HANDLE)
	{
		SetFailState("Couldn't load FixParentedTriggers game config!");
		return;
	}

	int offset = GameConfGetOffset(hGameConf, "PhysicsTouchTriggers");
	g_hPhysicsTouchTriggers = DHookCreate(offset, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, PhysicsTouchTriggers);
	DHookAddParam(g_hPhysicsTouchTriggers, HookParamType_VectorPtr);

	CloseHandle(hGameConf);
}

public void OnEntityCreated(int iEntity, const char[] sClassname)
{
	if(StrContains(sClassname, "trigger_", false) != -1)
		DHookEntity(g_hPhysicsTouchTriggers, false, iEntity);
}

// void CBaseEntity::PhysicsTouchTriggers( const Vector *pPrevAbsOrigin )
public MRESReturn PhysicsTouchTriggers()
{
	return MRES_Supercede;
}