"""Postprocess frozen Julia outcomes: python notebook/sensitivity-intervals.py.
Requires numpy and matplotlib; no trajectories or model parameters are changed.
AI-generated analysis, with executable independent arithmetic checks.
"""
import csv, hashlib, json, pathlib, platform, runpy
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

ROOT = pathlib.Path(__file__).resolve().parents[1]
d = runpy.run_path(str(ROOT/'notebook/reconstruct-summaries.py'))
tables = ROOT/'figures/tables'
ids = sorted(d['inputs'])
existing = d['rows']('monte_carlo_sensitivity')
B, SEED = 2000, 404205
indices = np.random.Generator(np.random.PCG64(SEED)).integers(0, len(ids), (B, len(ids)))
assert np.array_equal(indices, np.random.Generator(np.random.PCG64(SEED)).integers(0,len(ids),(B,len(ids))))

def rank(x):
    ordered = np.sort(x)
    return (np.searchsorted(ordered,x,'left')+np.searchsorted(ordered,x,'right')+1)/2

def standardized(x):
    r = rank(x); r -= r.mean(); norm = np.linalg.norm(r)
    return r/norm if norm else np.full(len(r),np.nan)

assert np.allclose(rank(np.array([1,1,2,3])),[1.5,1.5,3,4])
assert np.isnan(standardized(np.ones(4))).all()
assert np.isclose(standardized(np.arange(4)) @ standardized(np.arange(4)[::-1]),-1)

cache = {}
def vectors(key, x):
    if key not in cache:
        x=np.asarray(x,float)
        cache[key]=(standardized(x),np.array([standardized(x[i]) for i in indices]))
    return cache[key]

result=[]
for row in existing:
    key, strategy, metric = row['input'],row['strategy'],row['metric']
    x=[d['input_value'](d['inputs'][i],key) for i in ids]
    y=[d['groups'][strategy][i][metric] for i in ids]
    a,boot_a=vectors(('input',key),x)
    b,boot_b=vectors((strategy,metric),y)
    rho=float(a@b)
    assert (not row['spearman_rho'] and np.isnan(rho)) or np.isclose(rho,float(row['spearman_rho']),atol=1e-12)
    boot=np.einsum('ij,ij->i',boot_a,boot_b)
    # Independently rerank selected actual resamples with the stdlib implementation.
    for trial in (0, B-1):
        ii=indices[trial]
        check=d['spearman']([x[i] for i in ii],[y[i] for i in ii])
        assert (check is None and np.isnan(boot[trial])) or np.isclose(check,boot[trial],atol=1e-12)
    valid=boot[np.isfinite(boot)]
    # Undefined replicates are reported; do not condition an interval on their exclusion.
    low,high=np.quantile(valid,[.025,.975]) if len(valid)==B else (np.nan,np.nan)
    result.append(dict(strategy=strategy,input=key,metric=metric,spearman_rho=rho,
        ci_low=low,ci_high=high,valid_bootstraps=len(valid),bootstrap_count=B,n=len(ids)))

out=tables/'monte_carlo_sensitivity_intervals.csv'
with out.open('w',newline='',encoding='utf-8') as f:
    writer=csv.DictWriter(f,fieldnames=result[0]);writer.writeheader()
    writer.writerows({k:('' if isinstance(v,float) and not np.isfinite(v) else v) for k,v in r.items()} for r in result)

names=sorted({r['input'] for r in result})
fig,axes=plt.subplots(2,1,figsize=(11,11),layout='constrained')
for ax,metric in zip(axes,['peak_co2_ppm','peak_temperature_c']):
    for j,strategy in enumerate(['closed','partial','full']):
        rows=[next(r for r in result if r['strategy']==strategy and r['metric']==metric and r['input']==k) for k in names]
        pos=np.arange(len(names))+(j-1)*.22
        rho=np.array([r['spearman_rho'] for r in rows])
        ax.hlines(pos,[r['ci_low'] for r in rows],[r['ci_high'] for r in rows],color=f'C{j}')
        ax.scatter(rho,pos,s=18,label=strategy,color=f'C{j}')
    ax.set(yticks=np.arange(len(names)),yticklabels=[k.replace('_',' ') for k in names],xlim=(-1.05,1.05),xlabel='Spearman correlation; pointwise 95% percentile bootstrap interval',title=metric.replace('_',' '))
    ax.axvline(0,color='grey',linewidth=.7);ax.legend(loc='lower right')
fig.suptitle('Conditional sensitivity associations: 500 paired scenarios, 2000 resamples')
for ext in ('png','svg'):fig.savefig(ROOT/f'figures/monte_carlo/sensitivity_intervals.{ext}',dpi=160)
metadata=dict(seed=SEED,rng='NumPy PCG64',bootstrap_count=B,python=platform.python_version(),numpy=np.__version__,matplotlib=matplotlib.__version__,
    raw_sha256=hashlib.sha256((tables/'monte_carlo_raw.json').read_bytes()).hexdigest(),
    script_sha256=hashlib.sha256(pathlib.Path(__file__).read_bytes()).hexdigest(),
    method='IID scenario-row paired bootstrap; rerank each resample; pointwise percentile 95% CI; undefined replicates suppress CI',
    rows=len(result),undefined_rows=sum(not np.isfinite(r['spearman_rho']) for r in result))
(tables/'sensitivity_interval_manifest.json').write_text(json.dumps(metadata,indent=2)+'\n',encoding='utf-8')
print(json.dumps(metadata,indent=2))
for strategy in ('closed','partial','full'):
    for metric in ('peak_co2_ppm','peak_temperature_c'):
        print(strategy,metric,sorted([r for r in result if r['strategy']==strategy and r['metric']==metric],key=lambda r:abs(r['spearman_rho']),reverse=True)[:2])
