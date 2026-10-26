--@ title:       Post-processing a render
--@ revision:    2
--@ subtitle:    Exposure, contrast and color balance
--@ category:    Basics
--@ order:       140
--@ duration:    2:57
--@ description: Finish the default jewelry scene with the current Tone mapping
--@              and Color balance widgets on the right tool rail.

-- Adapted from https://www.youtube.com/watch?v=XY4WJG_EP4M . The video uses
-- an older Settings panel; these controls now live in two separate widgets.

include ("assets/tutorial_common.lua")

lt.import_scene ("data/models/default.zip")
te.wait_loads_complete (60)

lt.set_environment_from_file ("data/hdri/indoor_brown_photostudio.hdr")
lt.set_environment_param (0, lt.ENV_PARAM_INTENSITY, 0.7)
lt.set_environment_param (0, lt.ENV_PARAM_ROTATION, math.rad (185))

lt.set_environment_param (1, lt.ENV_PARAM_INTENSITY, 0.150)

local TM_BUTTON = "RightToolsContainer/##TMWidget/#image/"
local COLOR_BUTTON = "RightToolsContainer/##ColorBalanceWidget/#image/"

local floor = lt.find_by_name ("Scene floor")
assert (floor, "Expected the showcase catcher floor")

-- A plum backdrop makes the Render / Backplate switch visibly different.
-- Keep the original scene lighting and the default view of both rings.
lt.set_backplate_color ({ 0.09, 0.06, 0.12 })
lt.set_backplate_type (lt.BACKPLATE_SOLID_COLOR)
lt.select_node (floor)
open_tab ("Properties")
te.item_input_value_float ("Properties/Reflections:", 0.4)
te.item_input_text ("Properties/Roughness:/", 0.032)
lt.clear_selection()
te.item_click ("LeftGrabContainer/##LeftGrab/")
te.item_click ("RightGrabContainer/##RightGrab/")
te.wait_for_seconds (0.8)

tutorial_begin ("The rings are already lit and composed. Let's shape the finished"
             .. " image without changing the scene: first set exposure and contrast,"
             .. " then balance the colors. Both tools are on the right rail.")

-- ------------------------------------------------------------ tone mapping
point_step ("##1 Open tone-mapping widget on the right tool rail. The curve previews how"
         .. " bright and dark parts of the image will be mapped to the screen.",
            TM_BUTTON, "bottom", "top")
te.wait_for_marker (1)
te.item_click (TM_BUTTON)
te.wait_until_available ("ToneMapping/Exposure:", 5)
wait_step()
te.clear_attention()

step_at ("##1 Push Exposure up: the rings brighten, but the brightest facets"
      .. " start to lose detail. ##2 Pull it below zero to bring that detail"
      .. " back; now the gold feels too dim. ##3 Settle at -0.25 to keep it"
      .. " well-exposed and readable.",
         "ToneMapping/Exposure:", "left")
te.wait_for_marker (1)
te.item_input_value_float ("ToneMapping/Exposure:", 1.5)
te.wait_for_seconds (0.6)
te.checkpoint ("high exposure")
te.wait_for_marker (2)
te.item_input_value_float ("ToneMapping/Exposure:", -1.0)
te.wait_for_seconds (0.6)
te.checkpoint ("low exposure")
te.wait_for_marker (3)
te.item_input_value_float ("ToneMapping/Exposure:", -0.25)
wait_step()

step_at ("##1 More Contrast gives the metal deeper darks and brighter highlights."
      .. " ##2 A negative value flattens the image. ##3 Bring back just enough"
      .. " contrast to keep detail in both the gold and the stones.",
         "ToneMapping/Contrast:", "left")
te.wait_for_marker (1)
te.item_input_value_float ("ToneMapping/Contrast:", 6.0)
te.wait_for_seconds (0.6)
te.checkpoint ("strong contrast")
te.wait_for_marker (2)
te.item_input_value_float ("ToneMapping/Contrast:", -5.0)
te.wait_for_seconds (0.6)
te.checkpoint ("flat contrast")
te.wait_for_marker (3)
te.item_input_value_float ("ToneMapping/Contrast:", 1.5)
wait_step()

step_at ("##1 Open Advanced. The Midpoint control shifts where that contrast"
      .. " curve bends; the graph above updates as you move it.",
         "ToneMapping/Advanced/##btn", "left")
te.wait_for_marker (1)
te.item_click ("ToneMapping/Advanced/##btn")
te.wait_until_available ("ToneMapping/Midpoint:", 5)
wait_step()

step_at ("##1 Move Midpoint and watch the curve bend, then ##2 bring it back."
      .. " Small changes here are usually enough; the main Contrast slider"
      .. " sets the overall strength.", "ToneMapping/Midpoint:", "left")
te.wait_for_marker (1)
te.item_input_value_float ("ToneMapping/Midpoint:", 0.7)
te.wait_for_seconds (0.6)
te.checkpoint ("contrast midpoint shifted")
te.wait_for_marker (2)
te.item_input_value_float ("ToneMapping/Midpoint:", 0.5)
wait_step()

-- ----------------------------------------------------------- color balance
point_step ("##1 Open Color balance. It is a separate widget, with controls"
         .. " for which parts of the image receive the grade.",
            COLOR_BUTTON, "bottom", "top")
te.wait_for_marker (1)
te.item_click (COLOR_BUTTON)
te.wait_until_available ("ColorBalance/Saturation:", 5)
wait_step()
te.clear_attention()

step_at ("The three buttons choose where the grade goes. ##1 Select Render and"
      .. " remove saturation: the rings lose their color, but the plum backdrop"
      .. " remains. ##2 Select Backplate to affect only the background. ##3 Choose"
      .. " All and restore saturation for the finished image.",
         "ColorBalance/Render##ColorBalance", "left")
te.wait_for_marker (1)
te.item_click ("ColorBalance/Render##ColorBalance")
te.item_input_value_float ("ColorBalance/Saturation:", 0.0)
te.wait_for_seconds (0.7)
te.checkpoint ("render desaturated")
te.wait_for_marker (2)
te.item_click ("ColorBalance/Backplate##ColorBalance")
te.wait_for_seconds (0.7)
te.checkpoint ("backplate desaturated")
te.wait_for_marker (3)
te.item_click ("ColorBalance/All##ColorBalance")
te.item_input_value_float ("ColorBalance/Saturation:", 1.1)
te.wait_for_seconds (0.7)
te.checkpoint ("color restored")
wait_step()

step_at ("##1 Switch back to Render so the backdrop keeps its color while we"
      .. " grade the jewelry. ##2 The three wheels handle shadows, midtones and"
      .. " highlights independently.", "ColorBalance/Render##ColorBalance", "left")
te.wait_for_marker (1)
te.item_click ("ColorBalance/Render##ColorBalance")
te.wait_for_marker (2)
te.scribble_at ("ColorBalance/Midtones:/ColorCircle")
te.wait_for_seconds (0.4)
wait_step()
te.clear_attention()

step_at ("##1 Add a touch of blue to the Shadows. Notice that the bright facets"
      .. " remain mostly neutral; this wheel shapes the darker metal and reflections.",
         "ColorBalance/Shadows:/ColorCircle", "left")
te.wait_for_marker (1)
te.item_click_pos ("ColorBalance/Shadows:/ColorCircle", 0.45, 0.42)
te.wait_for_seconds (0.7)
te.checkpoint ("cool shadows")
wait_step()

step_at ("##1 Nudge the Midtones brighter, then ##2 give the Highlights a little"
      .. " warmth. The wheels let us separate these ranges without changing the"
      .. " scene lights or gemstone materials.",
         "ColorBalance/Highlights:/ColorCircle", "left")
te.wait_for_marker (1)
te.item_input_value_float ("ColorBalance/Midtones:", 1.05)
te.wait_for_marker (2)
te.item_click_pos ("ColorBalance/Highlights:/ColorCircle", 0.55, 0.563)
te.wait_for_seconds (0.8)
te.checkpoint ("warm highlights")
wait_step()

te.capture_thumbnail()

tutorial_end ("Exposure and contrast shape the tonal range; Color balance grades"
           .. " the render, the backdrop, or both. These are post-processing"
           .. " controls, so you can try a look and see it immediately without"
           .. " restarting the path-traced render.")
