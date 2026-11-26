# References and source status

These sources explain the model family, numerical methods and statistical summaries. Relevant paper sections and documentation were opened and checked during development on 25-26 November 2026. They do not validate the assumed classroom, fixed coefficients or synthetic input distributions.

1. EnergyPlus, *Engineering Reference, Version 24.2*, “Infiltration/Ventilation,” section “Ventilation by Wind and Stack with Open Area.” https://bigladdersoftware.com/epx/docs/24-2/engineering-reference/infiltration-ventilation.html . Supports equation form; fixed coefficients and added infiltration remain project assumptions.
2. A. Persily and L. de Jonge, "Carbon dioxide generation rates for building occupants," *Indoor Air*, vol. 27, no. 5, pp. 868-879, 2017. [DOI 10.1111/ina.12383](https://doi.org/10.1111/ina.12383); [NIST-hosted paper](https://tsapps.nist.gov/publication/get_pdf.cfm?pub_id=920870). Relevant sections on generation variability were checked. This supports metabolic variability, not the project's exact distributions or shared heat/generation multiplier.
3. Open-Meteo, “Historical Weather API.” https://open-meteo.com/en/docs/historical-weather-api . Supports historical reanalysis interpretation and input variables/units.

Inherited weather attribution also credits Copernicus ERA5: https://doi.org/10.24381/cds.adbb2d47 . This identifier was preserved, not independently resolved in this rebuild.

4. S. Batterman, "Review and Extension of CO2-Based Methods to Determine Ventilation Rates with Application to School Classrooms," *International Journal of Environmental Research and Public Health*, vol. 14, no. 2, article 145, 2017. [DOI 10.3390/ijerph14020145](https://doi.org/10.3390/ijerph14020145); [full text](https://pmc.ncbi.nlm.nih.gov/articles/PMC5334699/). Supports the fully mixed transient mass balance and its occupancy/mixing limitations. The project solves a forward problem; it does not estimate ventilation from classroom observations.

5. G. E. Ovando-Chacon, A. Rodriguez-Leon, S. L. Ovando-Chacon, M. Hernandez-Ordonez, M. Diaz-Gonzalez, and F. de J. Pozos-Texon, "Computational Study of Thermal Comfort and Reduction of CO2 Levels inside a Classroom," *International Journal of Environmental Research and Public Health*, vol. 19, no. 5, article 2956, 2022. [DOI 10.3390/ijerph19052956](https://doi.org/10.3390/ijerph19052956); [full text](https://pmc.ncbi.nlm.nih.gov/articles/PMC8910020/). Contrasting spatial CFD model; its mechanically ventilated conditions and results are not transferred to this natural-opening model.

6. W. S. Dols and B. J. Polidoro, *CONTAM User Guide and Program Documentation Version 3.4*, NIST Technical Note 1887 Revision 1, 2020. [DOI 10.6028/NIST.TN.1887r1](https://doi.org/10.6028/NIST.TN.1887r1); [publication record](https://www.nist.gov/publications/contam-user-guide-and-program-documentation-version-34). Describes a more detailed multizone alternative. The publication record and abstract were checked; full manual review is not claimed.

7. T. A. Driscoll and R. J. Braun, "Euler's method," *Fundamentals of Numerical Computation*, online Julia edition, sec. 6.2. [Chapter](https://tobydriscoll.net/fnc-julia/ivp/euler.html). Supports the explicit method and first-order error framework.

8. T. A. Driscoll and R. J. Braun, "Runge-Kutta methods," *Fundamentals of Numerical Computation*, online Julia edition, sec. 6.4. [Chapter](https://tobydriscoll.net/fnc-julia/ivp/rk.html). Supports multistage integration; smooth-problem order does not automatically extend across the nonsmooth stack-flow crossing.

9. NIST/SEMATECH, "Confidence intervals," *e-Handbook of Statistical Methods*, sec. 7.2.4.1. [Documentation](https://www.itl.nist.gov/div898/handbook/prc/section2/prc241.htm). Supports Wilson score event-probability intervals, including zero-event interpretation.

Code uses the MIT licence. Data retains the attribution and terms in [data/README.md](data/README.md). Source support for equations is distinct from empirical validation of the project.
