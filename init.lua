minetest.register_privilege("adminshop", {
	description = "Player can place and destruct any adminshop",
	give_to_singleplayer= true,
})

-- Adminshop
-- Globaler Arrayspeicher
default.adminshop_current_shop_position = {}
minetest.register_node("adminshop:adminshop", {
    description = "Adminshop",
		tiles = {"shop_top.png",
				"shop_top.png",
				"shop.png",
				"shop.png",
				"shop.png",
				"shop.png",},
		is_ground_content = true,
		-- light_source = 10,
    groups = {dig_immediate=2},
    sounds = default.node_sound_stone_defaults(),
-- Registriere den Owner beim Platzieren:
    after_place_node = function(pos, placer, itemstack)
      if not minetest.check_player_privs(placer:get_player_name(), { adminshop=true }) then
  --    if minetest.check_player_privs(placer:get_player_name(), { adminshop=false }) then
        minetest.chat_send_player(placer:get_player_name(),"You don't have the required privilege to place an adminshop!")
        minetest.remove_node(pos)
      end
      local meta = minetest.get_meta(pos)
      meta:set_string("owner", placer:get_player_name())
			meta:set_int("adminshop:counter", 0)
      local inv = meta:get_inventory()
      inv:set_size("einnahme", 2*2)
      inv:set_size("ausgabe", 2*2)
    end,
    on_rightclick = function(pos, node, player, itemstack, pointed_thing)
      -- Schreibe die eigene Position des Blockes in eine öffentliche Variable mit dem Namen des Spielernamens, welcher auf den Block zugegriffen hat
      default.adminshop_current_shop_position[player:get_player_name()] = pos
      adminshop_show_spec(player)
      --end
    end,
    allow_metadata_inventory_put = function(pos, listname, index, stack, player)
      local meta = minetest.get_meta(pos)
      if player:get_player_name() ~= meta:get_string("owner") then return 0 end
      return stack:get_count()
    end,
    allow_metadata_inventory_take = function(pos, listname, index, stack, player)
      local meta = minetest.get_meta(pos)
      if player:get_player_name() ~= meta:get_string("owner") then return 0 end
      return stack:get_count()
    end,
    can_dig = function(pos, player)
      if minetest.check_player_privs(player:get_player_name(), { adminshop=true }) then
        return true
      else
        return false
    end
  end


})

adminshop_show_spec = function (player)
    local pos = default.adminshop_current_shop_position[player:get_player_name()]
    local meta = minetest.get_meta(pos)
    local listname = "nodemeta:"..pos.x..','..pos.y..','..pos.z
    if player:get_player_name() == meta:get_string("owner") then
      --"label[0,0;Welcome back, " .. meta:get_string("owner") ..
      --  "list["..listname..";einnahme;0,3.5;8,4;]"
     minetest.show_formspec(player:get_player_name(), "adminshop:adminshop", "size[8,7.5]"..
     "label[0,0;Welcome back, ".. meta:get_string("owner").."]" ..
		 "label[3.5,1.15;Counter: "..meta:get_int("adminshop:counter").."]" ..
     "label[0,0.5;Paying:]" ..
     "list["..listname..";einnahme;0,1;2,2;]"..
     "label[6,0.5;Getting:]" ..
     "list["..listname..";ausgabe;6,1;2,2;]" ..
     "list[current_player;main;0,3.5;8,4;]" ..
     "button[3,1.5;2,1;exchange;Exchange]"
   )
    else
--      minetest.show_formspec(player:get_player_name(), "adminshop:adminshop", "size[8,5]"..  "label[0,0;Hello, " ..player:get_player_name() .. "list[player;main;0,3.5;8,4;]")
      minetest.show_formspec(player:get_player_name(), "adminshop:adminshop", "size[8,7.5]"..
      "label[0,0;Welcome, "..player:get_player_name().."]" ..
      "label[0,0.5;Paying:]" ..
      "list["..listname..";einnahme;0,1;2,2;]"..
      "label[6,0.5;Getting:]" ..
      "list["..listname..";ausgabe;6,1;2,2;]" ..
      "list[current_player;main;0,3.5;8,4;]" ..
      "button[3,1.5;2,1;exchange;Exchange]"
    )
  end
end

-- Wenn der Spieler auf Exchange gedrückt hat:
minetest.register_on_player_receive_fields(function(customer, formname, fields)
	if formname == "adminshop:adminshop" and fields.exchange ~= nil and fields.exchange ~= "" then
    local pos = default.adminshop_current_shop_position[customer:get_player_name()]
    local meta = minetest.get_meta(pos)
    local minv = meta:get_inventory()
    local pinv = customer:get_inventory()

    local wants = minv:get_list("einnahme")
    local gives = minv:get_list("ausgabe")
    if wants == nil or gives == nil then return end -- do not crash the server
    -- Check if we can exchange
    local enough_items = true
    local enough_space = true
    for i, item in pairs(wants) do
      if not pinv:contains_item("main",item) then
        enough_items = false
      end
    end
    for i, item in pairs(gives) do
      if not pinv:room_for_item("main", item)  then
        enough_space = false
      end

    end
    if enough_items and enough_space then
			meta:set_int("adminshop:counter", meta:get_int("adminshop:counter") + 1)
      for i, item in pairs(wants) do
        pinv:remove_item("main",item)
      end
      for i, item in pairs(gives) do
        pinv:add_item("main",item)
      end
      -- minetest.chat_send_player(customer:get_player_name(),"Exchanged!")
    elseif enough_space then
      minetest.chat_send_player(customer:get_player_name(),"You don't have the required items in your inventory!")
    else
      minetest.chat_send_player(customer:get_player_name(),"You don't have enough space in your inventory!")
    end
  end
end)
----------------------------------------------------------------------------
-- Adminshop with licenses
----------------------------------------------------------------------------
if minetest.get_modpath("licenses") ~= nil then
	default.adminshop_current_license_shop_position = {}
	minetest.register_node("adminshop:adminshop_license", {

	    description = "Adminshop with licenses integrated",
			tiles = {"shop_licenses_top.png",
					"shop_licenses_top.png",
					"shop_licenses.png",
					"shop_licenses.png",
					"shop_licenses.png",
					"shop_licenses.png",},
			-- light_source = 10,
	    is_ground_content = true,
	    groups = {dig_immediate=2},
	    sounds = default.node_sound_stone_defaults(),
	-- Registriere den Owner beim Platzieren:
	    after_place_node = function(pos, placer, itemstack)
	      if not minetest.check_player_privs(placer:get_player_name(), { adminshop=true }) then
	  --    if minetest.check_player_privs(placer:get_player_name(), { adminshop=false }) then
	        minetest.chat_send_player(placer:get_player_name(),"You don't have the required privilege to place an adminshop!")
	        minetest.remove_node(pos)
	      end
	      local meta = minetest.get_meta(pos)
				meta:set_int("adminshop:counter", 0)
	      meta:set_string("owner", placer:get_player_name())
	      local inv = meta:get_inventory()
	      inv:set_size("einnahme", 2*2)
	      inv:set_size("ausgabe", 2*2)
	    end,
	    on_rightclick = function(pos, node, player, itemstack, pointed_thing)
	      -- Schreibe die eigene Position des Blockes in eine öffentliche Variable mit dem Namen des Spielernamens, welcher auf den Block zugegriffen hat
	      default.adminshop_current_license_shop_position[player:get_player_name()] = pos
	      show_specl(player)
	      --end
	    end,
	    allow_metadata_inventory_put = function(pos, listname, index, stack, player)
	      local meta = minetest.get_meta(pos)
	      if player:get_player_name() ~= meta:get_string("owner") then return 0 end
	      return stack:get_count()
	    end,
	    allow_metadata_inventory_take = function(pos, listname, index, stack, player)
	      local meta = minetest.get_meta(pos)
	      if player:get_player_name() ~= meta:get_string("owner") then return 0 end
	      return stack:get_count()
	    end,
	    can_dig = function(pos, player)
	      if minetest.check_player_privs(player:get_player_name(), { adminshop=true }) then
	        return true
	      else
	        return false
	    end
	  end


	})

	show_specl = function (player)
	    local pos = default.adminshop_current_license_shop_position[player:get_player_name()]
	    local meta = minetest.get_meta(pos)
	    local listname = "nodemeta:"..pos.x..','..pos.y..','..pos.z
			local licenses_string = ""
			local licenses_required = ""
			local ltable = minetest.deserialize(meta:get_string("adminshop:ltable"))
			if ltable == nil then
				ltable = {}
			end
			for k, v in pairs(ltable) do
				 if v == "defined" then
					 licenses_string = licenses_string  .. k ..","
					 licenses_required = licenses_required .. k .. " "
				 end
			end
			if licenses_required == "" then
				licenses_required = "nothing"
			end
	    if player:get_player_name() == meta:get_string("owner") then
	     minetest.show_formspec(player:get_player_name(), "adminshop:adminshop_license", "size[11,7.5]"..
	     "label[0,0;Welcome back, ".. meta:get_string("owner").."]" ..
			 "label[3.5,1.15;Counter: "..meta:get_int("adminshop:counter").."]" ..
			 -- Licenses:
			 "label[8,0;Licenses:]" ..
			 "textlist[8,0.5;2.8,5;license_list;"..licenses_string.."]" ..
			 "button[8,5.5;1.5,1;add_license;Add]" ..
			 "button[9.5,5.5;1.5,1;remove_license;Remove]" ..
			 "field[8.3,6.7;3,1;license_text;;]" ..
			 --for word in string.gmatch("Hello Lua user", "%a+") do print(word) end
			 -------------
	     "label[0,0.5;Paying:]" ..
	     "list["..listname..";einnahme;0,1;2,2;]"..
	     "label[6,0.5;Getting:]" ..
	     "list["..listname..";ausgabe;6,1;2,2;]" ..
	     "list[current_player;main;0,3.5;8,4;]" ..
	     "button[3,1.5;2,1;exchange;Exchange]"
	   )
	    else
	      minetest.show_formspec(player:get_player_name(), "adminshop:adminshop_license", "size[8,7.5]"..
	      "label[0,0;Welcome, "..player:get_player_name().."]" ..
				"label[2.5,0;License required: "..licenses_required.."]" ..
	      "label[0,0.5;Paying:]" ..
	      "list["..listname..";einnahme;0,1;2,2;]"..
	      "label[6,0.5;Getting:]" ..
	      "list["..listname..";ausgabe;6,1;2,2;]" ..
	      "list[current_player;main;0,3.5;8,4;]" ..
	      "button[3,1.5;2,1;exchange;Exchange]"
	    )
	  end
	end

	-- Wenn der Spieler auf Exchange gedrückt hat:
	minetest.register_on_player_receive_fields(function(customer, formname, fields)
		if formname == "adminshop:adminshop_license" and fields.exchange ~= nil and fields.exchange ~= "" then
	    local pos = default.adminshop_current_license_shop_position[customer:get_player_name()]
	    local meta = minetest.get_meta(pos)
	    local minv = meta:get_inventory()
	    local pinv = customer:get_inventory()

	    local wants = minv:get_list("einnahme")
	    local gives = minv:get_list("ausgabe")
	    if wants == nil or gives == nil then return end -- do not crash the server
	    -- Check if we can exchange
	    local enough_items = true
	    local enough_space = true
	    for i, item in pairs(wants) do
	      if not pinv:contains_item("main",item) then
	        enough_items = false
	      end
	    end
	    for i, item in pairs(gives) do
	      if not pinv:room_for_item("main", item)  then
	        enough_space = false
	      end

	    end
			-- Check Licence
			local allowed = false
			local empty = true
			local ltable = minetest.deserialize(meta:get_string("adminshop:ltable"))
			if ltable == nil then
				ltable = {}
			end

			for k, v in pairs(ltable) do
				empty = false
				if v == "defined" then
					if licenses_check_player_by_licese(customer:get_player_name(), k) then
						allowed = true
					end
				end
			end

			if empty then
				allowed = true
			end

			--
	    if enough_items and enough_space and allowed then
				meta:set_int("adminshop:counter", meta:get_int("adminshop:counter") + 1)
	      for i, item in pairs(wants) do
	        pinv:remove_item("main",item)
	      end
	      for i, item in pairs(gives) do
	        pinv:add_item("main",item)
	      end
	      -- minetest.chat_send_player(customer:get_player_name(),"Exchanged!")
			elseif not allowed then
				minetest.chat_send_player(customer:get_player_name(),"You are not allowd to buy this!" )
			elseif enough_space then
	      minetest.chat_send_player(customer:get_player_name(),"You don't have the required items in your inventory!")
	    else
	      minetest.chat_send_player(customer:get_player_name(),"You don't have enough space in your inventory!")
	    end
	  end
	end)
end

minetest.register_on_player_receive_fields(function(customer, formname, fields)
	if formname == "adminshop:adminshop_license" and fields.add_license ~= nil and fields.add_license ~= "" then
    local pos = default.adminshop_current_license_shop_position[customer:get_player_name()]
    local meta = minetest.get_meta(pos)
		local ltable = minetest.deserialize(meta:get_string("adminshop:ltable"))
		if ltable == nil then
			ltable = {}
		end
		-- Checke, ob das wirklich existiert
    if licenses_exists(fields.license_text) then
			ltable[fields.license_text] = "defined"
			meta:set_string("adminshop:ltable", minetest.serialize(ltable))
			show_specl(customer)
		else
			minetest.chat_send_player(customer:get_player_name(),"This license doesnt exist! Add this with /licenses_add " .. fields.license_text )
		end
	end
end)


minetest.register_on_player_receive_fields(function(customer, formname, fields)
	if formname == "adminshop:adminshop_license" and fields.remove_license ~= nil and fields.remove_license ~= "" then
		local pos = default.adminshop_current_license_shop_position[customer:get_player_name()]
		local meta = minetest.get_meta(pos)
		local ltable = minetest.deserialize(meta:get_string("adminshop:ltable"))
		if ltable == nil then
			ltable = {}
		end
		ltable[fields.license_text] = nil
		meta:set_string("adminshop:ltable", minetest.serialize(ltable))
		show_specl(customer)
	end
end)

----------------------------------------------------------------------------
-- Adminshop with licenses and currency with atm support
----------------------------------------------------------------------------
if minetest.get_modpath("licenses") ~= nil and minetest.get_modpath("currency") ~= nil and minetest.get_modpath("atm") ~= nil then
	default.adminshop_current_license_atm_shop_position = {}
	minetest.register_node("adminshop:adminshop_license_atm", {

	    description = "Adminshop with licenses and atm integrated",
			tiles = {"shop_licenses_top.png",
					"shop_licenses_top.png",
					"shop_licenses.png",
					"shop_licenses.png",
					"shop_licenses.png",
					"shop_licenses.png",},
	    is_ground_content = true,
			-- light_source = 10,
	    groups = {dig_immediate=2},
	    sounds = default.node_sound_stone_defaults(),
	-- Registriere den Owner beim Platzieren:
	    after_place_node = function(pos, placer, itemstack)
	      if not minetest.check_player_privs(placer:get_player_name(), { adminshop=true }) then
	  --    if minetest.check_player_privs(placer:get_player_name(), { adminshop=false }) then
	        minetest.chat_send_player(placer:get_player_name(),"You don't have the required privilege to place an adminshop!")
	        minetest.remove_node(pos)
	      end
	      local meta = minetest.get_meta(pos)
				meta:set_string("adminshop:bs", "Buy")
				meta:set_int("adminshop:price", 0)
	      meta:set_string("owner", placer:get_player_name())
				meta:set_int("adminshop:counter", 0)
	      local inv = meta:get_inventory()
	      inv:set_size("einnahme", 2*2)
	      inv:set_size("ausgabe", 2*2)
	    end,
	    on_rightclick = function(pos, node, player, itemstack, pointed_thing)
	      -- Schreibe die eigene Position des Blockes in eine öffentliche Variable mit dem Namen des Spielernamens, welcher auf den Block zugegriffen hat
	      default.adminshop_current_license_atm_shop_position[player:get_player_name()] = pos
	      show_specl_atm(player)
	      --end
	    end,
	    allow_metadata_inventory_put = function(pos, listname, index, stack, player)
	      local meta = minetest.get_meta(pos)
	      if player:get_player_name() ~= meta:get_string("owner") then return 0 end
	      return stack:get_count()
	    end,
	    allow_metadata_inventory_take = function(pos, listname, index, stack, player)
	      local meta = minetest.get_meta(pos)
	      if player:get_player_name() ~= meta:get_string("owner") then return 0 end
	      return stack:get_count()
	    end,
	    can_dig = function(pos, player)
	      if minetest.check_player_privs(player:get_player_name(), { adminshop=true }) then
	        return true
	      else
	        return false
	    end
	  end


	})

	show_specl_atm = function (player)
	    local pos = default.adminshop_current_license_atm_shop_position[player:get_player_name()]
	    local meta = minetest.get_meta(pos)
	    local listname = "nodemeta:"..pos.x..','..pos.y..','..pos.z
			local licenses_string = ""
			local licenses_required = ""
			local ltable = minetest.deserialize(meta:get_string("adminshop:ltable"))
			if atm.balance[player:get_player_name()] == nil then
				atm.balance[player:get_player_name()] = 0
			end
			if ltable == nil then
				ltable = {}
			end
			for k, v in pairs(ltable) do
				 if v == "defined" then
					 licenses_string = licenses_string  .. k ..","
					 licenses_required = licenses_required .. k .. " "
				 end
			end
			if licenses_required == "" then
				licenses_required = "nothing"
			end
	    if player:get_player_name() == meta:get_string("owner") then
	     minetest.show_formspec(player:get_player_name(), "adminshop:adminshop_license_atm", "size[11,7.5]"..
	     "label[0,0;Welcome back, ".. meta:get_string("owner").."]" ..
			 "label[3.5,1.15;Counter: "..meta:get_int("adminshop:counter").."]" ..
			 -- Licenses:
			 "label[8,0;Licenses:]" ..
			 "textlist[8,0.5;2.8,5;license_list;"..licenses_string.."]" ..
			 "button[8,5.5;1.5,1;add_license;Add]" ..
			 "button[9.5,5.5;1.5,1;remove_license;Remove]" ..
			 "field[8.3,6.7;3,1;license_text;;]" ..
			 --for word in string.gmatch("Hello Lua user", "%a+") do print(word) end
			 -------------
	     "label[0,0.5;Items:]" ..
	     "list["..listname..";einnahme;0,1;2,2;]"..
			 "field[5.4,1.8;2.7,1;price_field;Price:;"..meta:get_string("adminshop:price").."]" ..
			 "button[5.1,2.3;2.7,1;set_price;Set Price]" ..
	     "list[current_player;main;0,3.5;8,4;]" ..
	     "button[3,1.5;2,1;set_buy_sell;"..meta:get_string("adminshop:bs").."]"
	   )
	    else
	      minetest.show_formspec(player:get_player_name(), "adminshop:adminshop_license_atm", "size[8,7.5]"..
	      "label[0,0;Welcome, "..player:get_player_name().."]" ..
	      "label[0,0.5;Items:]" ..
	      "list["..listname..";einnahme;0,1;2,2;]"..
				"label[2.5,0;License required: "..licenses_required.."]" ..
	      "label[5.7,1.45;Price: "..meta:get_string("adminshop:price").."]" ..
				"label[5.7,1.8;Your Balance: "..atm.balance[player:get_player_name()].."]" ..
	      "list[current_player;main;0,3.5;8,4;]" ..
	      "button[3,1.5;2,1;buy_sell;"..meta:get_string("adminshop:bs").."]"
	    )
	  end
	end

	-- Wenn der Spieler auf Exchange gedrückt hat:
	minetest.register_on_player_receive_fields(function(customer, formname, fields)
		if formname == "adminshop:adminshop_license_atm" and fields.buy_sell ~= nil and fields.buy_sell ~= "" then
	    local pos = default.adminshop_current_license_atm_shop_position[customer:get_player_name()]
	    local meta = minetest.get_meta(pos)
	    local minv = meta:get_inventory()
	    local pinv = customer:get_inventory()
	    local items = minv:get_list("einnahme")
	    if items == nil then return end -- do not crash the server

		-- Check if We Can Exchange:
		local enough_space = true
		local enough_items = true
			-- BUY:
			if meta:get_string("adminshop:bs") == "Buy" then
				for i, item in pairs(items) do
					if not pinv:room_for_item("main", item)  then
						enough_space = false
					end
				end



			-- SELL:
			else
				for i, item in pairs(items) do
					if not pinv:contains_item("main",item) then
						enough_items = false
					end
				end
			end


		-- Check Licence:
			local allowed = false
			local empty = true
			local ltable = minetest.deserialize(meta:get_string("adminshop:ltable"))
			if ltable == nil then
				ltable = {}
			end
			for k, v in pairs(ltable) do
				empty = false
				if v == "defined" then
					if licenses_check_player_by_licese(customer:get_player_name(), k) then
						allowed = true
					end
				end
			end
			if empty then
				allowed = true
			end
		-- Enough Money???
			if meta:get_string("adminshop:bs") == "Buy" and atm.balance[customer:get_player_name()] < meta:get_int("adminshop:price") then
				minetest.chat_send_player(customer:get_player_name(),"You dont have enough money on your account!" )
				return
			end

		-- Do the thing:
			-- BUY:
			if meta:get_string("adminshop:bs") == "Buy" then
				if enough_space and allowed then
					for i, item in pairs(items) do
						pinv:add_item("main",item)
					end
					atm.balance[customer:get_player_name()] = atm.balance[customer:get_player_name()] - meta:get_int("adminshop:price")
					show_specl_atm(customer)
					meta:set_int("adminshop:counter", meta:get_int("adminshop:counter") + 1)
				elseif not allowed then
					minetest.chat_send_player(customer:get_player_name(),"You are not allowed to buy this!" )
				elseif not enough_space then
					minetest.chat_send_player(customer:get_player_name(),"You don't have enough space in your inventory!")
				end
			-- SELL:
			else
				if allowed and enough_items then
					for i, item in pairs(items) do
				 	 pinv:remove_item("main",item)
				  end
					atm.balance[customer:get_player_name()] = atm.balance[customer:get_player_name()] + meta:get_int("adminshop:price")
					show_specl_atm(customer)
					meta:set_int("adminshop:counter", meta:get_int("adminshop:counter") + 1)
				elseif not allowed then
					minetest.chat_send_player(customer:get_player_name(),"You are not allowed to buy this!" )
				else
					minetest.chat_send_player(customer:get_player_name(),"You don't have the required items in your inventory!" )
				end

			end
			atm.saveaccounts()
			-- --
	    -- if enough_space and allowed then
	    --   for i, item in pairs(items) do
	    --     pinv:remove_item("main",item)
	    --   end
	    --   for i, item in pairs(gives) do
	    --     pinv:add_item("main",item)
	    --   end
	    --   -- minetest.chat_send_player(customer:get_player_name(),"Exchanged!")
			-- elseif not allowed then
			-- 	minetest.chat_send_player(customer:get_player_name(),"You are not allowd to buy this!" )
			-- elseif enough_space then
	    --   minetest.chat_send_player(customer:get_player_name(),"You don't have the required items in your inventory!")
	    -- else
	    --   minetest.chat_send_player(customer:get_player_name(),"You don't have enough space in your inventory!")
	    -- end
	  end
	end)
end

-- Add License
minetest.register_on_player_receive_fields(function(customer, formname, fields)
	if formname == "adminshop:adminshop_license_atm" and fields.add_license ~= nil and fields.add_license ~= "" then
    local pos = default.adminshop_current_license_atm_shop_position[customer:get_player_name()]
    local meta = minetest.get_meta(pos)
		local ltable = minetest.deserialize(meta:get_string("adminshop:ltable"))
		if ltable == nil then
			ltable = {}
		end
		-- Checke, ob das wirklich existiert
    if licenses_exists(fields.license_text) then
			ltable[fields.license_text] = "defined"
			meta:set_string("adminshop:ltable", minetest.serialize(ltable))
			show_specl_atm(customer)
		else
			minetest.chat_send_player(customer:get_player_name(),"This license doesnt exist! Add this with /licenses_add " .. fields.license_text )
		end
	end
end)

-- Remove License
minetest.register_on_player_receive_fields(function(customer, formname, fields)
	if formname == "adminshop:adminshop_license_atm" and fields.remove_license ~= nil and fields.remove_license ~= "" then
		local pos = default.adminshop_current_license_atm_shop_position[customer:get_player_name()]
		local meta = minetest.get_meta(pos)
		local ltable = minetest.deserialize(meta:get_string("adminshop:ltable"))
		if ltable == nil then
			ltable = {}
		end
		ltable[fields.license_text] = nil
		meta:set_string("adminshop:ltable", minetest.serialize(ltable))
		show_specl_atm(customer)
	end
end)

-- Set Buy / Sell
minetest.register_on_player_receive_fields(function(customer, formname, fields)
	if formname == "adminshop:adminshop_license_atm" and fields.set_buy_sell ~= nil and fields.set_buy_sell ~= "" then
		local pos = default.adminshop_current_license_atm_shop_position[customer:get_player_name()]
		local meta = minetest.get_meta(pos)
		if meta:get_string("adminshop:bs") == "Buy" then
			meta:set_string("adminshop:bs", "Sell")
		else
			meta:set_string("adminshop:bs", "Buy")
		end

		show_specl_atm(customer)
	end
end)

-- Set Price
minetest.register_on_player_receive_fields(function(customer, formname, fields)
	if formname == "adminshop:adminshop_license_atm" and fields.set_price ~= nil and fields.set_price ~= "" then
		local pos = default.adminshop_current_license_atm_shop_position[customer:get_player_name()]
		local meta = minetest.get_meta(pos)
		if tonumber(fields.price_field) ~= nil then
			meta:set_int("adminshop:price", fields.price_field)
		end;
		show_specl_atm(customer)
	end
end)
