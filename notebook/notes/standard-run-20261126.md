# Standard experiment refresh and sampling precision

New execution on 26 November 2026: six notebook code cells replayed in sequence in a fresh local Julia 1.12.7 process, 30.461 seconds for the final successful run, using preinstalled dependencies. The complete 302-check suite passed. This is not a fresh-install or Colab runtime result. Actual notebook stdout, warnings and three rendered plots were saved. No physics, solver, numerical tolerance or standard experiment step was changed.

Deterministic RK4 used 15-second steps and a 7.5-second comparison. The paired Monte Carlo used 500 scenarios from `Xoshiro(4042)`, 7.5-second steps and a 3.75-second comparison for every strategy/scenario. Sampling was repeated with the same seed and the inputs compared equal. All 1500 outcome records and 1500 refinement records are saved, together with 500 complete inputs and all weather knots. The same scenario ID is reused across closed/partial/full strategies.

## Refreshed results

Default deterministic closed/partial/full peak CO2: 5723.828/681.383/557.126 ppm. Peak temperature: 54.722/31.958/30.621 C. All three exceed the illustrative temperature band; only closed exceeds the CO2 threshold. These values reproduce the previous run.

| Strategy | MC mean peak CO2, ppm | SE of mean, ppm | Approximate 95% mean interval, ppm | CO2 events |
| --- | ---: | ---: | ---: | ---: |
| Closed | 5627.54 | 49.83 | 5529.87-5725.22 | 500/500 |
| Partial | 852.75 | 4.94 | 843.07-862.43 | 51/500 |
| Full | 681.36 | 3.27 | 674.94-687.77 | 0/500 |

The corresponding relative SEs are about 0.89%,0.58%,0.48%. These quantify Monte Carlo precision of conditional means; they do not quantify uncertainty in the physical model or assumed distributions. Outcome spread is much larger: peak-CO2 5th-95th percentiles are 3927.51-7629.43,673.28-1038.90,559.13-805.10 ppm. These percentiles are not confidence intervals, and their sampling uncertainty was not estimated.

Partial-opening CO2 event probability is 10.2%, with two-sided 95% Wilson interval **7.84%-13.16%**. For fully open windows, zero observed CO2 events gives **0%-0.7624%**, not zero population probability. Closed-window CO2 and every strategy's thermal-event intervals are **99.2376%-100%**. Every strategy had 500/500 thermal excursions and 0/500 lectures meeting both limits throughout; this does not prove the corresponding population probabilities are exactly one or zero.

Mean peak temperatures are 60.154,37.212,35.425 C, with mean SEs 0.3101,0.08384,0.07201 C. Mean minutes outside the band are 117.428,117.157,115.970. Partial-opening mean minutes above 1000 ppm is **7.806**, SE **1.128**, approximate mean interval **5.595-10.017** minutes: relative SE about 14.4%, so duration precision is much weaker than peak-mean precision. The full-opening duration sample has zero variance; the implementation leaves its mean interval missing rather than asserting zero uncertainty.

Pairing matters: full minus partial mean peak CO2 is **-171.397 ppm**, SE **1.750**, interval **[-174.827,-167.966] ppm**. Full minus partial peak temperature is **-1.7877 C**, SE **0.01735**, interval **[-1.8217,-1.7537] C**. These intervals use differences within matched scenarios, not two independent means. Peak-temperature and CO2 improvements do not imply an adequate thermal-comfort solution.

## Precision versus numerical error

Across all 1500 Monte Carlo strategy outcomes, maximum coarse/fine differences were:

| Metric | Maximum difference | Unchanged check limit |
| --- | ---: | ---: |
| Peak CO2 | 0.0130941 ppm | 0.1 ppm |
| Peak temperature | 0.00000434608 C | 0.005 C |
| CO2 duration | 0.0301829 s | 1 s |
| Temperature-band duration | 0.0407990 s | 1 s |

All checks passed; no scenario was removed. For these aggregate means, measured half-step differences are small compared with Monte Carlo SEs. A half-step difference is not a bound on exact ODE error, and smooth fourth-order convergence must not be inferred across stack-flow or weather nonsmoothness. The separate hot/calm 15-second demo limitation remains documented in [hot-calm-accuracy.md](hot-calm-accuracy.md). Neither that finding nor the current run justifies loosening tolerances or claiming a universal 0.01 ppm accuracy guarantee.

Prefix peak-mean SEs decrease from n=50 to n=500: closed 152.31 to 49.83 ppm, partial 15.37 to 4.94 ppm, full 10.28 to 3.27 ppm, broadly consistent with the expected square-root sample-size scaling. Prefix means fluctuate: the full-opening mean is 663.50,676.89,675.91,681.36 ppm at n=50,100,250,500. These nested samples are correlated and are not evidence of unbiased physical predictions or a formal stopping rule. No user-specified precision target was supplied; the run supports comparison at these reported precision levels, not a blanket claim that 500 is sufficient for rare events, tail quantiles or sensitivity rankings.

## Interpretation and provenance

Under the prescribed distributions and one-month reanalysis weather pool, increased opening substantially reduces CO2 accumulation and peak air temperature. None of the tested strategies reliably keeps the illustrative air-temperature band for the whole lecture. This is conditional evidence for a tradeoff study, not an empirically validated optimum, a regulatory compliance assessment or a calibrated building-design recommendation. Air-only thermal storage, assumed ventilation coefficients, omitted humidity/radiation/wall storage and limited weather representativeness remain major limitations.

The final summaries, event probabilities, sensitivity values and shared deterministic table fields exactly reproduce the pre-refresh tables. Paired duration summaries differ only by up to 8.882e-15 due to subtraction/conversion ordering. The final sensitivity export preserves time-weighted weather means. An initial reporting draft used unweighted knot means and was corrected after comparison with the archived runner, before the final execution. Figures were regenerated, including four outcome panels and both peak sensitivities.

The independently implemented Python reconstruction passed **825 numeric/missing fields** across summaries, prefixes, paired differences, Wilson intervals and Spearman coefficients from saved raw inputs/outcomes. All **372 JavaScript reference checks** passed against the freshly exported Julia reference. A separate Node check also passed the eleven previously exported hot/calm refinements; those Julia hot/calm trajectories were not rerun in this refresh. Visual inspection checked the refreshed outcome, sensitivity and weather plots; this is not browser UI verification.
