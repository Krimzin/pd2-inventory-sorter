inventory_sorter = setmetatable({}, {__index = _G})
setfenv(1, inventory_sorter)

function sort_items(category)
	if category == "primaries" then
		sort_primary_weapons()
	elseif category == "secondaries" then
		sort_secondary_weapons()
	elseif category == "masks" then
		sort_masks()
	end
end

function sort_primary_weapons()
	local primaries = Global.blackmarket_manager.crafted_items.primaries
	local profiles = Global.multi_profile._profiles
	local equipped_weapons = {}

	-- Keep a (potentially sparse) list of weapons equipped by the player and crew.
	-- This list may be sparse because it's possible for crew to not have a weapon equipped.
	for i, profile in ipairs(profiles) do
		local base = (i - 1) * 4
		equipped_weapons[base + 1] = primaries[profile.primary]
		equipped_weapons[base + 2] = primaries[profile.henchmen_loadout[1].primary_slot]
		equipped_weapons[base + 3] = primaries[profile.henchmen_loadout[2].primary_slot]
		equipped_weapons[base + 4] = primaries[profile.henchmen_loadout[3].primary_slot]
	end

	local primaries = table.map_values(primaries, compare_weapons)
	local weapon_indices = {}

	-- Map weapons to their index.
	for i, weapon in ipairs(primaries) do
		weapon_indices[weapon] = i
	end

	-- Update the equipped weapon indices.
	for i, profile in ipairs(profiles) do
		local base = (i - 1) * 4
		profile.primary = weapon_indices[equipped_weapons[base + 1]]
		profile.henchmen_loadout[1].primary_slot = weapon_indices[equipped_weapons[base + 2]]
		profile.henchmen_loadout[2].primary_slot = weapon_indices[equipped_weapons[base + 3]]
		profile.henchmen_loadout[3].primary_slot = weapon_indices[equipped_weapons[base + 4]]
	end

	Global.blackmarket_manager.crafted_items.primaries = primaries
end

function sort_secondary_weapons()
	local secondaries = Global.blackmarket_manager.crafted_items.secondaries
	local profiles = Global.multi_profile._profiles
	local equipped_weapons = {}

	-- Keep a list of weapons equipped by the player.
	for i, profile in ipairs(profiles) do
		equipped_weapons[i] = secondaries[profile.secondary]
	end

	local secondaries = table.map_values(secondaries, compare_weapons)
	local weapon_indices = {}

	-- Map weapons to their index.
	for i, weapon in ipairs(secondaries) do
		weapon_indices[weapon] = i
	end

	-- Update the equipped weapon indices.
	for i, profile in ipairs(profiles) do
		profile.secondary = weapon_indices[equipped_weapons[i]]
	end

	Global.blackmarket_manager.crafted_items.secondaries = secondaries
end

-- Sort weapons by category and name.
function compare_weapons(a, b)
	local a_category = get_weapon_category(a)
	local b_category = get_weapon_category(b)

	if a_category == b_category then
		return get_weapon_name(a) < get_weapon_name(b)
	else
		return a_category < b_category
	end
end

function compare_damage(a, b)
	local a_category = get_weapon_category(a)
	local b_category = get_weapon_category(b)

	if a_category == b_category then
		return get_weapon_name(a) < get_weapon_name(b)
	else
		return a_category < b_category
	end
end

function get_weapon_category(weapon)
	local categories = tweak_data.weapon[weapon.weapon_id].categories
	local category = tweak_data.gui.buy_weapon_category_aliases[categories[1]] or categories[1]

	-- Identify akimbo categories.
	if (category == "akimbo") and categories[2] then
		category = string.format("%s_%s", category, categories[2])
	end

	return category
end

function get_weapon_name(weapon)
	return weapon.custom_name or managers.weapon_factory:get_weapon_name_by_weapon_id(weapon.weapon_id)
end

function sort_masks()
	local masks = Global.blackmarket_manager.crafted_items.masks
	local profiles = Global.multi_profile._profiles
	local equipped_masks = {}

	-- Keep a list of masks equipped by the player and crew.
	for i, profile in ipairs(profiles) do
		local base = (i - 1) * 4
		equipped_masks[base + 1] = masks[profile.mask]
		equipped_masks[base + 2] = masks[profile.henchmen_loadout[1].mask_slot]
		equipped_masks[base + 3] = masks[profile.henchmen_loadout[2].mask_slot]
		equipped_masks[base + 4] = masks[profile.henchmen_loadout[3].mask_slot]
	end

	local masks = table.map_values(masks, compare_masks)
	local mask_indices = {}

	-- Map masks to their index.
	for i, mask in ipairs(masks) do
		mask_indices[mask] = i
	end

	-- Update the equipped mask indices.
	for i, profile in ipairs(profiles) do
		local base = (i - 1) * 4
		profile.mask = mask_indices[equipped_masks[base + 1]]
		profile.henchmen_loadout[1].mask_slot = mask_indices[equipped_masks[base + 2]]
		profile.henchmen_loadout[2].mask_slot = mask_indices[equipped_masks[base + 3]]
		profile.henchmen_loadout[3].mask_slot = mask_indices[equipped_masks[base + 4]]
	end

	Global.blackmarket_manager.crafted_items.masks = masks
end

-- Ensure the default character mask is always first, otherwise compare names.
function compare_masks(a, b)
	if b.mask_id == "character_locked" then
		return false
	end

	if a.mask_id == "character_locked" then
		return true
	end

	return get_mask_name(a) < get_mask_name(b)
end

function get_mask_name(mask)
	local name_id = tweak_data.blackmarket.masks[mask.mask_id].name_id
	return mask.custom_name or managers.localization:text(name_id)
end
