# User guide

Double-click `docs/index.html` in Chrome, Edge or Firefox. No network is required.

1. Set occupants, outdoor temperature and opening-level wind speed.
2. Press **Start** to animate the three fixed strategies together.
3. **Pause** stops animation; **Start** resumes. **Reset** applies slider settings and returns to initial conditions.
4. Read CO₂/temperature plots and the peaks/threshold-duration table. Metrics cover elapsed time, becoming full lecture metrics at 120 minutes.
5. **Check Julia reference** runs a complete default case independently of slider settings and reports tolerance agreement.

Try 35 occupants, 29 °C and 2 m/s, then reduce wind to 0.2 m/s or raise occupancy to 45. Reset after changing settings. Internal heat can accumulate even when outdoor air is hot.

The comparison limits are illustrative, not health/regulatory limits. Outdoor CO₂ is 420 ppm and initial state is (450 ppm,28 °C). Background infiltration remains with closed windows. Air-only thermal storage can yield unrealistic warming. The demo is deterministic; use the notebook for historical-weather Monte Carlo.

Execution status is in [verification record](notebook/VERIFICATION.md). A labelled screenshot remains to be added after visual browser verification.

The Julia-reference button checks agreement between implementations, not absolute accuracy of the ODE solution. For the tested hot/calm case (45 people,34 C,zero wind,fully open), the demo's 15-second sampled peak is 814.383340 ppm versus a refined continuous reference of 814.417082 ppm: an error of -0.033743 ppm. This case does not meet 0.01 ppm absolute peak accuracy. See the [refinement investigation](notebook/notes/hot-calm-accuracy.md) for error separation and supported finer steps; no universal slider-range accuracy is claimed.
