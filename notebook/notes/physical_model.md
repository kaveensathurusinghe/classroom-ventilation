> Inherited development note. Stage descriptions and earlier run claims are historical; see VERIFICATION.md for rebuild execution.

# Physical model: stage 2

Implemented in `src/models/`. This stage evaluates instantaneous derivatives;
it does not integrate trajectories or establish empirical validity.

## Interface and units

`RoomParameters` stores constant physical properties. `VentilationParameters`
stores airflow assumptions. `Forcing` stores instantaneous occupancy, outdoor
CO₂, outdoor temperature and local wind speed. All use validated keyword
constructors. State order is `(C, T)` in ppm and °C; time is hours.

```julia
using ClassroomVentilation
room = RoomParameters()
ventilation = VentilationParameters()
forcing = Forcing()
dC_dt, dT_dt = derivatives(INITIAL_STATE, forcing, FIXED_STRATEGIES.partial,
                          room, ventilation)
terms = balance_terms(INITIAL_STATE, forcing, room; ach=2.0)
```

`balance_terms` permits specified constant ACH for verification and exposes
signed source/exchange terms. `derivatives` calculates ACH from the current
temperature and opening fraction. Future RK4 stages must reevaluate both forcing
and ventilation at each stage. Functions do not mutate inputs or use randomness.

## Balances

The implementation follows the original model plan:

```text
dC/dt = 1000 N G / V + ACH (C_out - C)
dT/dt = ACH (T_out - T)
        + 3600 UA (T_out - T) / (rho cp V)
        + 3600 (N q + Q) / (rho cp V)
```

One litre per cubic metre is 1000 ppm, giving the CO₂ source conversion.
`rho cp V` is air heat capacity in J/K; multiplying watts by 3600 converts to
J/hour. Equal inflow and outflow maintain constant zone volume. CO₂ is treated
as a dilute tracer, and air density and specific heat are constant.

## Ventilation

We adapt the wind-and-stack open-area formulation in the
[EnergyPlus 24.2 Engineering Reference](https://bigladdersoftware.com/epx/docs/24-2/engineering-reference/infiltration-ventilation.html#ventilation-by-wind-and-stack-with-open-area)
(accessed 2026-11-22):

```text
A = opening_fraction * opening_area_m2
wind_flow  = Cw A wind_speed                         [m³/s]
stack_flow = Cd A sqrt(2 g H |T - T_out| / (T+273.15)) [m³/s]
ACH = infiltration_ach + 3600 hypot(wind_flow, stack_flow) / V
```

The reference combines wind and stack flow in quadrature and uses indoor
absolute temperature for the buoyancy term. H is the distance from the lower
opening midpoint to the neutral pressure level. It is not the classroom height;
the reference notes that estimating it is difficult. We fix coefficients rather
than computing wind-direction dependence. We additionally assume constant
background infiltration. These are simplified exchange magnitudes, not resolved
flow paths or pressure-network calculations.

## Default parameter register

Every classroom-specific default below is an assumption, not a measurement or
a calibrated estimate. The airflow source supports the equation form; it does
not validate this classroom or the selected parameter set.

| Input | Default | Basis and interpretation |
| --- | --- | --- |
| Volume V | 179.2 m³ | 8 × 7 × 3.2 m, specified in the original model plan |
| Occupants N | 35 | Project nominal value; nonnegative integer |
| Initial C / outdoor C | 450 / 420 ppm | Project assumptions |
| Initial T / outdoor T | 28 / 29°C | Project assumptions |
| Local wind speed | 2 m/s | Project assumption; opening-level input |
| G | 18 L/person/hour | Illustrative source strength, equivalent to 0.005 L/s; requires literature refinement or measurement before final experiments |
| q | 75 W/person | Illustrative sensible gain; no latent heat model; requires refinement before final experiments |
| Q | 0 W | Baseline omits equipment and solar gains; does not assert their real absence |
| UA | 80 W/K | Illustrative aggregate envelope conductance, not derived from a surveyed building |
| rho | 1.2 kg/m³ | Rounded constant air-density approximation |
| cp | 1005 J/(kg K) | Rounded constant dry-air specific heat approximation |
| Full opening area | 2 m² | Assumed equivalent exchange opening area, not a sum of surveyed windows |
| Cw | 0.3 | Fixed illustrative opening effectiveness; orientation and shelter unresolved |
| Cd | 0.6 | Assumed discharge coefficient; geometry unresolved |
| H | 1 m | Assumed neutral-pressure-level separation |
| Infiltration | 0.3 h⁻¹ | Assumed constant background leakage, including with windows closed |
| Opening fractions | 0, 0.5, 1 | Closed, partial, full; fractions of area, not opening angle |
| g | 9.81 m/s² | Fixed gravitational acceleration approximation |

G, q, UA, opening geometry and leakage need evidence or justified uncertainty
ranges before interpreting strategy performance. Uncertainty distributions are now documented in uncertainty.md. Weather API wind at a reference height must not silently
be treated as opening-level wind: document a conversion or an explicit proxy
assumption in the later weather stage.

## Validation and limitations

Parameters must be finite; volume, density and specific heat must be positive.
Heat gains, conductance, generation, wind, area, height and ACH are nonnegative.
Fractions and airflow coefficients are bounded to [0, 1] for this formulation.
Temperatures must exceed absolute zero and concentrations lie in [0, 10⁶] ppm.
These broad guards catch invalid arithmetic inputs; they are not a calibration
domain. The model is intended for classroom conditions and dilute CO₂, not the
extremes allowed by those guards. Invalid states raise errors rather than being
clipped. Negative heat gains (active cooling) are outside the current scope.

Only air stores heat: the default heat capacity is about 216 kJ/K. Occupant heat
alone therefore gives roughly 44 K/hour at the initial instant. This can lead to
unrealistically rapid transients; no wall/furniture storage is included. Envelope
transfer is represented only by UA. Larger openings initially admit hotter air
when outdoors is hotter, even though they increase heat removal once indoors is
hotter. Temperature is never forced into the illustrative comfort band.

The model omits humidity, radiant temperature, local air movement experienced by
occupants, spatial gradients, wind direction and resolved flow paths. It is not
CFD, a validated building model, or a complete thermal-comfort assessment.
At zero wind, the stack expression is nonsmooth at equal indoor/outdoor
temperatures; smooth constant-ACH cases should establish solver convergence
before assessing the coupled model.

## Verification performed

On Julia 1.12.7, `Pkg.test()` passed 91 checks (including 2 package setup checks):

- Parameter ranges and malformed input rejection.
- Closed/calm, wind-only, stack-only and combined airflow limits, including the
  m³/s-to-h⁻¹ conversion and inverse-volume scaling.
- Sealed-room CO₂ accumulation, zero-source conservation, specified-ACH
  equilibria, and independent mass and energy audits in m³ CO₂/hour and watts.
- Heating and cooling directions, envelope transfer and additional gains.
- Agreement with the derivative of analytical CO₂ decay at several times.
- Coupling and the initial hotter-outdoor-air behaviour across opening fractions.

These are equation-level checks. The subsequent solver-stage checks for accuracy,
convergence, stability and trajectory conservation are now documented in
[numerical_methods.md](numerical_methods.md).
Run `julia --startup-file=no --project=. scripts/check_model.jl` to inspect initial
derivatives; its output is not a prediction of a two-hour lecture.
