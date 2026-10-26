--@ title:       Lighting the scene
--@ revision:    2
--@ subtitle:    Environment slots, maps, lights and backgrounds
--@ category:    Basics
--@ order:       40
--@ duration:    9:03
--@ description: A walkthrough of the Environment tab: build and assign
--@              lighting slots, compare Plain, HDRI map and Sun & sky environments,
--@              adjust brightness and orientation, position map lights, and
--@              finish with projection and backplate controls. Includes
--@              separate metal and gemstone lighting and library downloads.

-- Environment tab walkthrough, with the hands-on slot setup

include ("assets/tutorial_common.lua")

lt.import_scene ("data/models/default.zip")
te.wait_loads_complete (60)
open_tab ("Environment")
te.do_camera_transition_to ({ eye = {88.573, -78.331, 63.298}, target = {0.638, 0.372, 1.714}, up = {-0.352, 0.311, 0.883} })

-- Both rings contain a Frame, a Main stone and fourteen smaller Gems.
-- Walk the hierarchy: find_by_name alone would only find one ring's parts.
local metals, stones = {}, {}
local function collect (parent)
  for i = 1, lt.get_sub_node_count (parent) do
    local node = lt.get_sub_node (parent, i)
    local name = node:get_name()
    if name == "Frame" then
      table.insert (metals, node)
    elseif name == "Main" or name == "Gem" or string.match (name, "^Gem %- %d+$") then
      table.insert (stones, node)
    end
    collect (node)
  end
end
collect (lt.root())
assert (#metals == 2 and #stones == 30, "Expected the two showcase rings and all their stones")

-- The Scene Explorer's material list, in the order it draws the showcase
-- scene's materials: Catcher, Diamond, Diamond, Diamond Fancy Blue Violet,
-- Diamond Fancy Green, Gold 750, Rhodium. Clicking a row selects every part
-- made of that material.
local MATERIAL_ROW = "Scene Explorer^/Content_ECC52E9C/^%d/Select"
local ROW_DIAMOND, ROW_DIAMOND_FANCY_GREEN, ROW_GOLD, ROW_RHODIUM = 1, 4, 5, 6

local function material_row (row)
  return string.format (MATERIAL_ROW, row)
end

--! Fails the lesson unless exactly these parts are selected.
local function expect_selection (parts, what)
  assert (lt.get_selected_node_count() == #parts,
          string.format ("Expected %d %s selected, got %d", #parts, what, lt.get_selected_node_count()))
end

local function expect_slot (parts, slot)
  for _, node in ipairs (parts) do
    assert (node:get_material_environment_slot() == slot - 1,
            node:get_name() .. " was not assigned to environment slot " .. slot)
  end
end

--! Applies a map from the HDRI library already filtered to its category, and
--! narrates the download when there is one.
local function apply_library_map (map_id)
  library_apply_map (map_id, "2k", 180, function (state, thumbnail)
    if state == "download" then
      step ("This map is still a cloud preview, so clicking it opens a download popup. Choose a resolution"
         .. " here; we will take 2K when it is available and wait for the download to finish.", "center")
      te.checkpoint ("HDRI download popup", "window")
      wait_step()
    elseif state == "apply" then
      step_at ("The download has finished. Click the same thumbnail again to apply the map to the active"
         .. " environment slot.", thumbnail, "left")
    else
      step_at ("This map is already downloaded, so the first click applies it straight away.", thumbnail, "left")
    end
  end)
  wait_step()
  te.item_input_text ("Library/##MapFilter", "")
  open_tab ("Properties") -- release the library filter's keyboard focus
end

-- silent setup
te.item_click ("Environment/erase_1/#image/")
te.item_click ("Environment/setup_0")

tutorial_begin ("The Environment tab controls the light around your scene and the background behind it."
             .. " We will look at the lighting controls, environment lights and the"
             .. " backplate, and along the way build separate lighting for the metal and the gemstones"
             .. " of these rings.")

-- ---------------------------------------------------------- environment types
point_step ("In the Editor you choose the environment type: ##1 Plain, ##2 HDRI map or ##3 Sun & sky. ##4 Plain"
   .. " blends an upper and a lower colour into a simple environment - a soft starting point without"
   .. " photographic detail. ##5 Sun & sky generates sunlight and atmosphere procedurally.",
   "Environment/Editor", "top", "right")

te.wait_for_marker (1)
te.move_to_item ("Environment/Plain")

te.wait_for_marker (2)
te.move_to_item ("Environment/HDRI map/")

te.wait_for_marker (3)
te.move_to_item ("Environment/Sun & sky/")

te.wait_for_marker (4)
te.item_click ("Environment/Plain")
te.checkpoint ("plain environment", "window")

te.wait_for_marker (5)
te.item_click ("Environment/Sun & sky")

wait_step()

step_at ("For our studio setup we will use ##1 HDRI maps. These panoramas store a wide range of brightness,"
   .. " so their bright areas light the scene and show up in reflections. The library has both"
   .. " photographed places and studio lighting designed for particular materials.",
   "Environment/Editor", "right")
te.wait_for_marker (1)
te.item_click ("Environment/HDRI map/")
wait_step()

-- -------------------------------------------------------------------- slots
scribble_step ("You can keep up to four environments here. The highlighted slot is the one you are editing;"
   .. " which materials use it is set in the Properties tab.",
   "Environment/setup_0/", { side = "right", at = "Environment/Slots" })
wait_step()

-- -------------------------------------------------------------- metal map
step ("Start with slot one, for the metal. ##1 Open the Library, ##2 choose HDRIs ##3 and filter for Jewelry"
   .. " Metal. These studio maps have broad bright areas that make smooth, readable reflections on"
   .. " polished metal.", "center")
te.wait_for_marker (1)
open_tab ("Library")
te.wait_for_marker (2)
te.item_click ("Library/HDRIs/")
te.item_input_text ("Library/##MapFilter", "")
library_category ("All maps")
te.wait_for_marker (3)
te.item_input_text ("Library/##MapFilter", "jewelry metal")
library_preset_ref ("hdri", "external:metal_softbox_ceiling")
wait_step()

apply_library_map ("external:metal_softbox_ceiling")
te.checkpoint ("metal environment loaded")

open_tab ("Environment")
te.wait_until_available ("Environment/##Adjust/#image/", 5)
point_step ("The menu button in the corner of the map preview ##1 opens image adjustments: resolution,"
   .. " blurring and colour changes. They edit the environment image itself. We will keep the library"
   .. " map as it is and use the lighting controls below it instead.",
   "Environment/##Adjust/#image/", "bottom", { side = "right", at = "Environment/Editor" })
te.wait_for_marker (1)
te.item_click ("Environment/##Adjust/#image/")
te.wait_until_available ("MapTools/", 5)
te.checkpoint ("map image adjustments", "window")
wait_step()
te.item_click ("Environment/##Adjust/#image/")

-- ------------------------------------------------------- metal to slot one
step ("Now let the metal use slot one. ##1 In the Scene Explorer, ##2 switch to the list of materials."
   .. " ##3 Click Gold 750 ##4 and Ctrl-click Rhodium: every part made of either metal is selected, which"
   .. " is both frames.", "center")
te.wait_for_marker (1)
open_tab ("Scene Explorer")
te.wait_for_marker (2)
te.item_click ("Scene Explorer/##Materials")
te.wait_for_marker (3)
te.item_click (material_row (ROW_GOLD))
te.wait_for_marker (4)
te.item_click (material_row (ROW_RHODIUM), 0, { ctrl = true })
te.wait_for_seconds (0.3)
expect_selection (metals, "metal frames")
wait_step()

te.wait_until_available ("Properties/##Slot", 5)

te.point_at ("Properties/##Slot", "left")
step_at ("In Properties, the Environment slot dropdown chooses the lighting their materials use. ##1 Open it"
   .. " ##2 and pick Environment slot 1.", "RightToolsContainer/##TMWidget/#image/", "left")
te.wait_for_marker (1)
te.item_click ("Properties/##Slot")
te.wait_for_marker (2)
te.item_click ("<popup>/Environment slot 1")
te.wait_for_seconds (0.5)
expect_slot (metals, 1)
te.checkpoint ("metal assigned to slot one", "window")
wait_step()

-- ---------------------------------------------------------- gemstone slot
lt.clear_selection()
open_tab ("Environment")
point_step ("Now create the gemstone environment. ##1 Click the plus beside slot one: it creates slot two and"
   .. " selects it for editing, while the metal keeps using slot one.",
   "Environment/setup_1/#image/", "bottom", { side = "right", at = "Environment/Slots" })
te.wait_for_marker (1)
te.item_click ("Environment/setup_1/#image/")
te.wait_for_seconds (0.5)
wait_step()

step ("With slot two active, ##1 go back to the Library ##2 and filter for Jewelry Gemstones. These maps"
   .. " gather their light into small, bright highlights that make the facets sparkle.", "center")
te.wait_for_marker (1)
open_tab ("Library")
te.item_click ("Library/HDRIs/")
te.wait_for_marker (2)
te.item_input_text ("Library/##MapFilter", "jewelry gemstones")
library_category ("All maps")
library_preset_ref ("hdri", "external:gem_brilliance_max")
wait_step()

apply_library_map ("external:gem_brilliance_max")
assert (lt.get_environment(0).type == lt.ENV_IMAGE and lt.get_environment(1).type == lt.ENV_IMAGE,
        "Both slots must contain HDRI maps")

-- ---------------------------------------------------- stones to slot two
step ("Now the stones. ##1 Back in the Scene Explorer's list of materials, ##2 click the first Diamond ##3 and"
   .. " Shift-click Diamond Fancy Green to take the whole range: all thirty stones of both rings.", "center")
te.wait_for_marker (1)
open_tab ("Scene Explorer")
te.wait_for_marker (2)
te.item_click (material_row (ROW_DIAMOND))
te.wait_for_marker (3)
te.item_click (material_row (ROW_DIAMOND_FANCY_GREEN), 0, { shift = true })
te.wait_for_seconds (0.3)
expect_selection (stones, "stones")
wait_step()

te.wait_until_available ("Properties/##Slot", 5)
te.point_at ("Properties/##Slot", "left")
step_at ("##1 Open the Environment slot dropdown again ##2 and choose Environment slot 2. The stones now use"
   .. " the gemstone map, while the metal keeps its own lighting.", "RightToolsContainer/##TMWidget/#image/", "left")
te.wait_for_marker (1)
te.item_click ("Properties/##Slot")
te.wait_for_marker (2)
te.item_click ("<popup>/Environment slot 2")
te.wait_for_seconds (0.5)
expect_slot (stones, 2)
expect_slot (metals, 1)
te.checkpoint ("gemstones assigned to slot two", "window")
wait_step()

-- ------------------------------------------------ intensity and a fill light
lt.clear_selection()
open_tab ("Environment")
te.wait_until_available ("Environment/Intensity:", 5)
local stoneIntensity = lt.get_environment_param (1, lt.ENV_PARAM_INTENSITY)
point_step ("The gemstone map is a bit too bright for these stones, so ##1 let's lower its Intensity.",
   "Environment/Intensity:", "bottom", "right")
te.wait_for_marker (1)
te.item_input_value_float ("Environment/Intensity:", stoneIntensity * 0.6)
te.checkpoint ("gemstone map dimmed")
wait_step()

local metalLights = lt.get_environment_light_count (0)
local stoneLights = lt.get_environment_light_count (1)
step ("To soften the contrast, add a broad fill light. ##1 Open the Library, ##2 switch to Lights ##3 and filter"
   .. " for umbrella. ##4 Clicking the big umbrella adds it to the active slot, slot two, facing the scene"
   .. " from where the camera looks.", "center")
te.wait_for_marker (1)
open_tab ("Library")
te.wait_for_marker (2)
te.item_click ("Library/Lights")
te.wait_for_marker (3)
te.item_input_text ("Library/##LightFilter", "umbrella")
library_preset_ref ("lights", "builtin:alsens_umbrella_big_gs.ltl")
te.wait_for_marker (4)
te.item_click (library_preset_ref ("lights", "builtin:alsens_umbrella_big_gs.ltl"))
te.wait_until_available ("Properties/Width:", 5)
assert (lt.get_environment_light_count(1) == stoneLights + 1, "The umbrella must belong to slot two")
assert (lt.get_environment_light_count(0) == metalLights, "Slot one's lights must stay unchanged")
wait_step()

step_at ("The light's properties are here. ##1 Width and Height set how large the umbrella appears,"
   .. " note"
   .. " ##2 and Radiance how bright it is. ##3 Azimuth and Elevation place it around the scene; ##4 dragging its"
   .. " marker on the map does the same.", "Properties/Radiance:##Light", "left")
te.wait_for_marker (1)
te.item_input_value_float ("Properties/Width:", 130)
te.wait_for_marker (2)
te.item_input_value_float ("Properties/Radiance:##Light", 15)
te.wait_for_marker (3)
te.item_input_value_float ("Properties/Azimuth:", 0)
te.item_input_value_float ("Properties/Elevation:", 30)
te.wait_for_marker (4)
te.item_drag_internal ("Environment/MapPreview/", 0.62, 0.46, 0.51, 0.39)
te.checkpoint ("umbrella fill light", "window")
wait_step()

point_step ("A Flag does the opposite: it masks its patch of the environment, which helps remove an unwanted"
   .. " reflection. ##1 Switch this source to Flag to compare, ##2 then back to Light.",
   "Properties/Flag", "top", "left")
te.wait_for_marker (1)
te.item_click ("Properties/Flag")
te.wait_for_seconds (1)
te.checkpoint ("flag")
te.wait_for_marker (2)
te.item_click ("Properties/Light")
te.wait_for_seconds (1)
wait_step()

-- ------------------------------------------------------------ light list
open_tab ("Environment")
te.wait_until_available ("Environment/Add/#image/", 5)
point_step ("Lights are listed below the map, and each slot keeps its own: this list belongs to slot two and"
   .. " does not touch the metal. ##1 Add creates another source, ##2 and Delete removes the selected one.",
   "Environment/Add/#image/", "bottom", { side = "right", at = "Environment/Lights" })
te.wait_for_marker (1)
te.item_click ("Environment/Add/#image/")
te.wait_for_seconds (0.5)
te.wait_for_marker (2)
te.item_click ("Environment/Delete/#image/")
te.wait_for_seconds (0.5)
assert (lt.get_environment_light_count(1) == stoneLights + 1, "Keep the umbrella fill light")
assert (lt.get_environment_light_count(0) == metalLights, "Slot one's lights must stay unchanged")
wait_step()

point_step ("The lock ##1 makes added lights rotate with their environment. Keep it on when a studio setup"
   .. " should turn as a unit; turn it off to rotate the panorama under lights that stay in place. We"
   .. " will keep our umbrella attached to the gemstone map.",
   "Environment/##LockLights/#image/", "bottom", { side = "right", at = "Environment/Editor" })
te.wait_for_marker (1)
if lt.get_environment_param (1, lt.ENV_PARAM_LOCK_LIGHTS) == 0 then
  te.item_click ("Environment/##LockLights/#image/")
else
  te.move_to_item ("Environment/##LockLights/#image/")
end
wait_step()

local metalRotation = lt.get_environment_param (0, lt.ENV_PARAM_ROTATION)
point_step ("Each slot has its own settings. ##1 Rotate slot two to move the highlights across the stones;"
   .. " slot one's map and the metal stay as they are.", "Environment/Rotation:", "bottom", "right")
te.wait_for_marker (1)
te.item_input_value_float ("Environment/Rotation:", 35)
te.wait_for_seconds (1)
assert (lt.get_environment_param(0, lt.ENV_PARAM_ROTATION) == metalRotation,
        "Rotating slot two must not rotate slot one")
te.checkpoint ("gemstone environment rotated")
wait_step()

step_at ("##1 The arrow below the Editor opens advanced settings. ##2 Inclination tilts the map"
   .. " around a horizontal axis, which is useful for moving the horizon or the height of a reflection.",
   "Environment/Advanced settings##More/##btn", "right")
te.wait_for_marker (1)
if not te.item_status ("Environment/Inclination:").exists then
  te.item_click ("Environment/Advanced settings##More/##btn")
end
te.wait_until_available ("Environment/Inclination:", 5)
local stoneInclination = lt.get_environment_param (1, lt.ENV_PARAM_INCLINATION)
te.wait_for_marker (2)
te.item_input_value_float ("Environment/Inclination:", 15)
te.checkpoint ("environment inclined")
wait_step()
te.item_input_value_float ("Environment/Inclination:", math.deg (stoneInclination))
te.item_click ("Environment/Advanced settings##More/##btn")

-- --------------------------------------------------------------- backplate
point_step ("The Backplate section decides what appears behind the scene. ##1 Disabled shows the environment"
   .. " itself, as the camera sees it. ##2 Normally, environment lights are drawn on top of the HDRI and can be seen with"
   .. " backplate disabled as well.",
   "Environment/Backplate", "top", "right")
te.wait_for_marker (1)
te.item_click ("Environment/Disabled")
te.checkpoint ("backplate disabled")

te.wait_for_marker (2)
te.viewport_drag ({ start = {0.47005, 0.57042}, delta = {-1.33, -86.00}, button = "left", duration = 1.0, eye = {99.873352, -87.314316, 11.024683}, target = {0.745499, 0.070030, 1.575278}, up = {-0.053520, 0.047148, 0.997453} })
te.item_click ("Environment/setup_0/")
te.item_click ("Environment/Add/#image/")
te.item_drag_internal ("Environment/MapPreview/", 0.51, 0.50, 0.10, 0.50)
wait_step()


point_step ("The eye button ##1 hides these lights from view while they keep lighting the scene."
   .. " ##2 Click it again to bring them back.",
   "Environment/##ShowHide/#image/", "bottom", { side = "right", at = "Environment/Editor" })
te.wait_for_marker (1)
te.item_click ("Environment/##ShowHide/#image/")
te.wait_for_marker (2)
te.item_click ("Environment/##ShowHide/#image/")
te.item_click ("Environment^/Content_ECD639AA/^0/Select/")
te.item_click ("Environment/Delete/#image/")
wait_step()


point_step ("Blank mode makes the background transparent, for compositing in an"
   .. " image or video editor. Backplate modes do not change how the scene is lit at all.",
   "Environment/Backplate", "top", "right")
te.item_click ("Environment/Blank")
te.checkpoint ("transparent backplate")
wait_step()


step_at ("##1 Gradient mode paints the background with two colours. ##2 Let's give it two distinct ones, so the changes"
   .. " are easy to see. ##3 Linear blends them along a straight line, ##4 and Radial spreads them out from a"
   .. " centre point.", "Environment/Backplate", "right")
te.wait_for_marker (1)
te.item_click ("Environment/Gradient")
te.wait_until_available ("Environment/GradientPreview", 5)
te.wait_for_marker (2)
te.item_click ("Environment/Start:##Bg/Start:##Bg/##TitleIconButton/")
te.item_click ("##Popup_e49a7beb/##swatches_grid/Leaf Mist/")
te.item_click ("Environment/GradientPreview") -- closes the colour popup
te.item_click ("Environment/Final:##Bg/Final:##Bg/##TitleIconButton/")
te.item_click ("##Popup_5d2d69e3/##swatches_grid/Royal Purple/")
te.item_click ("Environment/GradientPreview")
te.wait_for_marker (3)
te.item_click ("Environment/Linear")
te.checkpoint ("linear gradient backplate", "window")
te.wait_for_marker (4)
te.item_click ("Environment/Radial")
wait_step()

--! Drags a gradient handle to a spot in the preview, given in fractions of it.
local function drag_gradient_handle (handle, rel_x, rel_y)
  te.mouse_move_rel ("Environment/" .. handle, 0.5, 0.5)
  te.mouse_down()
  te.mouse_move_rel ("Environment/GradientPreview", rel_x, rel_y)
  te.mouse_up()
  te.wait_for_seconds (0.3)
end

step_at ("The handles in the preview place the gradient in the frame. ##1 The first sets its centre, ##2 the"
   .. " second how far it reaches. ##3 Stretching reshapes a radial gradient along the line between them.",
   "Environment/GradientPreview", "right")
te.wait_for_marker (1)
drag_gradient_handle ("##GradientStart", 0.42, 0.42)
te.wait_for_marker (2)
drag_gradient_handle ("##GradientFinal", 0.82, 0.22)
te.wait_for_marker (3)
te.item_input_value_float ("Environment/Stretching:", 0.4)
te.wait_for_seconds (1)
te.checkpoint ("radial gradient backplate", "window")
wait_step()

te.force_file_open_path ("data/tutorials/assets/environment_backdrop.jpg")
step_at ("##1 Image uses a photograph or artwork as the backplate: choosing it asks for a file. ##2 Stretch"
   .. " makes the image fill the frame exactly, ##3 and Auto-fit keeps its proportions.",
   "Environment/Backplate", "right")
te.wait_for_marker (1)
te.item_click ("Environment/Image")
te.wait_until_available ("Environment/FitType#Row1/Stretch", 5)
te.wait_for_seconds (1)
te.wait_for_marker (2)
te.item_click ("Environment/FitType#Row1/Stretch")
te.wait_for_seconds (0.5)
te.wait_for_marker (3)
te.item_click ("Environment/FitType#Row1/Auto-fit")
te.wait_for_seconds (1)
te.checkpoint ("image backplate", "window")
wait_step()

step_at ("For these rings ##1 we will go back to the white bacground.",
   "Environment/Backplate", "right")
te.wait_for_marker (1)
te.item_click ("Environment/Gradient/")
te.item_click ("Environment/Start:##Bg/Start:##Bg/##TitleIconButton/")
te.item_click ("##Popup_e49a7beb/##swatches_grid/Pure White/")
te.item_click ("Environment/Final:##Bg/Final:##Bg/##TitleIconButton/")
te.item_click ("##Popup_5d2d69e3/##swatches_grid/Warm Pearl/")
te.item_drag_internal ("Environment/GradientPreview/", 0.82, 0.22, 0.86, 0.50)
te.item_drag_internal ("Environment/GradientPreview/", 0.43, 0.41, 0.52, 0.50)

wait_step()

-- --------------------------------------------------------- import / export
-- Scroll back to the Editor before pointing at the file controls.
te.item_click ("Environment/setup_1")
point_step ("##1 Import map opens an HDRI of your own, such as an HDR or EXR file. ##2 Export map saves the"
   .. " current environment with its added lights, so you can reuse the lighting in another project or"
   .. " in other software. Both work on the active slot, just like the library.",
   "Environment/^b239^b130^b147 Import map", "bottom", { side = "right", at = "Environment/Editor" })
te.wait_for_marker (1)
te.move_to_item ("Environment/^b239^b130^b147 Import map")
te.wait_for_marker (2)
te.move_to_item ("Environment/^b239^b128^b153 Export map")
wait_step()
te.capture_thumbnail()

tutorial_end ("That is the Environment tab: the Editor composes the lighting, slots give you flexible art"
           .. " direction, and the backplate controls the background. Our rings now have separate lighting"
           .. " for the metal and the gemstones - smooth reflections on the frames and lively fire in the"
           .. " diamonds, which is hard to get from a single environment.")
