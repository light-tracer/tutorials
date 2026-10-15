--@ title:       Materials from the library
--@ subtitle:    Built-in presets, color controls and your own materials
--@ category:    Basics
--@ order:       120
--@ duration:    3:55
--@ description: Browse the built-in materials, recolor a diamond through
--@              absorption, turn a plastic preset into a custom finish, and
--@              save both finishes in the User library.

-- Based on the material-library walkthrough at
-- https://www.youtube.com/watch?v=C01RkUvj9sM . This lesson deliberately
-- uses only presets shipped with Light Tracer, not the cloud catalog.

include ("assets/tutorial_common.lua")

lt.import_scene ("data/models/default.zip")
te.wait_loads_complete (60)

local LIBRARY_TAB = "Library/"
local MATERIALS_TAB = "Library/Materials/"
local FILTER = "Library/##Filter/"
local BUILTIN = "Library^/TreeScrollArea_FE54A26B/All materials/Built-in/##clickable_area/"
local GEMSTONES = "Library^/TreeScrollArea_FE54A26B/All materials/Built-in/Gemstones/##clickable_area/"
local PLASTIC = "Library^/TreeScrollArea_FE54A26B/All materials/Built-in/Plastic/##clickable_area/"
local USER = "Library^/TreeScrollArea_FE54A26B/All materials/User/##clickable_area/"
local ADD_TO_LIBRARY = "Properties/^b239^b132^b174 Add to library/"
local DIAMOND_NAME = "Tutorial Violet Diamond"
local PLASTIC_NAME = "Tutorial Coral Charger"
local RT_BUTTON = "RightToolsContainer/##RT/#image/"

local diamond_view = { eye = { -18, -34, 4 }, target = { -0.3, -9.2, -6.4 }, up = { 0, 0, 1 } }

-- The shorter showcase ring lies on the floor, where its main stone makes
-- the absorption change easy to see.
local near_ring = nil
for i = 1, lt.get_sub_node_count (lt.root()) do
  local n = lt.get_sub_node (lt.root(), i)
  if n:get_name() == "square solitaire" then
    if near_ring == nil or n:world_bounds().size[3] < near_ring:world_bounds().size[3] then
      near_ring = n
    end
  end
end

local function child_named (parent, name)
  for i = 1, lt.get_sub_node_count (parent) do
    local n = lt.get_sub_node (parent, i)
    if n:get_name() == name then return n end
  end
end

assert (near_ring, "Expected a showcase ring")
local stone = child_named (near_ring, "Main")
assert (stone, "Expected the ring's main stone")

local function look (view)
  te.do_camera_transition_to (view)
  for _ = 1, 30 do
    te.wait_for_seconds (0.1)
    local now = te.get_camera()
    local delta = 0
    for i = 1, 3 do
      delta = delta + math.abs (now.eye[i] - view.eye[i])
                    + math.abs (now.target[i] - view.target[i])
    end
    if delta < 0.05 then break end
  end
  te.wait_for_seconds (0.4)
end

local function preset_ref (name, search)
  if search then te.item_input_text (FILTER, name) end
  return library_preset_ref ("materials", "builtin:" .. name)
end

local function set_color (label, rgb)
  te.item_click ("Properties/" .. label .. "/##TitleIconButton/")
  te.item_click ("<popup>/Spectrum/")
  te.item_input_value_float ("<popup>/R:/", rgb[1] * 255)
  te.item_input_value_float ("<popup>/G:/", rgb[2] * 255)
  te.item_input_value_float ("<popup>/B:/", rgb[3] * 255)
end

local function save_and_remove (name, category, subject)
  step_at ("If you'd like to reuse this " .. subject .. " material later, ##1 choose Add to library."
        .. " It saves your changes as a separate preset without changing the built-in one.",
           "Properties/^b239^b128^b153 Export material/", "left")
           
  te.wait_for_marker (1)
  te.item_click (ADD_TO_LIBRARY)
  wait_step()

  step ("##1 Name the new material, ##2 give it a category, and ##3 click Add.", "center")
  te.wait_for_marker (1)
  te.item_input_text ("##Popup_4c4c9200/##Material", name)
  te.wait_for_marker (2)
  te.item_input_text ("##Popup_4c4c9200/##Category", category)
  te.wait_for_marker (3)
  local existing = {}
  for _, id in ipairs (te.library_material_ids()) do existing[id] = true end
  te.item_click ("##Popup_4c4c9200/^b239^b128^b140 Add/")
  te.wait_until_not_available ("##Popup_4c4c9200/##Material", 5)
  local saved_id = nil
  for _, id in ipairs (te.library_material_ids()) do
    if not existing[id] then
      assert (saved_id == nil, "Expected only one new library material")
      saved_id = id
    end
  end
  assert (saved_id and string.sub (saved_id, 1, 5) == "user:", "Expected a new User preset")
  wait_step()

  open_tab ("Library")
  te.item_click (MATERIALS_TAB)
  te.item_input_text (FILTER, "") -- a preset search can hide User in the tree
  te.wait_for_frames (3)
  step_at ("##1 Choose User category to find the material you just saved. We'll remove this tutorial"
        .. " copy after finding it, so replaying the lesson won't fill your library.", USER, "left")
  te.wait_for_marker (1)
  library_category ("All materials/User")
  te.item_input_text (FILTER, name)
  te.wait_for_seconds (0.5)
  local ref = library_preset_ref ("materials", saved_id)
  te.checkpoint ("saved " .. subject .. " in User library", "window")
  wait_step()

  step_at ("##1 Right-click this saved preset and ##2 choose Delete. The material already on"
        .. " the model stays in the scene; only the library copy is removed.", ref, "left")
  te.wait_for_marker (1)
  te.item_click (library_preset_ref ("materials", saved_id), 1)
  te.wait_for_marker (2)
  te.item_click ("##Popup_b6ea11e9/Delete")
  te.wait_for_frames (3)
  local _, count = te.library_preset_ref ("materials", saved_id)
  te.expect_eq (count, 0, "tutorial preset removed from User library")
  te.item_input_text (FILTER, "")
  wait_step()
end

tutorial_begin ("The material library gives you ready-made surfaces to try on a model."
             .. " We'll explore the built-in presets, recolor a diamond on this ring, then"
             .. " switch to a product scene and customize its materials. Finally, we'll see where"
             .. " your own materials are saved.")

-- Jewelry mode renders the showcase rings quickly while we compare gems.
te.item_click (RT_BUTTON)
te.wait_for_seconds (0.6)

-- --------------------------------------------------------------- browse
te.point_at (LIBRARY_TAB, "right")
step_at ("##1 Open the Library on the right and ##2 choose Materials. The category tree"
      .. " and search field help you narrow the presets.", "Properties/", "left")
      
te.wait_for_marker (1)
open_tab ("Library")
te.wait_for_marker (2)
te.item_click (MATERIALS_TAB)
te.item_input_text (FILTER, "")
te.wait_for_seconds (0.3)
wait_step()

step_at ("##1 Select Built-in: these presets come with Light Tracer. ##2 Open Gemstones,"
      .. " then ##3 search for Diamond Fancy Green.", BUILTIN, "left")
te.wait_for_marker (1)
library_category ("All materials/Built-in")
te.wait_for_marker (2)
library_category ("All materials/Built-in/Gemstones")
te.wait_for_marker (3)
te.item_input_text (FILTER, "Diamond Fancy Green")
te.wait_for_seconds (0.4)
te.checkpoint ("built-in material search", "window")
wait_step()

-- --------------------------------------------------------------- diamond
look (diamond_view)
step ("On this ring, ##1 select the main stone and ##2 apply Diamond Fancy Green."
   .. " Its glass and light settings are already prepared for a colored gem.", "left")
te.wait_for_marker (1)
lt.select_node (stone)
te.wait_for_marker (2)
te.item_click (preset_ref ("Diamond Fancy Green")) -- keep the existing search
te.wait_loads_complete (30)
te.expect_eq (stone:get_material_name(), "Diamond Fancy Green", "colored diamond preset applied")
te.wait_for_seconds (0.6)
te.checkpoint ("colored diamond preset")
wait_step()

te.point_at ("Properties/", "right")
open_tab ("Properties")

step_at ("Open Properties. Under Glass, ##1 Absorption sets the color the gem takes on"
      .. " as light travels through it. ##2 Depth controls how strongly that tint appears.",
         "Properties/", "left")

te.wait_for_marker (1)
te.move_to_item ("Properties/Absorption:##Absorp/##TitleIconButton/")

te.wait_for_marker (2)
te.move_to_item ("Properties/Depth:/")

wait_step()

step_at ("Change Absorption to violet.",
         "Properties/Interior/", "left")
set_color ("Absorption:##Absorp", { 0.70, 0.25, 0.90 })
wait_step()

step_at ("Increase Depth to lighten the tint."
      .. " A smaller Depth would make the same color stronger.",
         "Properties/Interior/", "left")

te.item_input_value_float ("Properties/Depth:", 500.0)
wait_step()

te.checkpoint ("diamond absorption color")


save_and_remove (DIAMOND_NAME, "Gemstones", "diamond")

-- ---------------------------------------------------------------- plastic
step ("Now let's try the same library on a different product: a laptop charger."
   .. " We'll give its shell a custom plastic finish.", "center")
wait_step()
te.item_click (RT_BUTTON) -- the charger uses the normal renderer, not ring mode
lt.import_scene ("data/tutorials/assets/apple_charger.zip", nil, { load_settings = false })
te.wait_loads_complete (60)
te.wait_for_seconds (0.5)
local charger = lt.find_by_name ("12w_usb_charger_eu (1)")
local front = charger and child_named (charger, "front")
local shell_group = front and child_named (front, "shell")
local shell = shell_group and child_named (shell_group, "shell")
assert (shell, "Expected the charger's front plastic shell")
te.item_click (LIBRARY_TAB)
te.item_click (MATERIALS_TAB)
te.item_input_text (FILTER, "")
te.wait_for_frames (3)
library_category ("All materials/Built-in")

step_at ("##1 Select the charger's front shell, ##2 open Plastic in the built-in library,"
      .. " and ##3 apply Shiny-20 as a starting point.", PLASTIC, "left")
te.wait_for_marker (1)
lt.select_node (shell)
te.wait_for_marker (2)
library_category ("All materials/Built-in/Plastic")
te.wait_for_marker (3)
te.item_click (preset_ref ("Shiny-20 (Windows Blue)", true))
te.wait_loads_complete (30)
te.expect_eq (shell:get_material_name(), "Shiny-20 (Windows Blue)", "plastic preset applied")
te.wait_for_seconds (0.6)
te.checkpoint ("plastic preset")
wait_step()


open_tab ("Properties")
step_at ("A preset is just a starting point. ##1 Make the Base color coral. ##2 Raise Metalness"
      .. " to see a metallic finish, then ##3 return it to zero for plastic. ##4 Increase"
      .. " Roughness for a softer highlight.", "RightToolsContainer/##Denoising/#image/", "left")
te.wait_for_marker (1)
set_color ("Base:##BaseColor", { 0.90, 0.28, 0.22 })
te.wait_for_seconds (0.5)
te.wait_for_marker (2)
te.item_input_value_float ("Properties/Metalness:", 0.65)
te.wait_for_seconds (0.5)
te.checkpoint ("plastic metallic comparison")
te.wait_for_marker (3)
te.item_input_value_float ("Properties/Metalness:", 0.0)
te.wait_for_marker (4)
te.item_input_value_float ("Properties/Roughness:", 0.55)
te.wait_for_seconds (0.7)
te.checkpoint ("custom coral plastic")
wait_step()

-- --------------------------------------------------------------- save
save_and_remove (PLASTIC_NAME, "Studio", "plastic")

lt.clear_selection()
te.item_input_text (FILTER, "")
open_tab ("Tutorials")
te.capture_thumbnail()

tutorial_end ("Built-in presets make a quick starting point. Tune their colors and surface"
           .. " properties to suite your model; when you want to save it for later, save it to the Library.")
