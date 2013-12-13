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

// GiveNamedItem(string classname, int subtype)
new Handle:hGiveNamedItem;
// Weapon_Equip(CBaseCombatWeapon * weapon)
new Handle:hWeapon_Equip;
// Weapon_Drop(CBaseCombatWeapon *,Vector const*,Vector const*)
new Handle:hWeapon_Drop;
// Weapon_Switch(CBaseCombatWeapon *,int)
new Handle:hWeapon_Switch;
// GiveAmmo(int, str, bool)
new Handle:hGiveAmmo;
// RemoveAllItems(bool remove_suit)
new Handle:hRemoveAllItems;
// Spawn(void)
new Handle:hSpawn;


// CPVK2Player::GetServerClass(void)
new Handle:hPVK2_GetServerClass;
// CPVK2Player::ChangeTeam(int)
new Handle:hPVK2_ChangeTeam;
// CPVK2Player::SetMaxArmor(int)
new Handle:hPVK2_SetMaxArmor;
// CPVK2Player::GetMaxArmor(void)
new Handle:hPVK2_GetMaxArmor;
// CPVK2Player::SetSpecial(int)
new Handle:hPVK2_SetSpecial;
// CPVK2Player::GetSpecial(void)
new Handle:hPVK2_GetSpecial;
// CPVK2Player::GetMaxSpecial(void)
new Handle:hPVK2_GetMaxSpecial;
// CPVK2Player::IsSpecialAvailable(void)
new Handle:hPVK2_IsSpecialAvailable;
// CPVK2Player::IncrementSpecial(int)
new Handle:hPVK2_IncrementSpecial;
// CPVK2Player::ReduceSpecial(int)
new Handle:hPVK2_ReduceSpecial;
// CPVK2Player::CancelSpecial(void)
new Handle:hPVK2_CancelSpecial;
// CPVK2Player::Knockback(float,CPVK2Player*)
new Handle:hPVK2_Knockback;
// CPVK2Player::IsBerserking(void)
new Handle:hPVK2_IsBerserking;
// CPVK2Player::SetBerserkTime(float)
new Handle:hPVK2_SetBerserkTime;
// CPVK2Player::GetBerserkTime(void)
new Handle:hPVK2_GetBerserkTime;
// CPVK2Player::StartBerserk(void)
new Handle:hPVK2_StartBerserk;
// CPVK2Player::StopBerserk(void)
new Handle:hPVK2_StopBerserk;
// CPVK2Player::HasHealthEffect(void)
new Handle:hPVK2_HasHealthEffect;
// CPVK2Player::AddHealthEffect(int,float,float,int,CBaseEntity *,CBaseEntity *)
new Handle:hPVK2_AddHealthEffect;
// CPVK2Player::ClearHealthEffects(void)
new Handle:hPVK2_ClearHealthEffects;
// CPVK2Player::PerformHealthEffects(void)
new Handle:hPVK2_PerformHealthEffects;
// CPVK2Player::GetFullHealthAdjustedHealthEffects(void)
new Handle:hPVK2_GetFullHealthAdjustedHealthEffects;
// CPVK2Player::AddToRoundScore(float)
new Handle:hPVK2_AddToRoundScore;
// CPVK2Player::ResetRoundScore(void)
new Handle:hPVK2_ResetRoundScore;
// CPVK2Player::GetRoundScore(void)
new Handle:hPVK2_GetRoundScore;
// CPVK2Player::ChangeClass(int)
new Handle:hPVK2_ChangeClass;
// CPVK2Player::InitClass(int)
new Handle:hPVK2_InitClass;
// CPVK2Player::SetDefaultSpeed(float)
new Handle:hPVK2_SetDefaultSpeed;
// CPVK2Player::GetDefaultSpeed(void)const
new Handle:hPVK2_GetDefaultSpeed;
// CPVK2Player::GetPlayerClass(void)const
new Handle:hPVK2_GetPlayerClass;
// CPVK2Player::IsStunned(void)
new Handle:hPVK2_IsStunned;
// CPVK2Player::GetStunAmount(void)
new Handle:hPVK2_GetStunAmount;

new h_iMaxHealth;
new h_iHealth;
new h_iMaxArmor;
new h_iArmorValue;
new h_flMaxspeed;
new h_flDefaultSpeed;
new h_iPlayerClass;
new h_OffsetFlags;
