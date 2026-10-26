--@ title:       Working with geometry
--@ revision:    2
--@ subtitle:    Split, combine, shade and fix normals
--@ category:    Basics
--@ order:       30
--@ duration:    4:26
--@ description: The object context menu and its Mesh tools: extracting one
--@              part or separating them all, flat and smooth shading,
--@              reversing flipped normals, and combining small parts back
--@              into one object. Works on the solitaire ring from the
--@              showcase scene.

-- The object context menu and its Mesh tools section: extracting and
-- separating parts, fixing shading and normals, and combining parts back
-- together. Follows the "Basic course, module 1" video, on the solitaire
-- ring from the built-in showcase scene.

include ("assets/tutorial_common.lua")

-- ------------------------------------------------------------- the ring
-- The showcase scene ships the ring as a group of parts. The lesson starts
-- from the situation the video starts from - one object straight out of a
-- CAD package - so the parts are combined and the group dropped before the
-- first note appears.

-- Three views of the ring: the whole thing, the large stone, and the row of
-- small stones on the band.
local VIEW_RING  = { eye = { 18, -52, 30 }, target = { -0.3, -4, -6.5 }, up = { 0, 0, 1 } }
local VIEW_STONE = { eye = { 7.7, -29.2, 6.6 }, target = { -0.3, -9.2, -6.4 }, up = { 0, 0, 1 } }
local VIEW_BAND  = { eye = {21.526829, -20.064070, 7.499211}, target = {8.844396, -1.036497, -7.299852}, up = {-0.301315, 0.452119, 0.839522} }

-- Where the band is on screen in each view, as fractions of the viewport.
-- These sit in the middle of a wide stretch of band, so they survive the small
-- layout differences between machines; the stones are too small for that and
-- are clicked by their world position instead (see the setup below).

local STONE_VIEW_BAND  = { 0.40, 0.10 }   -- in VIEW_STONE, the band behind the stone
local BAND             = { 0.65, 0.22 }   -- in VIEW_BAND, the flat top of the band

-- World positions of the stones, filled in before the ring is folded into one
-- mesh: the parts keep their places through every command in the lesson.
local STONE_AT        = nil
local SMALL_STONES_AT = {}

-- The check-mark button every Mesh tools popup ends with.
local PERFORM = "<popup>/^b239^b128^b140 Perform/"

--! Opens the context menu of the current selection and goes into Mesh tools.
local function open_mesh_tools ()
  te.show_object_context_menu()
  te.item_click ("<popup>/Mesh tools/")
end

--! Runs one Mesh tools command on the current selection.
local function mesh_tool (label)
  open_mesh_tools()
  te.item_click ("<popup>/" .. label .. "/")
end

--! Same, for the commands that ask for confirmation first.
local function mesh_tool_confirm (label)
  mesh_tool (label)
  te.item_click (PERFORM)
end

--! Shade smooth asks for the angle: typing a value performs the command as
--! well (Enter is the popup's confirm), so no Perform click follows.
local function shade_smooth (angle)
  mesh_tool ("Shade smooth")
  te.wait_for_seconds (0.4)
  te.item_input_value_float ("<popup>/Max face angle:", angle)
end

-- Clicks go through the application's own mouse handling, so they behave
-- exactly as a viewer's would: a click on a part of a group selects the
-- group, a double-click steps into it, Ctrl adds to the selection. The
-- render viewport runs underneath the side panels, so the panels are folded
-- away (see fold_panels) whenever the lesson clicks near the window's sides.

--! Clicks a viewport spot given as fractions of the viewport.
local function click (pos, opts)
  te.click_viewport (pos[1], pos[2], opts)
  te.wait_for_seconds (0.3)
end

--! Clicks a world position, wherever the camera is.
local function click_world (world, opts)
  local x, y = te.world_to_screen (world)
  te.click_viewport (x, y, opts)
  te.wait_for_seconds (0.3)
end

--! Folds both side panels away, or brings them back. The grab handles toggle,
--! so this assumes the panels start out open, as they do on a fresh launch.
local function fold_panels ()
  te.item_click ("LeftGrabContainer/##LeftGrab/")
  te.item_click ("RightGrabContainer/##RightGrab/")
  te.wait_for_seconds (0.6)
end

--! Applies a Library preset to the selection by filtering the materials by
--! name and locating the built-in preset by ID. The right panel is folded away at
--! this point, so it is opened for the click and folded back afterwards; in
--! the lesson player the panel slides in over several frames, so every step
--! waits for what it needs to be on screen rather than assuming it is.
local function apply_library_material (name)
  te.item_click ("RightGrabContainer/##RightGrab/")
  te.wait_until_available ("Library/", 5)
  open_tab ("Library")
  te.item_click ("Library/Materials/")
  te.wait_until_available ("Library/##Filter", 5)
  te.item_input_text ("Library/##Filter", "")
  library_category ("All materials/Built-in/Gemstones")
  te.item_input_text ("Library/##Filter", name)
  te.item_click (library_preset_ref ("materials", "builtin:" .. name))
  te.wait_for_seconds (0.8)
  -- Leave the filter empty and unfocused, so the next visit starts clean.
  te.item_input_text ("Library/##Filter", "")
  te.item_click ("Library/Materials/")
  te.wait_for_seconds (0.3)
  te.item_click ("RightGrabContainer/##RightGrab/")
  te.wait_for_seconds (0.5)
end

--! Moves the camera and waits until it has arrived, so that whatever is
--! clicked next is where the view says it is.
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

lt.import_scene ("data/models/default.zip")
te.wait_for_seconds (0.5)

-- Two rings come with the scene; keep the one lying on the floor. Both are
-- named the same, so the standing one is told apart by its height.
do
  local root = lt.root()
  for i = lt.get_sub_node_count (root), 1, -1 do
    local node = lt.get_sub_node (root, i)
    if node:get_name() == "square solitaire" and node:world_bounds().size[3] > 10 then
      node:delete()
    end
  end
end

-- Remember where the stones are while they are still separate parts: the
-- large one, and the five along the band that VIEW_BAND looks at.
STONE_AT = lt.find_by_name ("Main"):world_bounds().center
for _, name in ipairs ({ "Gem - 12", "Gem - 11", "Gem - 13", "Gem", "Gem - 3", "Gem - 7", "Gem - 6" }) do
  SMALL_STONES_AT[#SMALL_STONES_AT + 1] = lt.find_by_name (name):world_bounds().center
end

-- Fold the parts into one mesh. The band goes first so the combined object
-- keeps its metal, and the whole thing is smooth-shaded afterwards: that is
-- how a mesh often arrives, and it is what the lesson then fixes.
--
-- Both steps go through lt.*, not through the menus the lesson is about to
-- teach: the viewer should meet the ring already in this state rather than
-- watch it being prepared, and neither step lands in the undo history, so the
-- Ctrl+Z the lesson hands out cannot take the preparation apart.
do
  local group = lt.find_by_name ("square solitaire")

  local parts = { lt.find_by_name ("Frame") }
  for i = 1, lt.get_sub_node_count (group) do
    local part = lt.get_sub_node (group, i)
    if part:get_name() ~= "Frame" then
      parts[#parts + 1] = part
    end
  end

  local mesh = lt.combine_nodes (parts)
  lt.assign_node_to_parent (mesh, lt.root())
  group:delete()
  mesh:set_name ("Ring")

  lt.shade_smooth (mesh, 120)
  lt.clear_selection()
end

look (VIEW_RING)

tutorial_begin ("In this lesson we work with the geometry of an object. The ring on screen was imported"
             .. " as a single mesh, the way models sometimes arrive from a CAD package. We will handle"
             .. " common issues and fix its shading normals while exploring the Mesh tools menu.")

-- ---------------------------------------------------------- context menu

te.select_at_screen_pos ({ at = {0.401, 0.478}, point = {-8.906967, 0.478256, -6.360424}, node = "Ring", append = false, right = false })

te.show_object_context_menu()

step ("Right click an object to open its context menu. From here you can ##1 clone the object,"
   .. " ##2 remove it, ##3 point the camera at it, ##4 isolate it by hiding everything else,"
   .. " or ##5 hide the object itself.", "left")

te.wait_for_marker (1)
te.scribble_at ("<popup>/Clone/", 1.5)
te.wait_for_marker (2)
te.scribble_at ("<popup>/Remove/", 1.5)
te.wait_for_marker (3)
te.scribble_at ("<popup>/Look here/", 1.5)
te.wait_for_marker (4)
te.scribble_at ("<popup>/Show only/", 1.5)
te.wait_for_marker (5)
te.scribble_at ("<popup>/Hide entirely/")


te.checkpoint ("object context menu", "window")
wait_step()

step ("Feel free to experiment with these. Whatever you do with object or its visibility, Ctrl+Z - or the undo button in the"
   .. " top row - takes it back. The camera change on the other hand will not be reverted.", "left")

wait_step()

-- ------------------------------------------------------------ mesh tools
te.select_at_screen_pos ({ at = {0.401, 0.478}, point = {-8.906967, 0.478256, -6.360424}, node = "Ring", append = false, right = false })

te.show_object_context_menu()

step ("The last entry, ##1 Mesh tools, is the one this lesson is about. It edits the geometry"
   .. " itself: splitting and combining parts, flat or smooth shading, and repairing normals.", "left")

te.wait_for_marker (1)
te.item_click ("<popup>/Mesh tools/")
te.scribble_at ("<popup>/Extract part/")

te.checkpoint ("mesh tools menu", "window")
wait_step()

-- ----------------------------------------------------------- extract part
te.clear_attention()
fold_panels()
look (VIEW_STONE)

step ("Let's start by separating the large stone from the rest of the ring. ##1 Right click on a spot"
   .. " where the stone is clearly visible and ##2 choose Extract part: the connected piece under"
   .. " the cursor becomes an object of its own.", "top")

te.wait_for_marker (1)
click_world (STONE_AT)
open_mesh_tools()

te.wait_for_marker (2)
te.item_click ("<popup>/Extract part/")
te.wait_for_seconds (0.5)

te.checkpoint ("main stone extracted")
wait_step()

step ("Now that the stone is a separate object we can give it a material. ##1 Let's apply a diamond"
   .. " from the Library.", "top")

te.wait_for_marker (1)
apply_library_material ("Diamond")

te.checkpoint ("diamond with smooth normals")
wait_step()

step ("Looks a bit strange, doesn't it? The stone was smooth-shaded, so its normals are blended"
   .. " across the facets. ##1 Open Mesh tools again and ##2 choose Shade flat: it removes the smoothing,"
   .. " which is exactly right for a cut gemstone.", "top")

te.wait_for_marker (1)
click_world (STONE_AT)
open_mesh_tools()

te.wait_for_marker (2)
te.item_click ("<popup>/Shade flat/")
te.wait_for_seconds (0.5)

te.checkpoint ("main stone flat shaded")
wait_step()

look (VIEW_RING)

-- -------------------------------------------------------- separate parts
step ("To split every disconnected piece of an object in one go, use Separate parts. ##1 Select the"
   .. " ring, ##2 open Mesh tools, ##3 choose Separate parts ##4 and confirm.", "top")

te.wait_for_marker (1)
click (STONE_VIEW_BAND)

te.wait_for_marker (2)
open_mesh_tools()

te.wait_for_marker (3)
te.item_click ("<popup>/Separate parts/")

te.wait_for_marker (4)
te.item_click (PERFORM)
te.wait_for_seconds (0.8)

te.checkpoint ("ring separated into parts")
wait_step()

-- ------------------------------------------------------- small stones
look (VIEW_BAND)

step ("Each small stone is now an object too, inside a group. ##1 Double-click one stone to step"
   .. " into the group, ##2 then hold Ctrl and click the others to select several at once, ##3 and"
   .. " apply the diamond material to all of them.", "top")

-- A single click on any of the separated parts selects the group as a whole;
-- a double-click steps into it.
te.wait_for_marker (1)
click_world (SMALL_STONES_AT[1], { count = 2 })

te.wait_for_marker (2)
for i = 2, #SMALL_STONES_AT do
  click_world (SMALL_STONES_AT[i], { ctrl = true })
end

te.wait_for_marker (3)
apply_library_material ("Diamond")

te.checkpoint ("small stones assigned diamond")
wait_step()

step ("The same fix as before: ##1 Mesh tools, ##2 Shade flat - and the facets come back on every"
   .. " selected stone at once.", "top")

te.wait_for_marker (1)

te.move_to_screen_pos ({ at = {0.329, 0.586}, point = {7.946707, -3.398927, -7.001979} })
open_mesh_tools()

te.wait_for_marker (2)
te.item_click ("<popup>/Shade flat/")
te.wait_for_seconds (0.5)

te.checkpoint ("small stones flat shaded")
wait_step()

-- ------------------------------------------------------- reverse normals
step ("Sometimes a part still renders dark or looks inside out after that. Its normals are"
   .. " flipped, and Reverse normals turns them the right way round. These stones are fine,"
   .. " so ##1 applying it here shows what a flipped part looks like - ##2 and Undo puts it back.", "top")

te.wait_for_marker (1)
te.move_to_screen_pos ({ at = {0.329, 0.586}, point = {7.946707, -3.398927, -7.001979} })

mesh_tool ("Reverse normals")
te.checkpoint ("reversed stone normals")
te.wait_for_seconds (1.0)

te.wait_for_marker (2)
te.item_click ("ToolContainer/Undo/#image/")

te.checkpoint ("normals restored by undo")
wait_step()

-- --------------------------------------------------------- combine parts
step ("When a scene has too many small objects, combine them. With the stones still selected,"
   .. " ##1 open Mesh tools and ##2 choose Combine parts: ##3 they become a single object again.", "top")

te.wait_for_marker (1)

te.move_to_screen_pos ({ at = {0.329, 0.586}, point = {7.946707, -3.398927, -7.001979} })

open_mesh_tools()

te.wait_for_marker (2)
te.item_click ("<popup>/Combine parts/")

te.wait_for_marker (3)
te.item_click (PERFORM)
te.wait_for_seconds (0.5)

te.checkpoint ("small stones combined")
wait_step()

-- ---------------------------------------------------------- shade smooth
-- The band has been smooth-shaded since the lesson began, so it is flattened
-- first or Shade smooth would change nothing visible. That step is said out
-- loud rather than slipped in under a sentence about something else.
step ("Shade smooth is the opposite of Shade flat. ##1 Double-click the band to select it, ##2 flatten"
   .. " it first so the difference shows, then ##3 choose Shade smooth: a small window asks for the"
   .. " maximum face angle. ##4 Faces that meet at a sharper angle keep their edge, everything flatter"
   .. " is blended - so the band comes out smooth while its edges stay crisp.", "top")

te.wait_for_marker (1)

te.deselect()
click ({ 0.66, 0.22 }, { count = 2 })

te.wait_for_marker (2)
mesh_tool ("Shade flat")
te.checkpoint ("band flat shaded")
te.wait_for_seconds (0.5)

te.wait_for_marker (3)
mesh_tool ("Shade smooth")
te.wait_until_available ("<popup>/Max face angle:", 5)

te.wait_for_marker (4)
te.item_input_value_float ("<popup>/Max face angle:", 30)
te.wait_for_seconds (0.5)

te.checkpoint ("band smooth shaded")
wait_step()

-- ------------------------------------------------------------------- outro
lt.clear_selection()
look (VIEW_RING)

-- The picture this lesson is listed by. Ignored while a viewer plays it;
-- a bookkeeping run is what turns it into the thumbnail.
te.capture_thumbnail()

fold_panels()
open_tab ("Tutorials")

tutorial_end ("That covers the main tools for working with geometry in Light Tracer. You now know how"
           .. " to split and combine parts, switch between flat and smooth shading, and fix flipped"
           .. " normals.")






