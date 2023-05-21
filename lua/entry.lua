dofile(ModPath .. "lua/inventorysorter.lua")

Hooks:Add("LocalizationManagerPostInit", "InventorySorter", function (localization_manager)
	localization_manager:add_localized_strings({
		InventorySorter_sort = "Sort",
		InventorySorter_confirm_title = "Are you sure?",
		InventorySorter_confirm_text = "Are you sure you want to sort this inventory?"
	})
end)
