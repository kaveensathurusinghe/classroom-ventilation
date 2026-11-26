/* AI-generated JavaScript port of the Julia deterministic model. */
'use strict';
(function(root){
  const dt=1/240, fractions=[0,.5,1], names=['Closed','Half open','Fully open'];
  function rhs(u,f,p){
    const [c,t]=u,area=2*f;
    const fw=.3*area*p.wind,fs=.6*area*Math.sqrt(2*9.81*Math.abs(t-p.outdoor)/(t+273.15));
    const ach=.3+3600*Math.hypot(fw,fs)/179.2,capacity=1.2*1005*179.2;
    return [1000*p.occupants*18/179.2+ach*(420-c),ach*(p.outdoor-t)+3600*80*(p.outdoor-t)/capacity+3600*p.occupants*75/capacity];
  }
  function step(u,f,p,h=dt){
    const add=(x,k,s)=>x.map((v,i)=>v+s*k[i]);
    const a=rhs(u,f,p),b=rhs(add(u,a,h/2),f,p),c=rhs(add(u,b,h/2),f,p),d=rhs(add(u,c,h),f,p);
    return u.map((v,i)=>v+h*(a[i]+2*b[i]+2*c[i]+d[i])/6);
  }
  function above(a,b,limit,h){
    if(a>limit&&b>limit)return h;
    if(a>limit)return h*(a-limit)/(a-b);
    if(b>limit)return h*(b-limit)/(b-a);
    return 0;
  }
  function fresh(){return fractions.map((f,i)=>({f,name:names[i],times:[0],states:[[450,28]],peakC:450,peakT:28,aboveC:0,outsideT:0}));}
  function advance(r,p){
    const old=r.states[r.states.length-1],h=Math.min(dt,2-r.times[r.times.length-1]);
    if(h<=1e-12)return;
    const u=step(old,r.f,p,h);
    if(!u.every(Number.isFinite)||u[1]<=-273.15||u[0]<0)throw Error('Invalid numerical state');
    r.times.push(Math.min(2,r.times[r.times.length-1]+h));r.states.push(u);
    r.peakC=Math.max(r.peakC,u[0]);r.peakT=Math.max(r.peakT,u[1]);
    r.aboveC+=above(old[0],u[0],1000,h);
    r.outsideT+=above(-old[1],-u[1],-24,h)+above(old[1],u[1],30,h);
  }
  function run(p={occupants:35,outdoor:29,wind:2}){const rs=fresh();for(let i=0;i<480;i++)rs.forEach(r=>advance(r,p));return rs;}
  function check(reference){
    const failures=[], identities=['closed','partial','full'], checkpointTimes=[0,.5,1,2];
    const result=()=>({passed:failures.length===0,failures});
    if(!reference||!Array.isArray(reference.strategies)){
      failures.push('Julia reference must contain a strategies array');return result();
    }
    const byStrategy=new Map();
    if(reference.strategies.length!==identities.length)failures.push('Expected exactly three strategies');
    for(const entry of reference.strategies){
      if(!entry||!identities.includes(entry.strategy)){failures.push('Unknown or missing strategy identity');continue;}
      if(byStrategy.has(entry.strategy)){failures.push(`Duplicate strategy: ${entry.strategy}`);continue;}
      byStrategy.set(entry.strategy,entry);
    }
    const actual=run();
    identities.forEach((identity,i)=>{
      const a=actual[i], b=byStrategy.get(identity);
      if(!b){failures.push(`Missing strategy: ${identity}`);return;}
      for(const [key,value,tolerance] of [['peak_co2_ppm',a.peakC,.01],['peak_temperature_c',a.peakT,.001],['minutes_above_co2',60*a.aboveC,1/60],['minutes_outside_temperature_band',60*a.outsideT,1/60]])
        if(!Number.isFinite(b[key])||Math.abs(value-b[key])>tolerance)failures.push(`${a.name}: ${key}`);
      if(!Array.isArray(b.checkpoints)){failures.push(`${a.name}: missing checkpoints array`);return;}
      if(b.checkpoints.length!==checkpointTimes.length)failures.push(`${a.name}: expected four checkpoints`);
      const byTime=new Map();
      for(const point of b.checkpoints){
        // These reference times (hours) are exact binary fractions. Never coerce strings.
        if(!point||!Number.isFinite(point.time_hours)||!checkpointTimes.includes(point.time_hours)){
          failures.push(`${a.name}: invalid checkpoint time`);continue;
        }
        if(byTime.has(point.time_hours)){failures.push(`${a.name}: duplicate checkpoint time ${point.time_hours}`);continue;}
        byTime.set(point.time_hours,point);
      }
      for(const time of checkpointTimes){
        const expected=byTime.get(time), state=a.states[Math.round(time/dt)];
        if(!expected||!Number.isFinite(expected.co2_ppm)||!Number.isFinite(expected.temperature_c)||
            Math.abs(state[0]-expected.co2_ppm)>.01||Math.abs(state[1]-expected.temperature_c)>.001)
          failures.push(`${a.name}: checkpoint at ${time} hours`);
      }
    });
    return result();
  }
  root.VentilationModel={rhs,step,run,check};
  if(typeof document==='undefined')return;
  const $=id=>document.getElementById(id),colors=['#223e49','#b16813','#077d70'];
  let runs=fresh(),params={occupants:35,outdoor:29,wind:2},playing=false,frameId=0;
  function chart(id,component,label,limits){
    const canvas=$(id),ctx=canvas.getContext('2d'),w=canvas.width,h=canvas.height;
    ctx.clearRect(0,0,w,h);
    const low=component===0?400:Math.min(24,params.outdoor),high=Math.max(component===0?1100:32,...runs.map(r=>component===0?r.peakC:r.peakT))*1.03;
    const x=t=>64+(w-85)*t/2,y=v=>h-45-(h-70)*(v-low)/(high-low);
    if(component===1){ctx.fillStyle='#edf6ef';ctx.fillRect(64,y(30),w-85,y(24)-y(30));}
    ctx.font='15px system-ui';ctx.lineWidth=1;ctx.fillStyle='#526970';
    for(let i=0;i<=4;i++){const v=low+(high-low)*i/4;ctx.strokeStyle='#e3eaea';ctx.beginPath();ctx.moveTo(64,y(v));ctx.lineTo(w-21,y(v));ctx.stroke();ctx.fillText(v.toFixed(component===0?0:1),8,y(v)+5);ctx.fillText(String(i*30),x(i*.5)-8,h-20);}
    limits.forEach(v=>{ctx.strokeStyle='#a7604d';ctx.setLineDash([5,5]);ctx.beginPath();ctx.moveTo(64,y(v));ctx.lineTo(w-21,y(v));ctx.stroke();ctx.setLineDash([]);});
    runs.forEach((r,i)=>{ctx.strokeStyle=colors[i];ctx.lineWidth=3;ctx.beginPath();r.states.forEach((u,j)=>j?ctx.lineTo(x(r.times[j]),y(u[component])):ctx.moveTo(x(r.times[j]),y(u[component])));ctx.stroke();});
    ctx.fillStyle='#526970';ctx.fillText('Elapsed minutes',w/2-45,h-1);ctx.fillText(label,65,16);
  }
  function render(){chart('co2',0,'ppm',[1000]);chart('heat',1,'°C',[24,30]);$('elapsed').textContent=`${(60*runs[0].times.at(-1)).toFixed(1)} / 120 minutes`;
    $('metrics').innerHTML=runs.map(r=>`<tr><td>${r.name}</td><td>${r.peakC.toFixed(1)}</td><td>${(60*r.aboveC).toFixed(2)}</td><td>${r.peakT.toFixed(2)}</td><td>${(60*r.outsideT).toFixed(2)}</td></tr>`).join('');}
  function frame(){if(!playing)return;try{for(let j=0;j<4;j++)runs.forEach(r=>advance(r,params));render();if(runs[0].times.at(-1)>=2-1e-12){playing=false;$('status').textContent='Complete: 120-minute lecture.';}else frameId=requestAnimationFrame(frame);}catch(e){playing=false;$('status').textContent=e.message;}}
  $('start').onclick=()=>{if(!playing&&runs[0].times.at(-1)<2-1e-12){playing=true;$('status').textContent='Running with settings applied at last Reset.';frameId=requestAnimationFrame(frame);}};
  $('pause').onclick=()=>{playing=false;cancelAnimationFrame(frameId);$('status').textContent='Paused. Start resumes this run.';};
  $('reset').onclick=()=>{playing=false;cancelAnimationFrame(frameId);params={occupants:+$('occupants').value,outdoor:+$('temperature').value,wind:+$('wind').value};runs=fresh();render();$('status').textContent='Reset. Current settings applied.';};
  for(const [id,out,suffix] of [['occupants','nValue',''],['temperature','tValue',' °C'],['wind','wValue',' m/s']])$(id).oninput=()=>{$(out).textContent=$(id).value+suffix;$('status').textContent='Settings changed. Reset to apply.';};
  $('reference').onclick=()=>{try{const c=check(root.JULIA_REFERENCE);$('checkStatus').textContent=c.passed?'PASS: Julia agreement within 0.01 ppm, 0.001 °C and 1 second.':'FAIL: '+c.failures.join(', ');}catch(e){$('checkStatus').textContent=e.message;}};
  render();
})(typeof globalThis==='undefined'?window:globalThis);
