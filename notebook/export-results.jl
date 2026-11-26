# Included by the final notebook cell after the standard experiments.
# Uses their actual results; does not resample or rerun trajectories.
function export_results(destination)
    mkpath(destination)
    tables=joinpath(destination,"tables");mkpath(tables)
    function csv(name,rows)
        open(joinpath(tables,name*".csv"),"w") do io
            println(io,join(string.(keys(first(rows))),","))
            for row in rows
                println(io,join([ismissing(v) ? "" : "\""*replace(string(v),'"'=>"\"\"")*"\"" for v in values(row)],","))
            end
        end
    end
    minute_metrics(m)=(peak_co2_ppm=m.peak_co2_ppm,peak_temperature_c=m.peak_temperature_c,
        minutes_above_co2=60m.hours_above_co2,minutes_outside_temperature_band=60m.hours_outside_temperature_band)
    average_profile(x,p)=sum((x[1:end-1]+x[2:end])./2 .* diff(p.hours))/(p.hours[end]-p.hours[1])
    input_rows=[merge((id=s.id,profile_index=s.profile_index,weather_date=string(profiles[s.profile_index].day),
        occupants=s.occupants,metabolism=s.metabolism,wind_factor=s.wind_factor),
        NamedTuple{fieldnames(RoomParameters)}(Tuple(getfield(s.room,k) for k in fieldnames(RoomParameters))),
        NamedTuple{fieldnames(VentilationParameters)}(Tuple(getfield(s.ventilation,k) for k in fieldnames(VentilationParameters)))) for s in scenarios]
    weather_rows=[(profile_index=i,date=string(p.day),hour=p.hours[j],temperature_c=p.temperature_c[j],wind_10m_mps=p.wind_mps[j]) for (i,p) in enumerate(profiles) for j in eachindex(p.hours)]
    payload=(seed=seed,rng="Random.Xoshiro",julia_version=string(VERSION),sample_count=sample_count,
        method="classical RK4",dt_hours=1/480,refinement_dt_hours=1/960,initial_co2_ppm=450.,initial_temperature_c=28.,
        outdoor_co2_ppm=420.,co2_threshold_ppm=1000.,temperature_band_c=[24.,30.],
        weather_sha256=bytes2hex(sha256(read(weather_path))),inputs=input_rows,weather_knots=weather_rows,
        outcomes=mc.outcomes,refinements=mc.refinements)
    rawpath=joinpath(tables,"monte_carlo_raw.json")
    write(rawpath,JSON.json(payload))
    csv("monte_carlo_inputs",input_rows);csv("monte_carlo_weather_knots",weather_rows)
    csv("monte_carlo_outcomes",mc.outcomes);csv("monte_carlo_refinements",mc.refinements)
    # Read the exported raw outcomes back. All published aggregate tables below
    # are reconstructed from this file, rather than the in-memory experiment.
    raw=JSON.parsefile(rawpath)
    outcomes=[(id=Int(r["id"]),strategy=Symbol(r["strategy"]),peak_co2_ppm=r["peak_co2_ppm"],
        peak_temperature_c=r["peak_temperature_c"],minutes_above_co2=60r["hours_above_co2"],
        minutes_outside_temperature_band=60r["hours_outside_temperature_band"]) for r in raw["outcomes"]]
    @assert length(unique(r.id for r in input_rows))==sample_count
    @assert scenarios==sample_scenarios(Xoshiro(seed),profiles,sample_count)
    metrics=keys(minute_metrics(first(mc.outcomes)))
    summaries,events,paired,sensitivity,prefixes=NamedTuple[],NamedTuple[],NamedTuple[],NamedTuple[],NamedTuple[]
    groups=Dict(s=>sort(filter(r->r.strategy==s,outcomes);by=r->r.id) for s in keys(FIXED_STRATEGIES))
    for strategy in keys(FIXED_STRATEGIES)
        group=groups[strategy]
        @assert [r.id for r in group]==collect(1:sample_count)
        for metric in metrics
            x=[getproperty(r,metric) for r in group]
            push!(summaries,merge((;strategy,metric),sample_summary(x)))
            original=[getproperty(minute_metrics(r),metric) for r in mc.outcomes if r.strategy==strategy]
            @assert x==original
            for n in filter(n->n<=sample_count,(50,100,250,500))
                push!(prefixes,merge((;strategy,metric),sample_summary(x[1:n])))
            end
        end
        for (event,predicate) in ((:any_co2_exceedance,r->r.minutes_above_co2>0),
                (:any_temperature_exceedance,r->r.minutes_outside_temperature_band>0),
                (:both_limits_met_entire_lecture,r->r.minutes_above_co2==0 && r.minutes_outside_temperature_band==0))
            successes=count(predicate,group)
            push!(events,merge((;strategy,event,successes,n=sample_count),wilson_interval(successes,sample_count)))
        end
        inputs=Dict(:occupants=>[s.occupants for s in scenarios],:metabolism=>[s.metabolism for s in scenarios],
            :wind_factor=>[s.wind_factor for s in scenarios],:ua_w_per_k=>[s.room.envelope_ua_w_per_k for s in scenarios],
            :additional_heat_w=>[s.room.additional_heat_w for s in scenarios],:infiltration_ach=>[s.ventilation.infiltration_ach for s in scenarios],
            :wind_effectiveness=>[s.ventilation.wind_effectiveness for s in scenarios],:discharge_coefficient=>[s.ventilation.discharge_coefficient for s in scenarios],
            :stack_height_m=>[s.ventilation.stack_height_m for s in scenarios],
            :mean_outdoor_temperature_c=>[average_profile(profiles[s.profile_index].temperature_c,profiles[s.profile_index]) for s in scenarios],
            :mean_local_wind_mps=>[s.wind_factor*average_profile(profiles[s.profile_index].wind_mps,profiles[s.profile_index]) for s in scenarios])
        for input in sort(collect(keys(inputs))), metric in metrics
            push!(sensitivity,(;strategy,input,metric,spearman_rho=spearman_correlation(inputs[input],[getproperty(r,metric) for r in group])))
        end
    end
    for (strategy,reference) in ((:partial,:closed),(:full,:closed),(:full,:partial)), metric in metrics
        a,b=groups[strategy],groups[reference]
        @assert [r.id for r in a]==[r.id for r in b]
        push!(paired,merge((;strategy,reference,metric),sample_summary([getproperty(x,metric)-getproperty(y,metric) for (x,y) in zip(a,b)])))
    end
    csv("monte_carlo_summary",summaries);csv("monte_carlo_event_probabilities",events)
    csv("monte_carlo_paired_differences",paired);csv("monte_carlo_sensitivity",sensitivity);csv("monte_carlo_precision_prefixes",prefixes)
    csv("solver_convergence",orders)
    csv("deterministic_baseline_summary",[merge((strategy=r.strategy,opening_fraction=r.opening_fraction),r.metrics,minute_metrics(r.metrics),
        (minutes_below_temperature_band=60r.metrics.hours_below_temperature_band,minutes_above_temperature_band=60r.metrics.hours_above_temperature_band)) for r in baseline])
    csv("deterministic_baseline_step_refinement",[(strategy=a.strategy,
        max_co2_difference_ppm=maximum(abs.(a.solution.states[1,:]-b.solution.states[1,1:2:end])),
        max_temperature_difference_c=maximum(abs.(a.solution.states[2,:]-b.solution.states[2,1:2:end])),
        peak_co2_difference_ppm=abs(a.metrics.peak_co2_ppm-b.metrics.peak_co2_ppm),
        peak_temperature_difference_c=abs(a.metrics.peak_temperature_c-b.metrics.peak_temperature_c),
        co2_duration_difference_seconds=3600abs(a.metrics.hours_above_co2-b.metrics.hours_above_co2),
        temperature_duration_difference_seconds=3600abs(a.metrics.hours_outside_temperature_band-b.metrics.hours_outside_temperature_band)) for (a,b) in zip(baseline,refined)])
    for sub in ("deterministic_baseline","monte_carlo");mkpath(joinpath(destination,sub));end
    function saveboth(p,relative)
        for ext in ("svg",);savefig(p,joinpath(destination,relative*"."*ext));end
    end
    saveboth(pc,"deterministic_baseline/co2");saveboth(pt,"deterministic_baseline/temperature")
    pv=plot(;xlabel="Minutes",ylabel="ACH (1/hour)",title="Assumed ventilation")
    for r in baseline;plot!(pv,60r.solution.times,r.ach;label=string(r.strategy));end
    saveboth(pv,"deterministic_baseline/ventilation")
    savefig(error_plot,joinpath(destination,"solver_convergence.svg"))
    panels=[]
    for metric in metrics
        panel=plot(;xlabel=string(metric),ylabel="Empirical cumulative probability",legend=:bottomright,
            xscale=(metric==:peak_co2_ppm ? :log10 : :identity),ylims=(0,1.02))
        for strategy in keys(FIXED_STRATEGIES)
            x=sort([getproperty(r,metric) for r in groups[strategy]])
            plot!(panel,vcat(x[1],x),vcat(0.,(1:sample_count)./sample_count);seriestype=:steppost,label=string(strategy))
        end
        push!(panels,panel)
    end
    saveboth(plot(panels...;layout=(2,2),size=(1100,800),plot_title="500 paired scenarios: assumed inputs"),"monte_carlo/outcome_distributions")
    wt=plot(;xlabel="Lecture hours",ylabel="Outdoor temperature (C)",legend=false)
    ww=plot(;xlabel="Lecture hours",ylabel="10 m wind (m/s)",legend=false)
    for p in profiles;plot!(wt,p.hours,p.temperature_c);plot!(ww,p.hours,p.wind_mps);end
    saveboth(plot(wt,ww;layout=(2,1),size=(850,650)),"monte_carlo/weather_profiles")
    names=sort(unique(r.input for r in sensitivity))
    sp=[]
    for metric in (:peak_co2_ppm,:peak_temperature_c)
        ps=plot(;xlabel="Spearman rho",title=string(metric)*" association (not causal)",legend=:outerbottom)
        for strategy in keys(FIXED_STRATEGIES)
            values=[only(r.spearman_rho for r in sensitivity if r.strategy==strategy && r.input==n && r.metric==metric) for n in names]
            scatter!(ps,values,1:length(names);yticks=(1:length(names),string.(names)),label=string(strategy))
        end
        push!(sp,ps)
    end
    saveboth(plot(sp...;layout=(2,1),size=(1000,1100)),"monte_carlo/sensitivity")
    reference=(description="Julia deterministic baseline; hours, ppm, C and minutes",dt_hours=1/240,julia_version=string(VERSION),generated_utc=string(now(UTC)),strategies=[merge((strategy=r.strategy,),minute_metrics(r.metrics),
        (checkpoints=[(time_hours=t,co2_ppm=r.solution.states[1,round(Int,t*240)+1],temperature_c=r.solution.states[2,round(Int,t*240)+1]) for t in (0.,.5,1.,2.)],)) for r in baseline])
    write(joinpath(destination,"julia-reference.js"),"globalThis.JULIA_REFERENCE = "*JSON.json(reference)*";\n")
    println("Exported ",sample_count," inputs, ",length(outcomes)," paired outcomes and ",length(mc.refinements)," refinements to ",destination)
    println("Round-trip outcomes and seed reproducibility passed; summaries reconstructed from raw JSON.")
    println("Maximum refinement deltas: ",[(k,maximum(getproperty(r,k) for r in mc.refinements)) for k in (:peak_co2_delta_ppm,:peak_temperature_delta_c,:co2_duration_delta_seconds,:temperature_duration_delta_seconds)])
    for r in summaries;println("PRECISION ",r);end
    for r in events;println("EVENT ",r);end
end
export_results(get(ENV,"VENTILATION_EXPORT_DIR",joinpath(notebook_root,"results")))
