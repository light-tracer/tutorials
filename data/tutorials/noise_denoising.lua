--@ title:       Noise, samples and denoising
--@ revision:    2
--@ subtitle:    Balance render time, detail and image cleanup
--@ category:    Basics
--@ order:       150
--@ duration:    3:45
--@ description: Compare the Samples limit with the adaptive Noise threshold, learn
--@              how to fix blocky dark areas, and enable the AI denoiser.

include ("assets/tutorial_common.lua")

local NOISE = "TitleBarWindow/Noise:/"
local SAMPLES = "TitleBarWindow/Samples:/"
local DENOISER = "RightToolsContainer/##Denoising/#image/"

lt.import_scene ("data/tutorials/assets/sss_samples.zip")
te.wait_loads_complete (60)
lt.set_target_spp (512)
lt.set_param ("NoiseLevel", 0.0)

local function setup_candy (name, base_color, interior_color)
  local candy = assert (lt.find_by_name (name))
  lt.unlink_material (candy)
  lt.set_material_value (candy, lt.SUBSURFACE_WEIGHT, 1.0)
  -- This scene uses centimeters: 6.457 mm is 0.6457 scene units.
  lt.set_material_value (candy, lt.SUBSURFACE_RADIUS, 0.6457)
  lt.set_material_color (candy, lt.BASE_COLOR, base_color)
  lt.set_material_color (candy, lt.SUBSURFACE_RADIUS_TINT, interior_color)
end

-- Interior colors are linear RGB. The yellow matches sRGB (255, 196, 25),
-- with the blue channel clamped to the material's minimum of 0.01.
setup_candy ("Candy sample", { 0.8, 0.39, 0.12 }, { 1.0, 0.5520114, 0.01 })
setup_candy ("Opaque reference", { 0.12, 0.39, 0.8 }, { 0.01, 0.5520114, 1.0 })

te.item_click ("LeftGrabContainer/##LeftGrab/")
te.item_click ("RightGrabContainer/##RightGrab/")

tutorial_begin ("A path-traced image grows cleaner as it collects samples."
             .. " Let's use the two controls in the title bar to decide when"
             .. " to stop, then try the denoiser as a finishing tool.")

point_step ("##1 Set Samples to 30 for a quick baseline. This limits each"
         .. " pixel to 30 samples. The render finishes quickly, but grain remains"
         .. " on the candy cubes and in the shadows. More samples usually reduce"
         .. " the grain, but take longer to render.", SAMPLES, "bottom", "bottom")
te.wait_for_marker (1)
te.item_input_value_int (SAMPLES, 30)
te.reset_sample_counter()
te.checkpoint ("30 fixed samples", "window")
wait_step()
te.clear_attention()

te.move_to_item (NOISE)
point_step ("##1 Noise is a second stopping rule. At zero, adaptive sampling"
         .. " is off, so every pixel gets the full sample count. The percentage"
         .. " sets a target for the noise left in the image. It does not tell"
         .. " you how many pixels are noisy. Adaptive sampling spends more time"
         .. " on noisy areas and lets cleaner areas stop early.",
            NOISE, "bottom", "bottom")
te.wait_for_marker (1)
wait_step()
te.clear_attention()

step_at ("##1 Set Noise to 5%, a loose target. ##2 Raise Samples to 1000"
      .. " to give difficult areas room to improve. The render may stop"
      .. " before that cap if it meets the noise target; 1000 is a limit,"
      .. " not a promise that every pixel gets 1000 samples.", NOISE, "bottom")
te.wait_for_marker (1)
te.item_input_value_float (NOISE, 5.0)
te.wait_for_marker (2)
te.item_input_value_int (SAMPLES, 1000)
te.reset_sample_counter()
te.wait_for_seconds (0.7)
te.checkpoint ("loose noise threshold", "window")
wait_step()

step_at ("##1 Lower Noise to 0.5% while keeping the 1000-sample cap."
      .. " This is a stricter target, so the renderer spends more time"
      .. " on difficult parts of the image. Watch how much longer it takes"
      .. " and compare the remaining noise in the shadows.", NOISE, "bottom")
te.wait_for_marker (1)
te.item_input_value_float (NOISE, 0.5)
te.reset_sample_counter()
te.wait_for_seconds (0.7)
te.checkpoint ("stricter noise threshold", "window")
wait_step()

step_at ("If you see blocky image artifacts in dark areas, try lowering"
      .. " Noise first: for example, from 2% to 0.5%. Adaptive sampling"
      .. " works in patches, and a loose threshold can leave a dark patch"
      .. " under-sampled. If the image is still noisy at the Samples cap,"
      .. " raise that cap as well.", NOISE, "bottom")
wait_step()

step_at ("The AI denoiser is an image filter that estimates a cleaner result"
      .. " from a noisy render. It can polish a final image or make a quick"
      .. " preview usable, but it cannot restore detail that was never"
      .. " sampled.", DENOISER, "left")
wait_step()

point_step ("##1 Enable the denoiser on the right tool rail. Watch it smooth"
         .. " the remaining grain on the candy cubes and in their shadows.",
            DENOISER, "right", "left")
te.wait_for_marker (1)
te.item_click (DENOISER)
te.wait_for_seconds (1.5)
te.checkpoint ("high-sample render with denoising", "window")
wait_step()
te.clear_attention()

step_at ("Before committing to a full-quality video, make a fast draft to"
      .. " check the camera and motion. ##1 Cap each frame at 30 samples. The denoiser"
      .. " stays on to clean up that quick preview.", SAMPLES, "bottom")
te.wait_for_marker (1)
te.item_input_value_int (SAMPLES, 30)
te.reset_sample_counter()
te.wait_for_seconds (0.7)
te.checkpoint ("30-sample denoised draft", "window")
wait_step()

te.capture_thumbnail()

te.item_click ("RightGrabContainer/##RightGrab/")
te.item_click ("LeftGrabContainer/##LeftGrab/")
te.item_click ("Tutorials/")

tutorial_end ("The Samples setting limits how many samples the renderer takes."
           .. " Noise lets it stop early when the image is clean enough."
           .. " Lower Noise if you see dark blocks. Raise Samples if the render"
           .. " reaches the limit and still looks noisy. Use the denoiser to"
           .. " clean up a quick draft or a final image.")
