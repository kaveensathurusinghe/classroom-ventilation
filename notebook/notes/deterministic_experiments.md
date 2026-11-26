> Inherited development note. Stage descriptions and earlier run claims are historical; see VERIFICATION.md for rebuild execution.

# Deterministic strategy comparison: stage 4

This is a reproducible baseline experiment under assumed constant conditions.
It is not based on measured classroom data or downloaded weather and does not
establish an optimum across uncertain conditions.

## Reproduce

From the repository root:

```powershell
julia --startup-file=no --project=. -e 'using Pkg; Pkg.instantiate()'
julia --startup-file=no --project=. -e 'using Pkg; Pkg.test()'
julia --startup-file=no --project=. experiments/run_deterministic.jl
```

The runner activates its project relative to its own location, uses headless
Plots.jl/GR, and overwrites its own named baseline output files on reruns.
Initial plotting setup downloads backend binaries and precompiles packages.
Plots is used only by the experiment runner; the model and tests do not load it.
Plot export follows the [Plots.jl documentation](https://docs.juliaplots.org/latest/tutorial/).

## Experimental design

All three strategies receive exactly the same constant inputs and initial state:

- Room volume 179.2 m³, 35 occupants, duration 2 hours.
- Initial CO₂ 450 ppm and temperature 28°C.
- Outdoor CO₂ 420 ppm, temperature 29°C and local wind 2 m/s.
- Opening fractions 0, 0.5 and 1; default full opening area 2 m².
- All remaining coefficients from the [physical model register](physical_model.md).
- Manual RK4 with a 1/240-hour (15-second) step; refinement at 7.5 seconds.
- CO₂ comparison threshold 1000 ppm and illustrative temperature band 24–30°C.

ACH is recalculated from the current indoor temperature at every RK4 stage.
Only opening fraction changes between strategies. Weather and occupancy are
held fixed; no random sampling occurs and no seed is required. The public
`simulate_fixed_strategies` function accepts alternative parameters without
plotting or writing files, for later scenario and uncertainty work.

## Metric definitions

Peaks and minima are taken over saved trajectory samples, including the initial
and final states. They are not continuous-time extrema searches. Duration above
1000 ppm uses strict `C > 1000`; time outside the band uses `T < 24` or `T > 30`.
Equality is inside the selected limit. Units in the reusable metric API are
hours; summary tables report minutes.

For a crossing between two samples, the crossing time is linearly interpolated
and only the exceeding fraction of that interval is counted. This works on
nonuniform grids, including a shortened final step. The lower and upper band
durations are calculated separately and summed, so a segment crossing both
limits is handled correctly. Unobserved excursions between samples can still be
missed; refinement is required rather than assuming exact event detection.

## Results

The executed nominal simulation on Julia 1.12.7 produced the following rounded
values. Both endpoints of the temperature band are illustrative, not regulatory
criteria or a full thermal-comfort assessment.

| Strategy | Peak CO₂ (ppm) | Minutes above 1000 ppm | Peak temperature (°C) | Minutes outside 24–30°C |
| --- | ---: | ---: | ---: | ---: |
| Closed | 5723.83 | 110.36 | 54.72 | 117.25 |
| Partial (50%) | 681.38 | 0.00 | 31.96 | 117.15 |
| Full (100%) | 557.13 | 0.00 | 30.62 | 116.82 |

All outside-band time here is above 30°C. Under these assumptions, opening the
windows substantially reduces CO₂ and peak temperature. Neither open-window
strategy keeps temperature within the selected band throughout the lecture.
The duration metric alone hides substantial differences in the magnitude of
temperature exceedance, so inspect peaks and trajectories together.

The very high closed-window temperature is an outcome of the assumed heat
gains, weak ventilation and simplified air-only heat storage/envelope model.
It is not evidence that a real classroom reaches this temperature. Refining the
time step does not fix missing physics or uncalibrated coefficients. These
results do not justify a general recommendation that fully open windows are
optimal in all weather conditions.

## Verification and outputs

The expanded test suite passes 240 checks. New checks cover ascending/descending
and exact-boundary crossings, nonuniform times, both temperature-band crossings,
invalid series, an exponential crossing with known time, common initial states,
unoccupied equilibrium, and baseline metric refinement.

The runner compares baseline and refined trajectories at shared times and fails
before writing outputs if the following declared tolerances are exceeded:

- Maximum CO₂ trajectory and peak differences: less than 0.01 ppm.
- Maximum temperature trajectory and peak differences: less than 0.001°C.
- CO₂ and temperature threshold-duration differences: less than 1 second.

These tolerances assess numerical resolution of this baseline, not physical
prediction uncertainty. The output files record the actual differences:

The completed run passed these checks. Across the three strategies, the largest
shared-time CO₂ difference was 0.0010182 ppm, the largest temperature difference
was 7.84e-7°C, and the largest threshold-duration difference was 0.12584 seconds.
All three PNG figures were visually inspected after export; matching SVG files
are provided for scalable report graphics. Plots 1.41.8 was used.

```text
results/tables/deterministic_baseline/
    summary.csv           Peaks, final values and threshold durations
    trajectories.csv      Strategy, time, CO₂, temperature and ACH
    step_refinement.csv   Differences between 15-second and 7.5-second steps
    metadata.txt          All parameters, solver, thresholds, versions and Git state
results/figures/deterministic_baseline/
    co2.png / co2.svg
    temperature.png / temperature.svg
    ventilation.png / ventilation.svg
```

Generated outputs remain Git-ignored. Keep the source, Project.toml and
Manifest.toml under version control; explicitly select final report artifacts
for archiving when needed. Metadata records whether the working tree is dirty,
so a commit identifier alone must not be mistaken for an exact source snapshot.

Next stages are weather/input modelling and justified uncertainty distributions,
followed by Monte Carlo and sensitivity analysis. The current results should be
revisited after those assumptions are examined.
