--@ title:       Composing object animations
--@ revision:    2
--@ subtitle:    Create keyframe animations to move objects
--@ category:    Basics
--@ order:       70
--@ duration:    3:45
--@ description: Animating an object with keyframes: a shadow catcher under the
--@              product with its shadow baked and locked, moving a whole group
--@              instead of a single part, a keyframe at each end of the move,
--@              and the button that records the result as a video.

-- Assembles a charger in front of the camera: the product moves, the camera
-- does not. The lighting comes from the showcase scene and the model from its
-- own file, which is why the second import asks for the geometry alone.

include ("assets/tutorial_common.lua")

lt.import_scene ("data/models/default.zip") -- only for environment map (slot 0)
lt.import_scene ("data/tutorials/assets/apple_charger.zip", nil, { load_settings = false })

te.wait_for_seconds (0.5)

local SCENE_KEY = "Animation/SceneKey/#image/"
local PLAY      = "Animation/Video/Play/#image/"
local START     = "Animation/Video/Start/#image/"
local UNDO      = "ToolContainer/Undo/#image/"

--! Waits until the catcher's shadow mask has finished baking.
local function wait_for_bake (node, seconds)
  for _ = 1, math.ceil ((seconds or 30) / 0.5) do
    if node:get_baked_map_ready() then
      return true
    end

    te.wait_for_seconds (0.5)
  end

  return false
end

tutorial_begin ("In this tutorial, we'll turn this charger into a simple product animation. We'll"
             .. " lift the front section away, bring it back, and keep its shadow firmly in place"
             .. " throughout the shot.")

-- ------------------------------------------------------------ the catcher
step ("Let's start by giving the charger a surface to sit on. ##1 Open the modeling toolbox and add"
   .. " a square floor. This floor is a shadow catcher: it stays invisible while receiving the"
   .. " charger's shadow and reflection. ##2 Scale it down to fit beneath the charger.", "center")

te.wait_for_marker (1)
te.item_click ("LeftGrabContainer/##LeftGrab/")
te.item_click ("LeftToolsContainer/##Model/#image/")
te.item_click ("Modeling/Square floor/##/")

local catcher = lt.get_selected_node (1)

te.wait_for_marker (2)
te.gizmo_drag ({ handle = "ScXYZ", origin = {0.54049, 0.74467}, start = {2.34, -1.20}, delta = {-0.03023, -0.00454}, duration = 0.6, T = {0.000000, 0.000000, 0.000000}, R = {0.000000, 0.000000, 0.000000}, S = {0.600000, 0.600000, 0.600000} })
te.item_click ("LeftToolsContainer/##Model/#image/")
te.item_click ("LeftGrabContainer/##LeftGrab/")

te.checkpoint ("the catcher floor")

wait_step()

step_at ("Now let's adjust the catcher in Properties. ##1 Turn Reflections all the way down. We only"
   .. " need a soft contact shadow here, not a mirror image of the charger.", "Properties/", "left")

te.item_click ("Properties/")

te.wait_for_marker (1)
te.item_drag_internal ("Properties/Reflections:/", 0.48, 0.50, -0.17, 0.61)

wait_step()

step_at ("Next, ##1 enable Baked opacity under Textures. This captures the shadow in a texture, so it"
   .. " doesn't have to be recalculated for every frame. Once the bake is complete, ##2 lock the"
   .. " map. The shadow will now stay in place while the charger moves.",
   "Properties/", "left")

te.wait_for_marker (1)
te.item_click ("Properties/^1/Baked opacity/")

wait_for_bake (catcher, 60)
te.checkpoint ("the shadow baked into a mask")

te.wait_for_marker (2)
te.item_click ("Properties/^1/##Lock/#image/")

wait_step()

-- -------------------------------------------------------- moving the parts
te.viewport_zoom ({ at = {0.39258, 0.46788}, scroll = -32.0000, steps = 7, duration = 0.5, eye = {565.780640, 226.976334, 161.607040}, target = {0.000000, 19.500000, 23.000000}, up = {-0.205558, -0.080431, 0.975334} })

step ("Before we animate the charger, let's make sure we're moving the right object. ##1 Double-click"
   .. " the front in the viewport to select the individual part beneath the cursor. ##2 Drag the"
   .. " blue arrow, and only that one part moves.",
   "left")

te.wait_for_marker (1)
do
  local x, y = te.world_to_screen ({ 13.992554, 16.689987, 36.347946 })
  te.click_viewport (x, y, { count = 2 })
end
te.wait_for_seconds (0.5)

te.wait_for_marker (2)
te.gizmo_drag ({ handle = "TrZ", origin = {0.55618, 0.46481}, start = {-0.83, -166.94}, delta = {-0.00983, -0.21693}, duration = 1.46875, T = {0.000000, 0.000000, 34.930222}, R = {0.000000, 0.000000, 0.000000}, S = {1.000000, 1.000000, 1.000000} })
te.checkpoint ("one part moved on its own")

wait_step()

step ("That's not quite what we want. The shell, pins, and inner pieces should all move together."
   .. " ##1 Undo that change, then ##2 select the entire front group in the Scene Explorer. The"
   .. " model is already organized for us. ##3 Now when we lift it, the whole assembly moves as"
   .. " one piece.", "bottom")

te.wait_for_marker (1)
te.item_click (UNDO)

te.wait_for_marker (2)
te.item_click ("Scene Explorer^/Content_ECC52E9C/^0/12w_usb_charger_eu (1)/^1/front/##clickable_area/")

te.wait_for_marker (3)
te.gizmo_drag ({ handle = "TrZ", origin = {0.58324, 0.49790}, start = {-0.10, -180.73}, delta = {0.01361, -0.27816}, duration = 1.31551, T = {0.000000, 0.000000, 44.520065}, R = {0.000000, 0.000000, 0.000000}, S = {1.000000, 1.000000, 1.000000} })
te.checkpoint ("the whole front group moved")

wait_step()

-- ------------------------------------------------------------- keyframes
step ("Now we're ready to animate. ##1 Undo the move to return the front to its starting position,"
   .. " then ##2 open the Animation tab. ##3 Choose the Scene track, which controls object motion,"
   .. " and ##4 switch it to Keyframes. ##5 Add a keyframe to save this first pose: the fully"
   .. " assembled charger.", "left")

te.wait_for_marker (1)
te.item_click (UNDO)

te.wait_for_marker (2)
te.item_click ("Animation/")

te.wait_for_marker (3)
te.item_click ("Animation/Scene/")

te.wait_for_marker (4)
te.item_click ("Animation/Keyframes##script/")

te.wait_for_marker (5)
te.item_click (SCENE_KEY)

wait_step()

step ("For the second pose, ##1 lift the front section away from the body again. ##2 Add another"
   .. " keyframe to save its new position. You can also press K to do this without leaving the"
   .. " viewport. Light Tracer creates the motion between the two poses automatically.", "left")

te.wait_for_marker (1)
te.gizmo_drag ({ handle = "TrZ", origin = {0.58328, 0.49799}, start = {1.80, -174.84}, delta = {0.00076, -0.20333}, duration = 1.40926, T = {0.000000, 0.000000, 32.694592}, R = {0.000000, 0.000000, 0.000000}, S = {1.000000, 1.000000, 1.000000} })

te.wait_for_marker (2)
te.item_click (SCENE_KEY)
te.checkpoint ("two keyframes")

wait_step()

step ("##1 Let's play that back. The front section now lifts smoothly away from the charger, while"
   .. " the baked shadow remains fixed beneath it.", "left")

te.wait_for_marker (1)
te.item_click (START)
te.item_click (PLAY)

-- The timeline, not the clock: a scripted run plays at its own speed. The
-- keyframes are two seconds apart, which is frame 60 of the thirty a second,
-- so the move is half made at 30.
te.wait_for_video_frame (30, 30)

te.item_click (PLAY)
te.checkpoint ("mid-way through the move")
te.item_click (PLAY)
te.wait_for_video_frame (75, 30)
te.item_click (PLAY)
te.item_click (START)

wait_step()

-- ------------------------------------------------- closing the animation
step ("Right now the animation ends with the charger open. Let's bring it back together. ##1 Select"
   .. " the first keyframe, then ##2 copy it to the end of the timeline. The animation now returns"
   .. " to its starting pose, which also makes it loop cleanly. ##3 Fit the video length to the"
   .. " keyframes, then ##4 play the complete animation.", "left")

te.wait_for_marker (1)
te.item_click ("Animation^/ScriptKeys_B0463F9E/^0/Select/")

te.wait_for_marker (2)
te.item_click ("Animation/CopySceneKey/#image/")

te.wait_for_marker (3)
te.item_click ("Animation/##FitLength/")

te.wait_for_marker (4)
te.item_click (START)
te.item_click (PLAY)
-- Fitted to the keyframes the video is four seconds, 120 frames: 90 is in the
-- middle of the charger closing again.
te.wait_for_video_frame (90, 40)
te.item_click (PLAY)
te.checkpoint ("the charger closing again")
te.item_click (PLAY)
te.wait_for_video_frame (120, 40)
te.item_click (PLAY)
te.item_click (START)

wait_step()

-- ------------------------------------------------------------ saving it
te.point_at ("ToolContainer/VideoExport/#image/", "left")
step_at ("When you're happy with the result, it's time to export. ##1 Open Video Export from the"
   .. " top toolbar. ##2 Choose MP4 or GIF for a finished animation, or ##3 export PNG or JPG"
   .. " frames if you want to assemble and edit the sequence elsewhere.",
   "ToolContainer/UI/#image/", "right")

te.wait_for_marker (1)
te.item_click ("ToolContainer/VideoExport/#image/")
te.wait_until_available ("<popup>/MP4", 5)

te.wait_for_marker (2)
te.move_to_item ("<popup>/MP4")
te.wait_for_seconds (0.8)
te.move_to_item ("<popup>/GIF")

te.wait_for_marker (3)
te.move_to_item ("<popup>/PNG")
te.wait_for_seconds (0.8)
te.move_to_item ("<popup>/JPG")

te.checkpoint ("where the animation is saved", "window")

wait_step()

-- --------------------------------------------------------------------- outro
open_tab ("Tutorials")

te.capture_thumbnail()

tutorial_end ("And that's our finished product animation. The basic workflow is simple: save a"
           .. " keyframe, move an object, and save another. Repeat those steps to build more"
           .. " complex motion.")
