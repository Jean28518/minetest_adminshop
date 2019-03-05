minetest.register_privilege("adminshop", {
	description = "Player can place and destruct any adminshop",
	give_to_singleplayer= false,
})

-- Adminshop
-- Globaler Arrayspeicher
default.adminshop_current_shop_position = {}
minetest.register_node("adminshop:adminshop", {

    description = "Adminshop",
    tiles = {"dummy.png"},
    is_ground_content = true,
    groups = {choppy=2},
    sounds = default.node_sound_wood_defaults(),
-- Registriere den Owner beim Platzieren:
    after_place_node = function(pos, placer, itemstack)
      if not minetest.check_player_privs(placer:get_player_name(), { adminshop=true }) then
  --    if minetest.check_player_privs(placer:get_player_name(), { adminshop=false }) then
        minetest.chat_send_player(placer:get_player_name(),"You don't have the required privilege to place an adminshop!")
        minetest.remove_node(pos)
      end
      local meta = minetest.get_meta(pos)
      meta:set_string("owner", placer:get_player_name())
      local inv = meta:get_inventory()
      inv:set_size("einnahme", 2*2)
      inv:set_size("ausgabe", 2*2)
    end,
    on_rightclick = function(pos, node, player, itemstack, pointed_thing)
      -- Schreibe die eigene Position des Blockes in eine öffentliche Variable mit dem Namen des Spielernamens, welcher auf den Block zugegriffen hat
      default.adminshop_current_shop_position[player:get_player_name()] = pos
      show_spec(player)
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

show_spec = function (player)
    local pos = default.adminshop_current_shop_position[player:get_player_name()]
    local meta = minetest.get_meta(pos)
    local listname = "nodemeta:"..pos.x..','..pos.y..','..pos.z
    if player:get_player_name() == meta:get_string("owner") then
      --"label[0,0;Welcome back, " .. meta:get_string("owner") ..
      --  "list["..listname..";einnahme;0,3.5;8,4;]"
     minetest.show_formspec(player:get_player_name(), "adminshop:adminshop", "size[8,7.5]"..
     "label[0,0;Welcome back, ".. meta:get_string("owner").."]" ..
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
      for i, item in pairs(wants) do
        pinv:remove_item("main",item)
      end
      for i, item in pairs(gives) do
        pinv:add_item("main",item)
      end
      minetest.chat_send_player(customer:get_player_name(),"Exchanged!")
    elseif enough_space then
      minetest.chat_send_player(customer:get_player_name(),"You don't have the required items in your inventory!")
    else
      minetest.chat_send_player(customer:get_player_name(),"You don't have enough space in your inventory!")
    end
  end
end)
