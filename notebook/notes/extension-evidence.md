# Verification and sensitivity evidence assessment

Assessment dated 26 November 2026. This is an evidence assessment, not an award of extension credit. The supplied brief's optional-extension criteria were checked on pages 7-9; its release gate must qualify before X2-X6 count. The core notebook must also run. Final evidence must be publicly visible and summarised in the required report and links document.

## Release gate (X1)

Not established. The minimum is a public repository, live GitHub Pages demo, complete README and no course or university affiliation anywhere in the public release. The full criteria also require the prescribed structure, theory, user guide, references, generic Concepts applied, licence, genuine commit history and final v1.0 tag. The README still lacks a live-demo URL and working Colab badge; fresh Colab execution is pending. The configured remote name contains restricted wording. No remote visibility or hosting success was verified in this assessment, and no publication, repository rename or history rewrite was performed. A release audit must include repository metadata, tracked contents, commit messages and notebook outputs. Private evidence remains ignored. Never fabricate history.

## Rigorous verification (X2)

**Technical evidence supported; eligibility remains conditional on X1.** The requirement is a second independent check plus measured error scaling on a log-log plot.

The notebook's verification cell contains integrating-factor analytical CO2 and thermal solutions independent of the numerical stepper. Source-free CO2 decay is the first check. A separate heat-balance reference uses thermal capacity and envelope conductance; sealed-room source/unit checks and integrated CO2 conservation provide further checks. An augmented budget uses the same stepper, so it is a consistency check rather than an independent solver. JavaScript agreement alone would not establish independent scientific correctness because it ports the same equations and algorithm.

The embedded `verification/benchmarks.jl` measures maximum absolute trajectory error on each grid against the analytical solution at h = 0.2, 0.1, 0.05, 0.025 hours. The existing [log-log plot](../../figures/solver_convergence.png) was visually inspected. [Numeric errors and adjacent-grid orders](../../figures/tables/solver_convergence.csv) give p = log(error(h)/error(h/2))/log(2):

| Method | Finest CO2 order | Finest temperature order |
| --- | ---: | ---: |
| Euler | 1.015366 | 1.036466 |
| RK4 | 4.030083 | 4.068586 |

These are measured smooth-problem orders, not theoretical slopes pasted onto a plot. The successful earlier same-day full notebook replay and 302 tests are recorded in [VERIFICATION.md](../VERIFICATION.md); they were not rerun for this assessment. No new solver implementation is needed merely to claim a second independent check. The [hot/calm transformed-coordinate reference](hot-calm-accuracy.md) is additional independent numerical evidence: its midpoint cross-check agrees within 6.648e-9 ppm, but the nonsmooth crossing does not support fourth-order convergence. Its 15-second production peak error remains -0.033743 ppm. Do not generalise smooth convergence to all operating conditions or confuse numerical verification with empirical validation.

## Sensitivity and uncertainty (X5)

**The missing sensitivity intervals are now supplied.** The existing systematic study crosses 11 input descriptors with four outcomes and all three strategies, using 500 paired scenarios from Xoshiro(4042). It already had mean, event-probability and paired-difference intervals, but these did not quantify uncertainty in the sensitivity coefficients themselves.

[Public postprocessor](../sensitivity-intervals.py) reads the frozen Julia outputs and adds [132 sensitivity rows](../../figures/tables/monte_carlo_sensitivity_intervals.csv) and a [confidence-interval figure](../../figures/monte_carlo/sensitivity_intervals.png). Run `python notebook/sensitivity-intervals.py` from the repository with NumPy and Matplotlib installed. This companion analysis is separate from the Julia notebook's Run all; no model, embedded payload, environment or trajectory has changed. Versions, input hash, script hash and resampling configuration are in the [manifest](../../figures/tables/sensitivity_interval_manifest.json).

Each of 2000 bootstrap replicates samples 500 complete scenario IDs with replacement, using NumPy PCG64 seed 404205. The same index matrix applies to all inputs, outcomes and strategies, preserving weather pairing, shared metabolism and within-scenario strategy dependence. Ranks, including ties, are recomputed inside every replicate. Bounds are the 2.5th and 97.5th percentiles of the bootstrap correlations. These are approximate pointwise 95% sampling intervals, not simultaneous intervals or prediction intervals. Resampling seed 404205 does not replace the original simulation seed 4042. All 121 estimable rows had 2000 finite replicates. Eleven full-opening CO2-duration correlations are undefined because all durations are zero; their estimates and bounds remain blank, not zero.

| Strategy / outcome | Strong association | rho | Pointwise 95% interval |
| --- | --- | ---: | --- |
| Closed / peak CO2 | Occupants | 0.812 | [0.782, 0.839] |
| Closed / peak CO2 | Infiltration | -0.472 | [-0.539, -0.401] |
| Partial / peak CO2 | Mean local wind | -0.586 | [-0.649, -0.517] |
| Full / peak CO2 | Mean local wind | -0.677 | [-0.729, -0.618] |
| Closed / peak temperature | Occupants | 0.656 | [0.603, 0.704] |
| Closed / peak temperature | Envelope UA | -0.564 | [-0.620, -0.501] |
| Partial / peak temperature | Mean outdoor temperature | 0.757 | [0.710, 0.799] |
| Full / peak temperature | Mean outdoor temperature | 0.820 | [0.783, 0.854] |

Thus the inputs most strongly associated with outcomes change with opening strategy. Occupancy and infiltration matter for closed-window CO2; wind is strongly associated with open-window CO2; outdoor temperature is strongly associated with open-window temperature. These support interpreting the ventilation/temperature tradeoff, not selecting a uniquely optimal strategy.

The study screens monotone marginal associations. Weather temperature/wind are dependent, and local wind contains the wind multiplier; descriptors are not independent causal contributions. Interactions and nonmonotone effects can be missed. Intervals condition on the assumed input distributions and fixed weather pool, not uncertainty in the population of weather days, physical parameters or model form. There is no multiple-comparison adjustment or confidence interval for rank ordering; overlapping intervals should not be used to assert a definitive ranking. Air-only heat storage still limits physical interpretation. This is a defensible sensitivity study with intervals, not a Sobol decomposition or empirical validation.

## Unsupported claims

Historical weather input alone is **not X4 calibration or validation**. No classroom observation dataset was used to fit parameters or compare predicted and measured classroom CO2/temperature. Weather supplies forcing only. X3 and X6 were not assessed or claimed. X2/X5 can be presented as supported technical evidence, with X1, core execution and final evidence packaging still required before extension credit can be claimed.
