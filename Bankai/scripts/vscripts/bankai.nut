printl("[Bankai] Now Serviced");

::Bankai <- {
	durationPath = "bankai/duration"
	cooldownPath = "bankai/cooldown"
	counter = 0
	duration = 60
	cooltime = 0
	cooldown = 10
	isCooltime = false
	isAssign = false

	function SupplyWeapon()
	{
		local entity;
		local weapon;
		while (entity = Entities.FindByClassname(entity, "player"))
		{
			if (entity.GetNetworkIDString() != "BOT")
			{
				EmitAmbientSoundOn("Hint.Critical", 1, 1, 100, entity);
				ScreenFade(entity, 150, 0, 0, 30, duration, 0, 0);
				ScreenShake(entity.GetCenter(), 8, 32, 5, 512, 7168, false);
				if (!entity.IsIncapacitated() && !entity.IsDead())
				{
					weapon = entity.GetActiveWeapon().GetModelName();
					if (weapon.find("fireaxe") != null || weapon.find("katana") != null || weapon.find("knife") != null)
					{
						continue;
					}
					entity.GiveItem("katana");
					weapon = entity.GetActiveWeapon().GetModelName();
					if (weapon.find("katana") != null)
					{
						continue;
					}
					entity.GiveItem("knife");
				}
			}
                	}
	}

	function OnGameEvent_round_start(event)
	{
		local _duration = FileToString(durationPath);
		local _cooldown = FileToString(cooldownPath);
		if (_duration != null)
		{
			duration = _duration.tointeger();
		}
		if (_cooldown != null)
		{
			cooldown = _cooldown.tointeger();
		}
		isCooltime = false;
		isAssign = false;
		counter = 0;
		Convars.SetValue("melee_range", 70);
		Convars.SetValue("melee_force_scalar", 20);
		Convars.SetValue("survivor_friendly_fire_factor_normal", 0.1);
		Convars.SetValue("survivor_friendly_fire_factor_hard", 0.3);
		Convars.SetValue("survivor_friendly_fire_factor_expert", 0.5);
	}

	function OnGameEvent_player_say(event)
	{
		if (event.text == "!info")
		{
			ClientPrint(null, 3, "[Bankai] Now Serviced");
		}
		else if (event.text.find("!bankai_duration") != null)
		{
			if (GetPlayerFromUserID(event.userid).GetEntityIndex() != 1)
			{
				return;	
			}
			local args = split(event.text, " ");
			if (args.len() > 1)
			{
				local _duration = args[1].tointeger();
				duration = _duration > -1 ? _duration : 0;
				StringToFile(durationPath, duration.tostring());
				ClientPrint(null, 3, "[Bankai] Duration : " + duration);
			}
		}
		else if (event.text.find("!bankai_cooldown") != null)
		{
			if (GetPlayerFromUserID(event.userid).GetEntityIndex() != 1)
			{
				return;	
			}
			local args = split(event.text, " ");
			if (args.len() > 1)
			{
				local _cooldown = args[1].tointeger();
				cooldown = _cooldown > -1 ? _cooldown : 0;
				StringToFile(cooldownPath, cooldown.tostring());
				ClientPrint(null, 3, "[Bankai] Cooldown : " + cooldown);
			}
		}
		else if (event.text.find("!BANKAI") != null || event.text.find("BANKAI!") != null || event.text.find("bankai!") != null || event.text.find("!bankai") != null || event.text.find("만해!") != null || event.text.find("!만해") != null)
		{
			if (!isAssign)
			{
				isAssign = true;
				counter = 0;
				Convars.SetValue("melee_range", 1000);
				Convars.SetValue("melee_force_scalar", 1000);
				Convars.SetValue("survivor_friendly_fire_factor_normal", 0.0);
				Convars.SetValue("survivor_friendly_fire_factor_hard", 0.0);
				Convars.SetValue("survivor_friendly_fire_factor_expert", 0.0);
				SupplyWeapon();
				ClientPrint(null, 3, "!!!!!!!!!! 만해(卍解) !!!!!!!!!!");
				ClientPrint(null, 3, "[Bankai] 팀킬데미지 무효, 근접사거리 15배");
			}
		}
		else
		{
			return;
		}
	}

	function Update()
	{
		if (::Bankai.isCooltime)
		{
			if (::Bankai.cooltime >= ::Bankai.cooldown)
			{
				::Bankai.isCooltime = false;
				::Bankai.isAssign = false;
				::Bankai.cooltime = 0;
				ClientPrint(null, 3, "[Bankai] Ready");
			}
			else
			{
				::Bankai.cooltime++;
			}
		}
		else if (::Bankai.isAssign)
		{
			::Bankai.counter = ::Bankai.counter + 1;
			if (::Bankai.counter == ::Bankai.duration - 3)
			{
				ClientPrint(null, 3, "[Bankai] 만해(卍解) 3초 남음");
			}
			else if (::Bankai.counter == ::Bankai.duration - 2)
			{
				ClientPrint(null, 3, "[Bankai] 만해(卍解) 2초 남음");
			}
			else if (::Bankai.counter == ::Bankai.duration - 1)
			{
				ClientPrint(null, 3, "[Bankai] 만해(卍解) 1초 남음");
			}
			else if (::Bankai.counter >= ::Bankai.duration)
			{
				::Bankai.isCooltime = true;
				::Bankai.counter = 0;
				Convars.SetValue("melee_range", 70);
				Convars.SetValue("melee_force_scalar", 20);
				Convars.SetValue("survivor_friendly_fire_factor_normal", 0.1);
				Convars.SetValue("survivor_friendly_fire_factor_hard", 0.3);
				Convars.SetValue("survivor_friendly_fire_factor_expert", 0.5);
				ClientPrint(null, 3, "[Bankai] 만해(卍解) 종료");
			}
			else
			{
				return;
			}
		}
		else
		{
			return;
		}
	}
}

g_MapScript.ScriptedMode_AddUpdate(::Bankai.Update);
__CollectEventCallbacks(::Bankai, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener);