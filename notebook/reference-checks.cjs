// Run from any directory: node notebook/reference-checks.cjs
// Checks the shipped offline demo without a browser, server or dependencies.
'use strict';
const assert=require('node:assert/strict');
require('../docs/script.js');
require('../docs/reference.js');
const {check}=globalThis.VentilationModel, reference=globalThis.JULIA_REFERENCE;
let passed=0;
function verify(label,input,expected){
  const result=check(input);
  assert.equal(result.passed,expected,label);
  assert.equal(result.failures.length===0,expected,label+' diagnostics');
  passed++;
}
function corrupt(label,mutate){const copy=structuredClone(reference);mutate(copy);verify(label,copy,false);}
verify('shipped reference',reference,true);
const reordered=structuredClone(reference);
reordered.strategies.reverse();
reordered.strategies.forEach(s=>s.checkpoints.reverse());
verify('strategies and checkpoints reordered',reordered,true);
for(const invalid of [NaN,Infinity,-Infinity,undefined,null,'450',true,{},[]]){
  for(let s=0;s<3;s++)for(let c=0;c<4;c++)for(const field of ['co2_ppm','temperature_c','time_hours'])
    corrupt(`invalid ${field} at ${s}/${c}`,r=>{r.strategies[s].checkpoints[c][field]=invalid;});
}
for(const invalid of [undefined,null,{},[],0,'reference'])verify('invalid root',invalid,false);
for(const invalid of [undefined,null,{},'strategies'])corrupt('invalid strategies',r=>{r.strategies=invalid;});
corrupt('missing strategy',r=>r.strategies.pop());
corrupt('extra strategy',r=>r.strategies.push(structuredClone(r.strategies[0])));
corrupt('duplicate identity',r=>{r.strategies[1].strategy='closed';});
corrupt('unknown identity',r=>{r.strategies[0].strategy='other';});
corrupt('missing identity',r=>{delete r.strategies[0].strategy;});
corrupt('null strategy',r=>{r.strategies[0]=null;});
corrupt('swapped identities with unchanged values',r=>{r.strategies[0].strategy='full';r.strategies[2].strategy='closed';});
for(const invalid of [undefined,null,{},'checkpoints'])corrupt('invalid checkpoints',r=>{r.strategies[0].checkpoints=invalid;});
corrupt('missing checkpoint',r=>r.strategies[0].checkpoints.pop());
corrupt('extra checkpoint',r=>r.strategies[0].checkpoints.push(structuredClone(r.strategies[0].checkpoints[0])));
corrupt('null checkpoint',r=>{r.strategies[0].checkpoints[0]=null;});
corrupt('duplicate time',r=>{r.strategies[0].checkpoints[1].time_hours=0;});
for(const time of [-1,.25,30,120,2.0001])corrupt('incorrect time/units',r=>{r.strategies[0].checkpoints[1].time_hours=time;});
corrupt('valid times attached to wrong states',r=>{r.strategies[0].checkpoints[0].time_hours=.5;r.strategies[0].checkpoints[1].time_hours=0;});
for(const field of ['co2_ppm','temperature_c'])corrupt('finite wrong checkpoint',r=>{r.strategies[0].checkpoints[1][field]+=1;});
for(const field of ['peak_co2_ppm','peak_temperature_c','minutes_above_co2','minutes_outside_temperature_band']){
  corrupt('finite wrong metric',r=>{r.strategies[0][field]+=1;});
  corrupt('missing metric',r=>{delete r.strategies[0][field];});
  corrupt('NaN metric',r=>{r.strategies[0][field]=NaN;});
}
const near=structuredClone(reference);
near.strategies[0].checkpoints[1].co2_ppm+=.005;
near.strategies[0].checkpoints[1].temperature_c+=.0005;
verify('finite values within tolerance',near,true);
console.log(`PASS: ${passed} reference checks (${process.version}); malformed inputs fail with diagnostics.`);
