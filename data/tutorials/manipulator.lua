--@ title:       Moving objects
--@ revision:    2
--@ subtitle:    Move, rotate, scale and duplicate
--@ category:    Basics
--@ order:       20
--@ duration:    3:04
--@ description: The manipulator widget: scaling on the central sphere,
--@              precise numeric entry, duplicating with Shift+D, rotating in
--@              local space with Q, and multi-select duplication to arrange a
--@              scene.


include ("assets/tutorial_common.lua")

lt.import_scene ("data/models/default.zip")
te.wait_for_seconds (0.5)

-- filter the default scene
lt.find_by_name ("square solitaire"):delete()
-- lt.find_by_name ("Scene floor"):delete()

te.show_note ("In this lesson we work with the manipulator: the one widget that combines all three"
             .. " transforms: translate, rotate and scale. Select an object and the gizmo appears right"
             .. " on top of it in the viewport.", "center")

te.do_camera_transition_to ({ eye = {105.607048, -43.094440, 80.696075}, target = {0.638237, 0.372276, 1.714592}, up = {-0.527377, 0.218384, 0.821086} })
te.wait_for_seconds (0.5)


te.item_click ("RightGrabContainer/##RightGrab/")
te.item_click ("LeftGrabContainer/##LeftGrab/")

te.wait_for_note()

--------------------------------------------------------------- the manipulator
-- Enter object-manipulation mode so the gizmo is shown for the selection.

te.select_at_screen_pos (0.497, 0.400, false)


step ("Selecting any object shows the"
   .. " gizmo: colored arrows to move, rings to rotate and handles to scale, all in one place. ##1 The manipulator window lives on the left tool rail.",
   "bottom")

te.wait_for_marker(1)

te.item_click ("LeftToolsContainer/##Trfm/#image/")

te.checkpoint ("manipulator window", "window")
wait_step()

---------------------------------------------------------------
step ("To change object position drag the arrows or circles to move an object along one axis or in plane respectively.", "bottom")

te.item_click ("Transform/Translate/")
te.item_click ("Transform/Space/World/")


te.gizmo_drag ({ origin = {0.53790, 0.45158}, start = {-65.71, 18.44}, delta = {-0.08126, 0.04587}, duration = 1.80000 })
te.wait_for_seconds (0.5)

te.gizmo_drag ({ origin = {0.49382, 0.47186}, start = {-41.92, -28.03}, delta = {0.15596, -0.05898}, duration = 2.80730 })
te.checkpoint ("translated ring", "window")

te.wait_for_seconds (0.5)

te.item_click ("ToolContainer/Undo/#image/")
te.item_click ("ToolContainer/Undo/#image/")


wait_step()

----------------------------------------------------------------- uniform scale
step ("To scale an object proportionally, drag the white sphere at the centre of the gizmo. Every axis"
   .. " scales together, so the shape keeps its proportions.", "bottom")

te.item_click ("Transform/Scale/")

te.gizmo_drag ({ origin = {0.49396, 0.47172}, start = {-1.12, 3.08}, delta = {-0.04325, -0.00131}, duration = 2.58324 })
te.wait_for_seconds (0.5)

te.gizmo_drag ({ origin = {0.49401, 0.47165}, start = {-1.20, 0.13}, delta = {0.03408, -0.00393}, duration = 1.96609 })
te.checkpoint ("uniform scale", "window")
te.wait_for_seconds (0.5)

te.item_click ("ToolContainer/Undo/#image/")
te.item_click ("ToolContainer/Undo/#image/")

wait_step()

--------------------------------------------------------------- numeric entry
step_at ("When you have a specific size in mind, ##1 type the value into the manipulator window instead of"
   .. " dragging. ##2 Also you can drag the colored sphere for per-axis scale.", "Transform/##PivotRAdvanced/##btn/", "bottom")

te.item_click ("Transform/Scale/")

te.wait_for_marker (1)
te.item_input_text ("Transform/ ##ScaleX/", "0.5")
te.checkpoint ("numeric scale", "window")

te.wait_for_seconds (0.5)
te.item_click ("ToolContainer/Undo/#image/")

te.wait_for_marker (2) -- TODO
te.gizmo_drag ({ handle = "ScY", origin = {0.54253, 0.44973}, start = {-146.87, 33.00}, delta = {-0.06652, 0.01058}, duration = 1.39931, T = {-0.086937, 3.943082, 0.000000}, R = {0.000000, 0.000000, 0.000000}, S = {1.000000, 1.581576, 1.000000} })
te.checkpoint ("per-axis scale", "window")
te.wait_for_seconds (0.5)

te.item_click ("ToolContainer/Undo/#image/")


wait_step()



---------------------------------------------------------------
step_at ("Same goes for rotation. Drag the arcs or set specific values into the fields.", "Transform/##PivotRAdvanced/##btn/", "bottom")

te.item_click ("Transform/Rotate/")

te.gizmo_drag ({ handle = "RoX", origin = {0.54253, 0.44973}, start = {-56.87, -99.00}, delta = {-0.07559, 0.07256}, duration = 1.19928, T = {-0.086937, 3.943082, 0.000000}, R = {0.859536, 0.000000, 0.000000}, S = {1.000000, 1.000000, 1.000000} })
te.wait_for_seconds (0.5)

te.gizmo_drag ({ handle = "RoZ", origin = {0.54249, 0.44987}, start = {-102.78, 61.82}, delta = {0.13001, 0.02268}, duration = 1.50213, T = {-0.086937, 3.943082, 0.000000}, R = {0.859536, 0.000000, 1.141671}, S = {1.000000, 1.000000, 1.000000} })
te.checkpoint ("rotated ring", "window")
te.wait_for_seconds (0.5)

te.item_click ("ToolContainer/Undo/#image/")
te.item_click ("ToolContainer/Undo/#image/")

wait_step()

--------------------------------------------------------------- 
step_at ("When rotating it's often useful to ##1 toggle a snapping step so you can use the manipulator"
   .. " for setting precise values. ##2 Here you can also toggle Local mode to show the axes in local frame.",
   "Transform/##PivotRAdvanced/##btn/", "bottom")


te.wait_for_marker (1)
te.item_click ("Transform/Step:/##flag/")

te.gizmo_drag ({ handle = "RoX", origin = {0.54246, 0.44964}, start = {-45.69, -109.88}, delta = {-0.11640, 0.04611}, duration = 1.98160, T = {-0.086937, 3.943082, -0.000000}, R = {0.785398, 0.000000, 0.000000}, S = {1.000000, 1.000000, 1.000000} })

te.wait_for_marker (2)
te.item_click ("Transform/Space/Local/")
te.checkpoint ("snapped rotation in local space", "window")
te.wait_for_seconds (1.5)

te.item_click ("ToolContainer/Undo/#image/")

wait_step()

te.wait_for_seconds (0.5)

----------------------------------------------------------------- duplicate + move
step ("Now let's place a second ring. Duplicate the selected one with Shift+D: the copy lands exactly in the same place"
   .. " so we should move it to see it.", "bottom")

te.wait_for_seconds (0.5)

te.key_press (68, 1) -- Shift+D
te.gizmo_drag ({ handle = "TrY", origin = {0.54241, 0.44962}, start = {-103.56, 18.15}, delta = {0.16704, -0.03250}, duration = 1.05202, T = {-0.086937, 10.585595, 0.000000}, R = {0.000000, 0.000000, 0.000000}, S = {1.000000, 1.000000, 1.000000} })

te.item_click ("LeftToolsContainer/##Trfm/#image/")
te.item_click ("LeftGrabContainer/##LeftGrab/")

-- The new object shows up straight away in the Scene Explorer.
open_tab ("Scene Explorer")

te.checkpoint ("duplicate in scene explorer", "window")
wait_step()

step ("The duplicate appears immediately in the Scene Explorer, right next to the original, so you"
   .. " can always see and rename what you have added.", "bottom")

te.item_click ("Scene Explorer/Collapse/#image/")

te.item_click ("Scene Explorer^/Content_ECC52E9C/^1/square solitaire - 1/##clickable_area/", 1)
te.item_click ("##Popup_db6eb242/Rename/")
te.item_input_text ("##Popup_bee3dee3/##Name/", "Ring 2")


te.checkpoint ("renamed duplicate", "window")
wait_step()

--------------------------------------------------------------- rotate + local space
step ("Let's use the 3D manipulator widget to place the second ring.", "bottom")

te.item_click ("LeftGrabContainer/##LeftGrab/")

te.select_at_screen_pos ({ at = {0.596, 0.240}, point = {-4.100174, 9.810848, 7.948540}, node = "Ring 2", append = false, right = false })
te.gizmo_drag ({ handle = "TrY", origin = {0.62688, 0.41153}, start = {-33.82, 11.54}, delta = {-0.17385, 0.05669}, duration = 0.5, T = {-0.086937, 3.441298, 0.000000}, R = {0.000000, 0.000000, 0.000000}, S = {1.000000, 1.000000, 1.000000} })
te.gizmo_drag ({ handle = "RoX", origin = {0.53599, 0.45262}, start = {-110.14, -46.81}, delta = {0.09675, 0.00000}, duration = 0.5, T = {-0.086937, 3.441298, 0.000000}, R = {-1.308997, 0.000000, 0.000000}, S = {1.000000, 1.000000, 1.000000} })
te.gizmo_drag ({ handle = "TrY", origin = {0.53599, 0.45262}, start = {-48.14, -142.81}, delta = {0.03628, 0.15193}, duration = 0.5, T = {-0.086937, 5.306047, -6.959337}, R = {-1.308997, 0.000000, 0.000000}, S = {1.000000, 1.000000, 1.000000} })
te.gizmo_drag ({ handle = "TrXZ", origin = {0.55834, 0.59410}, start = {-21.34, 51.00}, delta = {0.00983, -0.00151}, duration = 0.5, T = {0.075195, 5.636030, -6.870927}, R = {-1.308997, 0.000000, 0.000000}, S = {1.000000, 1.000000, 1.000000} })
te.gizmo_drag ({ handle = "TrY", origin = {0.56337, 0.59259}, start = {-41.22, -135.99}, delta = {0.00983, 0.03401}, duration = 0.5, T = {0.075195, 6.078946, -8.523911}, R = {-1.308997, 0.000000, 0.000000}, S = {1.000000, 1.000000, 1.000000} })

te.checkpoint ("ring placed above floor")
wait_step()

---------------------------------------------------------------
step ("It can be hard to place the ring on the floor precisely, so let's use built-in simulation engine to do it."
.. "We will discuss the Physics window in detail in dedicated tutorial.", "bottom")

te.item_click ("LeftToolsContainer/##Physics/#image/")
te.item_click ("Physics/Dynamic/")
te.item_click ("Physics/^b239^b135^b152 Run/")
te.mouse_move_screen (0.260, 0.018)
te.deselect()
te.wait_for_seconds (3.0)
te.item_click ("Physics/^b239^b129^b129 Stop simulation/")
te.item_click ("LeftToolsContainer/##Physics/#image/")

te.checkpoint ("ring settled on floor")
wait_step()

te.capture_thumbnail()

---------------------------------------------------------------
step ("Finally, you can select multiple objects using this button or with Control key held while clicking.", "bottom")

te.item_click ("LeftToolsContainer/##Multiselect/#image/")
te.select_at_screen_pos ({ at = {0.502, 0.497}, point = {-7.484818, 3.880482, -4.291306}, node = "square solitaire", append = true, right = false })
te.select_at_screen_pos ({ at = {0.438, 0.617}, point = {-5.918869, -1.927723, -7.403198}, node = "Ring 2", append = true, right = false })
te.item_click ("LeftToolsContainer/##Multiselect/#image/")

te.checkpoint ("multiple rings selected", "window")
wait_step()

-- TODO: advanced tutorial with rotating manipulator with held alt

te.item_click ("RightGrabContainer/##RightGrab/")

te.item_click ("LeftGrabContainer/##LeftGrab/")

----------------------------------------------------------------------- outro
open_tab ("Tutorials")


tutorial_end ("That's how you move objects in Light Tracer: one 3D widget for moving, rotating and scaling. Use Shift+D to"
           .. " duplicate objects and Ctrl-click to select several objects at once. Together these tools will help to setup your scene quickly.")











