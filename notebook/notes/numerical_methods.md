> Inherited development note. Stage descriptions and earlier run claims are historical; see VERIFICATION.md for rebuild execution.

# Numerical methods and verification: stage 3

Manual forward Euler and classical fourth-order Runge–Kutta (RK4) are implemented
in `src/solvers/explicit.jl`. No third-party solver or new dependency is used.

## Method and interface

For `u' = f(t,u)` and step h, Euler updates `u_next = u + h f(t,u)`.
RK4 uses:

```text
k1 = f(t,       u)
k2 = f(t+h/2,   u+h*k1/2)
k3 = f(t+h/2,   u+h*k2/2)
k4 = f(t+h,     u+h*k3)
u_next = u + h*(k1 + 2*k2 + 2*k3 + k4)/6
```

Each stage recomputes the derivative using that stage's time and state. For the
classroom model this also recomputes temperature-dependent ventilation.

```julia
using ClassroomVentilation
room, air, forcing = RoomParameters(), VentilationParameters(), Forcing()
rhs = (t, u) -> derivatives(u, forcing, FIXED_STRATEGIES.partial, room, air)
validate = u -> begin
    0 <= u[1] <= 1e6 && u[2] > -273.15 || throw(DomainError(u))
    nothing
end
solution = solve_ode(rhs, INITIAL_STATE, (0.0, 2.0);
                     dt=1/240, method=:rk4, validate_state=validate)
# times in hours; states[1, :] is ppm; states[2, :] is degrees Celsius.
```

The illustrative step above is not a universal accuracy guarantee. The solver
uses Float64, accepts a nonempty tuple/vector, and returns a matrix with one
column per saved time. It preserves the caller's initial state. RHS callbacks
must not mutate their input. A positive finite step, forward finite time span,
matching finite derivatives and a step-count bound are required. A zero-duration
span returns only the initial state. The last step is shortened, with
floating-point endpoint snapping, to include the exact requested final time.

The optional validator runs at all intermediate stages and accepted endpoints.
The generic solver always checks finiteness but cannot infer physical bounds.
No clipping, adaptive error control, event detection or stiffness treatment is
implemented. Time-dependent forcing belongs in the RHS and must be evaluated
at each stage. Split runs at known discontinuities using the appropriate forcing
on each segment; no scheduler is implemented yet.

## Analytical reference and convergence experiment

`verification/benchmarks.jl` supplies a separate constant-coefficient analytical
reference. Each component has the form `x' = s + a*(x_out-x)`:

```text
x(t) = x_out + (x0-x_out)*exp(-a*t) + s*(1-exp(-a*t))/a,  a > 0
x(t) = x0 + s*t,                                         a = 0
```

For CO₂, `a=ACH` and `s=1000*N*G/V`. For temperature,
`a=ACH+3600*UA/(rho*cp*V)` and `s=3600*(N*q+Q)/(rho*cp*V)`.
The implementation uses `expm1` to reduce cancellation for small `a*t`.
Time in this expression is elapsed time from the initial condition.

The convergence case uses zero occupants, constant ACH=1 h⁻¹, the default room,
outdoor CO₂=420 ppm, outdoor temperature=25°C, initial state=(1200 ppm,32°C),
and duration=2 h. Both variables relax toward outdoor conditions. Errors are the
maximum absolute differences from the analytical solution at all saved points
on each grid, calculated separately by component. Observed order is
`log2(error(h)/error(h/2))`. It is not estimated from a mixed-unit vector norm.

Run:

```powershell
julia --startup-file=no --project=. -e 'using Pkg; Pkg.test()'
julia --startup-file=no --project=. scripts/verify_solvers.jl
```

The second command writes `results/tables/solver_convergence.csv` and
`solver_convergence_metadata.txt` with inputs, Julia version, Git revision and
working-tree status. These generated files are ignored by Git and can be
reproduced. No random seed is needed for these deterministic calculations.

## Observed results

Run on Julia 1.12.7: all **174 checks passed**, including 91 earlier checks and
83 new solver/trajectory checks. The following values are rounded from the
executed convergence study, not theoretical error estimates:

| Method | Step (h) | Max CO₂ error (ppm) | Max temperature error (°C) |
| --- | ---: | ---: | ---: |
| Euler | 0.2 | 31.3556 | 0.761295 |
| Euler | 0.1 | 14.9768 | 0.334192 |
| Euler | 0.05 | 7.32694 | 0.157886 |
| Euler | 0.025 | 3.62466 | 0.0769724 |
| RK4 | 0.2 | 0.00452162 | 0.00149939 |
| RK4 | 0.1 | 0.000259928 | 0.0000770260 |
| RK4 | 0.05 | 0.0000155814 | 0.00000437150 |
| RK4 | 0.025 | 0.000000953739 | 0.000000260534 |

On the final refinement, Euler orders were 1.015 (CO₂) and 1.036 (temperature);
RK4 orders were 4.030 and 4.069. These support the expected first- and
fourth-order behaviour on this smooth benchmark.

## Other checks and interpretation

- Final-time handling for nondividing steps, nonzero start times, short/empty
  intervals, invalid inputs, stage times and physical-validator rejection.
- Nonzero-source analytical solutions, including the zero-ACH/zero-UA linear
  limit, exact equilibrium and isolated conservation throughout trajectories.
- CO₂ budget using an augmented state for cumulative net export in litres:
  `V*C/1000 + exported = V*C_initial/1000 + N*G*t`. The maximum residual was
  below the test tolerance of 1e-9 L for both methods. The integral uses the
  same numerical stages, so this verifies discrete conservation and unit
  consistency; analytical comparisons separately assess integration accuracy.
- Source-free temperature remains between its initial and outdoor values and
  approaches the outdoor value monotonically at the tested stable steps.
- Coupled-model checks use all three opening fractions. RK4 grids of 1/480 and
  1/960 h agree at shared times within 0.001 ppm and 0.0001°C. Euler error
  relative to the finer RK4 reference decreases when refining 1/120 to 1/240 h.
  Agreement is a refinement check, not an exact solution or empirical validation.

## Stability and remaining limits

For scalar decay `y'=-lambda*y`, Euler has amplification `1-h*lambda`;
asymptotic stability requires `0<h*lambda<2`, while nonnegative monotone decay
requires `h*lambda<=1`. RK4 has amplification
`1-z+z²/2-z³/6+z⁴/24`, where `z=h*lambda`. Its stable negative-real interval
extends to approximately z=2.785. Intermediate stage bounds can be stricter
than endpoint stability. Tests demonstrate decay at small steps and growth
at deliberately oversized steps, without hiding it by clipping.

In the constant classroom case the decay rates are ACH for CO₂ and
`ACH+3600*UA/(rho*cp*V)` for temperature. Coupled ventilation changes with state,
so constant-rate stability limits alone do not guarantee accuracy or stability.
Recheck convergence for future extreme weather and uncertainty samples. The
zero-wind stack term is nonsmooth at equal indoor/outdoor temperatures; do not
assume fourth-order convergence across that point or input discontinuities.

This stage verifies numerical behaviour of the stated equations. It does not
resolve the air-only thermal storage limitation or calibrate assumed coefficients.
Strategy metrics, weather ingestion and Monte Carlo are now implemented; see the corresponding notes.
