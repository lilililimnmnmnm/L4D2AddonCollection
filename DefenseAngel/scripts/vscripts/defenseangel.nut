printl("[DefenseAngel] Now Serviced");

::DefenseAngel <- {
	function GetPlayerSlot1(player)
	{
		local inventory = {};
		GetInvTable(player, inventory);
		if ("slot1" in inventory)
		{
			return inventory["slot1"];
		}
		else
		{
			return null;
		}
	}

	function CheckShieldBlocking(attacker, victim)
	{
		local shield = GetPlayerSlot1(victim);
		if (shield == null || !shield.IsValid())
		{
			return 0;
		}
		if (shield.GetModelName() != "models/weapons/melee/v_riotshield.mdl")
		{
			return 0;
		}

		local direction = attacker.GetOrigin() - victim.GetOrigin();
		direction.Norm();

		local shieldForward;
		if (victim.GetActiveWeapon() == shield)
		{
			shieldForward = victim.GetForwardVector();
			if (shieldForward.Dot(direction) >= 0.5)
			{
				return 1;
			}
		}
		else
		{
			shieldForward = victim.GetForwardVector() * -1;
			if (shieldForward.Dot(direction) >= 0.5)
			{
				return 2;
			}
		}

		return 0;
	}

	function OnGameEvent_player_say(event)
	{
		if (event.text == "!info")
		{
			ClientPrint(null, 3, "[DefenseAngel] Now Serviced");
		}
	}

	function OnGameEvent_player_hurt(params)
	{
		if (!("attackerentid" in params) || !("userid" in params))
		{
			return;
		}

		local victim = GetPlayerFromUserID(params.userid);
		if (victim == null || !victim.IsValid() || !victim.IsSurvivor())
		{
			return;
		}

		local attacker = EntIndexToHScript(params.attackerentid);
		if (attacker == null || !attacker.IsValid() || attacker.GetClassname() != "infected")
		{
			return;
		}

		local state = CheckShieldBlocking(attacker, victim);
		if (state == 1)
		{
			victim.SetHealth(victim.GetHealth() + 18);
		}
		else if (state == 2)
		{
			victim.SetHealth(victim.GetHealth() + 9);
		}
		else
		{
			return;
		}
	}

	function OnGameEvent_tongue_grab(params)
	{
		local victim = GetPlayerFromUserID(params.victim);
		local attacker = GetPlayerFromUserID(params.userid);
		if (victim.IsValid() && !victim.IsStaggering() && CheckShieldBlocking(attacker, victim) > 0)
		{
			victim.TakeDamage(5, 0, attacker);
			victim.Stagger(attacker.GetOrigin());
			attacker.Stagger(victim.GetOrigin());
		}
	}

	function OnGameEvent_jockey_ride(params)
	{
		local victim = GetPlayerFromUserID(params.victim);
		local attacker = GetPlayerFromUserID(params.userid);
		if (victim.IsValid() && !victim.IsStaggering() && CheckShieldBlocking(attacker, victim) > 0)
		{
			victim.TakeDamage(5, 0, attacker);
			victim.Stagger(attacker.GetOrigin());
			attacker.Stagger(victim.GetOrigin());
		}
	}
	
	function OnGameEvent_lunge_pounce(params)
	{
		local victim = GetPlayerFromUserID(params.victim);
		local attacker = GetPlayerFromUserID(params.userid);
		if (victim.IsValid() && !victim.IsStaggering() && CheckShieldBlocking(attacker, victim) > 0)
		{
			victim.TakeDamage(5, 0, attacker);
			victim.Stagger(attacker.GetOrigin());
			attacker.Stagger(victim.GetOrigin());
		}
	}
}

__CollectEventCallbacks(::DefenseAngel, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener);