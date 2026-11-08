printl("[FirePunch] Now Serviced");

::FirePunch <- {
	assignArray = []

	function OnGameEvent_player_say(event)
	{
		if (event.text == "!info")
		{
			ClientPrint(null, 3, "[FirePunch] Now Serviced");
		}
		else if (event.text.find("파이어펀치") != null || event.text.find("firepunch") != null || event.text.find("FIREPUNCH") != null)
		{
			local entity = GetPlayerFromUserID(event.userid);
			if (entity != null && !entity.IsDead())
			{
				for (local i = 0; i < assignArray.len(); i++)
				{
					if (assignArray[i].entity == entity)
					{
						return;
					}
				}
				local origin = entity.GetOrigin();
				local angles = entity.GetAngles().ToKVString();
				local username = entity.GetNetworkIDString();
				local firename = "firepunch" + username;
				local explosionname = "e_firepunch" + username;
				local soundname = "s_firepunch" + username;
				local fire = SpawnEntityFromTable("env_fire",
				{
					targetname = firename,
					origin = origin,
					angles = angles,
					spawnflags = 5,
					firesize = 320
				});
				local explosion = SpawnEntityFromTable("env_explosion",
				{
					targetname = explosionname,
					origin = origin,
					iMagnitude = 100,
					iRadiusOverride = 320,
					spawnflags = 2
				});
				local sound = SpawnEntityFromTable("ambient_generic",
				{
					targetname = soundname,
					origin = origin,
					message = "ambient/explosions/explode_1.wav",	
					health = 10,
					spawnflags = 16
				});
				entity.__KeyValueFromString("targetname", username);
				EntFire(firename, "SetParent", username, 0.0);
				EntFire(explosionname, "SetParent", username, 0.0);
				EntFire(soundname, "SetParent", username, 0.0);
				EntFire(explosionname, "Explode", "", 0.0);
				EntFire(soundname, "PlaySound", "", 0.0);
				ScreenFade(entity, 150, 0, 0, 30, 60, 0, 0);
				ScreenShake(entity.GetCenter(), 2, 32, 3, 512, 7168, false);
				assignArray.append({
					entity = entity,
					fire = fire,
					explosion = explosion,
					sound = sound,
					name = entity.GetPlayerName(),
					counter = 0
				});
				ClientPrint(null, 3, "[FirePunch] Ignite - " + entity.GetPlayerName());
			}
		}
		else
		{
			return;
		}
	}

	function OnGameEvent_entity_shoved(event)
	{
		if (event.entityid != 0)
		{
			local entity = EntIndexToHScript(event.entityid);
			local attacker = GetPlayerFromUserID(event.attacker);
			local classname = entity.GetClassname();
			if (classname == "infected" || classname == "witch")
			{
				for (local i = 0; i < assignArray.len(); i++)
				{
					
					if (assignArray[i].entity == attacker && assignArray[i].counter < 60)
					{
						EntFire(assignArray[i].explosion.GetName(), "Explode", "", 0.0);
						EntFire(assignArray[i].sound.GetName(), "StopSound", "", 0.0);
						EntFire(assignArray[i].sound.GetName(), "PlaySound", "", 0.1);
						ScreenShake(entity.GetCenter(), 2, 32, 2, 512, 7168, false);
						return;
					}
				}
			}
		}
	}

	function OnGameEvent_player_shoved(event)
	{
		local entity = GetPlayerFromUserID(event.userid);
		local attacker = GetPlayerFromUserID(event.attacker);
		if (entity.GetZombieType() != 9)
		{
			for (local i = 0; i < assignArray.len(); i++)
			{
				if (assignArray[i].entity == attacker && assignArray[i].counter < 60)
				{
					EntFire(assignArray[i].explosion.GetName(), "Explode", "", 0.0);
					EntFire(assignArray[i].sound.GetName(), "StopSound", "", 0.0);
					EntFire(assignArray[i].sound.GetName(), "PlaySound", "", 0.1);
					ScreenShake(entity.GetCenter(), 2, 32, 2, 512, 7168, false);
					return;
				}
			}
		}
	}

	function Update()
	{
		local item = null;
		for (local i = ::FirePunch.assignArray.len() - 1; i >= 0; i--)
		{
			item = ::FirePunch.assignArray[i];
			item.counter++;
			if (item.counter == 60)
			{
				item.fire.Kill();
				item.explosion.Kill();
				item.sound.Kill();
				item.fire = null;
				item.explosion = null;
				item.sound = null;
				ClientPrint(null, 3, "[FirePunch] Extinguish - " + item.name);
			}
			if (item.counter == 120)
			{
				::FirePunch.assignArray.remove(i);
				ClientPrint(null, 3, "[FirePunch] Ready - " + item.name);
			}
		}
	}

	function AllowTakeDamage(damageTable)
	{
		if (damageTable.Attacker.GetName().find("firepunch") != null &&
			damageTable.Victim.IsPlayer() &&
			damageTable.Victim.GetZombieType() == 9)
		{
			return false;
		}
		else
		{
			return true;
		}
	}
}

g_MapScript.AllowTakeDamage <- ::FirePunch.AllowTakeDamage;
g_MapScript.ScriptedMode_AddUpdate(::FirePunch.Update);
__CollectEventCallbacks(::FirePunch, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener);

if ("AllowTakeDamage" in g_ModeScript)
{
	printl("[FirePunch] Initialize after Admin System")
	if (g_ModeScript.AllowTakeDamage != getroottable().AllowTakeDamage)
	{
		g_ModeScript.ModeAllowTakeDamage <- g_ModeScript.AllowTakeDamage;
		g_ModeScript.AllowTakeDamage <- getroottable().AllowTakeDamage;
	}
	if (g_MapScript.AllowTakeDamage != getroottable().AllowTakeDamage)
	{
		g_ModeScript.MapAllowTakeDamage <- g_MapScript.AllowTakeDamage;
		g_ModeScript.AllowTakeDamage <- getroottable().AllowTakeDamage;
	}
	else
	{
		g_ModeScript.AllowTakeDamage <- getroottable().AllowTakeDamage;
	}
}