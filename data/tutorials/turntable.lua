--@ title:       Turntable animations
--@ revision:    2
--@ subtitle:    Round and swing camera scripts
--@ category:    Basics
--@ order:       60
--@ duration:    3:20
--@ description: The Animation tab's camera scripts: set the video length on
--@              the timeline, let the Round script circle the scene or an
--@              object you pick as the orbit centre, adjust the angle and
--@              easing, and switch to the Swing script's figure-eight for
--@              jewellery.

-- The Animation tab's camera scripts: the timeline and the video length, the
-- Round script with its orbit centre, rotation angle and easing, and the
-- Swing script. Follows the "Turntable animations" video, on the showcase
-- rings, adapted to the current Animation tab.
--   https://www.youtube.com/watch?v=LcIPLaz9_bA

include ("assets/tutorial_common.lua")

-- The two rings from the side, with the standing one behind the lying one:
-- the orbit is easy to read from here.
local VIEW = { eye = { 18, -52, 30 }, target = { -0.3, -4, -6.5 }, up = { 0, 0, 1 } }

-- The lying ring's large stone, for the orbit-centre pick.
local STONE_AT = nil

-- The timeline's transport and the script controls.
local PLAY  = "Animation/Video/Play/#image"
local START = "Animation/Video/Start/#image"
local ORBIT_CENTER = "Animation/^b239^b129^b129 Set orbit center"   -- map-marker glyph
local PICK_OBJECT  = "OrbitCenter/^b239^b132^b164 Pick object"       -- location-arrow glyph
local PICK_POINT   = "OrbitCenter/^b239^b132^b164 Pick point"
local RESET_CENTER = "OrbitCenter/^b239^b131^b162 Reset"             -- undo glyph
local VIDEO_EXPORT = "ToolContainer/VideoExport/#image/"

--! Moves the camera and waits until it has arrived.
local function look (view)
  te.do_camera_transition_to (view)
  for _ = 1, 30 do
    te.wait_for_seconds (0.1)
    local now = te.get_camera()
    local d = 0
    for i = 1, 3 do
      d = d + math.abs (now.eye[i] - view.eye[i]) + math.abs (now.target[i] - view.target[i])
    end
    if d < 0.05 then
      break
    end
  end
  te.wait_for_seconds (0.4)
end

--! Plays the animation from the start for a while, then pauses it and
--! rewinds, so the next explanation starts from a still picture.
local function preview (seconds)
  te.item_click (START)
  te.item_click (PLAY)
  te.wait_for_seconds (seconds)
  te.item_click (PLAY)
  te.wait_for_seconds (0.3)
end

lt.import_scene ("data/models/default.zip")
te.wait_loads_complete (60)
look (VIEW)

do
  local root = lt.root()
  for i = 1, lt.get_sub_node_count (root) do
    local ring = lt.get_sub_node (root, i)
    if ring:get_name() == "square solitaire" and ring:world_bounds().size[3] < 10 then
      for j = 1, lt.get_sub_node_count (ring) do
        local part = lt.get_sub_node (ring, j)
        if part:get_name() == "Main" then
          STONE_AT = part:world_bounds().center
        end
      end
    end
  end
  assert (STONE_AT, "Expected the lying showcase ring")
end

tutorial_begin ("In this lesson we explore the basic animation techniques of Light Tracer: a camera that"
             .. " circles the scene like a turntable, and one that swings around a single position. Both take a few"
             .. " clicks and no keyframes at all.")

-- --------------------------------------------------------------- the tab
open_tab ("Animation")

te.scribble_at ("Animation/", 2.5)
step_at ("Everything starts in the Animation tab of the right panel. ##1 The timeline shows"
   .. " the keyframes and the total duration of the animation.", "Animation/Video/")
   
te.wait_for_marker (1)
te.point_at ("Animation/Video/", "left")

wait_step()

step_at ("##1 The animation time is set under Video length - six seconds for a full turn is a"
   .. " good start. ##2 Next to it sit two buttons: one fits the video duration to all the"
   .. " tracks you have added, ##3 the other locks the duration so that edits cannot change it.", "Animation/Video/",
   "left")

te.wait_for_marker (1)
te.item_input_value_float ("Animation/Video length:", 6)

te.wait_for_marker (2)
te.scribble_at ("Animation/##FitLength", 2.0)

te.wait_for_marker (3)
te.scribble_at ("Animation/##FixLength", 2.0)

wait_step()

-- ------------------------------------------------------------ round script
step_at ("Below the timeline are the animation scripts. ##1 Open the Camera tab and choose ##2 Round.",
   "Animation/Animation scripts", "left")

te.wait_for_marker (1)
te.item_click ("Animation/Camera")

te.wait_for_marker (2)
te.item_click ("Animation/Round")
te.wait_for_seconds (0.5)

wait_step()

step_at ("Round lets the camera rotate in a circle around a chosen centre. ##1 Press play on the"
   .. " timeline to watch it: a full turn in the six seconds we set.", "Animation/Animation scripts", "left")

te.wait_for_marker (1)
te.item_click (START)
te.item_click (PLAY)
te.wait_for_seconds (3.0)
-- A checkpoint waits for the render to settle, which a moving camera never
-- lets it: pause for the picture, then carry on.
te.item_click (PLAY)
te.checkpoint ("round, mid turn")
te.item_click (PLAY)
te.wait_for_seconds (3.0)
te.item_click (PLAY)

wait_step()

-- ----------------------------------------------------------- orbit centre
step_at ("To choose the centre of rotation, ##1 click Set orbit center. ##2 Reset puts it at the"
   .. " centre of the scene; ##3 Pick object aims it at an object you then click in the"
   .. " viewport - let's take the front ring's stone - ##4 and Pick point at any spot on a"
   .. " surface.", "Animation/Video/", "left")
   
te.item_click ("LeftGrabContainer/##LeftGrab/")

te.wait_for_marker (1)
te.item_click (ORBIT_CENTER)
te.wait_until_available (PICK_OBJECT, 5)

te.wait_for_marker (2)
te.scribble_at (RESET_CENTER, 2.0)

te.wait_for_marker (3)
te.item_click (PICK_OBJECT)
te.wait_for_seconds (0.3)
do
  local x, y = te.world_to_screen (STONE_AT)
  te.click_viewport (x, y)
end
te.wait_for_seconds (0.5)

te.wait_for_marker (4)
te.scribble_at (PICK_POINT, 2.0)

wait_step()

step_at ("##1 Close the widget and play again: the camera now circles the stone we picked.", "Animation/Animation scripts", "left")

te.wait_for_marker (1)
te.item_click (ORBIT_CENTER)
te.wait_for_seconds (0.3)
te.item_click (START)
te.item_click (PLAY)
te.wait_for_seconds (3.0)
te.item_click (PLAY)
te.checkpoint ("round around the picked stone")
te.item_click (PLAY)
te.wait_for_seconds (2.5)
te.item_click (PLAY)

wait_step()

te.item_click ("Animation/Video/Start/#image/")


-- ---------------------------------------------------------- rotation angle
scribble_step ("By default the camera rotates the full 360 degrees. ##1 Set a custom angle for a"
   .. " partial turn, ##2 and a negative value sends the rotation the other way round.",
   "Animation/Rotation:")

te.wait_for_marker (1)
te.item_input_value_float ("Animation/Rotation:", 90)
preview (2.0)

te.wait_for_marker (2)
te.item_input_value_float ("Animation/Rotation:", -90)
preview (2.0)
te.checkpoint ("minus ninety degrees")

wait_step()

te.item_click ("Animation/Video/Start/#image/")

-- ------------------------------------------------------------------ easing
step_at ("##1 Ease In slows the camera down at the start of the motion, ##2 Ease Out at the end."
   .. " ##3 Try switching them on and off and watch the difference in how the turn begins"
   .. " and ends.", "Animation/Animation scripts", "left")

te.wait_for_marker (1)
te.item_click ("Animation/Ease In")

te.wait_for_marker (2)
te.item_click ("Animation/Ease Out")

te.wait_for_marker (3)
preview (3.0)
te.item_click ("Animation/Ease In")
te.item_click ("Animation/Ease Out")

wait_step()

te.item_click ("Animation/Video/Start/#image/")

-- ------------------------------------------------------------------- swing
step_at ("##1 In the Swing tab the camera follows a figure-eight trajectory instead. ##2 Two angles"
   .. " set how far it moves horizontally ##3 and vertically. ##4 This kind of motion works"
   .. " very well for jewellery: the stones catch the light from every side.", "Animation/Animation scripts", "left")

te.wait_for_marker (1)
te.item_click ("Animation/Swing")
te.wait_for_seconds (0.5)

te.wait_for_marker (2)
te.item_input_value_float ("Animation/Hor. rotation:", 25)

te.wait_for_marker (3)
te.item_input_value_float ("Animation/Ver. rotation:", 15)

te.wait_for_marker (4)
te.item_click (START)
te.item_click (PLAY)
te.wait_for_seconds (3.0)
te.item_click (PLAY)
te.checkpoint ("swing")
te.item_click (PLAY)
te.wait_for_seconds (3.0)
te.item_click (PLAY)

wait_step()

te.item_click ("Animation/Video/Start/#image/")

-- ------------------------------------------------------------ saving it
te.point_at ("ToolContainer/VideoExport/#image/", "left")
step_at ("The motion is set; what is left is to record it. ##1 This button in the top row saves the"
   .. " animation: ##2 MP4 or GIF for a video, ##3 PNG or JPG for the frames one by one, to put"
   .. " together in a video editor.", "ToolContainer/UI/#image/", "right")

te.wait_for_marker (1)
te.item_click (VIDEO_EXPORT)
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

-- A second click on the button only closes the popup and opens it again; a
-- click in one of the panels is what puts it away.
open_tab ("Animation")

-- ------------------------------------------------------------------- outro
te.item_click (START)
te.wait_for_seconds (0.5)

-- The picture this lesson is listed by. Ignored while a viewer plays it;
-- a bookkeeping run is what turns it into the thumbnail.
te.capture_thumbnail()

te.item_click ("LeftGrabContainer/##LeftGrab/")

open_tab ("Tutorials")

tutorial_end ("That is the turntable in Light Tracer: choose Round or Swing, set the length, pick"
           .. " what the camera should circle, and play. When the motion looks right, save it from"
           .. " the top row and let it render.")
