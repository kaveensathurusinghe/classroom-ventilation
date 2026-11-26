// node notebook/hot-calm-demo-checks.cjs [fresh Julia JSON path]
'use strict';
const fs=require('node:fs'),assert=require('node:assert/strict');
require('../docs/script.js');
const data=JSON.parse(fs.readFileSync(process.argv[2]||require('node:path').join(__dirname,'notes/hot-calm-results.json'),'utf8'));
const model=globalThis.VentilationModel,p={occupants:45,outdoor:34,wind:0};
let maxPeak=0,maxFinalC=0,maxFinalT=0;
for(const row of data.refinement){
  const h=row.step_seconds/3600,n=Math.round(2/h);
  let u=[450,28],peak=450;
  for(let i=0;i<n;i++){
    u=model.step(u,1,p,h);peak=Math.max(peak,u[0]);
  }
  maxPeak=Math.max(maxPeak,Math.abs(peak-row.peak_co2_ppm));
  maxFinalC=Math.max(maxFinalC,Math.abs(u[0]-row.final_co2_ppm));
  maxFinalT=Math.max(maxFinalT,Math.abs(u[1]-row.final_temperature_c));
}
// Cross-language agreement is distinct from accuracy against the ODE reference.
assert(maxPeak<1e-7 && maxFinalC<1e-7 && maxFinalT<1e-8);
assert(Math.abs(model.run(p)[2].peakC-data.refinement[0].peak_co2_ppm)<1e-7);
console.log(JSON.stringify({node:process.version,levels:data.refinement.length,maxPeakPpm:maxPeak,maxFinalPpm:maxFinalC,maxFinalCelsius:maxFinalT,passed:true}));
