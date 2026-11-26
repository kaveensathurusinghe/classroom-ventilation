"""Independent stdlib-only check of published summaries from saved scenario data.
Run: python notebook/reconstruct-summaries.py [figures directory]
Does not import Julia, resample, or simulate trajectories.
"""
import csv,json,math,pathlib,statistics,sys
base=pathlib.Path(sys.argv[1]) if len(sys.argv)>1 else pathlib.Path(__file__).resolve().parents[1]/'figures'
tables=base/'tables'
raw=json.loads((tables/'monte_carlo_raw.json').read_text(encoding='utf-8'))
assert raw['seed']==4042 and raw['sample_count']==500
inputs={s['id']:s for s in raw['inputs']}
assert len(inputs)==500
groups={s:{} for s in ('closed','partial','full')}
for r in raw['outcomes']:
    assert r['id'] not in groups[r['strategy']]
    groups[r['strategy']][r['id']]={**r,'minutes_above_co2':60*r['hours_above_co2'],
        'minutes_outside_temperature_band':60*r['hours_outside_temperature_band']}
assert all(set(g)==set(inputs) for g in groups.values())
assert len(raw['refinements'])==1500
def quantile(x,p):
    x=sorted(x);i=(len(x)-1)*p;k=math.floor(i)
    return x[k]+(i-k)*(x[min(k+1,len(x)-1)]-x[k])
def summary(x):
    m=statistics.mean(x);sd=statistics.stdev(x);se=sd/math.sqrt(len(x))
    return dict(n=len(x),mean=m,sd=sd,mc_standard_error=se,
        mean_ci_low=m-1.96*se if sd else None,mean_ci_high=m+1.96*se if sd else None,
        p05=quantile(x,.05),median=quantile(x,.5),p95=quantile(x,.95))
def wilson(k,n):
    z=1.959963984540054;p=k/n;d=1+z*z/n
    c=(p+z*z/(2*n))/d;h=z*math.sqrt(p*(1-p)/n+z*z/(4*n*n))/d
    return dict(successes=k,n=n,probability=p,ci_low=0 if k==0 else c-h,ci_high=1 if k==n else c+h)
checks=0
def compare(row,expected):
    global checks
    for key,v in expected.items():
        actual=row[key]
        assert (actual=='' if v is None else math.isclose(float(actual),v,rel_tol=1e-12,abs_tol=1e-10)),(row,key,v)
        checks+=1
def rows(name):
    with (tables/(name+'.csv')).open(encoding='utf-8',newline='') as f:return list(csv.DictReader(f))
for name in ('monte_carlo_summary','monte_carlo_precision_prefixes','monte_carlo_paired_differences'):
    for r in rows(name):
        ids=sorted(inputs)[:int(r['n'])];g=groups[r['strategy']]
        x=[g[i][r['metric']] for i in ids]
        if 'reference' in r:x=[v-groups[r['reference']][i][r['metric']] for v,i in zip(x,ids)]
        compare(r,summary(x))
for r in rows('monte_carlo_event_probabilities'):
    g=groups[r['strategy']].values()
    predicates={'any_co2_exceedance':lambda v:v['minutes_above_co2']>0,
        'any_temperature_exceedance':lambda v:v['minutes_outside_temperature_band']>0,
        'both_limits_met_entire_lecture':lambda v:v['minutes_above_co2']==0 and v['minutes_outside_temperature_band']==0}
    compare(r,wilson(sum(predicates[r['event']](v) for v in g),len(inputs)))
def ranks(x):
    return [1+sum(v<t for v in x)+(sum(v==t for v in x)-1)/2 for t in x]
def spearman(x,y):
    a,b=ranks(x),ranks(y)
    if len(set(a))==1 or len(set(b))==1:return None
    return statistics.correlation(a,b)
knots=raw['weather_knots']
def input_value(s,key):
    if key=='ua_w_per_k':return s['envelope_ua_w_per_k']
    if key in ('mean_outdoor_temperature_c','mean_local_wind_mps'):
        field='temperature_c' if key=='mean_outdoor_temperature_c' else 'wind_10m_mps'
        p=sorted((k for k in knots if k['profile_index']==s['profile_index']),key=lambda k:k['hour'])
        mean=sum((a[field]+b[field])/2*(b['hour']-a['hour']) for a,b in zip(p,p[1:]))/(p[-1]['hour']-p[0]['hour'])
        return mean*(1 if field=='temperature_c' else s['wind_factor'])
    return s[key]
for r in rows('monte_carlo_sensitivity'):
    ids=sorted(inputs)
    compare(r,{'spearman_rho':spearman([input_value(inputs[i],r['input']) for i in ids],[groups[r['strategy']][i][r['metric']] for i in ids])})
print(f'PASS: {checks} aggregate numeric/missing fields reconstructed from 500 saved inputs and 1500 paired outcomes; seed metadata 4042.')
