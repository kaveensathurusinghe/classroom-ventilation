# Reconstructible standard experiment outputs

Refreshed from the notebook on 26 November 2026, Julia 1.12.7, `Random.Xoshiro(4042)`, 500 paired scenarios. These are new executed results, not copied historical tables. See [verification](../../notebook/VERIFICATION.md) and [precision interpretation](../../notebook/notes/standard-run-20261126.md).

- `monte_carlo_raw.json`: complete sampled inputs, all 21 weather profiles' knots, 1500 per-strategy outcomes, 1500 half-step comparisons and run settings. One scenario ID is shared by all three strategies. This saves outcome metrics, not all Monte Carlo trajectory states.
- `monte_carlo_inputs.csv`, `monte_carlo_weather_knots.csv`, `monte_carlo_outcomes.csv`, `monte_carlo_refinements.csv`: flattened versions for inspection.
- `monte_carlo_summary.csv`: mean, sample SD, Monte Carlo SE, approximate 95% mean interval and outcome percentiles for four metrics per strategy.
- `monte_carlo_event_probabilities.csv`: counts and two-sided 95% Wilson intervals.
- `monte_carlo_paired_differences.csv`: strategy minus reference, matched by scenario ID, for all three pairs and four metrics.
- `monte_carlo_sensitivity.csv`: tie-aware Spearman associations with eleven inputs. Mean weather covariates are time-weighted trapezoidal averages of the piecewise-linear profile, not unweighted knot means.
- `monte_carlo_precision_prefixes.csv`: nested first 50,100,250,500 scenarios; these are not independent replicate experiments.
- `run_manifest.json`: output checksums, actual execution metadata and comparison with pre-refresh tables.

Raw outcome duration fields use **hours**. Summary and paired duration metrics use **minutes**; refinement duration differences use **seconds**. CO2 is ppm, temperature C, time knots hours from lecture start. Raw weather wind is 10 m wind in m/s and is multiplied by each scenario's dimensionless `wind_factor` before use. Dates retain the frozen Asia/Colombo interpretation. Inputs: volume m3, CO2 generation L/person/hour, sensible heat W/person, UA W/K, additional heat W, air density kg/m3, air heat capacity J/(kg K), opening area m2, infiltration 1/hour, stack height m; effectiveness/discharge/metabolic factors are dimensionless. Occupancy is persons. Generation and sensible heat share the metabolic multiplier.

The standard initial state is (450 ppm,28 C), outdoor CO2 420 ppm, threshold 1000 ppm and band 24-30 C. The raw JSON includes these settings, source-weather SHA-256 and Julia/RNG identification. Weather and synthetic distributions are assumed inputs, not fitted classroom measurements. JSON retains finite numeric values; CSV empty interval/rank fields mean unavailable, not zero.

Run `python notebook/reconstruct-summaries.py` from the repository to independently recompute and check all 825 numeric/missing aggregate fields using Python's standard library. It reads the raw JSON and published CSVs; it does not simulate or use saved aggregate values to compute expected results. The notebook's final cell runs its embedded copy of `notebook/export-results.jl`, which writes to `<temporary notebook project>/results` by default. Set `VENTILATION_EXPORT_DIR` before that cell to choose an output directory. That directory contains tables, figures and `julia-reference.js` for the demo. Re-running uses the same 500 scenarios for all strategies and repeats step-halving checks; no failed scenario is dropped.
# Sensitivity interval supplement

`monte_carlo_sensitivity_intervals.csv` supplements the original point estimates with paired bootstrap intervals; `sensitivity_interval_manifest.json` records its input/script hashes, versions and seed. Regenerate with `python notebook/sensitivity-intervals.py` (NumPy and Matplotlib required). This is a separate postprocessing run, not part of the earlier `run_manifest.json` or embedded Julia exporter. Details and undefined-output handling: [evidence assessment](../../notebook/notes/extension-evidence.md).
