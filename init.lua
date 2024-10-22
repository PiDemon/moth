
local function get_send_formspec()
	return "formspec_version[8] size[8,7.75]"
	    .. "field[0.5,0.75;7,1;target;Recipent: ;]"
	    .. "textarea[0.5,2.25;7,4;message;Message: ;]"
	    .. "button_exit[2,6.5;4,1;send;Fly Away...]"
end

local function get_message_formspec(from, msg)
	return "formspec_version[8] size[8,7.75]"
	    .. "label[0.5,0.5;A moth whispers to you...]"
	    .. "label[0.5,1;(from "..core.formspec_escape(from)..")".."]"
	    .. "textarea[1,1.5;6.5,5.75;;" ..core.formspec_escape(msg) .. ";]"
end

local function get_error_formspec(msg)
	return "formspec_version[8] size[8,1]"
	    .. "label[0.5,0.5;"..core.formspec_escape(msg).."]"
end


core.register_node("moth:moth", {
	description = "Moth",
	inventory_image = "moth_img.png",
	wield_image = "moth_img.png",
	paramtype = "light",
	sunlight_propagates = true,
	drawtype = "plantlike",
	walkable = false,
	tiles = {{
		name = "moth.png",
		animation = { type="vertical_frames", aspect_w=16, aspect_h=16, length=1 }
	}},
	groups = { oddly_breakable_by_hand=2 },
	
	on_use = function(itemstack, player, pointed_thing)
		core.show_formspec(player:get_player_name(), "moth_send", get_send_formspec())
	end,
})


local form_handlers = {}

core.register_on_player_receive_fields(function(player, formname, fields)
	local h = form_handlers[formname]
	if h then return h(player, formname, fields) end
end)

function form_handlers.moth_send(player, formname, fields)
	if not fields.send then return end
	
	local name = player:get_player_name()
	local target = core.get_player_by_name(fields.target)
	if not target then
		core.show_formspec(name, "moth_error", get_error_formspec("The moth wasn't able to find "..fields.target))
		return
	end
	
	local pos = target:get_pos():offset(0,1,0)
	local node = core.get_node(pos)
	if node == "air" or core.registered_nodes[node.name].buildable_to then
		core.set_node(pos, { name="moth:moth" })
	else
		local target_inv = target:get_inventory()
		local rem = target_inv:add_item("main", "moth:moth")
		if not rem:is_empty() then
			core.show_formspec(name, "moth_error", get_error_formspec("The moth couldn't get to "..fields.target))
			return
		end
	end
	
	local player_inv = player:get_inventory()
	player_inv:remove_item("main", "moth:moth")
	
	core.show_formspec(target:get_player_name(), "moth_message", get_message_formspec(name, fields.message))
end


if core.get_modpath("flowers") then
	core.override_item("flowers:dandelion_white", {
		on_use = function(itemstack, player, pointed_thing)
			local pos = player:get_pos():offset(0,1,0)
			local node = core.get_node(pos)
			if node == "air" or core.registered_nodes[node.name].buildable_to then
				core.set_node(pos, { name="moth:moth" })
			end
		end,
	})
end
