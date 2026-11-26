> Inherited development note. Stage descriptions and earlier run claims are historical; see VERIFICATION.md for rebuild execution.

# Weather inputs, Monte Carlo and sensitivity

This study is conditional on an illustrative classroom, one month of weather,
and explicitly assumed parameter distributions. It does not estimate the
performance of a measured building or a representative full academic year.

## Weather and provenance

The inherited configuration selects the illustrative point 6.91°N, 79.97°E near Malabe, weekdays in
March 2025, 09:00–11:00 Asia/Colombo time. The explicit Open-Meteo ERA5 request
returned the grid point 7.0°N, 80.0°E. It contains 744 hourly records and 21
eligible weekday lecture blocks. Holidays are not excluded; this is not an
actual university timetable.

[Open-Meteo's historical API](https://open-meteo.com/en/docs/historical-weather-api)
provides reanalysis, not classroom observations. We request Celsius, m/s and
Asia/Colombo explicitly and verify response units and UTC offset (+05:30).
The original JSON, request URL, retrieval timestamp and SHA-256 are cached in
`data/raw/`. Reusing a cache requires a matching request and checksum. Missing
values, hourly gaps, duplicate timestamps or unexpected units stop processing;
they are not imputed or replaced with synthetic weather. The API may return a
grid location different from the requested coordinates, which is retained.

Source attribution: Open-Meteo.com and Copernicus ERA5,
[ERA5 hourly single levels](https://doi.org/10.24381/cds.adbb2d47).
Preserve source attribution with redistributed weather/results. Re-fetching can
change upstream data; the recorded response checksum identifies the actual run.

Each draw selects one complete day's three paired temperature/wind observations
at 09:00, 10:00 and 11:00, uniformly with replacement. Linear interpolation
preserves the paired profile across the lecture. Integrations restart at each
hourly knot with the previous endpoint as the next initial state. No
extrapolation is allowed. Resampling does not create new weather information:
the empirical weather population contains only 21 blocks.

## Synthetic input modelling

These are bounded exploratory distributions, not fitted measurements or
confidence intervals for physical parameters. Their centres retain the initial
project baseline, while ranges allow moderate variability. They require
refinement against measured geometry, attendance, activity and heat gains
before drawing building-design conclusions. Tri(a,m,b) denotes a triangular
distribution with minimum a, mode m and maximum b; U denotes continuous uniform.

| Input | Sampling assumption | Rationale and limitation |
| --- | --- | --- |
| Occupancy | Discrete uniform integers 25–45 | Illustrative variation around 35; no attendance data; constant during a lecture |
| Shared metabolic multiplier M | Tri(0.8,1,1.2) | Moderate variation around the baseline; not a physiological population fit |
| CO₂ generation G | 18 M L/person/hour | Scenario-average per-person rate, not separate individual draws |
| Sensible occupant heat q | 75 M W/person | Shares M with G; assumed dependence, not an exact metabolic conversion |
| Wind adjustment | Tri(0.3,0.6,1.0) × 10 m wind | Unmeasured shelter/height adjustment to local opening wind; not a calibrated log-law model |
| Envelope UA | Tri(40,80,120) W/K | Exploratory aggregate-conductance uncertainty |
| Additional heat Q | U(0,500) W | Unmeasured equipment/solar proxy; nonnegative, constant per lecture |
| Background infiltration | Tri(0.1,0.3,0.6) h⁻¹ | Exploratory leakage range, constant per lecture |
| Wind effectiveness Cw | U(0.2,0.4) | Uncalibrated airflow coefficient |
| Discharge coefficient Cd | U(0.5,0.7) | Uncalibrated opening-loss coefficient |
| Stack height H | U(0.5,1.5) m | Unmeasured neutral-pressure-level geometry |

CO₂ generation depends on occupant characteristics and activity, motivating
variation rather than a universal per-person constant; see
[Persily and de Jonge](https://www.nist.gov/publications/carbon-dioxide-generation-rates-building-occupants).
That reference does **not** establish the distribution or correlation chosen here.

All primitive draws are independent except the shared M and the paired weather
block. Weather summaries and local wind are therefore dependent derived inputs.
Full opening area remains 2 m², volume 179.2 m³, density 1.2 kg/m³ and specific
heat 1005 J/(kg K). Initial state (450 ppm,28°C), outdoor CO₂ 420 ppm and opening
fractions (0,0.5,1) remain fixed. Geometry and initial-state uncertainty are not
included, and Q is not linked to sunshine. These omissions matter.

The triangular random variate is implemented manually by inverse transform:
with U uniform on [0,1), p=(m-a)/(b-a), return
`a + sqrt(U*(b-a)*(m-a))` if U<=p, otherwise
`b - sqrt((1-U)*(b-a)*(b-m))`.
Occupancy and weather-index draws use Julia's discrete uniform sampling.
An explicit `Random.Xoshiro(4042)` RNG is passed to sampling; no global seed is
implicitly consumed. The manifest, Julia version and complete sampled-input
table are needed for replay; a seed alone is insufficient across software changes.

## Monte Carlo design and numerical checks

The default run draws 500 scenarios. Every scenario's weather, occupants and
coefficients are reused across all three strategies (common random inputs).
The resulting 1500 outcomes are paired, not independent strategy datasets.
Each simulation uses manual RK4 at 7.5-second steps; every scenario/strategy
is repeated at 3.75 seconds. No failing sample is silently removed. The runner
stops if a step-halving difference exceeds 0.1 ppm in peak CO₂, 0.005°C in peak
temperature, or 1 second in either threshold-duration metric.

These numerical tolerances do not measure model error. Peaks remain sampled
maxima and durations use piecewise-linear threshold crossings. Validation at all
RK4 stages rejects invalid physical states, but small-step agreement does not
prove general stability for an arbitrarily expanded parameter range.

## Statistical outputs

- Each outcome includes peak CO₂, peak temperature and threshold durations.
  Means, standard deviations, medians and 5th/95th percentiles describe the
  assumed outcome distribution. Percentiles are not confidence intervals.
- Monte Carlo standard error is `sample_sd/sqrt(n)`. Mean intervals use
  `mean ± 1.96*SE`, an approximate large-sample 95% interval conditional on the
  selected distributions and weather pool. They exclude structural model error,
  calibration uncertainty not represented by inputs, and weather-pool uncertainty.
  For zero sample variance the mean interval is left missing: a zero-width
  sample interval would not account for unobserved rare outcomes. In particular,
  zero full-opening CO₂-exceedance durations do not prove a zero population mean.
- Event proportions report any CO₂ exceedance, any temperature-band exceedance,
  and meeting both limits for the full lecture. A 95% Wilson interval is used,
  including when no sampled event or all sampled events occur. These are
  comparison-threshold events, not health or regulatory compliance probabilities.
- Paired differences subtract the reference strategy **within each scenario**,
  then compute the mean and standard error of those differences. Negative
  differences mean less of the named outcome under the first strategy.
- Prefix summaries at 50, 100, 250 and 500 draws (or the requested run size)
  show sampling precision. They are nested samples, not independent replications
  or a proof that the chosen sample count is universally adequate.
- Tie-aware Spearman correlations screen input/output associations by strategy.
  Constant inputs/outputs give missing values, not zero correlation. Correlations
  are not causal effects, partial correlations, Sobol indices, or a decomposition
  of variance. Dependencies, interactions and non-monotone effects limit ranking.

The study estimates a combined distribution of lecture variation and uncertain
coefficients. It does not separately identify aleatory and epistemic uncertainty.
The existing air-only thermal-storage limitation still applies.

## Run and inspect

```powershell
julia --startup-file=no --project=. -e 'using Pkg; Pkg.instantiate()'
julia --startup-file=no --project=. scripts/fetch_weather.jl
julia --startup-file=no --project=. test/runtests.jl
julia --startup-file=no --project=. experiments/run_monte_carlo.jl 500 4042
```

The fetch command reuses the validated cache. Pass `--refresh` to deliberately
replace it. The experiment requires that cache and has no synthetic fallback.
Arguments are sample count (at least 30) and seed. It overwrites its named
output files in `results/tables/monte_carlo/` and `results/figures/monte_carlo/`.
Archive a run before changing its settings if both versions are needed.

Tables: sampled_inputs, weather_profiles, outcomes, summary, event_probabilities,
paired_differences, sensitivity, sampling_convergence and step_refinement (CSV).
Metadata JSON records weather provenance, input constants, settings, versions,
Git state and hashes of source/configuration files. Figures show empirical
cumulative outcome distributions, sensitivity associations and weather blocks
in PNG and SVG. Raw/processed weather and generated results remain Git-ignored.

Tests use synthetic fixtures, with no network access. They check malformed
weather, units, cache identity/integrity, interpolation, triangular inverse-CDF
endpoints and moments, reproducibility, shared metabolic inputs, time-varying
thermal dynamics, paired outcomes, refinement, Wilson intervals and tied ranks.

## Executed results (seed 4042, 500 scenarios)

The 500 draws produced 1500 paired strategy outcomes. All 1500 step-halving
comparisons passed. Maximum differences were 0.01310 ppm for peak CO₂,
4.35e-6°C for peak temperature, 0.0302 seconds for CO₂ duration and 0.0408 seconds
for temperature-band duration. The full regression suite passes 302 checks.

| Strategy | Mean peak CO₂ (ppm) | 5th–95th peak CO₂ percentiles (ppm) | Runs exceeding 1000 ppm | Mean peak temperature (°C) |
| --- | ---: | ---: | ---: | ---: |
| Closed | 5627.54 | 3927.51–7629.43 | 500/500 | 60.15 |
| Partial | 852.75 | 673.28–1038.90 | 51/500 | 37.21 |
| Full | 681.36 | 559.13–805.10 | 0/500 | 35.42 |

The partial-opening CO₂ event estimate is 10.2% (95% Wilson interval 7.84–13.16%).
Full opening's zero-event estimate has interval 0–0.762%, not proof of zero risk.
Closed opening's interval is 99.24–100%. All 500 scenarios for every strategy
exceeded the illustrative temperature band at some point. Mean time outside it
was 117.43, 117.16 and 115.97 minutes for closed, partial and full opening.

The paired full-minus-partial mean peak CO₂ difference was -171.40 ppm
(approximate 95% Monte Carlo mean interval -174.83 to -167.97 ppm). The analogous
peak-temperature difference was -1.788°C (-1.822 to -1.754°C). These are
conditional comparisons, not estimates of real-building treatment effects.

Sensitivity screening found strong positive association of occupancy with
closed-window peak CO₂ (rho=0.812). Mean local wind was negatively associated
with open-window peak CO₂ (partial -0.586, full -0.677). Mean outdoor temperature
was positively associated with open-window peak temperature (partial 0.757,
full 0.820). Weather dependence and model interactions prevent interpreting
these as isolated causal effects or percentages of explained uncertainty.

The weather-driven run differs from the nominal 29°C/2 m/s baseline in several
inputs at once; differences between those experiments cannot be attributed to
weather alone. High simulated closed-window temperatures, including unrealistic
extremes, reinforce the need to improve/calibrate heat storage and heat-transfer
assumptions before using this model for design. Numerical convergence cannot
establish physical validity. No adaptive controller has been implemented.
