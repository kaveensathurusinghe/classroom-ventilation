# Public release

Classroom Ventilation Explorer compares fixed window-opening strategies using a transparent, well-mixed classroom model. The public project includes a self-contained Julia notebook, an offline browser demo, scientific documentation, frozen weather and reproducible experiment outputs.

## Entry points

- [Live browser demo](https://kaveensathurusinghe.github.io/classroom-ventilation/)
- [Repository](https://github.com/kaveensathurusinghe/classroom-ventilation)
- [Open the repository notebook in Colab](https://colab.research.google.com/github/kaveensathurusinghe/classroom-ventilation/blob/main/notebook/classroom-ventilation.ipynb)
- [User guide](../../USER_GUIDE.md)
- [Theory and methods](../../THEORY.md)
- [References and source status](../../REFERENCES.md)

## Reproducibility

The standard run uses 500 paired scenarios from `Random.Xoshiro(4042)` and 21 frozen weather blocks. Manual Euler and classical RK4 have independent analytical checks and measured smooth convergence. The saved Colab execution uses Julia 1.12.6, with 302 passing checks, setup in 101.339 seconds and a total of 172.167 seconds. Compiler diagnostics remain in the saved output. Runtime varies, and the export does not identify the account tier or hardware.

Browser calculations are checked against Julia reference values with tolerances of 0.01 ppm, 0.001 C and one second. Numerical consistency is distinct from browser layout or empirical building validation. Run `node notebook/reference-checks.cjs` for focused reference checks and `python notebook/reconstruct-summaries.py` for independent reconstruction of 825 aggregate numeric/missing fields.

## Interpretation

Only air stores heat. High closed-window temperatures can be unrealistic, and no measured classroom calibration is claimed. The CO2 and temperature comparison limits are illustrative. Full opening's zero observed CO2 events in the 500-scenario sample do not establish zero population risk. The nonsmooth hot/calm case has a documented 15-second peak-error limitation.

## Publication notes

Genuine Colab outputs replace local developer-path output in the current notebook. In historical public notebook snapshots, a local workspace prefix may be redacted with an explicit metadata note; numerical values are retained. Original execution evidence is kept separately. Commit dates, author/committer identities and messages are preserved when publication history is cleaned. Code is MIT-licensed; weather retains the attribution and terms in [data/README.md](../../data/README.md).
