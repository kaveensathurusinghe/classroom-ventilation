# Execution record

## Reviewed Colab execution and public demo - 26 November 2026

The owner supplied the revised executed notebook. Its six code-cell sources match the repository notebook exactly. The canonical notebook now uses these genuine Colab outputs instead of earlier local outputs that printed a developer workspace path. No numerical values were edited and no simulation was rerun for this publication cleanup. Earlier local records remain historical; their timing is not the Colab timing.

- Printed Julia version: **1.12.6**. Loaded JSON 1.13.4 and Statistics 1.11.5.
- **SETUP_SECONDS=101.339**; **TOTAL_NOTEBOOK_SECONDS=172.167** (2 minutes 52.167 seconds). Installation ran, including JSON and parser dependencies. The export has execution counts 1-6 and three SVG outputs. It contains no notebook-level error outputs.
- All **302 tests passed**. All **500 paired scenarios** and **1500 refinement records** completed. Final exports and round-trip/seed checks passed. Deterministic results and maximum refinement deltas match the documented standard outputs.
- Setup and verification streams retain compiler/task-print diagnostics. The project cache opt-out caused a skip-precompilation notice. Completion is demonstrated by later tests and export messages; this is not a warning-free run. Account tier and hardware are not recorded, so no particular free-tier configuration or universal timing guarantee is asserted.
- An unauthenticated HTTP request to `https://kaveensathurusinghe.github.io/classroom-ventilation/` returned **200**, with the expected title and Julia-reference button. This confirms the published entry page was accessible, not an automated browser control/console audit. Earlier owner screenshots and Pause/Reset reports remain the browser-operation evidence.

The public version's scientific implementation, step sizes, scenario count and tolerances are unchanged. Publication metadata and documentation are maintained separately from empirical validation claims.

## Lightweight setup revision - 26 November 2026

The owner reported the previous setup cell still executing after 10 minutes 10 seconds. This establishes a slow previous setup; successful earlier calculations alone did not meet the approximate ten-minute fresh-run target.

The revised environment removes Plots, GR, Qt and the native graphics tree: pinned manifest entries fall from 173 to 41. A bundled dependency-free Julia SVG renderer produces charts from actual current-run arrays. The project wrapper now uses `__precompile__(false)` to avoid wrapper-cache recompilation against kernel-loaded dependencies. Setup disables automatic Pkg precompilation; package loading may still compile code. Installation remains enabled by default. The first and final cells print `SETUP_SECONDS` and `TOTAL_NOTEBOOK_SECONDS`. No scenario count, solver step, scientific tolerance or physical assumption was relaxed.

Final actual local replay: Julia 1.12.7, all six notebook code cells in a new process with preinstalled packages and installation explicitly skipped. Command: `julia --compiled-modules=existing --startup-file=no --history-file=no --project=.private/performance-20261126/unpacked .private/performance-20261126/replay.jl`. A writable local depot and normal temporary directory were used because the sandbox rejected writes to the user's depot and precompilation in its redirected temporary path. Final elapsed replay was **57.573 seconds**, setup timer **20.790 seconds**, and the final in-notebook timer **57.400 seconds**; the first successful renderer draft replay was 38.577 seconds. These are local functional runs under varying load, not a controlled speed-up benchmark or fresh Colab timing. Loaded JSON was 1.13.4 and Statistics 1.11.5. The local `--compiled-modules=existing` flag is not an instruction to change the Colab kernel.

- All **302 scientific/regression checks passed**, and 500 paired scenarios plus all 1500 refinements completed. All three notebook chart outputs were refreshed as SVG from the successful final replay.
- `python .private/performance-20261126/check_outputs.py`: **37,824 CSV fields** matched prior exports, using relative 1e-12 and absolute 1e-10 tolerances for numeric differences. All 17 scientific/test/weather payloads compared byte-identically; the module wrapper differs only by the cache opt-out line. All 22 embedded payload hashes and root/embedded environments were checked. Seven SVG exports parsed as XML without NaN/Inf coordinates.
- `python notebook/reconstruct-summaries.py .private/performance-20261126/results`: **825 aggregate numeric/missing fields** independently reconstructed from the newly exported inputs/outcomes.
- `julia --compiled-modules=existing --startup-file=no notebook/svg-checks.jl`: **14 renderer checks passed**, including custom sensitivity tick labels, ECDF path production, finite log coordinates, panels, reference labels, SVG MIME display and export validation. An initial chart review exposed missing custom tick labels; that propagation defect was corrected before the final full replay.
- `node notebook/reference-checks.cjs`: **372 checks passed** against the shipped reference. A separate Node invocation accepted the freshly exported Julia reference. The browser demo and its shipped reference were not changed.
- `nbformat.validate` passed. Selected convergence, ECDF and sensitivity SVGs were visually inspected through a local SVG-to-PDF adapter and rasterisation. This does not prove rendering in Colab or a browser. SVGs are new exports; existing PNGs remain earlier plots of the unchanged scientific outcomes. A separate lightweight-run manifest records current hashes without rewriting the earlier run's provenance.

Local setup diagnostics: a normal-depot Pkg attempt was denied a manifest-usage lock. A writable-depot attempt failed precompiling Downloads with the redirected temporary path. After a normal temporary directory was set, Pkg precompilation and registry resolution encountered the sandbox's restriction on launching its bundled 7z. A local source-loading flag avoided precompilation for verification. The pinned manifest was pruned from the old dependency graph with existing weak dependencies retained, preserving versions, and its project hash was calculated using Julia 1.12.7 Pkg. An initial draft omitted a weak dependency and failed manifest validation; it was corrected before replay. These failed attempts are not fresh-install successes.

**Fresh free-tier Colab timing of this revised notebook remains pending.** The owner must upload/update the new repository notebook; the existing shared Drive copy does not synchronise automatically. Preserve the earlier executed Colab export as evidence of its older version. The already delivered report describes the earlier plotting/setup and needs its implementation/timing wording refreshed when the revised Colab run is recorded; its scientific result values remain unchanged.

## Owner browser screenshots and controls - 26 November 2026

The owner supplied a screenshot showing the default 35 occupants, 29 C and 2 m/s run completed at 120 minutes, with displayed peaks/durations matching the documented rounded baseline. A second screenshot shows the reference checker message: PASS within 0.01 ppm, 0.001 C and one second. The owner explicitly reported Pause and Reset work. A later owner-saved screenshot used in the report shows changed inputs (2 occupants, 24.5 C, 5 m/s), a paused run at 35 minutes and the default-reference PASS message. That message checks the default independently of the changed sliders.

These establish owner-reported browser operation and visible output, not an automated browser audit. Codex's attempted file-URL browser access was blocked by policy; no policy workaround was used. Console-error checks, multiple-browser checks and exhaustive parameter coverage remain unverified. Previous entries stating no visual browser evidence are historical and superseded only within this scope. No simulation code was changed for this report preparation.

## Owner-executed Colab notebook reviewed - 26 November 2026

The owner supplied `classroom_ventilation.ipynb` after executing it in Colab. Codex inspected its saved JSON and outputs, rather than executing Colab itself. The original uploaded file remains the primary evidence; an extracted JSON-text copy is retained privately as `classroom_ventilation.parsed-copy.ipynb`, not claimed byte-identical to the upload. This entry supersedes earlier statements that no Colab execution has been evidenced.

- Actual printed runtime: Julia **1.12.6**, versus the local manifest's recorded 1.12.7. Seven code cells have saved execution counts: the added version probe (1), setup (2), and the six-cell notebook's remaining cells (4 through 8). No saved output has notebook type `error`. The count gap means the export alone does not prove a single uninterrupted Run all or record every attempted cell.
- Setup ran dependency installation, reported 131 dependencies precompiled in **417 seconds**, then reached both final setup messages. It also reported one already-loaded dependency version mismatch, repeated cache/target mismatches, and seven `SYSTEM: caught exception of type :MethodError while trying to print a failed Task notice` messages. These are preserved warnings/errors in the stream, not erased or described as a clean setup. Their underlying cause and the actual loaded dependency versions were not established by this export.
- All **302 tests** passed across 15 printed test summaries. Finest smooth CO2 orders: Euler 1.0153656418 and RK4 4.0300829708. Deterministic peaks reproduce the recorded baseline: CO2 5723.827989 / 681.383462 / 557.126009 ppm and air temperature 54.722122 / 31.957965 / 30.621276 C (closed/partial/full).
- The 500 paired scenarios used seed 4042 and 21 weather blocks. All outcomes passed step refinement. Final output reports 500 input records, 1500 paired outcomes and 1500 refinement records exported inside the Colab temporary project; round-trip reconstruction and seed reproducibility checks passed. Exported raw files themselves were not attached or independently inspected here.
- Maximum reported refinement differences were 0.0130941354 ppm, 4.346079e-6 C, 0.030182914 seconds and 0.040798993 seconds. CO2 event counts were 500/500, 51/500 and 0/500. Three PNG plot outputs are embedded; presence was checked, visual appearance was not reviewed in this audit.
- Total elapsed time, accelerator, account tier and exact session start/end times are not recorded. **The ten-minute fresh-run target remains unverified**; 417 seconds is precompilation time only. The retained `local_execution` metadata describes the earlier local run and must not be interpreted as Colab timing.

All six original code-cell sources match the current repository notebook exactly; the owner added the version-probe cell. No scientific implementation, environment, canonical notebook outputs, demo reference or result table was changed for this evidence review. Browser UI verification remains pending. This is evidence of completed owner-executed Colab calculations with setup diagnostics, not a warning-free or fully audited dependency environment.

## Extension evidence and sensitivity intervals - 26 November 2026

New postprocessing run: `python -X utf8 notebook/sensitivity-intervals.py`, Python 3.14.5, NumPy 2.5.4, Matplotlib 3.11.2, exit 0. The runner independently reconstructed all 825 existing aggregate numeric/missing fields, matched all 132 existing Spearman estimates (absolute tolerance 1e-12 with NumPy relative tolerance), checked tied ranks, reversed ranks, constant-input handling and deterministic resample indices. It additionally compared two actual bootstrap replicates for every sensitivity row with the independent standard-library reranking/correlation implementation (264 comparisons, including undefined cases). All assertions passed.

Generated 2000 paired scenario-row bootstrap replicates with PCG64 seed 404205 from the unchanged 500-scenario Julia export. All 121 estimable rows have 2000 finite replicates; eleven full-opening CO2-duration rows remain undefined with blank intervals. Exported pointwise 95% percentile intervals, PNG/SVG and a separate hash/version manifest. The confidence-interval PNG and existing log-log convergence PNG were visually inspected for legibility. See [assessment and interpretation](notes/extension-evidence.md).

Existing analytical verification, measured convergence orders and 302-test results are inherited from the earlier recorded replay, not rerun here. No Julia trajectories, notebook code/payloads, environment, physical equations or demo were modified. No fresh Colab, browser, empirical validation or public-release check was completed. X2 has existing technical support; X5's sensitivity-interval gap is filled. Neither establishes eligibility before X1 qualifies. Historical weather forcing does not establish X4 calibration/validation. The initial PDF extraction failed on console character encoding and succeeded with UTF-8; no result relies on that failed extraction.

On 25 November 2026, the existing suite was run with the actual Julia 1.12.7 executable: all 302 checks passed. The Windows `julia.exe` application alias failed in this tool environment; invoking the installed executable directly succeeded.

Prior notes and figures were inherited. Copying them is not a fresh run. Further rebuild checks are appended as executed. Numerical verification is not real-classroom validation.

Pending external work: verified free-tier status and total fresh Colab timing (completed calculations are evidenced above); public hosting; final report and narrated video; complete original AI exports and signed declaration. Browser execution status is recorded separately below.

## Rebuild checks actually executed

- `scripts/export_demo_reference.jl`: exported actual Julia trajectories/metrics for the default case on Julia 1.12.7.
- `node scripts/check_demo.cjs`: passed comparisons at 0, 30, 60 and 120 minutes and four metrics for all three strategies. Tolerances: 0.01 ppm, 0.001 °C, one second. Deliberately corrupting the reference is detected.
- `experiments/run_deterministic.jl`: rerun successfully, including half-step comparisons. Closed/partial/full peak CO₂: 5723.83 / 681.38 / 557.13 ppm; peak air temperature: 54.72 / 31.96 / 30.62 °C. The high closed-window temperature demonstrates the air-only heat-capacity limitation, not an empirical classroom prediction.
- `experiments/run_monte_carlo.jl 500 4042`: all 500 paired scenarios completed, with all 1500 strategy outcomes repeated at half-step and passing the specified tolerances. Fresh CSVs and selected figures were generated. Mean peak CO₂ for closed/partial/full: 5627.54 / 852.75 / 681.36 ppm, conditional on assumed inputs and the frozen weather pool. The full-opening sample contained no CO₂ threshold event; this does not establish zero population probability.
- Notebook JSON validated with nbformat. Local code-cell execution status is recorded below when it completes.
- Original AGENTS.md SHA-256 matches the preserved pre-rebuild manifest.
- `scripts/verify_solvers.jl` rerun: final measured CO₂ error orders were 1.0154 for Euler and 4.0301 for RK4 on the smooth analytical benchmark.

## Blocked checks and corrected attempts

The ZIP templates could not be downloaded because of DNS restrictions; the printed structures and log columns in the supplied PDF were used. Exact template styling has not been checked.

Browser policy rejected navigation to the local `file:` URL. The interface has not been visually verified in a real browser; no screenshot, console-error check or cross-browser success is claimed. Node numerical consistency tests are separate evidence.

Fresh package instantiation in the notebook was attempted but blocked by the sandbox's inability to launch Julia's bundled archive executable while reading the installed registry. A local **preinstalled** verification mode explicitly skips dependency installation; it does not count as fresh Colab validation. Earlier failures involving the Windows application alias, depot log permissions and sandbox temporary paths were also observed. They are not silently reported as successful setup.

Notebook integration revealed a benchmark-module collision. The complete test suite is now scoped in its own ordinary Julia module, avoiding replacement of the notebook's imported analytical references. Failed local run logs are retained privately. The first isolation attempt used a dynamically constructed module without a local `include`, which was corrected before the next run.

## Completed local notebook replay

All six code cells executed sequentially in a new Julia 1.12.7 process in 73.5 seconds, using the explicitly selected preinstalled-dependency mode. The notebook contains actual captured stdout and three generated plot outputs. Its verification cell passed the analytical assertions, measured-order checks and complete 302-check suite. Its 500-scenario Monte Carlo cell passed all per-outcome refinement checks. This is local sequential code execution, not a Jupyter/Colab UI run; package installation was explicitly skipped after the earlier failed attempt.

Top-level Markdown links, frozen weather checksum, embedded Julia source hashes and notebook schema were checked. No missing local links or embedded-source differences were found. Original planning remains unchanged. Git staging was blocked by read-only `.git` access; no commit or push occurred.

## Fresh verification run — 26 November 2026

At the owner's request, Codex reran the existing embedded test suite without changing the model, solver, tests or notebook. All **302 checks passed** in a new Julia 1.12.7 process on Windows. The final process exited with code 0 and an empty stderr log. Tests and measurement reporting took 13.528 seconds after imports; this is not installation time or a full-notebook runtime.

The first notebook cell's bundled files were extracted into ignored `.private/verification-20261126/unpacked/`. Their existing `test/runtests.jl` was included inside an isolated ordinary module. A separate diagnostic script repeated existing cases to print measured errors rather than only pass/fail results. No dependency installation, network download, full notebook replay, plotting, browser check or 500-scenario Monte Carlo experiment was performed. The suite includes a small three-scenario Monte Carlo fixture, which is not the standard experiment.

Notebook SHA-256: `0e531987436c5b40b04a492b60e1d985ba1270cca8a9006505cee8521365fd11`.

Command (local ignored runner, not a public-clone entry point):

```powershell
& '<installed Julia 1.12.7>/bin/julia.exe' --startup-file=no --history-file=no --project=.private/verification-20261126/unpacked .private/verification-20261126/check.jl
```

Exact command path, runners and stdout/stderr are retained privately. Public-clone verification remains available in the notebook's verification cell. Preinstalled dependencies were used. An initial sandbox run failed on user-directory access. An authorized activation-after-startup run completed all checks but produced dependency-version/precompilation warnings and a PowerShell nonzero status. The final run selected the project at process startup and completed without those warnings. These earlier attempts are retained, not counted as clean final runs.

### Fresh analytical convergence measurements

Existing benchmark: zero occupants, ACH=1 h^-1, default room, outdoor (420 ppm, 25 C), initial (1200 ppm, 32 C), duration 2 hours. Errors are maximum absolute differences from the independent constant-coefficient analytical solution at saved times. Orders are `log2(error(h)/error(h/2))`; no mixed-unit norm is used.

| Method | Step, h | CO2 error, ppm | Temperature error, C | CO2 order | Temperature order |
| --- | ---: | ---: | ---: | ---: | ---: |
| Euler | 0.2 | 31.3555641 | 0.761295114 | — | — |
| Euler | 0.1 | 14.9767808 | 0.334191813 | 1.065994 | 1.187779 |
| Euler | 0.05 | 7.32694464 | 0.157885660 | 1.031444 | 1.081796 |
| Euler | 0.025 | 3.62466100 | 0.076972439 | 1.015366 | 1.036466 |
| RK4 | 0.2 | 0.00452162401 | 0.00149939101 | — | — |
| RK4 | 0.1 | 0.000259928024 | 0.0000770260331 | 4.120657 | 4.282887 |
| RK4 | 0.05 | 0.0000155813559 | 0.00000437149718 | 4.060219 | 4.139147 |
| RK4 | 0.025 | 0.000000953738663 | 0.000000260533579 | 4.030083 | 4.068586 |

Both components passed the existing final-order bands: Euler (0.9,1.2), RK4 (3.8,4.3), with decreasing errors on refinement.

### Fresh conservation, source and thermal measurements

- Zero ACH and zero UA, 10 occupants, initial (450 ppm,28 C), dt=0.001 h, duration 2 h: both methods' endpoint errors were 3.638e-12 ppm and 1.762e-12 C against linear accumulation.
- Same source case with ACH=2 h^-1: Euler endpoint errors 0.03457385 ppm and 0.0005305552 C; RK4 5.116e-12 ppm and 2.842e-14 C. Existing combined-vector relative tolerances were 1e-3 (Euler) and 1e-9 (RK4); the separately printed component errors expose the units rather than relying on that mixed-unit comparison.
- Integrated CO2 budget, default room, 10 occupants, ACH=2 h^-1, dt=0.01 h, duration 2 h: maximum residuals 2.842e-13 L (Euler), 1.705e-13 L (RK4), both below 1e-9 L. The export integral shares solver stages with the concentration state, so this establishes discrete conservation, not independent trajectory accuracy.
- Independent instantaneous balance audit: signed residual -2.776e-17 m^3 CO2/h and -1.137e-13 W. Existing tests use Julia's approximate-equality checks, with explicit tolerances where supplied.
- Source-free thermal relaxation, default room, ACH=2 h^-1, outdoors 25 C, dt=0.01 h, duration 2 h: maximum errors from 20 C were 0.03108297 C (Euler), 1.944e-8 C (RK4); from 35 C, 0.06216594 C and 3.888e-8 C. Both methods remained bounded and approached outdoors monotonically in both cases. These extra error measurements are diagnostics; the existing relaxation assertions check bounds and monotonicity.
- Existing equilibrium and isolated trajectories, dt=0.03 h, duration 2 h: exactly zero CO2 and temperature drift for both methods. Instantaneous occupied equilibria also passed.
- Coupled RK4 refinement at shared times, 1/480 versus 1/960 h: closed/half/full CO2 differences 1.546e-11 / 0.0004280084 / 0.0003277341 ppm; temperature differences 1.076e-11 / 3.340e-8 / 2.051e-7 C. All passed 0.001 ppm and 0.0001 C limits. These are inter-grid differences, not exact errors.

### Interpretation and gaps

These new results reproduce the historical smooth convergence results, but do not refresh historical full-notebook, standard Monte Carlo, installation or browser claims. No existing assertion failed.

Numerical verification supports correct solution of the specified equations for tested cases. It does not validate opening coefficients, occupancy assumptions, air-only thermal storage or classroom predictions against measurements. The coupled stack model has a nonsmooth temperature crossing; even nonzero wind leaves an ACH kink at indoor/outdoor equality. Smooth RK4 order must not be inferred across it. Current conservation testing uses constant ACH and an augmented CO2 export state; there is no comparable integrated thermal-energy budget or comprehensive variable-weather/stack-crossing conservation test. The source-solution test's mixed-unit vector relative tolerance is weaker than separate component tolerances. Wider parameter extremes, peak/event metric accuracy and empirical classroom calibration remain separate questions.

## Fresh uncertain-input audit — 26 November 2026

Codex reviewed the embedded sampler, weather parser, profile interpolation and weather-driven caller against the uncertainty register. A separate local diagnostic (`.private/verification-20261126/input-review.jl`) ran on Julia 1.12.7 with the previously extracted, unchanged notebook environment. Command: `julia --startup-file=no --history-file=no --project=.private/verification-20261126/unpacked .private/verification-20261126/input-review.jl`. Final exit code 0, empty stderr; no Monte Carlo trajectories rerun. A typo in the diagnostic's initial hash assertion caused its first attempt to fail; the diagnostic was corrected, with no project implementation changes.

- Notebook SHA-256 remained the value recorded above. `fetch_weather` validated the public frozen cache request and SHA-256 `284428f880d4708dab244858efc6e26ea36a28b61a9cc9012362dd3ff6f3efda`; no download was needed.
- Confirmed 744 hourly records and 21 weekday profiles, returned grid (7.0 N,80.0 E). Eligible profile knot ranges: 26.7–33.9 C and 0.11–5.12 m/s at 10 m.
- Two fresh 500-input draws using Xoshiro(4042) were identical; seed 4043 differed. A fresh 100-input draw matched the first 100 of the 500-input draw.
- All 500 draws satisfied the documented bounds for occupancy, metabolism, derived G and q, wind factor, UA, additional heat, infiltration, Cw, Cd and H. Every draw preserved G/18 = q/75 to floating-point tolerance. All 21 profiles occurred, with counts ranging from 18 to 34; this is not a goodness-of-fit test.
- Each of the four triangular parameterizations passed endpoint/mode, monotonicity and support checks over 1001 probability values. The existing symmetric Tri(0,1,2) moment diagnostic with 10,000 draws gave mean 0.997814700 (target 1, tolerance 0.02) and sample variance 0.166410268 (target 1/6, tolerance 0.01).
- All 21 real profiles passed exact knot recovery, midpoint interpolation and rejection outside the profile time interval.

These checks verify sampling implementation, not the appropriateness of the assumed distributions. In particular, wind-factor mean 0.633333 differs from its mode 0.6; infiltration mean 0.333333 h^-1 differs from its mode 0.3; additional-heat mean 250 W differs from the deterministic baseline 0 W. Shared G/q scaling imposes perfect positive dependence, while other primitive parameter draws are independent of weather. Weather is one month of reanalysis, not measured classroom data or a fitted annual weather distribution. A fixed seed alone does not guarantee identical streams across Julia versions or changes in draw ordering.

## Fresh statistical-formula audit — 26 November 2026

The unchanged `sample_summary`, `wilson_interval` and `spearman_correlation` functions were exercised on independently calculable examples in Julia 1.12.7. Local command: `julia --startup-file=no --history-file=no --project=.private/verification-20261126/unpacked .private/verification-20261126/statistics-review.jl`. All diagnostic assertions passed; process exit 0, empty stderr. No Monte Carlo trajectories were rerun.

- For [1,2,4,8], mean=3.75, sample SD=3.0956959368, SE=1.5478479684; p05=1.15, median=3, p95=7.4. Normal-approximation mean interval [0.7162179819,6.7837820181]. This verifies arithmetic, not adequacy of normal coverage for n=4.
- Wilson bounds matched independently solved score-test quadratic roots within 1e-12 for counts 0/500, 51/500, 500/500, 1/2 and 1/10. An independent arithmetic audit also checked the nine retained event-probability CSV rows against their recorded counts; raw event classification was not regenerated.
- Zero events out of 500: two-sided 95% Wilson upper bound 0.00762434046. A separately calculated one-sided exact 95% bound is 0.00597355152; the two conventions must not be conflated.
- Tied-rank example x=[1,1,2,3], y=[4,1,2,3] returned Spearman 0.10540925534, matching Pearson correlation of manually assigned average ranks. Reverse ordering returned -1; a constant vector returned missing.
- Paired example [10,20,30,40] minus [9,18,27,36] gave mean difference 2.5 and SE 0.6454972244, matching calculation from the four within-pair differences.

The code uses corrected sample SD (n-1 denominator), default linearly interpolated sample quantiles, approximate z-based mean intervals, Wilson score event intervals and tie-aware rank correlation. No formula error was found. Mean intervals are conditional Monte Carlo precision, not prediction intervals or coverage of physical/model error. Quantile and Spearman uncertainty are not quantified. Zero observed variance returns missing mean-interval endpoints. Without raw historical outcomes, saved means, quantiles, paired SDs and sensitivity coefficients cannot all be independently reconstructed from the aggregate CSVs.

## Fresh metrics and JavaScript consistency audit — 26 November 2026

Julia 1.12.7 reran unchanged `test/experiments.jl`: 28 threshold-duration and 38 fixed-strategy/refinement checks passed. Local runner `.private/verification-20261126/metrics-review.jl` exported fresh full trajectories and metrics for default (35 people,29 C,2 m/s), cool/empty (0,22,1), hot/calm (45,34,0), and low-wind (35,29,0.2) cases. Each case used all three strategies, 15-second steps and a 7.5-second comparison. Julia process exit 0, empty stderr. No model, notebook, demo or shipped reference was modified.

`node .private/verification-20261126/metrics-review.cjs` ran on Node v22.22.3, comparing all 481 saved states for each of the 12 trajectories and four demo metrics. Maximum cross-language discrepancies: 8.186e-12 ppm, 2.842e-14 C and 2.079e-11 seconds in time/duration comparisons. All passed 0.01 ppm, 0.001 C and one-second tolerances. The shipped reference and newly exported default reference passed the demo checker; an intentionally wrong peak failed as expected. This was numerical execution in Node, not browser UI verification.

JavaScript boundary fixtures passed for upward/downward crossings, equality, full intervals, a segment crossing both temperature-band edges and no extra final advance. Private in-memory instrumentation exposed internal functions for these checks without changing docs/script.js. Both languages include initial states in maxima; cool/empty cases retained initial peaks of 450 ppm and 28 C while final states were lower.

Default full-lecture metrics (fresh Julia):

| Strategy | Peak CO2, ppm | Peak temperature, C | Above 1000 ppm, min | Outside 24–30 C, min |
| --- | ---: | ---: | ---: | ---: |
| Closed | 5723.8279886 | 54.72212191 | 110.36059729 | 117.25438899 |
| Half open | 681.3834623 | 31.95796511 | 0 | 117.15423355 |
| Fully open | 557.1260087 | 30.62127575 | 0 | 116.82176415 |

All default temperature-outside time is above 30 C. Default half-step differences were at most 7.185e-11 ppm in peaks, 5.828e-11 C in temperature peaks, 0.002075 seconds in CO2 duration and 0.125838 seconds in temperature-outside duration.

Analytical crossing diagnostic C=420+780 exp(-t): exact crossing log(780/580)=0.296265816143 h. Interpolated-duration errors for h=0.1,0.05,0.025 h were 0.637057,0.308768,0.142520 seconds. These measure interpolation error on exact sampled states, not ODE error. The existing finest-grid tolerance of 1e-4 hours passed; a smooth fourth-order crossing claim is not supported.

Discrepancies and limitations found:

- Julia ends at exactly 2 hours. Repeated JavaScript time addition ends at 1.9999999999999942 hours, about 2.079e-11 seconds short. Its stopping tolerance prevents an extra step; this is negligible roundoff.
- Hot/calm full-opening peak CO2 changed by 0.0392103 ppm on the first halving, exceeding the strict 0.01 ppm default refinement target, although the two languages still agreed and the difference was below the Monte Carlo 0.1 ppm peak tolerance. Further step sizes 15,7.5,3.75,1.875 seconds gave peaks 814.383340,814.422550,814.409581,814.424889 ppm, respectively. Differences are nonmonotone and the last pair still differs by 0.015308 ppm. The zero-wind stack crossing and sampled peak location require further refinement/event-aware investigation before claiming 0.01 ppm accuracy for this case. No universal slider-range accuracy claim is made.
- The demo reference checker fails to reject a NaN checkpoint concentration: NaN comparisons are false, and checkpoint finiteness is not checked. Metric finiteness is checked. This is a reference-checker validation defect, not a demonstrated trajectory mismatch. The checker also relies on fixed array order and does not validate checkpoint time metadata.
- Peaks are sampled maxima, not continuous extrema. Piecewise-linear duration formulas correctly handle one crossing per threshold per segment but cannot recover unsampled excursions. Displayed durations convert hours to minutes once, and duration tolerances convert hours to seconds. Browser rendering and controls remain a separate unperformed check in this audit.

## Reference-checker fix and new verification - 26 November 2026

The owner explicitly requested the reference-checker fixes and focused positive/negative checks. The checker defect described in the preceding audit is now resolved for the tested reference schema. Only `check(reference)` in `docs/script.js` changed; the physical model, integrator, metric extraction and browser controls were preserved.

The checker requires exactly one strategy with each identity `closed`, `partial`, `full`, and exactly one checkpoint at each of 0, 0.5, 1 and 2 hours. Strategies are matched by identity and checkpoints by time, so reordering either reference array is accepted. Missing, unknown or duplicate identities and missing, duplicate or incorrect times fail. These specified times are exactly representable binary fractions; exact metadata equality is intentional. Checkpoint concentrations, temperatures and times must be finite JavaScript numbers: missing values, numeric strings, null, booleans, objects, arrays, NaN and infinities fail without numeric coercion. Existing metric validation and tolerances remain 0.01 ppm, 0.001 C and one second (1/60 minute).

New executions on Node v22.22.3 and Julia 1.12.7, all exit code 0:

- `node notebook/reference-checks.cjs`: **372 checks passed**. This public, dependency-free runner accepts the shipped reference, reordered references and finite checkpoint deviations within tolerance. It rejects corrupted numeric fields at every strategy/checkpoint position, malformed structures, incorrect identities/times, swapped labels attached to wrong values, and incorrect metrics. Failure cases must return nonempty diagnostics.
- `node .private/verification-20261126/checkpoint-regression.cjs --expect-fixed`: **144 invalid cases, zero incorrectly accepted**. The pre-fix diagnostic accepted 51 of these 144; that is prior evidence, not the post-fix outcome.
- `node --check docs/script.js`: syntax check passed.
- `julia --startup-file=no --history-file=no --project=.private/verification-20261126/unpacked .private/verification-20261126/metrics-review.jl`: newly reran the unchanged embedded experiment tests, **28 threshold-duration plus 38 fixed-strategy/refinement checks passed**. Exported fresh Julia trajectories for default, cool/empty, hot/calm and low-wind forcing, each with all three strategies and half-step comparisons.
- `node .private/verification-20261126/metrics-review.cjs`: compared all 481 states of each of those 12 fresh trajectories and four displayed metrics. Maximum discrepancies were 8.186e-12 ppm, 2.842e-14 C and 2.079e-11 seconds, within the above tolerances. Both shipped and freshly exported default references passed; corrupted peaks and NaN checkpoints failed. Crossing and final-step fixtures passed. The private diagnostic was updated to include strategy/time metadata required by the checker.
- The same diagnostic compared the pre-fix script snapshot with the new script: all source outside `check` was identical, and serialized simulation outputs for all four forcing cases were identical before/after.

The notebook and shipped reference were unchanged, confirmed by SHA-256 respectively `0e531987436c5b40b04a492b60e1d985ba1270cca8a9006505cee8521365fd11` and `9edc64eee07ef9b170abcf9e1d0308d2513c2a2bf96e401d389640a500284438`. No scientific output regeneration was needed for publication because the model/output values did not change. Private runners use the existing extracted notebook environment; the public focused runner needs only Node and the repository files.

These are new targeted numerical checks, not a new full-notebook/302-check/500-scenario run or browser UI test. No empirical validation is claimed. The hot/calm fully-open half-step peak difference again measured 0.0392103 ppm; the preceding refinement limitation remains unresolved and was not masked by changing the model or tolerances.

## Hot/calm refinement investigation - new runs, 26 November 2026

The previously unresolved discrepancy is now explained and quantified, while the production accuracy limitation remains. Full derivation, error table, commands and scope are in [hot-calm-accuracy.md](notes/hot-calm-accuracy.md); machine-readable results are in [hot-calm-results.json](notes/hot-calm-results.json). Public diagnostic sources: `notebook/hot-calm-review.jl` and `notebook/hot-calm-demo-checks.cjs`.

Actual command: `julia --startup-file=no --history-file=no --project=.private/verification-20261126/unpacked notebook/hot-calm-review.jl notebook/notes/hot-calm-results.json`, Julia 1.12.7. Final run exit 0, four reference-convergence/cross-method assertions passed. An independently evaluated transformation integrates time and CO2 versus signed square-root temperature difference, splitting at equality. Four reference resolutions and two explicit-midpoint cross-checks support a peak of 814.417082174638 ppm at 617.991151359107 seconds; equality occurs at 244.647592868665 seconds. Midpoint's finest peak differs by 6.648e-9 ppm. This is a numerical reference, not an exact analytical solution or physical calibration.

Production RK4 ran at eleven steps from 15 to 0.0146484375 seconds. At 15 seconds, total peak error is -0.0337426134 ppm, separated into -0.0028660132 ppm from sampling and -0.0308766002 ppm from integration. Maximum shared-time error over the reference window (0 to 1051.272129 seconds) is 0.0730419458 ppm and 4.3293e-5 C. Nonmonotone error persists under refinement because the square-root crossing changes position relative to RK stages. All tested steps at or below 0.9375 seconds had peak error below 0.00025 ppm and shared-time concentration error below 0.0009 ppm in that window; these are scoped observed errors, not universal bounds.

Smooth restart at T=35 C recovered orders 4.1593,4.0804,4.0407,4.0291. Exact-crossing restart retained about order 1.5, showing that event location/splitting alone cannot restore order four. No evidence of a wrong RK4 implementation was found. No production code, notebook, reference payload, physical coefficient, default step or tolerance was changed. The 0.01 ppm absolute peak goal fails for the current hot/calm 15-second case; cross-language agreement does not establish that goal. Documentation now makes this distinction explicit. Choosing a general production substepping/event method requires broader verification; tolerance relaxation was not used as a remedy.

`node notebook/hot-calm-demo-checks.cjs notebook/notes/hot-calm-results.json` on Node v22.22.3 passed comparisons of peaks/endpoints at all eleven levels and the normal demo run. Maximum peak/final-CO2/final-temperature discrepancies: 2.956e-12 ppm / 1.137e-13 ppm / 0 C, against 1e-7 ppm and 1e-8 C limits. `node notebook/reference-checks.cjs` again passed all 372 checks. Both exit 0. The final JSON export was regenerated by the successful Julia run.

Diagnostic development failures are not hidden: SciPy was unavailable, so no SciPy run is claimed. The first transformed interval ended at 37 C and did not bracket the peak; extending it to 38 C resolved the root-bracket assertion. A subsequent Julia diagnostic run stopped at a global soft-scope variable error; that diagnostic was corrected before the final successful run. No production implementation was changed by these corrections.

No full 302-test suite, notebook replay, Monte Carlo, browser UI or empirical validation was run for this investigation. Notebook/reference SHA-256 remain the values in the preceding section. Demo script SHA-256 is `06650baa1aea817f20ae9f3abe65489552d166bcd54106a20d185fd16f0787bb`. The investigation adds diagnostics/results and documentation only.

## Standard experiments and reconstructible exports - 26 November 2026

This section supersedes earlier pending rerun statements for the standard experiments. Full results and precision interpretation: [standard-run-20261126.md](notes/standard-run-20261126.md). Export schema and reconstruction instructions: [tables README](../figures/tables/README.md).

Final fresh-process Julia 1.12.7 replay executed all six notebook code cells sequentially in **30.461 seconds**, using preinstalled dependencies with installation explicitly skipped. **302 existing tests passed**, including analytical, convergence, conservation, thermal, sampling and experiment checks. Observed finest smooth CO2/temperature orders were Euler 1.015366/1.036466 and RK4 4.030083/4.068586. All stdout, warnings and three notebook plot outputs were refreshed from that successful run. Root/embedded environments match; all **21 embedded payload hashes** were verified, including the new reporting script. Existing physical-model and solver sources remain unchanged. Notebook and reference hashes in earlier sections refer to their earlier versions; current execution and output hashes are recorded in `figures/tables/run_manifest.json`.

Actual local replay command: `julia --startup-file=no --history-file=no --project=.private/verification-20261126/unpacked .private/verification-20261126/replay-refresh.jl`. The notebook still defaults to installing dependencies in its temporary project; this local wrapper explicitly skipped installation. Pkg reported 28 dependencies precompiled but different versions currently loaded; the warning is retained in notebook output. This run does not establish fresh installation, Colab timing or browser success.

The final cell now includes the embedded `verification/export-results.jl`, synchronized with public `notebook/export-results.jl`. It exports 500 complete inputs, all weather profile knots, 1500 strategy outcomes and 1500 half-step records using **Xoshiro(4042)**. Repeated sampling at the same seed matched. Strategy groups were checked for unique matching IDs 1:500; no outcomes were dropped. Summary tables are generated after reading the raw outcome JSON back. The prefix-report loop now excludes prefixes longer than the available sample count. Model equations, step sizes and tolerances were not changed.

Standard deterministic dt=1/240 h versus 1/480 h passed. The standard Monte Carlo used dt=1/480 h with 1/960 h comparison in every scenario. Maximum peak-CO2/peak-temperature/CO2-duration/temperature-duration differences: **0.0130941354 ppm / 4.346079e-6 C / 0.030182914 s / 0.040798993 s**, below unchanged limits 0.1 ppm / 0.005 C / 1 s / 1 s. These are inter-grid differences, not exact-error bounds. The separate hot/calm accuracy limitation remains.

Actual post-export commands, all exit 0:

- `python notebook/reconstruct-summaries.py`: **825 numeric/missing aggregate fields** independently reconstructed from saved raw inputs/outcomes, including means, SDs, SEs, intervals, percentiles, paired comparisons, Wilson intervals and Spearman associations. Standard-library implementation; numeric comparisons use relative 1e-12 and absolute 1e-10 tolerances.
- `node notebook/reference-checks.cjs`: **372 checks passed** against the freshly exported default Julia reference, Node v22.22.3.
- `node notebook/hot-calm-demo-checks.cjs`: eleven-level peak/endpoint comparison passed against the previously saved hot/calm Julia export; those Julia trajectories were not rerun during this refresh.

All selected deterministic/Monte Carlo/convergence tables and figures were regenerated. Outcome, sensitivity and weather PNGs were visually inspected for readable layout; browser UI was not exercised. Saved summaries/event probabilities/sensitivities and deterministic common fields reproduce the pre-refresh values exactly; paired duration summaries differ by at most 8.882e-15 due to arithmetic order. The public raw-data exports and independent reconstruction script are new. The refreshed notebook has six execution counts and three embedded plot outputs.

Execution issues: the first sandboxed replay was denied environment access; the authorized expanded-permission replay ran the experiments but its wrapper failed while collecting a newly defined global for metadata. That wrapper was corrected. An initial export draft used unweighted weather knot means, changing sensitivity values; comparison against the archived runner identified this and the final exporter restored trapezoidal time-weighted means. The final complete replay above succeeded after these corrections. No failed run is represented as the final successful run.

Sampling conclusions: peak-CO2 mean SEs are 49.833/4.938/3.274 ppm (closed/partial/full). Partial CO2 event probability is 10.2%, Wilson interval 7.843%-13.163%; full's 0/500 interval is 0%-0.7624%. All 500 scenarios in every strategy had a thermal excursion. Full-minus-partial mean peak difference is -171.397 ppm, paired SE 1.750 ppm. The results support conditional improvement under the assumed inputs, not real-building validation or a guarantee of zero risk. Half-open duration and rare-event/tail precision remain weaker; no universal sufficiency claim for n=500 is made.
