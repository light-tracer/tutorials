--@ title:       Noise, samples and denoising
--@ subtitle:    Balance render time, detail and image cleanup
--@ category:    Basics
--@ order:       150
--@ duration:    3:45
--@ description: Compare a samples cap with adaptive Noise threshold, learn
--@              how to fix blocky dark areas, and enable the AI denoiser.

-- Adapted from https://www.youtube.com/watch?v=UIXXKg-Zeqk . The video
-- demonstrates denoising at high and low sample counts; the current title
-- bar also has a Noise threshold, so this lesson explains both stop rules.

include ("assets/tutorial_common.lua")

local NOISE = "TitleBarWindow/Noise:/"
local SAMPLES = "TitleBarWindow/Samples:/"
local DENOISER = "RightToolsContainer/##Denoising/#image/"

lt.import_scene ("data/models/default.zip")
te.wait_loads_complete (60)

te.item_click ("LeftGrabContainer/##LeftGrab/")
te.item_click ("RightGrabContainer/##RightGrab/")
te.wait_for_seconds (0.6)

tutorial_begin ("A path-traced image grows cleaner as it collects samples."
             .. " Let's use the two controls in the title bar to decide when"
             .. " to stop, then try the denoiser as a finishing tool.")

point_step ("##1 Set Samples to 30 for a quick baseline. This is the upper"
         .. " limit per pixel: the render finishes quickly, but grain remains"
         .. " in the gems and shadows. More samples usually improve those"
         .. " details at the cost of render time.", SAMPLES, "left", "bottom")
te.wait_for_marker (1)
te.item_input_value_int (SAMPLES, 30)
te.reset_sample_counter()
te.checkpoint ("30 fixed samples", "window")
wait_step()
te.clear_attention()

point_step ("##1 Noise is a second stopping rule. At zero, adaptive sampling"
         .. " is off: every pixel is sampled up to the Samples cap. A noise"
         .. " percentage is a target for estimated residual noise, not the"
         .. " share of noisy pixels. It lets the renderer stop early while"
         .. " concentrating work on noisier areas.",
            NOISE, "left", "bottom")
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

point_step ("##1 Open the right panel to inspect where adaptive sampling"
         .. " is still working.", "RightGrabContainer/##RightGrab/", "left",
            "bottom")
te.wait_for_marker (1)
te.item_click ("RightGrabContainer/##RightGrab/")
open_tab ("Settings")
wait_step()
te.clear_attention()

step_at ("##1 Open Advanced under Sampling, then ##2 switch to Noise map."
      .. " It colors 8-by-8 pixel blocks relative to the Noise target: green"
      .. " has met it, while red is still noisy. Stronger tint marks blocks"
      .. " that are still being sampled.", "Settings/##Advanced/##btn/", "left")
te.wait_for_marker (1)
te.item_click ("Settings/##Advanced/##btn/")
te.wait_until_available ("Settings/NoiseMap/Noise map/", 5)
te.wait_for_marker (2)
te.item_click ("Settings/NoiseMap/Noise map/")
te.wait_for_seconds (0.7)
te.checkpoint ("adaptive noise map", "window")
wait_step()

step_at ("##1 Switch back to Rendered image to judge the actual result."
      .. " The noise map is only a diagnostic view, not part of the render.",
         "Settings/NoiseMap/Rendered image/", "left")
te.wait_for_marker (1)
te.item_click ("Settings/NoiseMap/Rendered image/")
te.item_click ("RightGrabContainer/##RightGrab/")
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

point_step ("##1 Enable the denoiser on the right tool rail. Compare the"
         .. " ring and its shadow before and after the remaining grain"
         .. " is smoothed.",
            DENOISER, "right", "left")
te.wait_for_marker (1)
te.item_click (DENOISER)
te.wait_for_seconds (1.5)
te.checkpoint ("high-sample render with denoising", "window")
wait_step()
te.clear_attention()

step_at ("Before committing to a full-quality video, make a fast draft to"
      .. " check the camera and motion. ##1 Cap each frame at 30 samples. The denoiser"
      .. " stays on to clean up that quick preview.", NOISE, "bottom")
te.wait_for_marker (1)
te.item_input_value_int (SAMPLES, 30)
te.reset_sample_counter()
te.wait_for_seconds (0.7)
te.checkpoint ("30-sample denoised draft", "window")
wait_step()

te.capture_thumbnail()

tutorial_end ("In Path Tracing, Noise and Samples are two stop conditions:"
           .. " the first one reached ends the render. Lower Noise if dark"
           .. " blocks remain, and raise Samples if you hit the cap first."
           .. " Use denoising for a fast draft or a final polish, then give"
           .. " the full-quality render enough samples to preserve detail.")
