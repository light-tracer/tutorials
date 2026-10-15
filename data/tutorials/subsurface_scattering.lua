--@ title:       Subsurface scattering
--@ subtitle:    Give wax and soft plastics a glow
--@ category:    Advanced
--@ order:       100
--@ duration:    1:40
--@ description: Compare an opaque surface with a waxy material, enable solid
--@              subsurface scattering and tune its weight and scatter radius.

include ("assets/tutorial_common.lua")

lt.import_scene ("data/tutorials/assets/sss_samples.glb")
te.wait_loads_complete (60)
lt.set_environment ({ type = lt.ENV_BLACK })
lt.set_environment_color (0, lt.ENV_COLOR_UPPER, {0.3, 0.3, 0.3})
lt.set_environment_color (0, lt.ENV_COLOR_LOWER, {0.1, 0.1, 0.1})
lt.find_by_name ("Softbox"):set_camera_visibility (lt.HIDDEN)
lt.set_camera_look_at ({0, -13, 6.5}, {0, 0, 1.6})
lt.set_camera_fov_y (math.rad (32))
lt.set_target_spp (256)

local wax = assert (lt.find_by_name ("Wax sample"))
lt.select_node (wax)
open_tab ("Properties")

tutorial_begin ("Subsurface scattering is light entering a material, bouncing inside"
             .. " and coming out again. It gives wax and some plastics their soft glow."
             .. " These two samples start with the same opaque material; we will change the one on the right.")

point_step ("##1 Add the Subsurface layer to the Standard material. ##2 Keep Solid"
         .. " selected: this sample is a closed object with real thickness.",
            "Properties/Subsurface/add", "right")
te.wait_for_marker (1)
te.item_click ("Properties/Subsurface/add")
te.wait_for_marker (2)
te.item_click ("Properties/Solid##Subsurface")
te.item_input_value_float ("Properties/Scatter radius:##Subsurface", 2.0)
wait_step()
te.clear_attention()

step_at ("Weight blends surface diffuse shading with scattering inside the body."
      .. " ##1 At zero, the sample is opaque again. ##2 At one, notice the light"
      .. " coming through the thin edges. The sample on the left stays unchanged.",
         "Properties/Weight:##Subsurface", "left")
te.wait_for_marker (1)
te.item_input_value_float ("Properties/Weight:##Subsurface", 0.0)
te.checkpoint ("opaque reference")
te.wait_for_marker (2)
te.item_input_value_float ("Properties/Weight:##Subsurface", 1.0)
te.checkpoint ("scattering enabled")
wait_step()

step_at ("Scatter radius sets how far light travels inside, in millimeters."
      .. " ##1 At half a millimeter, light stays near the surface. ##2 At four"
      .. " millimeters, it reaches farther through the sample. Object size matters:"
      .. " the same radius has a stronger effect on a thinner object.",
         "Properties/Scatter radius:##Subsurface", "left")
te.wait_for_marker (1)
te.item_input_value_float ("Properties/Scatter radius:##Subsurface", 0.5)
te.checkpoint ("short scatter radius")
te.wait_for_marker (2)
te.item_input_value_float ("Properties/Scatter radius:##Subsurface", 4.0)
te.checkpoint ("long scatter radius")
wait_step()

step_at ("##1 Settle on two millimeters for this small wax sample. Base color"
      .. " gives it its surface color; Interior color can let some colors travel"
      .. " deeper than others. Start with the radius, and keep that extra tint subtle.",
         "Properties/Scatter radius:##Subsurface", "left")
te.wait_for_marker (1)
te.item_input_value_float ("Properties/Scatter radius:##Subsurface", 2.0)
wait_step()
te.clear_note()
lt.clear_selection()
te.capture_thumbnail()

tutorial_end ("For a waxy material, use a nonmetallic Standard surface, add Subsurface,"
           .. " and match the scatter radius to the object's thickness. Lighting from"
           .. " behind or the side makes the difference easiest to see.")
