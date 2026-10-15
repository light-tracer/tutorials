-- Helpers shared by every lesson in data/tutorials.
--
-- Lessons are ordinary UI-automation scripts (the te.* bindings), so these are
-- only thin wrappers that keep the lesson files readable and give every lesson
-- the same pacing.

-- Seconds of silence between two spoken steps.
STEP_PAUSE = 0.4

--! Puts the interface where the in-app player starts every lesson from.
--!
--! The player resets it before pressing play; a scripted run inherits whatever
--! the launch left up, and a fresh launch leaves the welcome dialog open. That
--! one matters beyond tidiness: ImGui claims the mouse while a popup is open,
--! so the application drops viewport presses entirely - the lesson's first
--! click at an object selects nothing, and since the press never recorded a
--! start position the release can be read as a camera drag and quietly move
--! the view. A lesson whose preparation happened to click a panel dismissed
--! the dialog by accident and hid all of this.
function reset_ui_for_lesson ()
  te.reset_gui_for_lesson()
  te.wait_for_seconds (0.2)
end

-- Right here, not in tutorial_begin: a lesson prepares its scene before its
-- first note, and some of that preparation opens the panel the lesson starts
-- on. This file is included before any of it, which is where the player does
-- its own reset.
--
-- Not when the editor runs part of a lesson (RUN_FROM_LINE is set): that run
-- starts from the application as the earlier lines left it, popups and folded
-- panels included, and a reset would pull it out from under the line it
-- starts on.
if RUN_FROM_LINE == nil then
  reset_ui_for_lesson()
end

--! Shows the opening note of a lesson and waits for it to be read.
function tutorial_begin (message)
  te.clear_note()
  te.show_note (message, "center")
  te.wait_for_note()
end

--! Shows the narration of the next step. The note stays on screen while the
--! automation below it runs, so the viewer reads and watches at the same time.
function step (message, pos)
  te.show_note (message, pos or "auto")
end

--! Same as step(), but the note is pinned just outside the element, on the side
--! named ("left", "right", "top", "bottom") or on whichever side has room for
--! it. Use it whenever the words are about a particular thing on screen - the
--! reader's eyes then never have to leave it.
function step_at (message, ref, side)
  te.show_note_at_item (ref, side, message)
end

--! Waits until the current note has been read, then pauses briefly so the
--! steps do not run into each other.
function wait_step ()
  te.wait_for_note()
  te.wait_for_seconds (STEP_PAUSE)
end

--! Shows the closing note of a lesson and clears the overlay afterwards.
function tutorial_end (message)
  te.show_note (message, "center")
  te.wait_for_note()
  te.clear_note()
end

--! Brings the given docked panel to front by clicking its tab.
function open_tab (title)
  te.item_click (title .. "/")
  te.wait_for_seconds (0.3)
end

-- --------------------------------------------------------------- library

--! Selects a category and opens its ancestors without toggling open nodes
--! closed. Clear the search first if it could hide the requested category.
function library_category (path)
  local prefix = "Library^/TreeScrollArea_FE54A26B/"
  local parts = {}
  for part in string.gmatch (path, "[^/]+") do table.insert (parts, part) end
  for i, part in ipairs (parts) do
    prefix = prefix .. part .. "/"
    local ref = prefix .. "##clickable_area/"
    te.wait_until_available (ref, 5)
    local state = te.item_status (ref)
    assert (state.exists, "Library category is unavailable: " .. path)
    if i == #parts and not state.checked then
      te.item_click (ref)
      te.wait_for_frames (2)
      state = te.item_status (ref)
    end
    if state.openable and not state.opened then
      te.item_click (ref)
      te.wait_for_frames (2)
    end
  end
end

--! Resolves immediately before clicking: pins, downloads and new presets can
--! change the grid order. IDs include the origin (builtin/external/user).
function library_preset_ref (kind, id)
  te.wait_for_frames (2)
  local ref, count = te.library_preset_ref (kind, id)
  assert (ref, string.format ("Expected one %s preset '%s'; found %d", kind, id, count))
  te.wait_until_available (ref, 15)
  assert (te.item_status (ref).exists, "Library thumbnail is unavailable: " .. id)
  return ref
end

--! Ref of the n-th thumbnail in the library grid (0-based, as drawn).
LIBRARY_GRID_ITEM = "Library^/ScrollArea_4B19BEF1/^%d/#image/"

--! Applies an HDRI from the library grid, fetching it first when it has to be.
--!
--! The library lists every map the cloud library has, but keeps only previews
--! of the ones not fetched yet, and those answer a click with the download
--! popup rather than lighting the scene: pick a resolution there, wait for it
--! to arrive, and a second click is what applies it. A map already downloaded
--! applies on the first click and no popup appears at all. Both happen in a
--! lesson - the second time a viewer plays it, the map is already there - so
--! this handles either and returns TRUE when a download was needed.
--!
--! A resolution the library does not hold for that map is drawn dead: clicking
--! it does nothing and leaves the popup up, which is how the fallback below
--! knows to try the next one.
function library_apply_map (theId, theSize, theTimeout, onState)
  library_category ("All maps")
  local ref = library_preset_ref ("hdri", theId)

  te.item_click (ref)
  te.wait_for_seconds (0.8)

  if te.top_popup() == "" then
    te.wait_loads_complete (theTimeout or 180)
    if onState then onState ("ready", library_preset_ref ("hdri", theId)) end
    return false -- already here, and that click applied it
  end

  te.set_ref (te.top_popup())
  local isDownload = te.item_status ("###1k").exists
  te.set_ref ("")
  assert (isDownload, "Expected the HDRI resolution download popup")
  if onState then onState ("download") end

  local tried = {}
  for _, size in ipairs ({ theSize or "4k", "2k", "1k", "4k", "8k", "16k" }) do
    local popup = te.top_popup()

    if popup == "" then
      break
    end

    if not tried[size] then
      tried[size] = true
      te.set_ref (popup)
      te.item_click ("###" .. size)
      te.set_ref ("")
      te.wait_for_seconds (0.6)
    end
  end

  assert (te.top_popup() == "", "No available HDRI download resolution")

  te.wait_loads_complete (theTimeout or 180)
  te.wait_for_seconds (1.0)

  ref = library_preset_ref ("hdri", theId)
  if onState then onState ("apply", ref) end
  te.item_click (library_preset_ref ("hdri", theId)) -- resolve again after narration
  te.wait_loads_complete (theTimeout or 180)
  te.wait_for_seconds (1.0)
  assert (te.top_popup() == "", "HDRI download failed: applying reopened the download popup")

  return true
end

--! The side of an element opposite the one an arrow flies in from.
local OPPOSITE_SIDE = {
  left   = "right",
  right  = "left",
  top    = "bottom",
  bottom = "top",
}

--! Where the note of one of the steps below goes. `note` is either the side of
--! the element to put it on, or { side = ..., at = ref } to put it beside a
--! different element - a panel-wide header, say, so a note about a small
--! button in a side panel sits next to the panel rather than over its controls.
local function note_place (ref, note, default_side)
  if type (note) == "table" then
    return note.at or ref, note.side or default_side
  end
  return ref, note or default_side
end

--! Narrates a step while an arrow points at what it is about. `side` is the
--! side the arrow flies in from: "left", "right", "top" or "bottom". The note
--! goes on the far side of the element, where the arrow is not, unless `note`
--! says otherwise (see note_place).
function point_step (message, ref, side, note)
  te.point_at (ref, side or "left")
  step_at (message, note_place (ref, note, OPPOSITE_SIDE[side or "left"]))
end

--! Narrates a step while a loop is scribbled around the element. `note` is
--! where the note goes (see note_place); it finds a side of its own when none
--! is given.
function scribble_step (message, ref, note)
  te.scribble_at (ref)
  step_at (message, note_place (ref, note))
end
