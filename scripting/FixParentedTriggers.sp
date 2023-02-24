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

#define FSOLID_TRIGGER 0x0008

Handle g_hPhysicsTouchTriggers;

int g_iSolidFlags;

public void OnPluginStart()
{
	Handle hGameData = LoadGameConfigFile("FixParentedTriggers.games");

	if(hGameData == INVALID_HANDLE)
	{
		SetFailState("Couldn't load FixParentedTriggers game config!");
		return;
	}

	// CBaseEntity::PhysicsTouchTriggers
	g_hPhysicsTouchTriggers = DHookCreateFromConf(hGameData, "CBaseEntity__PhysicsTouchTriggers");
	if(!g_hPhysicsTouchTriggers)
	{
		delete hGameData;
		SetFailState("Failed to setup detour for CBaseEntity_::PhysicsTouchTriggers");
	}

	if(!DHookEnableDetour(g_hPhysicsTouchTriggers, false, Detour_PhysicsTouchTriggers))
	{
		delete hGameData;
		SetFailState("Failed to detour CBaseEntity::PhysicsTouchTriggers.");
	}

	CloseHandle(hGameData);
}

public void OnPluginEnd()
{
	DHookDisableDetour(g_hPhysicsTouchTriggers, false, Detour_PhysicsTouchTriggers);
}

public void OnMapStart()
{
	g_iSolidFlags = FindDataMapInfo(0, "m_usSolidFlags");
}

// void CBaseEntity::PhysicsTouchTriggers( const Vector *pPrevAbsOrigin )
public MRESReturn Detour_PhysicsTouchTriggers(int iEntity)
{
	if (GetEntData(iEntity, g_iSolidFlags) & FSOLID_TRIGGER)
		return MRES_Supercede;

	return MRES_Ignored;
}