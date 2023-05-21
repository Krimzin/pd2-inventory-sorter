local highlight = tweak_data.screen_colors.button_stage_2
local no_highlight = tweak_data.screen_colors.button_stage_3

Hooks:PostHook(BlackMarketGui, "_setup", "InventorySorter", function (self, is_start_page, component_data)
	local category = self._data.category

	if (category == "primaries") or (category == "secondaries") or (category == "masks") then
		self._InventorySorter_is_highlighted = self._InventorySorter_is_highlighted or false
		local panel = self._panel:panel({
			name = "InventorySorter_sort"
		})
		local text = panel:text({
			name = "InventorySorter_text",
			text = managers.localization:to_upper_text("InventorySorter_sort"),
			font = tweak_data.menu.pd2_medium_font,
			font_size = tweak_data.menu.pd2_medium_font_size,
			color = self._InventorySorter_is_highlighted and highlight or no_highlight
		})
		local x, y, w, h = text:text_rect()
		text:set_size(w, h)
		panel:set_size(w, h)
		panel:set_top(self._box_panel:bottom() + 4)
		panel:set_right(self._box_panel:right())
	end
end)

Hooks:PostHook(BlackMarketGui, "mouse_moved", "InventorySorter", function (self, o, x, y)
	local sort_button = self._panel:child("InventorySorter_sort")

	if alive(sort_button) then
		local sort_text = sort_button:child("InventorySorter_text")

		if sort_button:inside(x, y) then
			if not self._InventorySorter_is_highlighted then
				managers.menu_component:post_event("highlight")
				sort_text:set_color(highlight)
				self._InventorySorter_is_highlighted = true
			end
			
			local used = true
			local pointer = "link"
			return used, pointer
		elseif self._InventorySorter_is_highlighted then
			sort_text:set_color(no_highlight)
			self._InventorySorter_is_highlighted = false
		end
	end
end)

local left_button = Idstring("0")
Hooks:PostHook(BlackMarketGui, "mouse_pressed", "InventorySorter", function (self, button, x, y)
	local sort_button = self._panel:child("InventorySorter_sort")

	if alive(sort_button) and sort_button:inside(x, y) and (button == left_button) then
		managers.system_menu:show({
			title = managers.localization:to_upper_text("InventorySorter_confirm_title"),
			text = managers.localization:text("InventorySorter_confirm_text"),
			button_list = {
				{
					text = managers.localization:text("dialog_yes"),
					callback_func = function ()
						inventory_sorter.sort_items(self._data.category)
						self:reload()
					end
				},
				{
					text = managers.localization:text("dialog_no"),
					cancel_button = true
				}
			}
		})
	end
end)
