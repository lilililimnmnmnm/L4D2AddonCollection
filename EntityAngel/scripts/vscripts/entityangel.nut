printl("[EntityAngel] Now Serviced");

::EntityAngel <- {
	light = null,
	glow = [],
	markers = []

	function GetEntityName(entity)
	{
		local entityName = entity.GetName();
		if (entityName == null || entityName == "")
		{
			entityName = "EntityAngel" + entity.GetEntityIndex();
			entity.__KeyValueFromString("targetname", entityName);
		}
		return entityName;
	}

	function Find(event, args)
	{
		local len = args.len();
		local player = GetPlayerFromUserID(event.userid);
		if (player.GetEntityIndex() != 1)
		{
			return;	
		}
		else if (len == 1)
		{
			local entity = null;
			local count = 0;
			foreach (entity in glow)
			{
				if (entity != null && entity.IsValid())
				{
					NetProps.SetPropInt(entity, "m_Glow.m_iGlowType", 0);
					NetProps.SetPropInt(entity, "m_Glow.m_nGlowRange", 0);
				}
			}
			glow.clear();
			entity = null;
			while (entity = Entities.FindByClassnameWithin(entity, "weapon*", player.GetOrigin(), 1024.0))
			{
				if (entity.GetOwnerEntity() == null)
				{
					NetProps.SetPropInt(entity, "m_Glow.m_glowColorOverride", 255);
					NetProps.SetPropInt(entity, "m_Glow.m_nGlowRange", 99999);
					NetProps.SetPropInt(entity, "m_Glow.m_iGlowType", 3);
					count = count + 1;
					glow.append(entity);
				}
			}
			ClientPrint(null, 3, "[EntityAngel] Found {" + count + "} Items within 25m radius");
		}
		else if (len == 3 && args[1] == "entity")
		{
			local entity = null;
			local length = 0.0;
			local count = 0;
			while (entity = Entities.FindByClassnameWithin(entity, args[2], player.GetOrigin(), 1024.0))
			{
				local entityName = GetEntityName(entity);
				count = count + 1;
				length = (player.GetOrigin() - entity.GetOrigin()).Length();
				ClientPrint(null, 1, entity.GetClassname() + " | " + entityName +  " (" + floor(length * 0.0254) + "m)" + entity.GetOrigin());
			}
			ClientPrint(null, 3, "[EntityAngel] Found {" + count + "} Entity within 25m radius");
			ClientPrint(null, 3, "[EntityAngel] Check your console for a detailed list");
		}
		else if (len == 3 && args[1] == "env")
		{
			local entity = null;
			local count = 0;
			while (entity = Entities.FindByClassname(entity, args[2]))
			{
				local entityName = GetEntityName(entity);
				count = count + 1;
				ClientPrint(null, 1, entity.GetClassname() + " | " + entityName);
			}
			ClientPrint(null, 3, "[EntityAngel] Found {" + count + "} Entity");
			ClientPrint(null, 3, "[EntityAngel] Check your console for a detailed list");
		}
		else
		{
			return;
		}
	}

	function Entfire(event, args)
	{
		local len = args.len();
		if (GetPlayerFromUserID(event.userid).GetEntityIndex() != 1)
		{
			return;	
		}
		else if (len == 3)
		{
			EntFire(args[1], args[2], "", 0.0);
			ClientPrint(null, 3, "[EntityAngel] EntFire " + args[1]);
		}
		else if (len == 4)
		{
			EntFire(args[1], args[2], args[3], 0.0);
			ClientPrint(null, 3, "[EntityAngel] EntFire " + args[1]);
		}
		else
		{
			return;
		}
	}

	function Glow(event, args)
	{
		local len = args.len();
		if (GetPlayerFromUserID(event.userid).GetEntityIndex() != 1)
		{
			return;	
		}
		else if (len == 2 && args[1] == "off")
		{
			local entity = null;
			foreach (entity in glow)
			{
				if (entity != null && entity.IsValid())
				{
					NetProps.SetPropInt(entity, "m_Glow.m_iGlowType", 0);
					NetProps.SetPropInt(entity, "m_Glow.m_nGlowRange", 0);
				}
			}
			glow.clear();
			ClientPrint(null, 3, "[EntityAngel] Glow Off");
		}
		else if (len == 2)
		{
			local entityName = args[1];
			local entity = null;
			local count = 0;
			while (entity = Entities.FindByName(entity, entityName))
			{
				if (entity.IsValid())
				{
					NetProps.SetPropInt(entity, "m_Glow.m_glowColorOverride", 255);
					NetProps.SetPropInt(entity, "m_Glow.m_nGlowRange", 99999);
					NetProps.SetPropInt(entity, "m_Glow.m_iGlowType", 3);
					if (glow.find(entity) == null)
					{
						count = count + 1;
						glow.append(entity);
					}
				}
			}
	    		ClientPrint(null, 3, "[EntityAngel] Glow {" + count + "} Entity: " + entityName);
		}
		else
		{
			return;
		}
	}

	function Mark(event, args)
	{
		local len = args.len();
		if (GetPlayerFromUserID(event.userid).GetEntityIndex() != 1)
		{
			return;	
		}
		else if (len == 2 && args[1] == "off")
		{
			foreach (marker in markers)
			{
				marker.Kill();
			}
			markers.clear();
			ClientPrint(null, 3, "[EntityAngel] Mark Off");
		}
		else if (len == 2)
		{
			local entityName = args[1];
			local entity = null;
			local markerName = entityName + "Marker";
			local marker = null;
			while (entity = Entities.FindByName(entity, entityName))
			{
				marker = SpawnEntityFromTable("beam_spotlight", {
					targetname = markerName,
					origin = entity.GetOrigin(),
					angles = "-90 0 0",
					rendercolor = "0 255 255",
					renderamt = "180",
					spotlightwidth = "24",
					spotlightlength = "500",
					rendermode = "3",
					renderfx = "0",
					spawnflags = "1"
				});
				markers.append(marker);
			}
			EntFire(markerName, "LightOn", "", 0.0);
			ClientPrint(null, 3, "[EntityAngel] Mark: " + entityName);
		}
		else
		{
			return;
		}
	}

	function Hint(event, args)
	{
		local entity = null;
		local count = 0;
		local marker = null;
		local markerName = "HintMarker";
		while (entity = Entities.FindByClassname(entity, "func_button*"))
		{
			marker = SpawnEntityFromTable("beam_spotlight", {
				targetname = markerName,
				origin = entity.GetOrigin(),
				angles = "-90 0 0",
				rendercolor = "0 255 255",
				renderamt = "180",
				spotlightwidth = "24",
				spotlightlength = "500",
				rendermode = "3",
				renderfx = "0",
				spawnflags = "1"
			});
			markers.append(marker);
			count++;
		}
		entity = null;
		while (entity = Entities.FindByClassname(entity, "momentary_rot_button"))
		{
			marker = SpawnEntityFromTable("beam_spotlight", {
				targetname = markerName,
				origin = entity.GetOrigin(),
				angles = "-90 0 0",
				rendercolor = "0 255 255",
				renderamt = "180",
				spotlightwidth = "24",
				spotlightlength = "500",
				rendermode = "3",
				renderfx = "0",
				spawnflags = "1"
			});
			markers.append(marker);
			count++;
		}
		entity = null;
		while (entity = Entities.FindByClassname(entity, "point_prop_use_target"))
		{
			marker = SpawnEntityFromTable("beam_spotlight", {
				targetname = markerName,
				origin = entity.GetOrigin(),
				angles = "-90 0 0",
				rendercolor = "0 255 255",
				renderamt = "180",
				spotlightwidth = "24",
				spotlightlength = "500",
				rendermode = "3",
				renderfx = "0",
				spawnflags = "1"
			});
			markers.append(marker);
			count++;
		}
		entity = null;
		while (entity = Entities.FindByClassname(entity, "trigger_finale"))
		{
			marker = SpawnEntityFromTable("beam_spotlight", {
				targetname = markerName,
				origin = entity.GetOrigin(),
				angles = "-90 0 0",
				rendercolor = "0 255 255",
				renderamt = "180",
				spotlightwidth = "24",
				spotlightlength = "500",
				rendermode = "3",
				renderfx = "0",
				spawnflags = "1"
			});
			markers.append(marker);
			count++;
		}
		ClientPrint(null, 3, "[EntityAngel] Mark {" + count + "} Entities");
		EntFire(markerName, "LightOn", "", 0.0);
	}

	function Clear(event, args)
	{
		local len = args.len();
		if (GetPlayerFromUserID(event.userid).GetEntityIndex() != 1)
		{
			return;	
		}
		else if (len == 2)
		{
			local entity = null;
			local count = 0;
			while (entity = Entities.FindByClassname(entity, args[1]))
			{
				entity.Kill();
				count = count + 1;
			}
			ClientPrint(null, 3, "[EntityAngel] Clear {" + count + "} Entity");
		}
		else if (len == 3 && args[1] == "unnamed")
		{
			local entity = null;
			local count = 0;
			while (entity = Entities.FindByClassname(entity, args[2]))
			{
				local entityName = entity.GetName();
				if (entityName == null || entityName == "" || entityName.find("EntityAngel") != null)
				{
					entity.Kill();
					count = count + 1;
				}
			}
			ClientPrint(null, 3, "[EntityAngel] Clear {" + count + "} Entity");
		}
		else
		{
			return;
		}
	}

	function Optimize(event, args)
	{
		local len = args.len();
		if (GetPlayerFromUserID(event.userid).GetEntityIndex() != 1)
		{
			return;	
		}
		else if (len == 2 && args[1] == "performance")
		{
			local entity = null;
			local totalCount = 0;
			local count = 0;
			while (entity = Entities.FindByClassname(entity, "prop_ragdoll"))
			{
				local entityName = entity.GetName();
				if (entityName == null || entityName == "" || entityName.find("EntityAngel") != null)
				{
					entity.Kill();
					count = count + 1;
				}
			}
			ClientPrint(null, 1, "Clear {" + count + "} Entity: prop_ragdoll");
			totalCount = totalCount + count;
			count = 0;
			while (entity = Entities.FindByClassname(entity, "prop_physics*"))
			{
				local entityName = entity.GetName();
				if (entityName == null || entityName == "" || entityName.find("EntityAngel") != null)
				{
					entity.Kill();
					count = count + 1;
				}
			}
			ClientPrint(null, 1, "Clear {" + count + "}  Entity: prop_physics*");
			totalCount = totalCount + count;
			count = 0;
			while (entity = Entities.FindByClassname(entity, "prop_dynamic"))
			{
				local entityName = entity.GetName();
				if (entityName == null || entityName == "" || entityName.find("EntityAngel") != null)
				{
					entity.Kill();
					count = count + 1;
				}
			}
			ClientPrint(null, 1, "Clear {" + count + "} Entity: prop_dynamic");
			totalCount = totalCount + count;
			count = 0;
			while (entity = Entities.FindByClassname(entity, "move_rope"))
			{
				local entityName = entity.GetName();
				if (entityName == null || entityName == "" || entityName.find("EntityAngel") != null)
				{
					entity.Kill();
					count = count + 1;
				}
			}
			ClientPrint(null, 1, "Clear {" + count + "} Entity: move_rope");
			totalCount = totalCount + count;
			count = 0;
			while (entity = Entities.FindByClassname(entity, "keyframe_rope"))
			{
				local entityName = entity.GetName();
				if (entityName == null || entityName == "" || entityName.find("EntityAngel") != null)
				{
					entity.Kill();
					count = count + 1;
				}
			}
			ClientPrint(null, 1, "Clear {" + count + "} Entity: keyframe_rope");
			totalCount = totalCount + count;
			count = 0;
			while (entity = Entities.FindByClassname(entity, "env_wind"))
			{
				local entityName = entity.GetName();
				if (entityName == null || entityName == "" || entityName.find("EntityAngel") != null)
				{
					entity.Kill();
					count = count + 1;
				}
			}
			ClientPrint(null, 1, "Clear {" + count + "} Entity: env_wind");
			totalCount = totalCount + count;
			count = 0;
			while (entity = Entities.FindByClassname(entity, "env_sprite"))
			{
				local entityName = entity.GetName();
				if (entityName == null || entityName == "" || entityName.find("EntityAngel") != null)
				{
					entity.Kill();
					count = count + 1;
				}
			}
			ClientPrint(null, 1, "Clear {" + count + "} Entity: env_sprite");
			totalCount = totalCount + count;
			count = 0;
			while (entity = Entities.FindByClassname(entity, "env_spark"))
			{
				local entityName = entity.GetName();
				if (entityName == null || entityName == "" || entityName.find("EntityAngel") != null)
				{
					entity.Kill();
					count = count + 1;
				}
			}
			ClientPrint(null, 1, "Clear {" + count + "} Entity: env_spark");
			totalCount = totalCount + count;
			count = 0;
			while (entity = Entities.FindByClassname(entity, "env_dustpuff"))
			{
				local entityName = entity.GetName();
				if (entityName == null || entityName == "" || entityName.find("EntityAngel") != null)
				{
					entity.Kill();
					count = count + 1;
				}
			}
			ClientPrint(null, 1, "Clear {" + count + "} Entity: env_dustpuff");
			totalCount = totalCount + count;
			count = 0;
			ClientPrint(null, 3, "[EntityAngel] Clear {" + totalCount + "} Entity");
			ClientPrint(null, 3, "[EntityAngel] Check your console for a detailed list");
		}
		else if (len == 2 && args[1] == "sight")
		{
			local entity = null;
			local totalCount = 0;
			local count = 0;
			while (entity = Entities.FindByClassname(entity, "func_precipitation"))
			{
				entity.Kill();
				count = count + 1;
			}
			ClientPrint(null, 1, "Clear {" + count + "}  Entity: func_precipitation");
			totalCount = totalCount + count;
			count = 0;
			while (entity = Entities.FindByClassname(entity, "func_smokevolume"))
			{
				entity.Kill();
				count = count + 1;
			}
			ClientPrint(null, 1, "Clear {" + count + "}  Entity: func_smokevolume");
			totalCount = totalCount + count;
			count = 0;
			while (entity = Entities.FindByClassname(entity, "color_correction"))
			{
				entity.Kill();
				count = count + 1;
			}
			ClientPrint(null, 1, "Clear {" + count + "}  Entity: color_correction");
			totalCount = totalCount + count;
			count = 0;
			while (entity = Entities.FindByClassname(entity, "postprocess_controller"))
			{
				entity.Kill();
				count = count + 1;
			}
			ClientPrint(null, 1, "Clear {" + count + "}  Entity: postprocess_controller");
			totalCount = totalCount + count;
			count = 0;
			ClientPrint(null, 3, "[EntityAngel] Clear {" + totalCount + "} Entity");
			ClientPrint(null, 3, "[EntityAngel] Check your console for a detailed list");
		}
		else
		{
			return;
		}
	}


	function Rendering(event, args)
	{
		local len = args.len();
		if (GetPlayerFromUserID(event.userid).GetEntityIndex() != 1)
		{
			return;	
		}
		else if (len == 2)
		{
			local entity = null;
			local distance = args[1].tointeger();
			while (entity = Entities.FindByClassname(entity, "env_fog_controller"))
			{
				local entityName = entity.GetName();
				entity.__KeyValueFromInt("farz", floor(distance * 39.37));
				EntFire(entityName, "TurnOff", "", 0.0);
				EntFire(entityName, "TurnOn", "", 0.1);
			}
			ClientPrint(null, 3, "[EntityAngel] Set Rendering Distance {" + distance + "}m");
		}
		else
		{
			return;
		}
	}

	function Fog(event, args)
	{
		local len = args.len();
		if (GetPlayerFromUserID(event.userid).GetEntityIndex() != 1)
		{
			return;	
		}
		else if (len == 2 && args[1] == "info")
		{
			local entity = null;
			while (entity = Entities.FindByClassname(entity, "env_fog_controller"))
			{
				local entityName = GetEntityName(entity);
				ClientPrint(null, 3, "[EntityAngel] " + entityName);
			}
		}
		else if (len > 2 && args[1] == "on")
		{
			local selectall = args[2] == "all";
			local entity = null;
			while (entity = Entities.FindByClassname(entity, "env_fog_controller"))
			{
				local entityName = GetEntityName(entity);
				if (selectall || args[2] == entityName)
				{
					EntFire(entityName, "TurnOn", "", 0.0);
					ClientPrint(null, 3, "[EntityAngel] " + entityName + " <ON>");
				}
			}
		}
		else if (len > 2 && args[1] == "off")
		{
			local selectall = args[2] == "all";
			local entity = null;
			while (entity = Entities.FindByClassname(entity, "env_fog_controller"))
			{
				local entityName = GetEntityName(entity);
				if (selectall || args[2] == entityName)
				{
					EntFire(entityName, "TurnOff", "", 0.0);
					ClientPrint(null, 3, "[EntityAngel] " + entityName + " <OFF>");
				}
			}
		}
		else if (len > 3 && args[1] == "farz")
		{
			local selectall = args[2] == "all";
			local entity = null;
			while (entity = Entities.FindByClassname(entity, "env_fog_controller"))
			{
				local entityName = GetEntityName(entity);
				if (selectall || args[2] == entityName)
				{
					local farz = args[3].tointeger();
					entity.__KeyValueFromInt("farz", farz);
					EntFire(entityName, "TurnOff", "", 0.0);
					EntFire(entityName, "TurnOn", "", 0.1);
					ClientPrint(null, 3, "[EntityAngel] " + entityName + " <FarZ : " + farz + ">");
				}
			}
		}
		else if (len > 5 && args[1] == "color")
		{
			local selectall = args[2] == "all";
			local entity = null;
			while (entity = Entities.FindByClassname(entity, "env_fog_controller"))
			{
				local entityName = GetEntityName(entity);
				if (selectall || args[2] == entityName)
				{
					local color = args[3] + " " + args[4] + " " + args[5];
					entity.__KeyValueFromString("fogcolor", color);
					entity.__KeyValueFromString("fogcolor2", color);
					EntFire(entityName, "TurnOff", "", 0.0);
					EntFire(entityName, "TurnOn", "", 0.1);
					ClientPrint(null, 3, "[EntityAngel] " + entityName + " <Color : " + color + ">");
				}
			}
		}
		else if (len > 4 && args[1] == "distance")
		{
			local selectall = args[2] == "all";
			local entity = null;
			while (entity = Entities.FindByClassname(entity, "env_fog_controller"))
			{
				local entityName = GetEntityName(entity);
				if (selectall || args[2] == entityName)
				{
					local start = args[3].tointeger();
					local end = args[4].tointeger();
					entity.__KeyValueFromInt("fogstart", start);
					entity.__KeyValueFromInt("fogend", end);
					EntFire(entityName, "TurnOff", "", 0.0);
					EntFire(entityName, "TurnOn", "", 0.1);
					ClientPrint(null, 3, "[EntityAngel] " + entityName + " <Distance : " + start + " " + end +">");
				}
			}
		}
		else if (len > 3 && args[1] == "density")
		{
			local selectall = args[2] == "all";
			local entity = null;
			while (entity = Entities.FindByClassname(entity, "env_fog_controller"))
			{
				local entityName = GetEntityName(entity);
				if (selectall || args[2] == entityName)
				{
					EntFire(entityName, "SetMaxDensity", args[3], 0.0);
					ClientPrint(null, 3, "[EntityAngel] " + entityName + " <Density : " + args[3] + ">");
				}
			}
			
		}
		else if (len == 2 && args[1] == "type1")
		{
			local entity = null;
			while (entity = Entities.FindByClassname(entity, "env_fog_controller"))
			{
				local entityName = GetEntityName(entity);
				entity.__KeyValueFromInt("farz", -1);
				entity.__KeyValueFromInt("fogstart", 200);
				entity.__KeyValueFromInt("fogend", 5000);
				entity.__KeyValueFromString("fogcolor", "127 127 127");
				entity.__KeyValueFromString("fogcolor2", "127 127 127");
				EntFire(entityName, "TurnOff", "", 0.0);
				EntFire(entityName, "TurnOn", "", 0.1);
				ClientPrint(null, 3, "[EntityAngel] " + entityName + " <Set Type1>");
			}
		}
		else
		{
			return;
		}
	}

	function Other(event, args)
	{
		if (event.text.find("어두워ㅠ") != null)
		{
			local entity = GetPlayerFromUserID(event.userid);
			if (light != null)
			{
				light.Kill();
			}
			light = SpawnEntityFromTable("light_dynamic",
			{
				targetname = "EntityAngelLight",
				origin = entity.GetOrigin(),
				_light = "200 200 200 200",
				brightness = "3",
				distance = "1024",
				spotlight_radius = "64",
				style = "0"
			});
			EntFire("EntityAngelLight", "TurnOn", 0.0);
		}
		else if (event.text.find("!멈춰") != null || event.text.find("멈춰!") != null)
		{
			local player = GetPlayerFromUserID(event.userid);
			local entity = null;
			while (entity = Entities.FindByClassnameWithin(entity, "prop_physics", player.GetOrigin(), 1024.0))
			{
				local entityName = GetEntityName(entity);
				EntFire(entityName, "DisableMotion", "", 0.0);
				EntFire(entityName, "EnableMotion", "", 3.0);
			}
			ClientPrint(null, 3, "학교폭력!! 멈춰!!!");
		}
		else
		{
			return;
		}
	}


	function OnGameEvent_player_say(event)
	{
		if (event.text.len() > 0 && event.text.slice(0, 1) == "!")
		{
			local args = split(event.text, " ");
			if (args.len() > 0)
			{
				if (args[0] == "!info")
				{
					ClientPrint(null, 3, "[EntityAngel] Now Serviced");
				}
				else if (args[0] == "!find")
				{
					Find(event, args);
				}
				else if (args[0] == "!entfire")
				{
					Entfire(event, args);
				}
				else if (args[0] == "!glow")
				{
					Glow(event, args);
				}
				else if (args[0] == "!mark")
				{
					Mark(event, args);
				}
				else if (args[0] == "!hint")
				{
					Hint(event, args);
				}
				else if (args[0] == "!clear")
				{
					Clear(event, args);
				}
				else if (args[0] == "!optimize")
				{
					Optimize(event, args);
				}
				else if (args[0] == "!rendering")
				{
					Rendering(event, args);
				}
				else if (args[0] == "!fog")
				{
					Fog(event, args);
				}
				else
				{
					Other(event, args);
				}
			}
		}
		else
		{
			Other(event, null);
		}
	}

	function OnGameEvent_item_pickup(event)
	{
		for (local i = glow.len() - 1; i >= 0; i--)
		{
			local entity = glow[i];
			if (!entity.IsValid())
			{
				glow.remove(i);
				continue;
			}
			if (entity.GetClassname().find("weapon_*") != null)
			{
				if (entity.GetOwnerEntity() != null)
				{
					NetProps.SetPropInt(entity, "m_Glow.m_iGlowType", 0);
					NetProps.SetPropInt(entity, "m_Glow.m_nGlowRange", 0);
					glow.remove(i);
				}
			}
		}
	}
}

__CollectEventCallbacks(::EntityAngel, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener);