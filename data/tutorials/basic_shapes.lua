--@ title:       Building with shapes
--@ revision:    2
--@ subtitle:    Stands, primitives, placing, shading and scale
--@ category:    Basics
--@ order:       200
--@ duration:    3:40
--@ description: The modeling toolbox: the model stands that give a scene a
--@              floor or a backdrop in one click, dragging primitives into the
--@              scene, and the settings that decide how they land - placing
--@              mode, detail level, shading and scale. Ends by building a
--@              simple ring stand next to the showcase rings.

-- Walks through the modeling toolbox on the showcase scene: the five model
-- stands first, since everything else stands on one of them, then the eight
-- primitives and the four settings that decide what a dropped shape looks
-- like, and finally a ring stand put together from three of them.

include ("assets/tutorial_common.lua")

lt.import_scene ("data/models/default.zip")
te.wait_loads_complete (60)

-- The showcase comes with a floor already; the stands section builds its own,
-- so it starts from rings standing on nothing. No undo step is recorded, so
-- the lesson's own Undo clicks never bring it back.
lt.find_by_name ("Scene floor"):delete()

MODEL_BUTTON = "LeftToolsContainer/##Model/#image/"
UNDO_BUTTON  = "ToolContainer/Undo/#image/"

-- The showcase view the scene opens with, one far enough back to see a stand
-- the size of the whole scene, and one with room beside the rings to build in.
CLOSE_VIEW = { eye = {103.10, -83.49, 41.83}, target = {0.00, 0.00, 2.53}, up = {-0.22, 0.18, 0.96} }
WIDE_VIEW  = { eye = {620, -500, 330},        target = {0, 0, 20},         up = {-0.22, 0.18, 0.96} }
BUILD_VIEW = { eye = {150, -150, 60},         target = {15, 10, 8},        up = {-0.20, 0.20, 0.96} }

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

--! Drags a shape from the modeling panel into the viewport and drops it at the
--! given position, given in fractions of the window.
local function place_shape (id, pos_x, pos_y)
  te.mouse_move_rel (id, 0.5, 0.5)
  te.mouse_down()
  te.mouse_move_screen (pos_x, pos_y)
  te.mouse_up()
  te.wait_for_seconds (0.4)
end

--! Where a point in the scene is on screen, in the window fractions
--! place_shape takes.
local function screen_spot (point)
  return te.viewport_to_screen (te.world_to_screen (point))
end

--! A point on the axis of a node's bounds, a fraction of the way up them - the
--! spot to drop the next piece of a stack on.
local function point_up (node, height)
  local b = node:world_bounds()
  return { b.center[1], b.center[2], b.center[3] + b.size[3] * (height - 0.5) }
end

local function modeling (ref)
  return "Modeling/" .. ref
end

te.item_click ("RightGrabContainer/##RightGrab/")
te.item_click ("LeftGrabContainer/##LeftGrab/")

tutorial_begin ("Light Tracer has a small modeling toolbox of its own. It will not replace your CAD"
             .. " package, but it is enough to give a product a floor or a backdrop, block out a scene"
             .. " or build a simple stand: without leaving the renderer.")

-- ------------------------------------------------------------- the toolbox
point_step ("The toolbox lives behind ##1 this button on the left rail.", MODEL_BUTTON, "right")

te.wait_for_marker (1)
te.item_click (MODEL_BUTTON)

wait_step()

-- ---------------------------------------------------------------- the stands
scribble_step ("Start with what the scene stands on. Model stands builds a floor or a backdrop sized to"
   .. " the whole scene, with a single click: no dragging. ##1 Some of them are big, so let's step back"
   .. " first.", modeling ("Model stands"), "right")

te.wait_for_marker (1)
look (WIDE_VIEW)

wait_step()

point_step ("The bent stand ##1 curves up behind the scene into a backdrop with no horizon line, and"
   .. " turns to face the camera as it is built.", modeling ("Bent stand/##"), "right")

te.wait_for_marker (1)
te.item_click (modeling ("Bent stand/##"))
te.checkpoint ("bent stand")

wait_step()

point_step ("Undo takes it away again. The turn table ##1 is a round platform on a low stand - the"
   .. " one to use when the product spins in an animation.", modeling ("Turn table/##"), "right")

te.item_click (UNDO_BUTTON)
te.wait_for_marker (1)
te.item_click (modeling ("Turn table/##"))
te.checkpoint ("turn table")

wait_step()

point_step ("Undo once more. The bowl stand ##1 wraps around the scene on every side, a backdrop the"
   .. " camera can orbit all the way round.", modeling ("Bowl stand/##"), "right")

te.item_click (UNDO_BUTTON)
te.wait_for_marker (1)
te.item_click (modeling ("Bowl stand/##"))
te.checkpoint ("bowl stand")

wait_step()

point_step ("The two floors at the start of the list are different: they are shadow catchers. ##1 Back in"
   .. " close, ##2 the round floor is invisible itself: all it keeps is the shadows and reflections"
   .. " under the rings.", modeling ("Round floor/##"), "right")

te.wait_for_marker (1)
te.item_click (UNDO_BUTTON)
look (CLOSE_VIEW)
te.wait_for_marker (2)
te.item_click (modeling ("Round floor/##"))
te.checkpoint ("round floor")

wait_step()

point_step ("Undo, and ##1 the square floor does the same with straight edges. It is the floor the showcase"
   .. " scene came with, so we keep this one.", modeling ("Square floor/##"), "right")

te.item_click (UNDO_BUTTON)
te.wait_for_marker (1)
te.item_click (modeling ("Square floor/##"))

wait_step()

-- ------------------------------------------------------------ the primitives
look (BUILD_VIEW)

scribble_step ("Basic shapes holds eight primitives: a plane, a disk, a sphere in two flavours, a cube, a"
   .. " cone, a cylinder and a torus.", modeling ("Basic shapes"), "right")

wait_step()

step_at ("You do not click a shape to add it: ##1 you drag it out of the panel and drop it where you"
   .. " want it. It lands on whatever is under the cursor: here, on the floor.",
   modeling ("Cube/##"), "right")

te.wait_for_marker (1)
place_shape (modeling ("Cube/##"), 0.66, 0.78)

local cube = lt.get_selected_node (1)

wait_step()

-- ------------------------------------------------------------- placing mode
-- The middle of the cube's side facing the camera's left.
local cube_box = cube:world_bounds()
local cube_side = { cube_box.center[1], cube_box.center[2] - cube_box.size[2] * 0.5, cube_box.center[3] }

scribble_step ("Rotated placing, the default, stands the shape on the surface it lands on and turns it"
   .. " to follow that surface. ##1 A cone dropped on the side of the cube sticks straight out of it.",
   modeling ("##PlacingMode/Rotated"), "right")

te.wait_for_marker (1)
place_shape (modeling ("Cone/##"), screen_spot (cube_side))

wait_step()

scribble_step ("Aligned keeps the world's axes instead, and puts the shape's centre right on the"
   .. " point you drop it at: ##1 so on the floor, half of it sinks in.",
   modeling ("##PlacingMode/Aligned"), "right")

te.item_click (modeling ("##PlacingMode/Aligned"))
te.wait_for_marker (1)
place_shape (modeling ("UV sphere/##"), 0.56, 0.88)
te.checkpoint ("placing modes")

wait_step()

-- ------------------------------------------------------------ detail level
te.item_click (modeling ("##PlacingMode/Rotated"))

step_at ("Detail level decides how finely a curved shape is tessellated. Low is cheap and shows its"
   .. " facets, high is smooth and costs more geometry. ##1 At the lowest level, ##2 an icosphere is"
   .. " barely round at all.", modeling ("Detail level:"), "right")

te.wait_for_marker (1)
te.item_input_value_int (modeling ("Detail level:"), 1)
te.wait_for_marker (2)
place_shape (modeling ("Icosphere/##"), 0.74, 0.66)

wait_step()

-- ------------------------------------------------- advanced: shading, scale
te.item_input_value_int (modeling ("Detail level:"), 2)

step_at ("The arrow under it opens two more settings. ##1 Shading: Smooth rounds the surface off,"
   .. " ##2 Flat keeps every facet sharp: what you want for anything faceted, like a gemstone. ##3 A"
   .. " cylinder built flat shows its sides as panels.",
   modeling ("##Advanced/##btn"), "right")

te.wait_for_marker (1)
te.item_click (modeling ("##Advanced/##btn"))
te.wait_for_marker (2)
te.item_click (modeling ("##ShadingMode/Flat"))
te.wait_for_marker (3)
place_shape (modeling ("Cylinder/##"), 0.48, 0.64)

wait_step()

step_at ("Scale is applied as the shape is built, so ##1 at one half, ##2 the next cube arrives half"
   .. " the size of the first.", modeling ("Scale:"), "right")

te.wait_for_marker (1)
te.item_input_value_float (modeling ("Scale:"), 0.5)
te.wait_for_marker (2)
place_shape (modeling ("Cube/##"), 0.62, 0.92)
te.checkpoint ("shading and scale")

wait_step()

-- ------------------------------------------------------------------- outro
te.item_click (MODEL_BUTTON)

-- The lesson folded the side panels before showing the toolbox. Restore the
-- left panel before selecting its Tutorials tab.
te.item_click ("LeftGrabContainer/##LeftGrab/")
te.wait_until_available ("Tutorials/", 5)
open_tab ("Tutorials")

-- The picture this lesson is listed by. Ignored while a viewer plays it;
-- a bookkeeping run is what turns it into the thumbnail.
te.capture_thumbnail()

te.item_click ("RightGrabContainer/##RightGrab/")

tutorial_end ("That is the toolbox. Everything you built is an ordinary object: select it in the Scene"
           .. " Explorer, move it into place, or drag a material onto it from the Library.")
