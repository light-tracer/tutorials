--@ title:       Subsurface scattering
--@ revision:    2
--@ subtitle:    Give candy, wax and soft plastics a glow
--@ category:    Advanced
--@ order:       100
--@ duration:    1:40
--@ description: Compare an opaque candy cube with a translucent one, enable solid
--@              subsurface scattering and tune its weight and scatter radius.

include ("assets/tutorial_common.lua")

lt.import_scene ("data/tutorials/assets/sss_samples.zip")
te.wait_loads_complete (60)
lt.set_target_spp (512)

local candy = assert (lt.find_by_name ("Candy sample"))
lt.select_node (candy)
open_tab ("Properties")

tutorial_begin ("Subsurface scattering is light entering a material, bouncing inside"
             .. " and coming out again. It gives hard candy, wax and some plastics their soft glow."
             .. " These two candy cubes start with the same opaque material; we will change the one on the right.")

point_step ("##1 Add the Subsurface layer to the Standard material. ##2 Keep Solid"
         .. " selected: this candy is a closed object with real thickness.",
            "Properties/Subsurface/add", "left")
te.wait_for_marker (1)
te.item_click ("Properties/Subsurface/add")
te.wait_for_marker (2)
te.item_click ("Properties/Solid##Subsurface")
te.item_input_value_float ("Properties/Scatter radius:##Subsurface", 6.457)
te.item_click ("Properties/Interior color:##Subsurface/##TitleIconButton/")
te.item_click ("##Popup_f98ad4b5/Spectrum/")
te.item_input_text ("##Popup_f98ad4b5/R:/", "255")
te.item_input_text ("##Popup_f98ad4b5/G:/", "196")
te.item_input_text ("##Popup_f98ad4b5/B:/", "25")
wait_step()
te.clear_attention()

step_at ("Weight blends surface diffuse shading with scattering inside the body."
      .. " ##1 At zero, the cube is opaque again. ##2 At one, notice the light"
      .. " coming through its rounded edges and corners. The cube on the left stays unchanged.",
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
      .. " millimeters, it reaches farther through the cube. Object size matters:"
      .. " the same radius has a stronger effect on a smaller object.",
         "Properties/Scatter radius:##Subsurface", "left")
te.wait_for_marker (1)
te.item_input_value_float ("Properties/Scatter radius:##Subsurface", 0.5)
te.checkpoint ("short scatter radius")
te.wait_for_marker (2)
te.item_input_value_float ("Properties/Scatter radius:##Subsurface", 4.0)
te.checkpoint ("long scatter radius")
wait_step()

step_at ("##1 Settle on six millimeters for this candy. Base color"
      .. " gives it its surface color; Interior color can let some colors travel"
      .. " deeper than others. Start with the radius, and keep that extra tint subtle.",
         "Properties/Scatter radius:##Subsurface", "left")
te.wait_for_marker (1)
te.item_input_value_float ("Properties/Scatter radius:##Subsurface", 6.0)
wait_step()
te.clear_note()
lt.clear_selection()
te.capture_thumbnail()

tutorial_end ("For candy or wax, use a nonmetallic Standard surface, add Subsurface,"
           .. " and match the scatter radius to the object's thickness. Lighting from"
           .. " behind or the side makes the difference easiest to see.")
