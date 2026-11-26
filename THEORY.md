# Model and mathematics

One well-mixed, constant-volume room uses time in hours, CO₂ $C$ in ppm and temperature $T$ in °C. Nominal $V=179.2$ m³, $N=35$, initial (450 ppm,28 °C), outdoor (420 ppm,29 °C), two-hour duration and local wind 2 m/s are assumptions.

## Balances

$$\frac{dC}{dt}=\frac{1000NG}{V}+a(C_{out}-C).$$

$G=18$ L/person/hour is illustrative generation, $a$ is ACH in hour⁻¹. One L/m³ is 1000 ppm. Equal inflow and outflow preserve volume.

$$\frac{dT}{dt}=a(T_{out}-T)+\frac{3600UA(T_{out}-T)}{\rho c_p V}+\frac{3600(Nq+Q)}{\rho c_p V}.$$

Baseline $UA=80$ W/K, $\rho=1.2$ kg/m³, $c_p=1005$ J/(kg K), sensible heat $q=75$ W/person and $Q=0$ W are assumptions or rounded air properties. The 3600 factor converts watts to J/hour. Only air stores heat, a major limitation.

## Ventilation

Adapted from [1] with assumed fixed coefficients:

$$A=fA_{max},\quad F_w=C_wAv,\quad F_s=C_dA\sqrt{2gH|T-T_{out}|/(T+273.15)},$$
$$a=a_0+3600\sqrt{F_w^2+F_s^2}/V.$$

Flows are m³/s. $f$ is 0,0.5,1; $A_{max}=2$ m², $C_w=0.3$, $C_d=0.6$, $H=1$ m, $g=9.81$ m/s², $a_0=0.3$ hour⁻¹. $H$ is neutral-pressure-level separation, not room height. Closed windows retain infiltration. This is uncalibrated exchange, not resolved airflow.

## Solvers

Euler: $u_{n+1}=u_n+hF(t_n,u_n)$. Classical RK4 evaluates four slopes at the start, two midpoints and endpoint and combines them with weights (1,2,2,1)/6. ACH is recalculated at each stage. Smooth-problem global orders are one and four. The zero-wind stack function is nonsmooth at equal indoor/outdoor temperature.

For scalar decay rate $\lambda$, Euler stability requires $0<h\lambda<2$, and nonnegative monotone decay requires $h\lambda\le1$. RK4's negative-real stability interval ends near 2.785. These linear limits do not replace nonlinear refinement checks.

The [hot/calm refinement investigation](notebook/notes/hot-calm-accuracy.md) separates sampled-peak loss from ODE error using an independently evaluated temperature-coordinate reference. Smooth-branch RK4 recovers order four, but restarting exactly at the zero-wind temperature crossing gives about order 1.5. Event splitting alone therefore does not restore fourth-order accuracy. At the current 15-second step, that case's CO2 peak error is -0.033743 ppm, dominated by integration error rather than sampled-peak loss. Cross-language agreement tolerances do not bound error against the continuous equations.

## Input modelling and Monte Carlo

`Random.Xoshiro(4042)` supplies paired scenarios reused across all strategies. Whole weather blocks preserve paired wind/temperature; linear interpolation is split at hourly knots. Occupancy is discrete uniform 25–45. Manually inverted triangular variates model metabolic multiplier (0.8,1,1.2), UA (40,80,120), wind adjustment (0.3,0.6,1), and infiltration (0.1,0.3,0.6). Other bounded coefficients and assumptions are tabulated in [input register](notebook/notes/uncertainty.md). Generation and heat share a metabolic multiplier; these distributions are not fitted measurements.

Approximate mean intervals are $\bar{x}\pm1.96s/\sqrt{n}$. With zero observed variance the mean interval is left unspecified. Percentiles describe outcome spread; Wilson intervals describe event-probability sampling uncertainty. Paired differences are calculated within scenarios. Spearman correlations screen associations, not causal effects or variance shares.

## Verification and interpretation

Sensitivity estimates now have paired scenario-bootstrap intervals: 2000 resamples of the 500 frozen scenarios, with ties reranked in each resample. These are pointwise 95% percentile intervals conditional on the assumed inputs and weather pool; constant outcomes retain undefined correlations. See the [method, results and sensitivity intervals](notebook/notes/extension-evidence.md) and [interval plot](figures/monte_carlo/sensitivity_intervals.png). The companion Python postprocessor operates on authoritative Julia outputs; it does not change the physical model. Correlations do not identify causal effects, interaction contributions or variance shares.

For zero occupants and constant ACH: $C(t)=C_{out}+(C_0-C_{out})e^{-at}$. Independent analytical CO₂/heat solutions establish error scaling. An augmented-state budget checks conservation in litres. Source-free temperatures relax toward outdoor conditions at stable steps. Peaks are sampled maxima; threshold durations use piecewise-linear crossings. Browser results are compared with Julia under explicit tolerances.

These verify implementation, not empirical accuracy. The 1000 ppm and 24–30 °C indicators are illustrative. No humidity, radiant comfort, furniture/wall storage or spatial gradients are resolved. See [REFERENCES.md](REFERENCES.md).
