/*  CS:GO Multi1v1: He grenade battle round addon
 *
 *  Copyright (C) 2018 Francisco 'Franc1sco' García
 * 
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) 
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with 
 * this program. If not, see http://www.gnu.org/licenses/.
 */
 
 
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <multi1v1>

#pragma semicolon 1
#pragma newdecls required

int g_iRoundType;

public Plugin myinfo = {
  name = "CS:GO Multi1v1: He grenade battle round addon",
  author = "Franc1sco franug",
  description = "Adds an unranked He grenade battle round-type",
  version = "1.1",
  url = "http://steamcommunity.com/id/franug"
};

public void Multi1v1_OnRoundTypesAdded() 
{
	// Add the custom round and get custom round index
	g_iRoundType = Multi1v1_AddRoundType("★手雷大战", "hegrenade", GrenadeHandler, true, false, "", true);
}

public void GrenadeHandler(int iClient) 
{
	// Start the custom round with a he grenade
	GivePlayerItem(iClient, "weapon_hegrenade");
	SetEntityHealth(iClient, 100);
	
	// Remove armor (Thanks to Wacci)
	SetEntProp(iClient, Prop_Data, "m_ArmorValue", 0);
}

public void OnEntityCreated(int iEntity, const char[] szClassname)
{
	// Check if new entity is a hegrenade
	if (!StrEqual(szClassname, "hegrenade_projectile"))
		return;
		
	// Hook spawn
	SDKHook(iEntity, SDKHook_Spawn, OnEntitySpawned);
}

public int OnEntitySpawned(int iEntity)
{
	// Get client index
	int iClient = GetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity");
	
	// checkers on the client index for prevent errors
	if (iClient == -1 || !IsClientInGame(iClient) || !IsPlayerAlive(iClient))
		return;
		
	// If current round is hegrenade round then do timer
	if(Multi1v1_GetCurrentRoundType(Multi1v1_GetArenaNumber(iClient)) == g_iRoundType)
		CreateTimer(1.4, Timer_GiveHe, GetClientUserId(iClient), TIMER_FLAG_NO_MAPCHANGE);

}

public Action Timer_GiveHe(Handle hTimer, int iUserid)
{
	// Get client index
	int iClient = GetClientOfUserId(iUserid);
		
	// checkers on the client index for prevent errors
	if (iClient == -1 || !IsClientInGame(iClient) || !IsPlayerAlive(iClient))
		return;
		
	// Check if the current round is still the dodgeball round
	if(Multi1v1_GetCurrentRoundType(Multi1v1_GetArenaNumber(iClient)) != g_iRoundType)
		return;

	// give a new hegrenade
	GivePlayerItem(iClient, "weapon_hegrenade");
}