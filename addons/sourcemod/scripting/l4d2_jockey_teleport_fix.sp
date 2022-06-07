#include <colors>
#include <left4dhooks>
#include <sdkhooks>
#include <sdktools>
#include <sourcemod>

#define UPDATE_URL "https://raw.githubusercontent.com/eyal282/l4d2-jockey-teleport-fix/master/addons/sourcemod/updatefile.txt"

#define HAMMER_WORLD_EDITOR_CENTER view_as<float>({ 0.0, 0.0, 0.0 })

float g_fLastOrigin[MAXPLAYERS + 1][3];

public Plugin myinfo =
{
	name        = "Jockey Teleport Fix",
	author      = "Eyal282",
	description = "Detects teleportation while jockeyed and teleports back to last known position afterwards..",
	version     = "1.0",
	url         = "None."
};

public void OnPluginStart()
{
	HookEvent("jockey_ride", Event_JockeyRide, EventHookMode_Post);
}

public void OnGameFrame()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		else if (!IsPlayerAlive(i))
			continue;

		else if (L4D_GetClientTeam(i) != L4DTeam_Survivor)
			continue;

		else if (L4D_GetAttackerJockey(i) == 0)
			continue;

		float fOrigin[3], fVelocity[3];
		GetClientAbsOrigin(i, fOrigin);
		GetEntPropVector(i, Prop_Data, "m_vecVelocity", fVelocity);

		float fEstimatedOrigin[3];

		ScaleVector(fVelocity, GetTickInterval());
		AddVectors(g_fLastOrigin[i], fVelocity, fEstimatedOrigin);

		if (GetVectorDistance(fEstimatedOrigin, fOrigin) > 150.0)
		{
			TeleportEntity(i, g_fLastOrigin[i], NULL_VECTOR, NULL_VECTOR);

			PrintToChatAll("Jockey Teleport Detected --> Teleported back.");
		}
		else
		{
			g_fLastOrigin[i] = fOrigin;
		}
	}
}

public Action Event_JockeyRide(Event event, const char[] name, bool dontBroadcast)
{
	int victim = GetClientOfUserId(GetEventInt(event, "victim"));

	GetClientAbsOrigin(victim, g_fLastOrigin[victim]);
}
