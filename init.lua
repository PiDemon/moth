local function get_moth_formspec()
	return "size[10,10]"..
		"field[1,1;8,1;target;Recipent: ;name]"..
		"textarea[1,3;8,5;message;Message: ;Help me!]"..
		"button_exit[1,8;5,1;send;Fly Away...]"
end
minetest.register_node("moth:moth", {
		description = "Moth",
		inventory_image = "moth_img.png",
		wield_image = "moth_img.png",
		paramtype = "light",
		sunlight_propagates = true,
		drawtype = "plantlike",
		walkable = false,
		tiles = {{
		    name = "moth.png",
		    animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 1}
		}},
		groups = {oddly_breakable_by_hand=3},
		on_use = function(itemstack, player, pointed_thing)
			minetest.show_formspec(player:get_player_name(), "moth_send", get_moth_formspec())
		end
})
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "moth_send" then
		if fields.send then
			local inv = player:get_inventory()
			inv:remove_item("main", "moth:moth")
			local rec = minetest.get_player_by_name(fields.target)
			if rec then 
				local pos = rec:get_pos()
				pos.y = pos.y + 1
				minetest.set_node(pos, {name = "moth:moth"})
				minetest.show_formspec(rec:get_player_name(), "moth_show", "size[10,10]".."label[0.5,0.5;A moth whispers to you...]".."label[0.5,1;(From "..minetest.formspec_escape(player:get_player_name())..")".."]".."textarea[0.5,2.5;7.5,7;;" ..minetest.formspec_escape(fields.message) .. ";]")
			end
		end
	end
end)
if minetest.get_modpath("flowers") then
	minetest.override_item("flowers:dandelion_white", {on_use = function(itemstack, player, pointed_thing) minetest.set_node(player:get_pos(), {name = "moth:moth"}) end})
end
