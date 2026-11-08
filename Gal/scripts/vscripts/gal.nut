printl("[Gal] Now Serviced");

::Gal <- {
	interval = 60
	assignTable = {}

	function AllClientPrint(text)
	{
		local entity = null;
		while (entity = Entities.FindByClassname(entity, "player"))
		{
			if (entity.GetNetworkIDString() != "BOT")
			{
				ClientPrint(entity, 3, text);
			}
		}
	}

	function EffectSound()
	{
		local entity = null;
		while (entity = Entities.FindByClassname(entity, "player"))
		{
			if (entity.GetNetworkIDString() != "BOT")
			{
				EmitAmbientSoundOn("plats/piano.wav", 1, 1, 100, entity);
			}
		}
	}


	function StaggerEntity(caster)
	{
		local entity = null;
		local distance = null;
		while (entity = Entities.FindByClassname(entity, "player"))
		{
			if (caster == entity || entity.IsIncapacitated() || entity.IsDead())
			{
				continue;
			}
			else
			{
				distance = entity.GetCenter() - caster.GetCenter();
				if (distance.Length() < 256)
				{
					entity.Stagger(caster.GetCenter());
				}
			}
		}
		entity = null;
		while (entity = Entities.FindByClassname(entity, "infected"))
		{
			distance = entity.GetCenter() - caster.GetCenter();
			if (distance.Length() < 256)
			{
				entity.TakeDamage(0, (1 << 25), caster);
			}	
		}
		entity = null;
		while(entity = Entities.FindByClassname(entity, "witch"))
		{
			distance = entity.GetCenter() - caster.GetCenter();
			if (distance.Length() < 256)
			{
				entity.TakeDamage(0, (1 << 25), caster);
				entity.TakeDamage(10, 64, caster);
			}
		}
	}

	function Gal(caster)
	{
		ScreenFade(caster, 0, 50, 150, 50, 0.3, 0, 1);
		ScreenShake(caster.GetCenter(), 8, 32, 4, 512, 7168, false);
		EffectSound();
		StaggerEntity(caster);
		AllClientPrint("喝!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
	}

	function OnGameEvent_player_say(event)
	{
		if (event.text == "!info")
		{
			AllClientPrint("[Gal] Now Serviced");
		}
		else if (event.text.find("!갈") != null || event.text.find("갈!") != null || event.text.find("GAL!") != null || event.text.find("!GAL") != null || event.text.find("!gal") != null || event.text.find("gal!") != null || event.text.find("rkf!") != null || event.text.find("!rkf") != null)
		{
			local entity = GetPlayerFromUserID(event.userid);
			local playerName = entity.GetPlayerName();
			if (entity.IsDead() || assignTable.rawin(playerName))
			{
				return;
			}
			else
			{
				assignTable[playerName] <- 0;
				Gal(entity);
			}
		}
		else
		{
			return;
		}
	}

	function Update()
	{
		local entity = null;
		while (entity = Entities.FindByClassname(entity, "player"))
		{
			local playerName = entity.GetPlayerName();
			if (::Gal.assignTable.rawin(playerName))
			{
				local counter = ::Gal.assignTable[playerName];
				if (counter == ::Gal.interval)
				{
					::Gal.assignTable.rawdelete(playerName);
					::Gal.AllClientPrint("[Gal] Ready - " + playerName);
				}
				else
				{
					::Gal.assignTable[playerName] <- counter + 1;
				}
			}
		}
		
	}
}

g_MapScript.ScriptedMode_AddUpdate(::Gal.Update);
__CollectEventCallbacks(::Gal, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener);