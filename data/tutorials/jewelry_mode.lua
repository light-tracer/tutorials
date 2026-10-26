--@ title:       Real-time jewelry mode
--@ revision:    2
--@ subtitle:    Fast renders, smooth materials and a baked catcher
--@ category:    Basics
--@ order:       110
--@ duration:    5:00
--@ description: The render mode made for rings on a clean backdrop: what it
--@              speeds up, the one rule about materials that keeps it fast,
--@              and the catcher floor whose shadows it bakes into a mask -
--@              with the brightness, contrast and lock that come with it.
--@              Ends by baking the same mask in the normal mode.

-- Follows the two videos on the mode (youtu.be/5ag_3J-zIWI, the mode and its
-- rules, and youtu.be/4iHzU_OWqwI, the baked catcher and its lock) on the
-- showcase scene, which already stands on a catcher floor.

include ("assets/tutorial_common.lua")

lt.import_scene ("data/models/default.zip")
te.wait_loads_complete (60)

RT_BUTTON    = "RightToolsContainer/##RT/#image/"
MODEL_BUTTON = "LeftToolsContainer/##Model/#image/"
UNDO_BUTTON  = "ToolContainer/Undo/#image/"

-- The same close view used by the physical-camera lesson: it fills the frame
-- with the lying ring's main stone while leaving enough of the setting visible
-- for a short orbit to read clearly.
local VIEW_DIAMOND = { eye = { -18, -34, 4 }, target = { -0.3, -9.2, -6.4 }, up = { 0, 0, 1 } }

-- The Scene Explorer's material list, in the order it draws the showcase
-- scene's materials: Catcher, Diamond, Diamond, Diamond Fancy Blue Violet,
-- Diamond Fancy Green, Gold 750, Rhodium. Clicking a row selects every part
-- made of that material.
local MATERIAL_ROW = "Scene Explorer^/Content_ECC52E9C/^%d/Select"
local ROW_CATCHER = 0

-- The catcher's mask slot is the first one under Textures; the lock sits over
-- the middle of the mask and the two sliders along its bottom.
local MASK_SLOT     = "Properties/^1/Baked opacity/"
local MASK_LOCK     = "Properties/^1/##Lock/#image/"
local MASK_BRIGHT   = "Properties/^1/Brightness:/"
local MASK_CONTRAST = "Properties/^1/Contrast:/"

local floor = lt.find_by_name ("Scene floor")

-- Both rings are groups called "square solitaire", so a lookup by name gives
-- whichever comes first. The lock is shown on the standing one - the taller of
-- the two - because its shadow is the one a viewer can actually see.
local ring = nil

for i = 1, lt.get_sub_node_count (lt.root()) do
  local node = lt.get_sub_node (lt.root(), i)

  if node:get_name() == "square solitaire"
     and (ring == nil or node:world_bounds().size[3] > ring:world_bounds().size[3]) then
    ring = node
  end
end

assert (floor ~= nil and ring ~= nil, "Expected the showcase scene")

local function material_row (row)
  return string.format (MATERIAL_ROW, row)
end

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

--! Baking runs over several frames; the mask is done when it reports ready.
local function wait_until_baked (seconds)
  local deadline = os.clock() + (seconds or 30)
  -- Always advance the application, including in fast mode and during Skip.
  -- Two frames let edits invalidate the previously ready mask before checking.
  te.wait_for_frames (2)
  repeat
    if floor:get_baked_map_ready() then
      return true
    end
    te.wait_for_frames (1)
  until os.clock() >= deadline

  return false
end

--! Waits for a bake that a change has just asked for. The mask still reports
--! ready for a moment after the change, so advance frames before checking it.
--! A small re-bake can start and finish between observations: seeing the stale
--! state is not required, only readiness after the edit has been processed.
local function wait_until_baked_again (seconds)
  -- Edits are applied across frames. Seeing the brief stale state is not
  -- required: a small bake can start and finish between two observations.
  return wait_until_baked (seconds)
end

--! Slides a node sideways over about a second, so the viewer sees it move
--! rather than jump. Records no undo step: the lesson slides it back itself.
local function slide (node, dx, dy)
  local steps = 30

  for _ = 1, steps do
    local t = node:get_world_transform()
    t[13] = t[13] + dx / steps
    t[14] = t[14] + dy / steps
    node:set_world_transform (t)
    te.wait_for_frames (2)
  end
end

tutorial_begin ("In this tutorial, we'll use Real-time jewelry-mode to produce a clean ring render"
             .. " much faster. We'll cover the materials it works best with, set up the catcher"
             .. " floor, and bake a shadow that stays exactly where we want it.")

-- ------------------------------------------------------------ switching it on
point_step ("##1 Turn on Real-time jewelry-mode with this button at the bottom of the right toolbar."
   .. " The image clears up almost immediately, so the viewport stays responsive while you adjust"
   .. " materials and lighting.", RT_BUTTON, "right")

te.wait_for_marker (1)
te.item_click (RT_BUTTON)
te.wait_for_seconds (1.0)
te.checkpoint ("jewelry mode on")

wait_step()

-- Keep the composition used by the rest of the lesson, then borrow the
-- physical-camera lesson's close-up for a short, visibly interactive orbit.
local overview = te.get_camera()

step ("Now watch that responsiveness up close. ##1 We'll move right in on the diamond, then ##2 orbit"
   .. " around it. As every facet and reflection changes, the stone keeps rendering interactively.",
   "top-right")

te.wait_for_marker (1)
look (VIEW_DIAMOND)
te.wait_for_marker (2)
te.viewport_drag ({ start = {0.54, 0.48}, delta = {-150, -18}, button = "left", duration = 3.0 })
te.wait_for_seconds (0.8)
te.checkpoint ("diamond stays interactive")

wait_step()
look (overview)
te.set_camera (overview) -- later recorded screen picks need the exact original view
te.wait_for_seconds (0.2)

-- --------------------------------------------------------------- the one rule
step ("This speed comes from specializing in jewelry materials. Metals and gemstones work especially"
   .. " well, whether the metal is polished, brushed, or matte. Diffuse materials such as plastic,"
   .. " plaster, fabric, and painted surfaces take much longer to become clean.", "top-right")

wait_step()

-- A shape from the modeling toolbox arrives in the default material, a plain
-- grey that is almost entirely diffuse - the very thing the rule is about.
te.point_at(MODEL_BUTTON, "left")
step ("Let's see that difference. ##1 Open the modeling toolbox, then ##2 drag a sphere onto the"
   .. " floor beside the rings. New shapes use a plain gray material, so this gives us a diffuse"
   .. " surface to compare against the jewelry.", "top")

te.wait_for_marker (1)
te.item_click (MODEL_BUTTON)
te.wait_until_available ("Modeling/UV sphere/##", 5)
te.wait_for_marker (2)
te.mouse_move_rel ("Modeling/UV sphere/##", 0.5, 0.5)
te.mouse_down()
te.mouse_move_screen (0.74, 0.66) -- a free stretch of floor to the right of the standing ring
te.mouse_up()

-- The modeling widget creates/selects the dropped mesh in a subsequent UI
-- frame. A presentation delay is removable by Skip, so wait for that result.
local sphere
local sphere_deadline = os.clock() + 5
repeat
  te.wait_for_frames (1)
  sphere = lt.get_selected_node (1)
until (sphere ~= nil and sphere:get_name() == "UV sphere") or os.clock() >= sphere_deadline
assert (sphere ~= nil and sphere:get_name() == "UV sphere", "Expected the dropped sphere selected")

wait_step()

te.item_click (MODEL_BUTTON)
lt.clear_selection() -- the gizmo would sit right over what the next note points out

step ("Compare them side by side. The metal and gemstones are already clean, while the gray sphere"
   .. " remains blotchy and noisy. It will eventually converge, but much more slowly, which defeats"
   .. " the purpose of this mode.", "top")

te.wait_for_seconds (1.5)
te.checkpoint ("diffuse sphere")

wait_step()

te.point_at (UNDO_BUTTON, "top")
step ("##1 Undo the sphere to remove it. If your shot depends on a diffuse prop, switch back to the"
   .. " normal render mode for the final image.", "top-right")

te.wait_for_marker (1)
te.item_click (UNDO_BUTTON)
te.wait_for_seconds (0.5)
assert (lt.find_by_name ("UV sphere") == nil, "Expected Undo to remove the sphere")

wait_step()

-- ---------------------------------------------------------------- the catcher
step ("Next, let's set up the surface beneath the rings. A catcher floor stays invisible but preserves"
   .. " the shadows and reflections that land on it, and it's optimized for this render mode. ##1"
   .. " Open the Scene Explorer, ##2 switch to the material list, and ##3 select Catcher.",
   "top")

te.wait_for_marker (1)
open_tab ("Scene Explorer")
te.wait_for_marker (2)
te.item_click ("Scene Explorer/##Materials")
te.wait_for_marker (3)
te.item_click (material_row (ROW_CATCHER))
te.wait_for_seconds (0.3)
assert (lt.get_selected_node_count() == 1 and lt.get_selected_node (1):get_name() == "Scene floor",
        "Expected the catcher floor selected")

wait_step()

te.wait_until_available ("Properties/Reflections:/", 5)

step_at ("The Shadows and Reflections controls decide what the catcher keeps. A white catalog shot"
   .. " usually needs soft shadows, while a darker setup can work well with a glossy floor. ##1 Raise"
   .. " Reflections and a mirror image appears beneath the rings.",
   "Properties/Reflections:/", "left")

te.wait_for_marker (1)
te.item_input_value_float ("Properties/Reflections:/", 0.35)
te.wait_for_seconds (1.0)
te.checkpoint ("catcher reflections")

wait_step()

te.item_click (UNDO_BUTTON)
te.wait_for_seconds (0.5)

-- ------------------------------------------------------------- the baked mask
te.expect (wait_until_baked (60), "jewelry mode bakes the catcher mask by itself")

scribble_step ("The Baked opacity slot under Textures is another reason this mode is so fast. The"
   .. " catcher automatically stores its shadows in a mask instead of tracing them again for every"
   .. " sample.", MASK_SLOT, { side = "left", at = "Properties/" })

wait_step()

step_at ("You can adjust the baked mask without baking it again. ##1 Increase Contrast to make the"
   .. " shadow darker and more defined. ##2 Then lower Brightness to lighten the entire mask.",
   MASK_CONTRAST, "left")

te.wait_for_marker (1)
te.item_input_value_float (MASK_CONTRAST, 2.0)
te.wait_for_seconds (0.8)
te.item_click ("Properties/Textures") -- between two typed fields, see the camera widget notes
te.item_click ("Properties/Textures")
te.wait_for_marker (2)
te.item_input_value_float (MASK_BRIGHT, -0.3)
te.wait_for_seconds (0.8)
te.checkpoint ("graded mask")

wait_step()

te.item_click ("ToolContainer/Undo/#image/")
te.item_click ("ToolContainer/Undo/#image/")

-- ------------------------------------------------------------------- the lock
step ("By default, the mask updates whenever the scene changes. ##1 Move the standing ring aside and"
   .. " its shadow is baked again in the new position. ##2 Undo the move, and the shadow returns with"
   .. " the ring.", "bottom-right")

te.wait_for_marker (1)
te.select_at_screen_pos ({ at = {0.392, 0.371}, point = {-8.375317, 2.879074, 4.619114}, node = "square solitaire", append = false, right = false })
te.gizmo_drag ({ handle = "TrXY", origin = {0.50544, 0.43855}, start = {39.08, 21.80}, delta = {-0.51172, -0.00076}, duration = 1.31902, T = {-18.083008, -1.714991, -0.000004}, R = {0.000000, 0.000000, 0.000000}, S = {1.000000, 1.000000, 1.000000} })
wait_until_baked_again (60)
te.checkpoint ("unlocked shadow moves with the ring")

te.wait_for_marker (2)
te.item_click (UNDO_BUTTON)
wait_until_baked_again (60) -- locking a mask that is still baking would freeze a half-made one

wait_step()

-- Back to the floor, whose Properties the lock is in.
te.select_at_screen_pos ({ at = {0.753, 0.730}, point = {17.530811, 9.732201, -9.853924}, node = "Scene floor", append = false, right = false })
te.wait_until_available (MASK_LOCK, 5)

point_step ("Once the shadow looks right, ##1 lock the mask. Light Tracer stops baking it, saves it with"
   .. " the scene, and can produce a clean image with only a small number of samples.",
   MASK_LOCK, "left", { side = "left", at = MASK_CONTRAST })

te.wait_for_marker (1)
te.item_click (MASK_LOCK)
te.wait_for_seconds (0.4)
te.expect (floor:get_baked_map_locked(), "the lock button locks the mask")

wait_step()

step ("Now the mask is frozen. ##1 Move the standing ring again, and its shadow stays behind in the"
   .. " original position.", "bottom-right")

te.wait_for_marker (1)
te.select_at_screen_pos ({ at = {0.392, 0.371}, point = {-8.375317, 2.879074, 4.619114}, node = "square solitaire", append = false, right = false })
te.gizmo_drag ({ handle = "TrXY", origin = {0.50544, 0.43855}, start = {39.08, 21.80}, delta = {-0.51172, -0.00076}, duration = 1.31902, T = {-18.083008, -1.714991, -0.000004}, R = {0.000000, 0.000000, 0.000000}, S = {1.000000, 1.000000, 1.000000} })

te.wait_for_seconds (0.8)
te.expect (floor:get_baked_map_ready(), "a locked mask is left alone when the ring moves")
te.checkpoint ("locked shadow left behind")

wait_step()

te.select_at_screen_pos ({ at = {0.753, 0.730}, point = {17.530811, 9.732201, -9.853924}, node = "Scene floor", append = false, right = false })

point_step ("If later changes should affect the shadow, ##1 unlock the mask. It immediately bakes again"
   .. " and catches up with the ring's new position.",
   MASK_LOCK, "left", { side = "left", at = MASK_CONTRAST })
   

te.wait_for_marker (1)
te.item_click (MASK_LOCK)
te.expect (wait_until_baked_again (60), "unlocking bakes the mask once more")
te.expect (not floor:get_baked_map_locked(), "and releases the lock")
te.checkpoint ("unlocked shadow follows")

te.select_at_screen_pos ({ at = {0.337, 0.388}, point = {-10.322231, -2.694527, 6.013432}, node = "square solitaire", append = false, right = false })
te.gizmo_drag ({ handle = "TrXY", origin = {0.24350, 0.43781}, start = {30.64, 24.78}, delta = {0.50113, -0.01361}, duration = 1.31902, T = {-0.864384, 5.048460, -0.000004}, R = {0.000000, 0.000000, 0.000000}, S = {1.000000, 1.000000, 1.000000} })

wait_step()

wait_until_baked_again (60)

-- ------------------------------------------------------ baking in normal mode
point_step ("Automatic baking belongs to Real-time jewelry-mode. ##1 Switch back to the normal mode and"
   .. " the slot becomes empty; the catcher now traces its shadows sample-by-sample with the rest of"
   .. " the image.", RT_BUTTON, "right")

te.wait_for_marker (1)
te.item_click (RT_BUTTON)
te.wait_for_seconds (1.0)

wait_step()

-- The ring was the last thing selected; the slot is in the floor's Properties.
te.select_at_screen_pos ({ at = {0.753, 0.730}, point = {17.530811, 9.732201, -9.853924}, node = "Scene floor", append = false, right = false })
te.wait_until_available (MASK_SLOT, 5)

point_step ("You can still bake the catcher manually in normal mode. ##1 Click the empty Baked opacity"
   .. " slot. The shadows are stored in a new mask with the same Brightness, Contrast, and Lock"
   .. " controls.", MASK_SLOT, "left", { side = "left", at = "Properties/" })

te.wait_for_marker (1)
te.item_click (MASK_SLOT)
te.expect (wait_until_baked (60), "the mask bakes in the normal mode")
te.checkpoint ("baked in normal mode")

wait_step()

-- ------------------------------------------------------------------- outro
te.item_click ("Scene Explorer/##Nodes")
lt.clear_selection()

open_tab ("Tutorials")

-- The picture this lesson is listed by. Ignored while a viewer plays it;
-- a bookkeeping run is what turns it into the thumbnail.
te.capture_thumbnail()

tutorial_end ("And that's the complete setup: jewelry-friendly materials, an invisible catcher, and a"
           .. " baked shadow you can grade and lock. For clean catalog renders of metal and"
           .. " gemstones, Real-time jewelry-mode is usually the fastest place to start.")
