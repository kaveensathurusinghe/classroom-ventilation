# Run with the project unpacked by the notebook (ClassroomVentilation must load).
# Diagnostic only: does not change the model, solver, or published references.
using ClassroomVentilation, Printf, Test, JSON

# Independent variable x = sign(T-34)*sqrt(abs(T-34)).
# T=34+x*abs(x); integrate (time,CO2) against x, splitting at x=0.
# Independent coefficient evaluation; no production RHS or solver is used here.
function transformed(x,y)
    T=34+x*abs(x)
    a=0.3+(3600/179.2)*1.2*sqrt(2*9.81/(T+273.15))*abs(x)
    ft=(a+3600*80/(1.2*1005*179.2))*(34-T)+3600*45*75/(1.2*1005*179.2)
    fc=1000*45*18/179.2+a*(420-y[2])
    @assert ft>0 # transformation valid only on this monotone warming interval
    scale=2*abs(x)/ft
    [scale,scale*fc]
end
function reference(n; midpoint=false)
    xs=vcat(collect(range(-sqrt(6),0;length=n+1)),collect(range(0,sqrt(4);length=n+1))[2:end])
    ys=zeros(2,length(xs));ys[:,1]=[0,450]
    for i in 1:length(xs)-1
        x=xs[i];h=xs[i+1]-x;y=ys[:,i]
        a=transformed(x,y);b=transformed(x+h/2,y+h*a/2)
        if midpoint
            ys[:,i+1]=y+h*b
        else
            c=transformed(x+h/2,y+h*b/2);d=transformed(x+h,y+h*c)
            ys[:,i+1]=y+h*(a+2b+2c+d)/6
        end
    end
    (xs,ys)
end
function atx(ref,x)
    xs,ys=ref;i=clamp(searchsortedlast(xs,x),1,length(xs)-1)
    h=xs[i+1]-xs[i];s=(x-xs[i])/h
    (2s^3-3s^2+1)*ys[:,i]+(s^3-2s^2+s)*h*transformed(xs[i],ys[:,i])+
        (-2s^3+3s^2)*ys[:,i+1]+(s^3-s^2)*h*transformed(xs[i+1],ys[:,i+1])
end
function bisect(f,l,r)
    fl=f(l);@assert fl*f(r)<=0
    for _ in 1:55
        m=(l+r)/2
        if fl*f(m)<=0;r=m;else;l=m;fl=f(l);end
    end
    (l+r)/2
end
function attime(ref,t)
    x=bisect(x->atx(ref,x)[1]-t,ref[1][1],ref[1][end])
    [atx(ref,x)[2],34+x*abs(x)]
end
function peak(ref)
    f(x)=begin
        C=atx(ref,x)[2];T=34+x*abs(x)
        a=.3+3600/179.2*1.2*sqrt(2*9.81/(T+273.15))*abs(x)
        1000*45*18/179.2+a*(420-C)
    end
    x=bisect(f,0,ref[1][end]);y=atx(ref,x)
    (time=y[1],co2=y[2],temperature=34+x*x)
end
refs=[reference(n) for n in (1024,2048,4096,8192)]
println("Transformed reference refinement (n per side):")
for (n,r) in zip((1024,2048,4096,8192),refs)
    p=peak(r);@printf("%d crossing_s=%.12f peak_s=%.12f peak_ppm=%.12f peak_T=%.12f\n",n,3600atx(r,0)[1],3600p.time,p.co2,p.temperature)
end
ref=refs[end];p=peak(ref);cross=atx(ref,0)[1]
@test abs(p.co2-peak(refs[end-1]).co2)<1e-7
@test abs(p.time-peak(refs[end-1]).time)*3600<1e-6
println("Different-method cross-check: explicit midpoint in transformed coordinate:")
for n in (32768,65536)
    m=peak(reference(n;midpoint=true))
    @printf("n=%d peak_difference_ppm=%+.9g peak_time_difference_s=%+.9g\n",n,m.co2-p.co2,3600*(m.time-p.time))
    @test abs(m.co2-p.co2)<1e-5
end
println("seconds,peak_ppm,total_peak_error_ppm,sampled_reference_bias_ppm,ode_peak_difference_ppm,max_local_C_error_ppm,max_local_T_error_C,pre_cross_C_error_ppm,cross_step_phase")
forcing=Forcing(occupants=45,outdoor_temperature_c=34.,wind_speed_mps=0.)
room=RoomParameters();vent=VentilationParameters()
rows=[]
for k in 0:10
    h=1/(240*2^k)
    sol=solve_ode((t,u)->derivatives(u,forcing,1.,room,vent),(450.,28.),(0.,2.);dt=h)
    # Compare exact same time samples to isolate sampled-peak loss from ODE error.
    indices=findall(t->t<=ref[2][1,end],sol.times)
    values=[attime(ref,sol.times[i]) for i in indices]
    sampled=maximum(u[1] for u in values)
    ce=maximum(abs(sol.states[1,i]-u[1]) for (i,u) in zip(indices,values))
    te=maximum(abs(sol.states[2,i]-u[2]) for (i,u) in zip(indices,values))
    pre=maximum(abs(sol.states[1,i]-u[1]) for (i,u) in zip(indices,values) if sol.times[i]<cross)
    measured=maximum(sol.states[1,:])
    push!(rows,(step_seconds=3600h,peak_co2_ppm=measured,total_peak_error_ppm=measured-p.co2,
        sampled_peak_bias_ppm=sampled-p.co2,ode_peak_difference_ppm=measured-sampled,
        max_local_co2_error_ppm=ce,max_local_temperature_error_c=te,
        final_co2_ppm=sol.states[1,end],final_temperature_c=sol.states[2,end]))
    @printf("%.9f,%.12f,%+.9g,%+.9g,%+.9g,%.9g,%.9g,%.9g,%.6f\n",3600h,measured,measured-p.co2,sampled-p.co2,measured-sampled,ce,te,pre,mod(cross/h,1))
end
println("Reference agreement at 501 shared times:")
times=range(0,ref[2][1,end]*.999;length=501)
for r in refs[1:end-1]
    diffs=[abs.(attime(r,t)-attime(ref,t)) for t in times]
    println(maximum(first,diffs)," ppm; ",maximum(last,diffs)," C")
end
println("Smooth restart at T=35 C, endpoint T=37.8 C (reference times), fixed step refinement:")
start=atx(ref,1.);finish=atx(ref,sqrt(3.8));previous=NaN
for k in 0:4
    h=(finish[1]-start[1])/(16*2^k)
    sol=solve_ode((t,u)->derivatives(u,forcing,1.,room,vent),(start[2],35.),(start[1],finish[1]);dt=h)
    err=abs(sol.states[1,end]-finish[2])
    @printf("h_s=%.9f C_error=%.9g observed_order=%.6f\n",3600h,err,log2(previous/err));global previous=err
end
println("Restart from the reference crossing state (nonsmooth right endpoint remains):")
for k in 0:5
    sol=solve_ode((t,u)->derivatives(u,forcing,1.,room,vent),(atx(ref,0)[2],34.),(cross,p.time);dt=1/(240*2^k))
    @printf("h_s=%.9f peak_time_C_error=%+.9g\n",15/2^k,sol.states[1,end]-p.co2)
end
if !isempty(ARGS)
    write(ARGS[1],JSON.json((case="45 people,34 C outdoors,zero wind,full opening",julia_version=string(VERSION),
        reference=(peak_co2_ppm=p.co2,peak_time_seconds=3600p.time,crossing_time_seconds=3600cross,
                   comparison_end_seconds=3600ref[2][1,end]),refinement=rows)))
end
println("PASS: reference convergence assertions; production refinement errors are measurements, not relaxed pass gates.")

