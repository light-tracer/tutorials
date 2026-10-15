--@ title:       Physics simulation
--@ subtitle:    Dropping, settling and recording a fall
--@ category:    Basics
--@ order:       120
--@ duration:    4:23
--@ description: The physics widget: the three ways an object can take part in
--@              a simulation, the settings of a dynamic body, gravity and
--@              recording time. Drops a ring so it settles on the floor the
--@              way a real one would, then records a fall as a baked
--@              animation and puts it on the timeline.

-- Follows the video on the feature (youtu.be/lqOJnO9zGg0) on the showcase
-- scene: the standing ring is the body that falls, the lying ring and the
-- floor are the obstacles it lands on.

include ("assets/tutorial_common.lua")

lt.import_scene ("data/models/default.zip")
te.wait_loads_complete (60)

PHYSICS_BUTTON = "LeftToolsContainer/##Physics/#image/"

local function physics (ref)
  return "Physics/" .. ref
end

-- The buttons carry an icon glyph in front of their text.
local RUN_BUTTON    = physics ("^b239^b135^b152 Run/")
local RECORD_BUTTON = physics ("^b239^b132^b145 Record/")
local STOP_BUTTON   = physics ("^b239^b129^b129 Stop simulation/")

-- The first take in the Animation tab's list of baked animations.
local TAKE_APPEND = "Animation^/Takes_1F6042E1/^0/Append"
local PLAY_BUTTON = "Animation/Video/Play/#image"

-- Both rings are groups called "square solitaire", so a lookup by name gives
-- whichever comes first; the one that falls is the standing ring, the taller
-- of the two.
local ring = nil

for i = 1, lt.get_sub_node_count (lt.root()) do
  local node = lt.get_sub_node (lt.root(), i)

  if node:get_name() == "square solitaire"
     and (ring == nil or node:world_bounds().size[3] > ring:world_bounds().size[3]) then
    ring = node
  end
end

assert (ring ~= nil, "Expected the showcase scene")

-- The large stone is solid where its centre is, which the ring as a whole is
-- not: the middle of its bounds is the hole.
local stone = nil

for i = 1, lt.get_sub_node_count (ring) do
  local part = lt.get_sub_node (ring, i)

  if part:get_name() == "Main" then
    stone = part
  end
end

assert (stone ~= nil, "Expected the standing ring's stone")

--! Lifts a node straight up, without an undo step. Physics 'down' is -Z.
local function lift (node, dz)
  local t = node:get_world_transform()
  t[15] = t[15] + dz
  node:set_world_transform (t)
  te.wait_for_seconds (0.3)
end

--! Waits until an item shows up, and says whether it did. Starting a
--! simulation builds the collision shapes first, behind a progress dialog, so
--! the button that ends it is not there at once.
local function wait_for_item (ref, seconds)
  for _ = 1, math.ceil ((seconds or 60) / 0.25) do
    if te.item_status (ref).exists then
      return true
    end

    te.wait_for_seconds (0.25)
  end

  return false
end

tutorial_begin ("In this tutorial, we'll use the physics engine to place a ring naturally on the"
             .. " floor, then record a second fall as an animation. The same workflow works for"
             .. " anything that needs to fall, roll, collide, or settle into place.")

-- ---------------------------------------------------------------- the widget
step_at ("##1 Open the Physics widget from the left toolbar.", "LeftToolsContainer/##Layers/#image/", "right")

te.wait_for_marker (1)
te.item_click (PHYSICS_BUTTON)
te.wait_until_available (RUN_BUTTON, 5)

wait_step()

step_at ("The controls in this widget apply to the current selection, so ##1 select the standing ring.",
   "LeftToolsContainer/##Layers/#image/", "right")

te.wait_for_marker (1)
te.click_viewport (te.world_to_screen (stone:world_bounds().center))
te.wait_for_seconds (0.4)
assert (lt.get_selected_node_count() == 1, "Expected the standing ring selected")
te.wait_until_available (physics ("Dynamic/"), 5)

wait_step()

-- ------------------------------------------------------------ the three types
te.scribble_at(physics ("Disabled/"))
step_at ("Each object can participate in one of three ways. Disabled removes it from the"
   .. " simulation completely, so other objects pass straight through it.",
   "LeftToolsContainer/##Layers/#image/", "right")

wait_step()

te.scribble_at(physics ("Static/"))
step_at ("Static makes an object a fixed obstacle. It won't move, but dynamic objects can land"
   .. " on it. Floors, stands, and walls are usually Static.", "LeftToolsContainer/##Layers/#image/", "right")

wait_step()

te.scribble_at(physics ("Dynamic/"))
step_at ("Dynamic allows gravity and collisions to move the object. ##1 Choose Dynamic for the"
   .. " ring so it can fall.", "LeftToolsContainer/##Layers/#image/", "right")

te.wait_for_marker (1)
te.item_click (physics ("Dynamic/"))
te.wait_until_available (physics ("Shape accuracy:/"), 5)
te.checkpoint ("dynamic body settings", "window")

wait_step()

-- ------------------------------------------------------- dynamic body settings
step_at ("Dynamic objects have a few extra settings. Shape accuracy controls how closely the collision"
   .. " shape follows the model. With a low value, the hole in this ring may be filled in. ##1 Raise"
   .. " it for hollow or detailed objects, but keep it lower for simple shapes to reduce setup time.",
   physics ("Shape accuracy:/"), "right")

te.wait_for_marker (1)
te.item_input_value_float (physics ("Shape accuracy:/"), 6.0)

wait_step()

step_at ("##1 Expand the advanced settings to find Mass, Friction, and Bouncing factor. Together they"
   .. " control how heavy the object feels, how easily it slides, and how much energy it keeps after"
   .. " a collision.", physics ("##MorePhysics/##btn"), "right")

te.wait_for_marker (1)
te.item_click (physics ("##MorePhysics/##btn"))
te.wait_until_available (physics ("Bouncing factor:/"), 5)

wait_step()

te.item_click (physics ("##MorePhysics/##btn"))

-- ------------------------------------------------------ gravity and duration
step_at ("Gravity factor applies to the entire scene. At zero, nothing falls. ##1 Set it to one for"
   .. " normal Earth-like gravity.",
   physics ("Gravity factor:/"), "right")

te.wait_for_marker (1)
te.item_input_value_float (physics ("Gravity factor:/"), 1.0)

wait_step()

-- ------------------------------------------------------------ run: settling
lift (ring, 8.0)

te.point_at(RUN_BUTTON, "left")
step_at ("Run starts a live simulation without recording it. ##1 Click Run. A selected object stays"
   .. " attached to its gizmo, so ##2 click an empty area to release the ring. It will fall and settle"
   .. " naturally. While the simulation is running, you can still drag dynamic objects and use them"
   .. " to push others around.", "LeftToolsContainer/##Layers/#image/", "right")

te.wait_for_marker (1)
te.item_click (RUN_BUTTON)

te.expect (wait_for_item (STOP_BUTTON, 90), "the simulation starts once the shapes are built")

te.wait_for_marker (2)
te.mouse_move_screen (0.338, 0.020) -- an empty strip of the top bar
te.deselect()

te.wait_for_seconds (15.0)

wait_step()

point_step ("##1 Stop the simulation once the ring comes to rest. Its new position is kept, giving you"
   .. " natural contact with the floor without the tiny gaps or intersections that are easy to"
   .. " create by hand.", STOP_BUTTON, "left")

te.wait_for_marker (1)
te.item_click (STOP_BUTTON)
te.expect (wait_for_item (RUN_BUTTON, 30), "stopping brings the Run button back")
te.checkpoint ("settled by the simulation")

wait_step()

step_at ("Recording time sets the maximum length of a recorded simulation. It only affects Record; a"
   .. " live Run continues until you stop it yourself. ##1 We'll use fifteen seconds, which gives the"
   .. " ring plenty of time to settle.", physics ("Recording time:/"), "right")

te.wait_for_marker (1)
te.item_input_value_float (physics ("Recording time:/"), 15.0)

wait_step()

-- ---------------------------------------------------------- record: a take
lift (ring, 10.0)

point_step ("Record runs the same simulation but saves the motion. ##1 Start recording and the ring"
   .. " falls again. This time, every frame is stored until the recording time ends.",
   RECORD_BUTTON, "left")

te.wait_for_marker (1)
te.item_click (RECORD_BUTTON)
te.wait_for_seconds (1.0)
te.expect (wait_for_item (RECORD_BUTTON, 120), "the recording ends by itself")

wait_step()

-- --------------------------------------------------------------- the timeline
step_at ("The result is saved as a baked animation. ##1 Open the Animation tab and you'll find it under"
   .. " Baked animations as a new physics take.", "RightToolsContainer/##ColorBalanceWidget/#image/", "left")

te.wait_for_marker (1)
open_tab ("Animation")
te.expect (wait_for_item (TAKE_APPEND, 10), "the recording is listed as a physics take")

wait_step()

te.scribble_at(TAKE_APPEND)
step_at ("The take isn't part of the video yet. ##1 Click the plus at the end of its row to add it to"
   .. " the timeline. From there, it can play once, loop, or stretch to match the video length.",
   "RightToolsContainer/##ColorBalanceWidget/#image/", "left")

te.wait_for_marker (1)
te.item_click (TAKE_APPEND)
te.wait_for_seconds (0.6)
te.checkpoint ("take on the timeline", "window")

wait_step()

step_at ("##1 Press Play to preview the recorded fall on the timeline. It's now ready to render as"
   .. " part of the final video.", "RightToolsContainer/##ColorBalanceWidget/#image/", "left")

te.wait_for_marker (1)
te.item_click (PLAY_BUTTON)
te.wait_for_seconds (4.5)
te.item_click (PLAY_BUTTON) -- it toggles; a checkpoint must never wait on a playing timeline

wait_step()

-- ------------------------------------------------------------------- outro
te.item_click (PHYSICS_BUTTON)
lt.clear_selection()

open_tab ("Tutorials")

-- The picture this lesson is listed by. Ignored while a viewer plays it;
-- a bookkeeping run is what turns it into the thumbnail.
te.capture_thumbnail()

tutorial_end ("That's the physics workflow: make moving objects Dynamic, give the scene some gravity,"
           .. " then use Run to arrange them or Record to preserve the motion. Try the same technique"
           .. " with loose gemstones, packaging, or several objects colliding at once.")
