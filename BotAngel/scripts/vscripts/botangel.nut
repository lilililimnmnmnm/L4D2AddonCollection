printl("[BotAngel] Now Serviced");

::BotAngel <- {
	counter = 0
	threshold = 80
	interval = 20
	recovery = 5
	isAssign = false

	function GiveHealth(entity)
	{
		local health = 0;
		local healthBuffer = 0;
		if (!entity.IsIncapacitated() && !entity.IsDead())
		{
			health = entity.GetHealth();
			healthBuffer = entity.GetHealthBuffer();
			if (health + healthBuffer <= threshold)
			{
				entity.SetHealth(health + recovery);
				entity.SetReviveCount(0);
				entity.UseAdrenaline(20);
			}
		}
	}

	function OnGameEvent_player_say(event)
	{
		if (event.text == "!info")
		{
			ClientPrint(null, 3, "[BotAngel] Now Serviced");
		}
		else if (event.text == "!mercy")
		{
			isAssign = true;
			ClientPrint(null, 3, "[BotAngel] Assigned");
		}
		else if (event.text == "!nomercy")
		{	
			isAssign = false;
			ClientPrint(null, 3, "[BotAngel] Deassigned");
		}
		else
		{
			return;
		}
	}

	function Update()
	{
		::BotAngel.counter = ::BotAngel.counter + 1;
		if (::BotAngel.counter >= ::BotAngel.interval)
		{
			::BotAngel.counter = 0;
			local entity = null;
			while (entity = Entities.FindByClassname(entity, "player"))
			{
				if (entity.IsSurvivor())
				{
					if (entity.GetNetworkIDString() == "BOT")
					{
						::BotAngel.GiveHealth(entity);
					}
					else if (::BotAngel.isAssign)
					{
						::BotAngel.GiveHealth(entity);
					}
					else
					{
						continue;
					}
				}
			}
		}
	}
}

g_MapScript.ScriptedMode_AddUpdate(::BotAngel.Update);
__CollectEventCallbacks(::BotAngel, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener);