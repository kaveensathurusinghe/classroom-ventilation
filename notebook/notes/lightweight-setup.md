# Lightweight notebook setup

The earlier owner-executed Colab notebook spent over ten minutes in its setup cell. The output showed 131 packages precompiled, followed by repeated compilation of the project, Plots and notebook extensions against already-loaded dependency versions. A completed older run did not establish the approximate ten-minute total execution target.

The revised notebook removes Plots and its native graphics dependency tree. `notebook/svg-plots.jl` is a small Julia SVG renderer embedded in the notebook, with line, scatter and ECDF plots, log axes, reference lines/bands, legends and panel layouts. Charts are generated from the current run's actual arrays. No frozen plot substitutes for execution. Exports are SVG; the earlier retained PNGs remain previous exports of the same scientific results.

Project.toml no longer depends on Plots. Manifest.toml retains pinned versions for the smaller dependency closure, including resolvable weak dependencies. The project wrapper opts out of its own compiled cache; physical functions and tests are unchanged. The setup disables automatic Pkg precompilation, but packages may still compile when loaded. It does not disable validation, reduce the scenario count, loosen numerical tolerances or skip installation by default. JSON and Statistics loaded versions are printed because notebook kernels may preload packages.

`SETUP_SECONDS` starts at the top of the first cell. `TOTAL_NOTEBOOK_SECONDS` is printed after the final exports. Run all on a fresh free-tier Julia Colab session to measure the target. Reusing an already-loaded session, skipping installation or comparing Windows warm timings with Linux fresh timings cannot establish the target. The shared Drive notebook must be updated explicitly; repository edits alone do not update it.

Verification and actual local timing are recorded in `../VERIFICATION.md`. Fresh Colab execution of the revised notebook remains pending. The model's air-only thermal and nonsmooth stack-flow limitations remain unchanged.
