--@ title:       First steps
--@ revision:    2
--@ subtitle:    A guided tour of the Light Tracer panels
--@ category:    Basics
--@ order:       10
--@ duration:    4:09
--@ description: A guided tour of the panels you use in every project: the
--@              scene tree, the environment, the material library and the
--@              render settings. Loads the built-in showcase scene so there
--@              is always something to explore.

-- A guided walk around the main panels. The lesson loads the built-in showcase
-- scene first so the tour always has something to look at, then drives the UI
-- and narrates each panel as it goes.

include ("assets/tutorial_common.lua")

-- Start from the built-in showcase so the tour always has content to show,
-- whatever the viewer had open. import_scene with no parent node clears the
-- current scene and replaces it - data/models/default.zip is the very scene
-- Light Tracer opens on a fresh launch.
lt.import_scene ("data/models/default.zip")
te.wait_for_seconds (0.5)

tutorial_begin ("Welcome to Light Tracer. In the next couple of minutes we will walk through the whole"
             .. " interface: the panels on the left and right, the tool rails around the viewport, and"
             .. " the menu behind the burger button. By the end you will know where everything lives.")

step ("Remember you can pause or stop any lesson from the controls in the"
           .. " top of the screen or directly on the text note like this one.", "center")

wait_step()

-- ---------------------------------------------------------------- scene tree
open_tab ("Scene Explorer")

scribble_step ("This is the Scene Explorer. Every model and material in your project shows up here,"
   .. " including the ones that are currently hidden, and selecting an object here is the same as"
   .. " clicking it in the viewport.", "Scene Explorer/")

te.checkpoint ("scene explorer", "window")
wait_step()

-- ----------------------------------------------------------------- viewport
step ("The viewport is a real path tracer, not a preview. ##1 Drag with the left mouse button to orbit,"
   .. " use the right button or the wheel to pan and zoom. ##2 Use the manipulator to move, scale or"
   .. " rotate the selected object: the image keeps refining while you work."
   .. " ##3 Note the thin green line on the top of the window. It shows the rendering progress or how many samples are computed.")

te.wait_for_marker (1)

te.viewport_drag ({ start = {0.47318, 0.52255}, delta = {-129.33, 8.00}, button = "left", duration = 1.33472, eye = {131.241287, -4.739657, 47.095200}, target = {0.626877, 0.391228, 1.714664}, up = {-0.327716, 0.012875, 0.944689} })

te.wait_for_seconds (0.8)

te.viewport_drag ({ start = {0.40859, 0.44192}, delta = {218.00, 82.67}, button = "left", duration = 1.40147, eye = {43.991776, -91.356148, 95.777138}, target = {0.626850, 0.391197, 1.714645}, up = {-0.290494, 0.614603, 0.733400} })

te.wait_for_marker (2)

te.select_at_screen_pos ({ at = {0.410, 0.459}, point = {-8.309765, 3.617455, -2.348602}, node = "square solitaire", append = false, right = false })
te.gizmo_drag ({ handle = "TrY", origin = {0.51219, 0.41883}, start = {-13.20, 21.89}, delta = {-0.06652, 0.10280}, duration = 0.82818, T = {-0.086937, -1.985778, 0.000000}, R = {0.000000, 0.000000, 0.000000}, S = {1.000000, 1.000000, 1.000000} })
te.gizmo_drag ({ handle = "RoY", origin = {0.47609, 0.51791}, start = {23.20, -100.20}, delta = {0.07256, 0.10355}, duration = 0.98366, T = {-0.086937, -1.985778, 0.000000}, R = {0.000000, 1.370874, 0.000000}, S = {1.000000, 1.000000, 1.000000} })
te.gizmo_drag ({ handle = "TrXY", origin = {0.47609, 0.51791}, start = {23.20, 51.80}, delta = {0.17687, -0.23205}, duration = 1.99006, T = {0.471035, 12.396050, 0.000000}, R = {0.000000, 1.370874, 0.000000}, S = {1.000000, 1.000000, 1.000000} })
te.item_click ("ToolContainer/Undo/#image/")
te.item_click ("ToolContainer/Undo/#image/")
te.item_click ("ToolContainer/Undo/#image/")
te.viewport_drag ({ start = {0.43958, 0.55933}, delta = {-46.00, -76.67}, button = "left", duration = 1.10577, eye = {81.072693, -100.829857, 50.995613}, target = {0.626839, 0.391197, 1.714664}, up = {-0.221595, 0.278825, 0.934426} })


te.checkpoint ("viewport after orbit and undo")
wait_step()

-- --------------------------------------------------------------- environment
open_tab ("Environment")

te.scribble_at ("Environment/")

step ("Lighting comes from the Environment tab. An HDRI map lights the whole scene at once, the"
   .. " backplate controls what you see behind the object, ##1 and from here you can also add and move"
   .. " individual light sources.", "top")

te.checkpoint ("environment panel", "window")
wait_step()

-- ------------------------------------------------------------------ properties

open_tab ("Properties")

te.scribble_at ("Properties/")

step ("The Properties tab on the right is where you shape a material. ##1 Select an object and this"
   .. " panel shows its ##2 colour, ##3 metalness, ##4 roughness, and every other material property.",
   "top")

te.item_click ("Scene Explorer/")

te.item_click ("Scene Explorer^/Content_ECC52E9C/^1/square solitaire/^14/Frame/##clickable_area/")

te.wait_for_marker (2)

te.move_to_item ("Properties/Base:##BaseColor/##TitleIconButton/")

te.wait_for_marker (3)

te.move_to_item ("Properties/Metalness:/")

te.wait_for_marker (4)

te.move_to_item ("Properties/Roughness:/")



te.checkpoint ("material properties", "window")
wait_step()

-- ------------------------------------------------------------------- library
open_tab ("Library")

te.scribble_at ("Library/")

step ("The Library holds ready-made presets. ##1 Materials and ##2 HDRI maps are here, as well as "
   .. " ##3 studio lights. Click or drag any preset to apply it.", "center")

te.item_click ("Library/Materials/")
te.wait_for_seconds (0.6)
te.item_click ("Library/HDRIs/")
te.wait_for_seconds (0.6)
te.item_click ("Library/Lights/")
te.wait_for_seconds (0.6)
te.item_click ("Library/Materials/")

te.checkpoint ("material library", "window")
wait_step()

-- ----------------------------------------------------------------- animation
open_tab ("Animation")

te.scribble_at ("Animation/")

step ("The Animation tab is where motion is set up. Spin the camera, move an object or rotate the environment,"
   .. " then play it back and arrange everything on the timeline.",
   "center")

te.checkpoint ("animation panel", "window")
wait_step()

-- ------------------------------------------------------------------ settings
open_tab ("Settings")

te.scribble_at ("Settings/")

step ("Everything that controls the render lives in the Settings tab: ##1 output resolution and ##2 render mode as well as the"
   .. " ##3 watermark and ##4 outline settings.", "center")

te.checkpoint ("render settings", "window")
wait_step()

-- --------------------------------------------------------------- widget rails

te.move_to_item ("LeftToolsContainer/##Layers/#image/")
te.point_at ("LeftToolsContainer/##Layers/#image/", "right")

step ("Around the viewport sit the tool rails. The left rail has ##1 layers widget, ##2 the 3D modeling toolbox,"
   .. " ##3 object position widget, ##4 physics simulation controls and ##5 the selection modes.")

te.wait_for_marker (1)
te.item_click ("LeftToolsContainer/##Layers/#image/")

te.wait_for_marker (2)
te.item_click ("LeftToolsContainer/##Model/#image/")

te.wait_for_marker (3)
te.item_click ("LeftToolsContainer/##Trfm/#image/")

te.wait_for_marker (4)
te.item_click ("LeftToolsContainer/##Physics/#image/")

te.wait_for_seconds(1)
te.item_click ("LeftToolsContainer/##Physics/#image/")

te.wait_for_marker (5)
te.move_to_item ("LeftToolsContainer/##Multiselect/#image/")

te.wait_for_seconds(1)
te.move_to_item ("LeftToolsContainer/##Rectselect/#image/")

te.checkpoint ("left tool rail", "window")
wait_step()

te.move_to_item("RightToolsContainer/##CameraWidget/#image/")
te.point_at ("RightToolsContainer/##CameraWidget/#image/", "left")
step ("The right rail carries: ##1 camera settings, ##2 bloom and glare, ##3 tone mapping,"
   .. " ##4 colour balance, ##5 AI denoising, and ##6 the shortcut for enabling real-time jewelry mode.")

te.wait_for_marker(1)
te.item_click ("RightToolsContainer/##CameraWidget/#image/")

te.wait_for_marker(2)
te.item_click ("RightToolsContainer/##BloomWidget/#image/")

te.wait_for_marker(3)
te.item_click ("RightToolsContainer/##TMWidget/#image/")

te.wait_for_marker(4)
te.item_click ("RightToolsContainer/##ColorBalanceWidget/#image/")

te.wait_for_marker(5)
te.item_click ("RightToolsContainer/##ColorBalanceWidget/#image/")
te.move_to_item ("RightToolsContainer/##Denoising/#image/")

te.wait_for_marker(6)
te.move_to_item ("RightToolsContainer/##RT/#image/")

te.checkpoint ("right tool rail", "window")
wait_step()

te.move_to_item("ToolContainer/Undo/#image/")
te.point_at ("ToolContainer/Undo/#image/", "bottom")
step ("Quick-access buttons sit along the top: ##1 undo and redo, ##2 reset camera, ##3 lock the viewport,"
   .. " ##4 save the render as an image or a video, ##5 hide the panels. As well as: ##6 toggle tiled rendering,"
   .. " ##7 subscription details, ##8 scene uploading and ##9 Help window. You can use help window to send any feedback you have.")

te.wait_for_marker(1)
te.move_to_item ("ToolContainer/Undo/#image/")

te.wait_for_seconds(1)
te.move_to_item ("ToolContainer/Redo/#image/")

te.wait_for_marker(2)
te.move_to_item ("ToolContainer/V/#image/")

te.wait_for_marker(3)
te.move_to_item ("ToolContainer/LockBtn/#image/")

te.wait_for_marker(4)
te.item_click ("ToolContainer/ImageExport/#image/")
te.wait_for_seconds(1)
te.item_click ("ToolContainer/VideoExport/#image/")

te.wait_for_marker(5)
te.item_click ("ToolContainer/UI/#image/")
te.wait_for_seconds(1)
te.item_click ("ToolContainer/UI/#image/")

te.wait_for_marker(6)
te.move_to_item ("ToolContainer/Tiles/#image/")

te.wait_for_marker(7)
te.move_to_item ("ToolContainer/Download/#image/")

te.wait_for_marker(8)
te.move_to_item ("ToolContainer/Publish/#image/")

te.wait_for_marker(9)
te.item_click ("ToolContainer/Help/#image/")
te.wait_for_seconds(1)

te.checkpoint ("help window", "window")
wait_step()

-- --------------------------------------------------------------- burger menu
te.item_click("TitleBarWindow/MainMenu/")
te.point_at ("TitleBarWindow/MainMenu/", "bottom")
step ("Finally, the burger menu in the top-left corner. It ##1 opens and saves scenes, ##2 exports"
   .. " renders and ##3 models. ##4 App settings can be accessed from here as well."
   .. " ##5 Nearby you can find the rendering pass selector and ##6 the Noise control."
   .. " It decides how clean the final image is: the render stops once the noise falls under it, or at the Samples cap next to it.",
   "center")

te.wait_for_marker(1)
te.move_to_item ("##Popup_79f741d8/Open/")

te.wait_for_seconds(1.0)
te.move_to_item ("##Popup_79f741d8/Save/")

te.wait_for_marker(2)
te.move_to_item ("##Popup_79f741d8/Render scene/")

te.wait_for_marker(3)
te.move_to_item ("##Popup_79f741d8/Export to OBJ/")

te.wait_for_marker(4)
te.move_to_item ("##Popup_79f741d8/Settings/")

te.wait_for_marker(5)
te.item_click ("TitleBarWindow/##Pass/")

te.wait_for_marker(6)
te.item_click ("TitleBarWindow/Noise:/")

te.checkpoint ("noise control", "window")
wait_step()

-- --------------------------------------------------------------------- outro
open_tab ("Tutorials")

-- The picture this lesson is listed by. Ignored while a viewer plays it;
-- a bookkeeping run is what turns it into the thumbnail.
te.capture_thumbnail()

tutorial_end ("That is the whole tour. Pick another lesson in the Tutorials tab whenever you want to go deeper.")











