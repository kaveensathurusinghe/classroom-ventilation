# Hot/calm full-opening accuracy investigation

New runs on 26 November 2026: Julia 1.12.7 and Node v22.22.3. Case: 45 occupants, outdoors 34 C, zero wind, full opening, initial (450 ppm,28 C), all other coefficients unchanged. This is numerical verification of the assumed equations, not classroom validation.

## Reference construction

Temperature rises monotonically through 34 C. Write `x=sign(T-34)*sqrt(abs(T-34))`, so `T=34+x*abs(x)` and `dT/dx=2*abs(x)`. If the original right-hand sides are `fC` and `fT`, integrate

```
dt/dx = 2*abs(x)/fT
dC/dx = fC * 2*abs(x)/fT
```

At zero wind ACH becomes `0.3 + (3600/179.2)*1.2*sqrt(2*9.81/(T+273.15))*abs(x)`. Splitting the transformed grid exactly at x=0 makes each branch smooth. The diagnostic independently evaluates these coefficients and integrates (time,CO2) against x, without calling the production RHS or solver. It uses RK4 in x, cubic Hermite interpolation within each branch and bisection of `dC/dt=0` for the continuous peak. An additional explicit-midpoint integration in x checks with a different integration formula.

The transformation is valid only where `fT>0`, which the diagnostic checks at every evaluation. The reference stops at 38 C (1051.272129 seconds), before thermal equilibrium; it is not a full-lecture reference or a general weather solver. It covers the crossing and peak. The production refinement runs cover the full two hours. No concentration feedback enters the temperature equation.

With 1024,2048,4096,8192 steps on each side, reference peaks were 814.417082173215, 814.417082174549, 814.417082174630, 814.417082174638 ppm. The last two references differed by at most 6.576e-8 ppm and 6.993e-10 C at 501 shared times; their peak values differed by about 8e-12 ppm. Midpoint at 32768 and 65536 steps per side differed from the finest RK4 reference peak by 2.659e-8 and 6.648e-9 ppm, decreasing by approximately four. These are empirical convergence checks, not rigorous error bounds; reported reference digits are computational values, not physical precision.

- Indoor/outdoor equality: **244.647592869 seconds**.
- Continuous CO2 peak: **814.417082175 ppm**, at **617.991151359 seconds**, indoor temperature **37.392127331 C**.

## Error separation

For each production grid, evaluate the reference at exactly the same times. Let P be its continuous peak, S the maximum of those reference samples, and M the production sampled peak. Then `M-P=(S-P)+(M-S)` exactly. `S-P` isolates lost peak height from sampling; `M-S` measures the change in sampled maximum due to ODE error. The maxima in M and S need not occur at the same sample, so the latter is not necessarily a pointwise error at one time. Also compare trajectory states directly at shared times up to the reference endpoint.

| Step, s | Signed total peak error, ppm | Sampling contribution, ppm | ODE contribution, ppm | Max shared-time CO2 error, ppm |
| ---: | ---: | ---: | ---: | ---: |
| 15 | -0.0337426134 | -0.0028660132 | -0.0308766002 | 0.0730419458 |
| 7.5 | +0.0054676529 | -0.0028660132 | +0.0083336661 | 0.0197216371 |
| 3.75 | -0.0075007146 | -0.0001824427 | -0.0073182719 | 0.0181329135 |
| 1.875 | +0.0078068452 | -0.0001824427 | +0.0079892879 | 0.0197933429 |
| 0.9375 | -0.0002032923 | -0.0000101397 | -0.0001931526 | 0.0008933350 |
| 0.46875 | -0.0002429849 | -0.0000101397 | -0.0002328452 | 0.0006627076 |
| 0.234375 | -0.0001281171 | -0.0000009858 | -0.0001271313 | 0.0003293418 |
| 0.1171875 | -0.0000083208 | -0.0000009858 | -0.0000073350 | 0.0000200945 |
| 0.05859375 | -0.0000061346 | -0.0000000026 | -0.0000061320 | 0.0000153554 |
| 0.029296875 | +0.0000005629 | -0.0000000026 | +0.0000005655 | 0.0000013982 |
| 0.0146484375 | -0.0000014365 | -0.0000000026 | -0.0000014338 | 0.0000035677 |

The initial 15-second grid has maximum shared-time temperature error 4.3293e-5 C. Its pre-crossing concentration error is at most 0.00328094 ppm on tested samples, much smaller than the 0.07304195 ppm maximum over the crossing/peak window. Small endpoint error at two hours would conceal this transient: all refined final concentrations agree to about 2e-9 ppm.

## Why refinement oscillates

At zero wind ACH contains `sqrt(abs(T-34))`; its temperature derivative is unbounded at equality. Temperature crosses with nonzero slope, so the CO2 RHS has a square-root cusp in time. The thermal ventilation term additionally multiplies the temperature difference, making it smoother than the CO2 exchange term. This explains the much smaller thermal errors without implying CO2 accuracy.

The crossing lies at fractional positions 0.309840,0.619679,0.239358,0.478716 within the first four step grids. Its position relative to RK4 stages changes on halving; both magnitude and sign of error change. Uniform fourth-order Richardson extrapolation or an order inferred from one pair is inappropriate here. Sampling adds another nonmonotone component, but it is not the main source at 15 seconds.

Two isolation experiments support that explanation:

1. Restart at the reference state at T=35 C and end at the reference time for T=37.8 C, wholly on a smooth branch. Endpoint concentration errors were 1.73194e-4,9.69275e-6,5.72949e-7,3.48122e-8,2.13231e-9 ppm. Successive observed orders were **4.1593,4.0804,4.0407,4.0291**.
2. Restart at the exact crossing state and evaluate at the reference peak time. Steps 15,7.5,3.75,1.875,0.9375,0.46875 seconds gave positive CO2 errors 0.0372281,0.0131661,0.00465494,0.00164574,0.000581850,0.000205714 ppm, approximately **order 1.5**. The nonsmooth endpoint remains even after locating the event exactly. Event splitting alone is insufficient to restore fourth order.

## Decision and supported accuracy

No production model, solver, time step or tolerance was changed. The evidence identifies a regularity limitation, not an incorrect RK4 formula or a Julia/JavaScript mismatch. The existing 0.01 ppm reference-check tolerance measures agreement between implementations; it must not be presented as an absolute ODE accuracy guarantee. A 0.01 ppm absolute peak requirement fails for this case at the current 15-second step.

For this case only, the measured 15-second peak error is 0.033743 ppm and maximum shared-time concentration error in the first 1051.27 seconds is 0.073042 ppm. These are measured errors, not newly relaxed acceptance tolerances or bounds on unsampled times. All seven tested steps from 0.9375 seconds down have absolute peak error below 0.00025 ppm and shared-time concentration error below 0.0009 ppm on the reference window. Thus 0.9375 seconds is a supported candidate for this case if 0.01 ppm is required, with a substantial measured margin; it is not certified for arbitrary inputs. The smallest-step errors still oscillate.

Future correction options are consistent substepping in both languages, or a crossing-aware transformed/adaptive method plus independent peak localization. A general change needs weather/nonmonotone cases, endpoint and duration checks, computational-cost assessment, and regeneration of affected outputs. Dense peak interpolation alone cannot remove the dominant integration error. Smoothing the absolute value would change the physical parameterization and is not justified by this audit. No tolerance was loosened to obtain a pass.

## Reproduction and scope

Run `notebook/hot-calm-review.jl` with the Julia project unpacked by the notebook, where `using ClassroomVentilation` works. The script's optional positional argument is the output JSON path:

```
julia --startup-file=no --history-file=no --project=<unpacked-project> notebook/hot-calm-review.jl notebook/notes/hot-calm-results.json
node notebook/hot-calm-demo-checks.cjs notebook/notes/hot-calm-results.json
node notebook/reference-checks.cjs
```

The actual local run used `.private/verification-20261126/unpacked`; the diagnostic sources and result JSON are public. The Julia diagnostic checks reference peak convergence (1e-7 ppm,1e-6 seconds) and different-method agreement (1e-5 ppm); all four assertions passed. The table deliberately reports production errors instead of imposing a relaxed pass criterion.

Node checked all 11 refinement levels using the demo's exported RK4 step, and its normal 15-second full-opening run. Maximum Julia/JavaScript peak discrepancy was 2.956e-12 ppm, final concentration discrepancy 1.137e-13 ppm and final temperature discrepancy zero; limits were 1e-7 ppm and 1e-8 C. All 372 checker tests passed again. This checks peaks/endpoints at refined steps, not every state of all refined runs. Browser UI, the full notebook, Monte Carlo and empirical classroom validation were not rerun.
