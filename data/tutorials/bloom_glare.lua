--@ title:       Bloom and glare
--@ subtitle:    Soft glow, sharp streaks and focused highlights
--@ category:    Basics
--@ order:       130
--@ duration:    3:26
--@ description: Stage the showcase rings against a dark background and a
--@              reflective catcher, then tune bloom, glare and their newer
--@              advanced controls in Real-time jewelry mode.

-- Adapted from https://www.youtube.com/watch?v=DicnLkucOhs . The current
-- panel adds Intensity, Rotation, Streak blur, Fringes and Dispersion to the
-- controls shown in the video.

include ("assets/tutorial_common.lua")

lt.import_scene ("data/models/default.zip")
te.wait_loads_complete (60)

local RT_BUTTON = "RightToolsContainer/##RT/#image/"
local BLOOM_BUTTON = "RightToolsContainer/##BloomWidget/#image/"
local floor = lt.find_by_name ("Scene floor")
assert (floor, "Expected the showcase catcher floor")

-- Use one HDRI for all the materials in this lesson. The showcase ships with
-- two slots; remove the second before replacing slot one with the studio map.
open_tab ("Environment")
te.item_click ("Environment/erase_1/#image/")
lt.set_environment_from_file ("data/hdri/indoor_brown_photostudio.hdr")
lt.set_environment_param (0, lt.ENV_PARAM_INTENSITY, 0.7)
lt.set_environment_param (0, lt.ENV_PARAM_ROTATION, math.rad (185))

te.wait_loads_complete (60)

-- A dark backdrop separates highlights from the background without changing
-- the HDRI lighting. The existing floor remains a catcher, and a little
-- reflection makes the ring feel grounded rather than suspended in black.
lt.set_backplate_color ({ 0.025, 0.025, 0.035 })
lt.set_backplate_type (lt.BACKPLATE_SOLID_COLOR)
lt.select_node (floor)
open_tab ("Properties")
te.item_input_value_float ("Properties/Reflections:", 0.4)
te.item_input_text ("Properties/Roughness:/", 0.032)


lt.clear_selection()

local home_view = { eye = { -48, -81, 23 }, target = { -0.3, -9.2, -6.4 }, up = { 0, 0, 1 } }
local orbit_view = { eye = { -40, -86, 24 }, target = home_view.target, up = home_view.up }
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
  te.wait_for_seconds (0.3)
end
look (home_view)

tutorial_begin ("Bright facets can feel more photographic with a little glow. Bloom makes a soft"
             .. " halo; glare draws sharper streaks from the brightest highlights. We'll try both"
             .. " on a ring lit by a studio HDRI, then shape the effect with Light Tracer's"
             .. " controls.")

-- ------------------------------------------------------------ stage and mode
point_step ("The ring is lit by one studio HDRI, with a dark background and reflective catcher."
         .. " Those bright facets give bloom something to work with. ##1 Enable Real-time"
         .. " jewelry mode to keep the preview responsive while we tune them.",
            RT_BUTTON, "right", "left")
te.wait_for_marker (1)
te.item_click (RT_BUTTON)
te.wait_for_seconds (1.0)
te.checkpoint ("dark ring stage")
wait_step()

point_step ("##1 Open Bloom widget from the right toolbar. The same panel holds the soft"
         .. " halo, the star-like streaks and their preview kernel.",
            BLOOM_BUTTON, "bottom", "top")
te.wait_for_marker (1)
te.item_click (BLOOM_BUTTON)
te.wait_until_available ("Bloom/Disabled", 5)
wait_step()

-- -------------------------------------------------------- off / soft bloom
step_at ("##1 Choose Disabled for a clean baseline. ##2 Switch to Enabled and watch the"
      .. " brightest facets begin to glow. This is post-processing: it does not change the"
      .. " ring's material or its lighting.", "Bloom/Disabled", "left")
te.wait_for_marker (1)
te.item_click ("Bloom/Disabled")
te.wait_for_seconds (0.7)
te.checkpoint ("glow disabled")
te.wait_for_marker (2)
te.item_click ("Bloom/Enabled")
te.wait_for_seconds (1.0)
wait_step()

step_at ("##1 Push Intensity high: even less-bright facets begin to glow. ##2 Ease it"
      .. " back so the glow favors the brightest highlights. ##3 Keep Glare low for now;"
      .. " that lets us see the soft halo on its own.",
         "Bloom/Intensity:", "left")
te.wait_for_marker (1)
te.item_input_value_float ("Bloom/Intensity:", 1.8)
te.wait_for_seconds (0.7)
te.checkpoint ("strong bloom halo")
te.wait_for_marker (2)
te.item_input_value_float ("Bloom/Intensity:", 0.5)
te.wait_for_marker (3)
te.item_input_value_float ("Bloom/Glare:", 0.05)
te.wait_for_seconds (1.0)
te.checkpoint ("soft bloom halo")
wait_step()

step_at ("##1 Increase Size and the same glow spreads farther, making it broader but"
      .. " less bright at the center. ##2 Bring it back for a tighter halo that keeps"
      .. " the facets crisp.",
         "Bloom/Size:", "left")
te.wait_for_marker (1)
te.item_input_value_float ("Bloom/Size:", 0.8)
te.wait_for_seconds (0.6)
te.checkpoint ("broad bloom")
te.wait_for_marker (2)
te.item_input_value_float ("Bloom/Size:", 0.31)
wait_step()

step ("The glow stays attached to the highlights as the camera moves. ##1 Let's orbit"
   .. " a little to see that shape from another angle, then ##2 return to the hero view.",
      "bottom")
te.wait_for_marker (1)
look (orbit_view)
te.checkpoint ("bloom from another angle")
te.wait_for_marker (2)
look (home_view)
wait_step()

-- ------------------------------------------------------- focused highlights
te.item_click ("Environment/")
te.wait_until_available ("Environment/Add/#image/", 5)
local lights_before = lt.get_environment_light_count (0)
point_step ("Bloom needs bright points to work with. ##1 Add a small environment light."
         .. " ##2 Narrow its Width and Height, then ##3 set the Radiance. A compact bright"
         .. " source draws a more defined glint on the stones.",
            "Environment/Add/#image/", "bottom",
            { side = "right", at = "Environment/Lights" })
te.wait_for_marker (1)
te.item_click ("Environment/Add/#image/")
te.wait_until_available ("Properties/Width:", 5)
te.expect_eq (lt.get_environment_light_count (0), lights_before + 1,
              "one environment light added")
te.wait_for_marker (2)
te.item_input_value_float ("Properties/Width:", 5)
te.wait_for_marker (3)
te.item_input_value_float ("Properties/Radiance:##Light", 160)
te.wait_for_seconds (1.0)
te.checkpoint ("focused environment highlight")
wait_step()

if not te.item_status ("Bloom/Glare:").exists then
  te.item_click (BLOOM_BUTTON)
end
te.wait_until_available ("Bloom/Glare:", 5)
step_at ("##1 Raise Glare to turn the halo into bright streaks. ##2 Try a busy"
      .. " eight-ray star, then ##3 reduce Streaks to two for the cleaner jewelry look.",
         "Bloom/Glare:", "left")
te.wait_for_marker (1)
te.item_input_value_float ("Bloom/Glare:", 0.93)
te.wait_for_marker (2)
te.item_input_value_int ("Bloom/Streaks:", 8)
te.wait_for_seconds (0.8)
te.checkpoint ("eight glare streaks")
te.wait_for_marker (3)
te.item_input_value_int ("Bloom/Streaks:", 2)
te.wait_for_seconds (1.1)
te.checkpoint ("two glare streaks")
wait_step()

step_at ("##1 Drag Rotation and watch the two-ray pattern turn while the ring and"
      .. " lights stay put.",
         "Bloom/Rotation:", "left")
te.wait_for_marker (1)

te.item_drag_internal ("Bloom/Rotation:/", 0.34, 0.61, 0.80, 0.52)
te.item_drag_internal ("Bloom/Rotation:/", 0.73, 0.36, 0.23, 0.54)

te.checkpoint ("rotated two-ray glare")
wait_step()

-- ----------------------------------------------------------- advanced shape
step_at ("##1 Open the advanced controls. These give the glow a softer falloff and"
      .. " let you style the streaks as you like them.",
         "Bloom/##Advanced/##btn", "left")
te.wait_for_marker (1)
te.item_click ("Bloom/##Advanced/##btn")
te.wait_until_available ("Bloom/Scattering:", 5)
wait_step()

step_at ("##1 Drop Scattering to zero to see the tight core, then ##2 take it"
      .. " all the way up for a wider falloff. ##3 Try a very soft Streak blur, then ##4"
      .. " revert it so the rays stay defined.",
         "Bloom/Scattering:", "top")
te.wait_for_marker (1)
te.item_input_value_float ("Bloom/Scattering:", 0.0)
te.wait_for_seconds (0.5)
te.wait_for_marker (2)
te.item_input_value_float ("Bloom/Scattering:", 1.0)
te.wait_for_marker (3)
te.item_input_value_float ("Bloom/Streak blur:", 0.6)
te.wait_for_seconds (0.6)
te.checkpoint ("blurred glare rays")
te.wait_for_marker (4)
te.item_input_value_float ("Bloom/Streak blur:", 0.10)
te.wait_for_seconds (0.7)
te.checkpoint ("softened streaks")
wait_step()

step_at ("##1 Turn Fringes down to remove the repeated detail along the rays,"
      .. " then ##2 bring it up. ##3 Dispersion at zero is colorless; ##4 at"
      .. " 1 the edges split into color. You can dial these back for a quieter shot.",
         "Bloom/Fringes:", "bottom")
te.wait_for_marker (1)
te.item_input_value_float ("Bloom/Fringes:", 0.0)
te.wait_for_seconds (0.5)
te.wait_for_marker (2)
te.item_input_value_float ("Bloom/Fringes:", 0.71)
te.wait_for_marker (3)
te.item_input_value_float ("Bloom/Dispersion:", 0.0)
te.wait_for_seconds (0.5)
te.wait_for_marker (4)
te.item_input_value_float ("Bloom/Dispersion:", 1.0)
te.wait_for_seconds (1.0)
te.checkpoint ("finished bloom and glare")
wait_step()

-- Leave the finished shot clear of controls for the gallery thumbnail.
te.item_click (BLOOM_BUTTON)
lt.clear_selection()
te.wait_for_seconds (0.6)
te.capture_thumbnail()

te.item_click ("Tutorials/")

tutorial_end ("Bloom gives bright details a soft halo; glare turns it into"
           .. " streaks. Start with restrained Intensity and Size, then adjust"
           .. " for the intended look. Feel free to experiment.")
