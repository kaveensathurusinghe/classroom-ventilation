# Focused renderer checks. Run: julia --startup-file=no notebook/svg-checks.jl
using Test
include(joinpath(@__DIR__,"svg-plots.jl"))
using .NotebookSVGPlots
@testset "Lightweight SVG renderer" begin
    p=plot(xlabel="time",ylabel="state",title="A < B & C")
    plot!(p,[0.,1.,2.],[1.,2.,3.];label="trajectory",marker=:circle)
    s=svg(p)
    @test occursin("A &lt; B &amp; C",s)
    @test length(collect(eachmatch(r"<circle ",s)))==3
    @test !occursin(r"\b(NaN|Inf)\b",s)
    @test_throws ArgumentError plot!(p,[0.,1.],[2.])
    hline!(p,[2.];label="limit");hspan!(p,[1.,2.];label="band")
    @test occursin("limit",svg(p)) && occursin("band",svg(p))
    @test showable(MIME"image/svg+xml"(),p)
    @test sprint(show,MIME"image/svg+xml"(),p)==svg(p)
    ranks=plot(xlabel="association")
    scatter!(ranks,[-.5,.5],[1,2];yticks=(1:2,["input A","input B"]),label="ranks")
    @test occursin("input A",svg(ranks)) && occursin("input B",svg(ranks))
    logp=plot(xscale=:log10,yscale=:log10)
    plot!(logp,[.01,.1],[1e-5,1e-3])
    @test !occursin(r"\b(NaN|Inf)\b",svg(logp))
    ecdf=plot();plot!(ecdf,[0.,0.,1.],[0.,.5,1.];seriestype=:steppost)
    @test occursin("<path",svg(ecdf))
    fig=plot(p,ecdf;layout=(2,1),size=(850,850))
    @test occursin("panel-2",svg(fig))
    @test_throws ArgumentError svg(plot(p,ecdf;layout=(1,1)))
    mktempdir() do dir
        path=joinpath(dir,"chart.svg");savefig(p,path)
        @test read(path,String)==svg(p)
        @test_throws ArgumentError savefig(p,joinpath(dir,"chart.png"))
    end
end
