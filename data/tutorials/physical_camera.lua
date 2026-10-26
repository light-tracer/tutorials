--@ title:       The physical camera
--@ revision:    2
--@ subtitle:    Depth of field, focus and focal length
--@ category:    Basics
--@ order:       50
--@ duration:    4:46
--@ description: The camera widget's physical model: open the aperture for a
--@              shallow depth of field, let autofocus follow the centre or
--@              pick the focus point yourself, type a focus distance, set the
--@              focal length by hand, and shape the bokeh with the aperture
--@              blades.

-- Depth of field with the physical camera model: the aperture, autofocus and
-- picking the focus point, typing a focus distance, the focal length, and the
-- aperture blades behind the bokeh.

include ("assets/tutorial_common.lua")

-- A close view of the lying ring's stone with the standing ring behind it:
-- the two are far enough apart that one of them is always out of focus.
local VIEW_CLOSE = { eye = { -18, -34, 4 }, target = { -0.3, -9.2, -6.4 }, up = { 0, 0, 1 } }


-- Filled in from the scene below: where to click for the focus pick, and the
-- distance to type for the near stone. The focus distance field is in world
-- units, the same the camera position is given in.
local FAR_BAND_AT   = nil  -- a point on the standing ring's band, in world units
local NEAR_STONE_AT = nil  -- the lying ring's large stone
local NEAR_RING     = nil  -- the lying ring, whose box the sparks later fill

-- The camera widget's controls. The round buttons follow the tool-rail
-- scheme (an #image item inside the button's id).
local CAMERA_BUTTON = "RightToolsContainer/##CameraWidget/#image/"
local AF_BUTTON     = "Camera/AF/#image/"
local DOF_BUTTON    = "Camera/AutoDOF/#image/"

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

--! Sets the f-number and lets the image show it.
local function set_aperture (f)
  te.item_input_value_float ("Camera/Aperture:", f)
  te.wait_for_seconds (1.5)
end

--! Folds both side panels away, or brings them back. The grab handles
--! toggle; the player starts a lesson with both panels open.
local function fold_panels ()
  te.item_click ("LeftGrabContainer/##LeftGrab/")
  te.item_click ("RightGrabContainer/##RightGrab/")
  te.wait_for_seconds (0.6)
end

lt.import_scene ("data/models/default.zip")
te.wait_loads_complete (60)
look (VIEW_CLOSE)

-- The two rings share their part names; tell them apart by height.
do
  local root = lt.root()
  local standing = nil
  for i = 1, lt.get_sub_node_count (root) do
    local ring = lt.get_sub_node (root, i)
    if ring:get_name() == "square solitaire" then
      if ring:world_bounds().size[3] > 10 then
        standing = ring
      else
        NEAR_RING = ring

        for j = 1, lt.get_sub_node_count (ring) do
          local part = lt.get_sub_node (ring, j)
          if part:get_name() == "Main" then
            NEAR_STONE_AT = part:world_bounds().center
          end
        end
      end
    end
  end
  assert (standing and NEAR_STONE_AT, "Expected both showcase rings")
  
  -- The standing ring's stones are all above the frame in this view; what is
  -- in the picture is the lower part of its band. Walk the band's circle (the
  -- ring stands in the XZ plane, its bounds' height includes the head) and
  -- take the first point that is on screen, in the left part of the viewport
  -- (the Camera widget floats over the right), and that is the surface facing
  -- the camera there - a point the near ring hides is no use to aim a click at.
  --
  -- te.pick_at reports what a click would hit without clicking or selecting
  -- anything, so none of this reaches the screen. Probing by selection, as this
  -- did, flashed the rings at the viewer before the lesson had said a word.
  local b = standing:world_bounds()
  local radius = b.size[1] / 2 - 0.8
  local cz = b.center[3] - b.size[3] / 2 + b.size[1] / 2
  for deg = 200, 340, 10 do
    local t = math.rad (deg)
    local p = { b.center[1] + radius * math.cos (t), b.center[2], cz + radius * math.sin (t) }
    local x, y = te.world_to_screen (p)
    if x and x > 0.05 and x < 0.55 and y > 0.05 and y < 0.9 then
      local hit = te.pick_at (x, y)

      -- The circle is only an estimate of where the band runs, so the hit is
      -- a unit or so off it - but the near ring, when it is what stands there
      -- instead, comes back the best part of ten units away. What is kept is
      -- the picked point itself: that one is on the surface exactly.
      local off = hit and math.sqrt ((hit.point[1] - p[1]) ^ 2
                                   + (hit.point[2] - p[2]) ^ 2
                                   + (hit.point[3] - p[3]) ^ 2)

      if off and off < 3.0 then
        FAR_BAND_AT = hit.point
        break
      end
    end
  end
  assert (FAR_BAND_AT, "Expected the standing ring's band to be in view")
end

--! Distance from the camera to a world point, in world units.
local function distance_to (world)
  local eye = te.get_camera().eye
  local dx, dy, dz = eye[1] - world[1], eye[2] - world[2], eye[3] - world[3]
  return math.sqrt (dx * dx + dy * dy + dz * dz)
end

-- ------------------------------------------------------------------ sparks
-- The showcase is lit by an environment map and has no small bright sources
-- of its own, so there is nothing in it for an aperture to draw with. These
-- put a handful in, for the blades section only.
--
-- Each is one camera-facing triangle about two pixels across. That smallness
-- is the whole trick: what reaches the screen then is the lens's disc rather
-- than the geometry, and three blades look different from eleven. A spark big
-- enough to see in focus draws its own outline instead, and the blade count
-- changes nothing - which is exactly how the first attempt at this failed.

local function vsub (a, b) return { a[1] - b[1], a[2] - b[2], a[3] - b[3] } end
local function vadd (a, b) return { a[1] + b[1], a[2] + b[2], a[3] + b[3] } end
local function vmul (a, s) return { a[1] * s, a[2] * s, a[3] * s } end

local function vcross (a, b)
  return { a[2] * b[3] - a[3] * b[2],
           a[3] * b[1] - a[1] * b[3],
           a[1] * b[2] - a[2] * b[1] }
end

local function vnorm (a)
  local l = math.sqrt (a[1] * a[1] + a[2] * a[2] + a[3] * a[3])
  return { a[1] / l, a[2] / l, a[3] / l }
end

-- They fill the box of the lying ring, grown by half, so the sparks stand
-- among the rings instead of behind them: the ones near the focus stay points,
-- and the further from it one is the wider its disc opens. That difference
-- across one picture is the whole point of the section.
local SPARK_COUNT  = 150   -- about a third of them land in the frame
local SPARK_GROW   = 1.5    -- of the lying ring's bounds, about its centre
local SPARK_PIXELS = 2.6    -- how big one is on screen, before the lens spreads it
-- Bright enough to stand out on black, dim enough that a disc is not a blown
-- white blob: the blades' shape lives in the edge of the disc, and at four
-- times this power three blades and eleven look the same.
local SPARK_POWER  = 900
local SPARK_SEED   = 20260918

local SPARKS = {}

--! Drops the sparks into the scene. They are sized for the camera in use now,
--! so they only make sense from the view they were placed for.
local function spawn_sparks ()
  local cam = te.get_camera()
  local fwd = vnorm (vsub (cam.target, cam.eye))
  local right = vnorm (vcross (fwd, cam.up))
  local up = vcross (right, fwd)

  local box = NEAR_RING:world_bounds()

  -- How far a world unit carries across the screen at the rings, measured with
  -- the projector: nothing exposes the field of view to ask. A spark further
  -- away is made bigger in the same proportion, so all of them arrive on screen
  -- the same size.
  local origin = box.center
  local ox = select (1, te.world_to_screen (origin))
  local perUnitX = select (1, te.world_to_screen (vadd (origin, right))) - ox
  local reference = distance_to (origin)

  math.randomseed (SPARK_SEED) -- the same handful of sparks in every run

  local normal = vmul (fwd, -1)

  for _ = 1, SPARK_COUNT do
    local centre = { }

    for i = 1, 3 do
      centre[i] = box.center[i] + (math.random() - 0.5) * box.size[i] * SPARK_GROW
    end

    local size = (SPARK_PIXELS / 1920) / perUnitX * (distance_to (centre) / reference)

    -- Turned by an angle of its own around the view axis. Two pixels of
    -- triangle cannot be told from two pixels of anything else, but the discs
    -- they open into are large, and identical triangles all pointing the same
    -- way would read as a pattern rather than as scattered light.
    local turn = math.random() * math.pi * 2
    local u = vadd (vmul (right,  math.cos (turn)), vmul (up, math.sin (turn)))
    local v = vadd (vmul (right, -math.sin (turn)), vmul (up, math.cos (turn)))

    local a = vadd (centre, vmul (v, size))
    local b = vadd (centre, vadd (vmul (u, -size * 0.87), vmul (v, -size * 0.5)))
    local c = vadd (centre, vadd (vmul (u,  size * 0.87), vmul (v, -size * 0.5)))

    local node = lt.load_model {
      name = "spark",
      vertices = { a[1], a[2], a[3], b[1], b[2], b[3], c[1], c[2], c[3] },
      normals  = { normal[1], normal[2], normal[3],
                   normal[1], normal[2], normal[3],
                   normal[1], normal[2], normal[3] },
      indices  = { 0, 1, 2 },
    }

    lt.set_material_color (node, lt.EMISSION_COLOR, { 1.0, 0.95, 0.85 })
    lt.set_material_value (node, lt.EMISSION_POWER, SPARK_POWER)

    SPARKS[#SPARKS + 1] = node
  end

  te.wait_for_seconds (1.5)
end

--! Takes them out again, so the lesson leaves the scene as it found it.
local function remove_sparks ()
  for _, node in ipairs (SPARKS) do
    node:delete()
  end

  SPARKS = {}

  te.wait_for_seconds (0.5)
end

-- A disc of light shows on a dark background and disappears against a bright
-- floor, so the sparks get a stage of their own: the floor out of the way and
-- the backplate turned down to nearly black. The environment still lights the
-- rings - a backplate is only what is seen behind them.
local HIDDEN_FLOOR = nil

local function darken_stage ()
  HIDDEN_FLOOR = lt.find_by_name ("Scene floor")

  if HIDDEN_FLOOR ~= nil then
    HIDDEN_FLOOR:set_object_visibility (lt.HIDDEN)
  end

  lt.set_backplate_color ({ 0.6, 0.6, 0.6 })
  lt.set_backplate_type (lt.BACKPLATE_SOLID_COLOR)

  te.wait_for_seconds (1.0)
end

local function restore_stage ()
  if HIDDEN_FLOOR ~= nil then
    HIDDEN_FLOOR:set_object_visibility (lt.NORMAL)
    HIDDEN_FLOOR = nil
  end

  lt.set_backplate_type (lt.BACKPLATE_ENVIRONMENT)

  te.wait_for_seconds (0.5)
end

-- The camera widget floats over the viewport, so the panels only take space.
fold_panels()

tutorial_begin ("To add realism to a render, use the physical camera. It behaves like a real lens and"
             .. " brings depth of field to the scene: whatever is away from the focus distance goes soft."
             .. " Let's take a closer look at how to use it.")

-- ----------------------------------------------------------- the widget
te.point_at (CAMERA_BUTTON, "top")
step ("The camera settings live behind ##1 this button on the right tool rail. The first row"
   .. " chooses the camera model: ##2 Pinhole camera renders everything sharp,"
   .. " ##3 Physical camera adds realistic lens effects, ##4 Orthographic camera shows objects without perspective,"
   .. " which is useful for technical views.",
   "top")

te.item_click (CAMERA_BUTTON)
te.wait_until_available ("Camera/Physical", 5)

te.wait_for_marker (2)
te.move_to_item("Camera/Pinhole")

te.wait_for_marker (3)
te.move_to_item ("Camera/Physical")

te.wait_for_marker (4)
te.move_to_item ("Camera/Ortho")

wait_step()

-- -------------------------------------------------------------- aperture
-- The aperture field belongs to the physical model and is not in the widget
-- until it is chosen, so the note cannot point at it from the start.
step ("Let's try the ##1 Physical camera. ##2 Let's open the aperture up to f/4. The F number defines"
   .. " the depth of field. The lower the value, the shallower the range in focus and the more blurred"
   .. " the background.", "top")

te.wait_for_marker (1)
te.item_click ("Camera/Physical")

te.wait_for_marker (2)
te.scribble_at ("Camera/Aperture:")
set_aperture (4.0)
te.checkpoint ("f/4")

wait_step()

step ("Close it down to f/30 and much more of the scene falls inside the sharp range - the standing"
   .. " ring behind comes back into focus. ##1 Somewhere between the two is what a photograph"
   .. " would look like.", "top")

set_aperture (30)
te.checkpoint ("f/30")

te.wait_for_marker (1)
set_aperture (10.0)

wait_step()

-- ------------------------------------------------------------- autofocus
scribble_step ("Autofocus is on by default: the focus distance follows whatever is at the centre of"
   .. " the viewport, which is why the stone in front is the sharp one.",
   AF_BUTTON)

wait_step()

step ("To focus on a specific point instead, ##1 click the autofocus button once - it switches to"
   .. " picking - ##2 and then click the point where the camera should acquire focus. Let's pick the"
   .. " ring behind.", "top")

te.wait_for_marker (1)
te.item_click (AF_BUTTON)
te.wait_for_seconds (0.5)

te.wait_for_marker (2)
te.item_click ("Camera/AF/#image/")
te.item_click ("Camera/AF/#image/")

te.click_viewport (te.world_to_screen (FAR_BAND_AT))

te.wait_for_seconds (1.5)
te.checkpoint ("focus picked on the far ring")

wait_step()

-- -------------------------------------------------------- focus distance
-- The ##Distance and ##Units below are item refs, not note markers: only a
-- note's text is scanned for those.
scribble_step ("Alternatively, set the focus distance directly by typing a value into this field."
   .. " It is in the scene's units; ##1 the measurement system that suits your model is chosen in"
   .. " the box next to it. ##2 Let's bring the focus back onto the stone in front.",
   "Camera/##Distance")

te.wait_for_marker (1)
te.scribble_at ("Camera/##Units", 2.0)

te.wait_for_marker (2)
te.item_input_value_float ("Camera/##Distance", math.floor (distance_to (NEAR_STONE_AT) + 0.5))
te.wait_for_seconds (1.5)
te.checkpoint ("focus distance typed")

wait_step()

step ("The control works in a cycle: the first click enters picking mode,"
   .. " and the second click either selects a point in the scene for manual focus or,"
   .." ##1 if you click the button again, switches back to autofocus.", "top")

te.item_click (AF_BUTTON)
te.wait_for_seconds (0.4)

te.wait_for_marker (1)
te.item_click (AF_BUTTON)
te.wait_for_seconds (1.5)

wait_step()

-- ---------------------------------------------------------- focal length

scribble_step ("The angle of view has a field of its own, in degrees, at the top of the diagram. It is"
   .. " the one framing control that works while the focal length is still automatic, because the"
   .. " automatic fit keeps whatever angle it is given. ##1 A wide angle takes in the room around the"
   .. " rings, ##2 a narrow one crops in on the stone.", "Camera/##FOV")

te.wait_for_marker (1)
te.item_input_value_float ("Camera/##FOV", 60)
te.wait_for_seconds (1.5)
te.checkpoint ("60 degrees")

te.wait_for_marker (2)
te.item_input_value_float ("Camera/##FOV", 20)
te.wait_for_seconds (1.5)
te.checkpoint ("20 degrees")

wait_step()


scribble_step ("The focal length is the distance from the lens to the sensor, and it is the alternative way to decide the field"
   .. " of view. ##1 Together with the film height it is especially useful when you'd like to match a real camera. Light Tracer picks it to fit the scene by default; ##2 switch the"
   .. " automatic adjustment off to set your own.", "Camera/##Length/")

te.wait_for_marker (1)
te.scribble_at ("Camera/##Sensor/")

te.wait_for_marker (2)
te.scribble_at (DOF_BUTTON)
te.item_click (DOF_BUTTON)
te.move_to_item ("Camera/##Length")


wait_step()

step ("The shorter the focal length, the wider the angle of view. ##1 At 30 millimetres we get the"
   .. " perspective of a wide-angle lens. ##2 A longer"
   .. " lens, say 85, narrows the view and flattens the perspective.", "top")

te.wait_for_marker (1)
te.item_input_value_float ("Camera/##Length", 30)
te.wait_for_seconds (1.5)
te.checkpoint ("30 mm")

te.wait_for_marker (2)
te.item_input_value_float ("Camera/##Length", 85)
te.wait_for_seconds (1.5)
te.checkpoint ("85 mm")

wait_step()

-- scribble_step ("Behind the lens sits the sensor, and its height is the other half of the angle of view:"
   -- .. " the same lens in front of a bigger sensor takes in more. ##1 Twenty-four millimetres is the"
   -- .. " height of a full-frame camera's sensor, ##2 twelve is closer to a compact's, and it crops the"
   -- .. " view to half. The field is greyed out while the focal length is automatic - that is because"
   -- .. " the sensor is what Light Tracer adjusts itself, to hold your angle of view as it re-fits the"
   -- .. " lens.", "Camera/##Sensor")

-- te.wait_for_marker (1)
-- te.item_input_value_float ("Camera/##Sensor", 24)
-- te.wait_for_seconds (1.5)
-- te.checkpoint ("24 mm sensor")

-- te.wait_for_marker (2)
-- te.item_input_value_float ("Camera/##Sensor", 12)
-- te.wait_for_seconds (1.5)
-- te.checkpoint ("12 mm sensor")

-- wait_step()

-- ---------------------------------------------------------------- blades

step ("The last part needs something small and bright to look at. ##1 Let's set the camera up for it -"
   .. " the lens back on automatic, the angle of view back where it was and the aperture opened wider"
   .. " than we have had it yet. ##2 We'll scatter sparks around the rings ##3 and turn the background down"
   .. " a bit. Every spark away from the focus stops being a point and opens into a disc -"
   .. " that is the bokeh.", "top")

-- The hand-set 85 mm on a 12 mm sensor is a small opening. Back on automatic,
-- Light Tracer fits a far longer lens to the scene - 150 mm here - and the
-- same f-number then means an aperture wide enough to open the sparks into
-- discs. The angle of view goes back first, because the fit keeps whatever
-- angle it is handed and would otherwise keep the narrow eight degrees left
-- over from the sensor step; typing the angle afterwards only turns the long
-- lens back into a short one.
te.wait_for_marker (1)
te.item_input_value_float ("Camera/##FOV", 30)
te.item_click (DOF_BUTTON)
set_aperture (2.0)

-- Only now the sparks: each is sized for the camera it is spawned under, and
-- ones made for the narrow eight-degree view arrive a third of the size in
-- this one - too little light left to open into anything.
te.wait_for_marker (2)
spawn_sparks() -- TODO: lower brightness to 100 and reduce bloom intensity and size

te.wait_for_marker (3)
darken_stage() -- TODO: disable backplate instead of darkening bg
te.checkpoint ("sparks in the dark")

wait_step()

step ("The shape of those discs is the aperture's own. ##1 Click the aperture in the lens diagram and"
   .. " you can set the number of blades it is built from. ##2 Three blades give triangles,"
   .. " ##3 five give pentagons, and ##4 eleven come out round.", "top")

te.wait_for_marker (1)
te.item_click ("Camera/##ApertureDisk")
te.wait_until_available ("<popup>/Blades count:", 5.0)

te.wait_for_marker (2)
te.item_input_value_int ("<popup>/Blades count:", 3)
te.checkpoint ("three blades")

-- Typing a value closes the popup; open it again for the way back.
te.wait_for_marker (3)
te.item_click ("Camera/##ApertureDisk")
te.wait_until_available ("<popup>/Blades count:", 5.0)
te.item_input_value_int ("<popup>/Blades count:", 5)
te.checkpoint ("five blades")

-- Typing a value closes the popup; open it again for the way back.
te.wait_for_marker (4)
te.item_click ("Camera/##ApertureDisk")
te.wait_until_available ("<popup>/Blades count:", 5.0)
te.item_input_value_int ("<popup>/Blades count:", 11)
te.wait_for_seconds (2.0)
te.checkpoint ("eleven blades")

wait_step()

-- ------------------------------------------------------------------- outro
-- The picture this lesson is listed by. Ignored while a viewer plays it;
-- a bookkeeping run is what turns it into the thumbnail.
te.capture_thumbnail()

-- The sparks and their dark stage belong to the blades section alone: the
-- scene is handed back the way the lesson found it.
remove_sparks()
restore_stage()
set_aperture (10.0)

te.item_click (CAMERA_BUTTON)
fold_panels()
open_tab ("Tutorials")

tutorial_end ("Create photo-realistic renders with the physical camera: open the aperture for a shallow"
           .. " depth of field, put the focus where it matters, and choose the focal length that"
           .. " suits the subject.")


