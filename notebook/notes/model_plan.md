> Inherited development note. Stage descriptions and earlier run claims are historical; see VERIFICATION.md for rebuild execution.

# Model assumptions and verification plan

This is a development plan, not simulation results.

Stage 2 is now implemented and documented in [physical_model.md](physical_model.md).
Its parameter register resolves the initial implementation choices below while
retaining the need for evidence and sensitivity analysis before final experiments.
Stage 3 solvers and executed numerical verification are documented in
[numerical_methods.md](numerical_methods.md).
Stage 4 fixed-strategy trajectories, threshold metrics and baseline refinement
are documented in [deterministic_experiments.md](deterministic_experiments.md).
Stages 5–6 weather ingestion, assumed input distributions, Monte Carlo and
sensitivity screening are documented in [uncertainty.md](uncertainty.md).

## Scope and units

Use a well-mixed single zone with time in hours, concentration in ppm and air
temperature in degrees Celsius. The balances are specified in the original model plan.
Classroom volume is 8 × 7 × 3.2 = 179.2 m³. The CO₂ source conversion is
1000 × N × G / V because G is in litres/hour and concentration is in ppm.
ACH is in h⁻¹. Convert heat input in watts to energy per hour using 3600 in
the thermal balance. Any absolute-temperature dependence in a future buoyancy
expression must use kelvin.

Initial conditions, occupancy, weather, comparison threshold and temperature
band in the original model plan are preliminary assumptions, not measured classroom data or
regulatory limits. The temperature band is an illustrative air-temperature
indicator, not a full thermal-comfort model.

## Decisions for the physical-model stage

- Document and justify G, UA, air density, specific heat, occupant sensible heat
  and additional gains. Distinguish assumptions from measurements.
- Select and cite a manageable ventilation parameterization depending on opening,
  wind and temperature difference. Define effective area, opening fractions and
  infiltration separately; closed windows need not imply zero ventilation.
  Label uncalibrated coefficients explicitly.
- State limitations of air-only thermal storage: envelope thermal mass, humidity,
  radiant temperature and spatial gradients are absent. This is neither CFD nor
  a classroom-validated model.
- Define weather location, lecture dates and local hours before downloading data.
  Record API units and convert wind speed to m/s where necessary.
- Justify bounded uncertain inputs and their dependence; do not silently assume
  weather variables are independent.

## Verification gates

Test zero-occupancy constant-ACH CO₂ decay against
`C(t) = C_out + (C(0) - C_out) * exp(-ACH * t)`. Check zero-ACH accumulation,
constant-source equilibrium and CO₂ mass balance. Repeatedly halve the time step
to assess first-order Euler and fourth-order RK4 convergence in a smooth case.
Check positivity and stability for the selected steps; explicit methods are not
stable at arbitrary step sizes and ventilation rates.

Check thermal equilibrium when gains vanish and indoor/outdoor temperatures match,
relaxation toward outdoor temperature without gains, and the constant-coefficient
thermal solution with gains. Do not clip temperature to the comfort band.
Verify final time and threshold durations, including crossings between samples.

Monte Carlo work follows deterministic verification. Record the seed and sampled
inputs, compare all strategies on the same scenarios, and assess sampling
uncertainty separately from numerical error. Qualify sensitivity results by the
assumed distributions and model limitations.
