/*******************************************************************************
*   This file is part of TestMod.
*
*   TestMod is free software: you can redistribute it and/or modify
*   it under the terms of the GNU General Public License as published by
*   the Free Software Foundation, either version 3 of the License, or
*   (at your option) any later version.
*
*   TestMod is distributed in the hope that it will be useful,
*   but WITHOUT ANY WARRANTY; without even the implied warranty of
*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*   GNU General Public License for more details.
*
*   You should have received a copy of the GNU General Public License
*   along with TestMod.  If not, see <http://www.gnu.org/licenses/>.
*
*   Copyright 2013-2014, Marty "MadKat" Lewis
*******************************************************************************/

#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#define PL_VERSION "0.1"
#define SERVER_TAG "tm"

#include "include/colors.sp"

#include "weaponsmaster.h"
#include "wm_config.h"
#include "tm_sdk.h"

#include "wm_config.sp"
#include "wm_logic.sp"
#include "tm_sdk.sp"

public Plugin:myinfo = {
    name        = "TestMod",
    author      = "MadKat",
    description = "Test the limitations of SourceMod plugins within PVKII.",
    version     = PL_VERSION,
    url         = "http://www.github.com/madkat"
}

public OnPluginStart() {

    InitSDKCalls();
    InitCVARs();
    SetupSoundDefaults();
    ReadConfig();
    InitSounds();
    
    /*
	Event Hooks
    */
    HookEvent("player_spawn", OnPlayerSpawn);
    HookEvent("player_death", OnPlayerDeath);
    HookEvent("player_changeteam", OnPlayerChangeTeam);
    HookEvent("player_changeclass", OnPlayerChangeClass);
    HookEvent("player_special", OnPlayerSpecial);

    HookEvent("round_end",			OnUnhandledEvent, EventHookMode_Pre);
    HookEvent("gamemode_roundrestart",		OnUnhandledEvent, EventHookMode_Pre);
    HookEvent("gamemode_territory_capture",	OnUnhandledEvent, EventHookMode_Pre);
    HookEvent("gamemode_territory_guard",	OnUnhandledEvent, EventHookMode_Pre);
    HookEvent("gamemode_territory_contested",	OnUnhandledEvent, EventHookMode_Pre);
    HookEvent("game_end", 			OnUnhandledEvent, EventHookMode_Pre);
    HookEvent("grail_pickup", 			OnUnhandledEvent, EventHookMode_Pre);
    HookEvent("chest_respawn", 			OnUnhandledEvent, EventHookMode_Pre);
    HookEvent("chest_pickup", 			OnUnhandledEvent, EventHookMode_Pre);

    HookEvent("gamemode_firstround_wait_begin",	OnGameModeFirstRoundBegin, EventHookMode_Pre);
    HookEvent("gamemode_firstround_wait_end",	OnGameModeFirstRoundEnd, EventHookMode_Pre);

    HookEvent("gamemode_suddendeath_begin",	OnUnhandledEvent, EventHookMode_Pre);
    
    RegAdminCmd("wm_levelplayer", AdminCommand_LevelPlayer, ADMFLAG_SLAY);
    RegAdminCmd("wm_levelallplayers", AdminCommand_LevelAllPlayers, ADMFLAG_SLAY);
    RegAdminCmd("wm_testsound", AdminCommand_TestSound, ADMFLAG_SLAY);
    RegAdminCmd("wm_testspree", AdminCommand_TestSpree, ADMFLAG_SLAY);

    AddServerTag(SERVER_TAG);
}

Debug(const String:message[], any:...)
{
    if (cvar_debug) {
        new String:formatted_string[strlen(message)+255];
	VFormat(formatted_string, strlen(message)+255, message, 2);
        PrintToServer("[WeaponsMaster] %s", formatted_string);
    }
}

public Action:OnDisabledEvent(Handle:event, const String:name[], bool:dontBroadcast)
{
    return Plugin_Handled;
}

public Action:OnGameModeFirstRoundBegin(Handle:event, const String:name[], bool:dontBroadcast)
{
    LaunchWarmupTimer();
    Debug("First Round Begins");
    WarmupInProgress = true;
    return Plugin_Continue;
}

public Action:OnGameModeFirstRoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
    Debug("First Round Ends");
    if (WarmupRemaining > 0) {
        WarmupRemaining = 0;
    }
    WarmupInProgress = false;
    return Plugin_Continue;
}

public Action:OnUnhandledEvent(Handle:event, const String:name[], bool:dontBroadcast)
{
    return Plugin_Continue;
}

public Action:AdminCommand_LevelPlayer(client, args) {
    TryLevelUp(client, 0, WeaponNames[WeaponOrder[ClientPlayerLevel[client]]], false);
    return Plugin_Handled;
}

public Action:AdminCommand_TestSound(client, args) {
    PlaySound(client, Welcome);
    return Plugin_Handled;
}

public Action:AdminCommand_TestSpree(client, args) {
    HandleKillingSpree(client);
    return Plugin_Handled;
}

public Action:AdminCommand_LevelAllPlayers(client, args) {
    for (new i = 1; i <= MaxClients; i++) if (IsClientInGame(i)) GiveWeapons(client);
    return Plugin_Handled;
}

public OnClientPutInServer(client) {
    if (cvar_enabled) {
	ClientUserID[client] = 0;
	ClientPlayerLevel[client] = 0;
	ClientKillCounter[client] = 0;
	ClientSpreeCounter[client] = 0;
	ClientSpreeEffects[client] = 0;
        ClientPlayerDead[client] = 1;
	ClientFirstJoin[client] = 1;
        ClientPlayerSpecial[client] = 0;

	SetEntData(client, h_iMaxHealth,	-1, 4, true);
	SetEntData(client, h_iHealth,		-1, 4, true);
	SetEntData(client, h_iMaxArmor,		-1, 4, true);
	SetEntData(client, h_iArmorValue,	-1, 4, true);
	SetEntDataFloat(client, h_flMaxspeed,	  -1.0, true);
	SetEntDataFloat(client, h_flDefaultSpeed, -1.0, true);
    }
}

public OnMapStart() {
    Debug("Map Start Called");
    for (new i = 1; i <= MaxClients; i++) if (IsClientInGame(i)) OnClientPutInServer(i);
    LeaderLevel = 0;
    LeaderName = "";
    GameWon = false;

    ReadConfig();
    InitSounds();
}

public OnMapEnd() {
    for ( new Sounds:i = Welcome; i < MaxSounds; i++ )
    {
        EventSounds[i][0] = '\0';
    }
}

public OnPlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast) {
    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    if (!client || !IsPlayerAlive(client) || !IsClientInGame(client) || !cvar_enabled)
	return;

    if (!ClientFirstJoin[client] && !ClientPlayerDead[client]) {
        if (!IsFakeClient(client)) {
            PrintLevelInfo(client);
        }
    }
    else {
        ClientPlayerDead[client] = 0;
    }

    new current_class = GetEntData(client, h_iPlayerClass);
    if (current_class >= 0) {
        if (!IsFakeClient(client)) {
            if (ClientFirstJoin[client]) {
                ClientFirstJoin[client] = 0;
                PlaySound(client, Welcome);
            }
        }
    }

    /*
    new current_health = GetEntData(client, h_iHealth);
    if (current_health <= 0) {
        return;
    }
    */

    SetEntData(client, h_iMaxHealth,	CfgPlayerMaxHealth, 4, true);
    SetEntData(client, h_iHealth,	CfgPlayerMaxHealth, 4, true);
    SetEntData(client, h_iMaxArmor,	CfgPlayerMaxArmor, 4, true);
    SetEntData(client, h_iArmorValue,	CfgPlayerMaxArmor, 4, true);
    SetEntDataFloat(client, h_flMaxspeed,	CfgPlayerMoveSpeed, true);
    SetEntDataFloat(client, h_flDefaultSpeed,	CfgPlayerMoveSpeed, true);

    if (GameWon) {
	FreezeClient(client);
	return;
    }

    LaunchDelayGiveWeapons(client);
}

public OnPlayerChangeTeam(Handle:event, const String:name[], bool:dontBroadcast) {
    new client = GetClientOfUserId(GetEventInt(event, "client"));
    if (!client || !IsPlayerAlive(client) || !IsClientInGame(client) || !cvar_enabled)
	return;

    ClientPlayerDead[client] = 1;
}

public OnPlayerChangeClass(Handle:event, const String:name[], bool:dontBroadcast) {
    new client = GetClientOfUserId(GetEventInt(event, "client"));
    if (!client || !IsPlayerAlive(client) || !IsClientInGame(client) || !cvar_enabled)
	return;

    ClientPlayerDead[client] = 1;
}

public OnPlayerSpecial(Handle:event, const String:name[], bool:dontBroadcast) {
    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    if (!client || !IsPlayerAlive(client) || !IsClientInGame(client) || !cvar_enabled)
	return;

    decl String:weapon[W_STRING_LEN];
    GetClientWeapon(client, weapon, W_STRING_LEN);
    new pos = FindCharInString(weapon, '_') + 1;

    if (StrEqual(WeaponNames[Weapon:GestirSpear], weapon[pos])
        || StrEqual(WeaponNames[Weapon:HuscarlSwordShield], weapon[pos])
        || StrEqual(WeaponNames[Weapon:SkirmisherCutlass], weapon[pos])) {
        ClientPlayerSpecial[client] = 1;
        LaunchHandleSpecial(client);
    }
}

public OnPlayerDeath(Handle:event, const String:name[], bool:dontBroadcast) {
    new victim = GetClientOfUserId(GetEventInt(event, "userid"));
    new client = GetClientOfUserId(GetEventInt(event, "attacker"));
    new special = GetEventBool(event, "special");
    if (!client || !IsPlayerAlive(client) || !IsClientInGame(client) || !cvar_enabled)
	return;

    if (ClientPlayerSpecial[victim] == 2) {
        HandleSpecial(Handle:0, victim);
    }

    ClientPlayerDead[victim] = 1;

    decl String:weapon[W_STRING_LEN];
    GetEventString(event, "weapon", weapon, W_STRING_LEN);
    Debug("Player got kill with %s", weapon);
    
    TryLevelUp(client, victim, weapon, special);
}
