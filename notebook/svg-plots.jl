"""Small dependency-free SVG renderer for the notebook's scientific charts.
It draws the supplied data only; it does not change simulation or statistics.
Supported: line/scatter/ECDF series, log axes, reference lines/bands and panels.
"""
module NotebookSVGPlots
export plot, plot!, scatter!, hline!, hspan!, savefig, svg

mutable struct SVGPlot
    attributes::Dict{Symbol,Any}
    series::Vector{Any}
    lines::Vector{Any}
    bands::Vector{Any}
end
struct SVGFigure
    panels::Vector{SVGPlot}
    attributes::Dict{Symbol,Any}
end
plot(;kwargs...) = SVGPlot(Dict{Symbol,Any}(kwargs),Any[],Any[],Any[])
plot(panels::SVGPlot...;kwargs...) = SVGFigure(collect(panels),Dict{Symbol,Any}(kwargs))
function plot!(p::SVGPlot,x,y;kwargs...)
    length(x)==length(y) || throw(ArgumentError("plot coordinate lengths differ"))
    for key in (:yticks,:xlabel,:ylabel,:title,:xscale,:yscale,:ylims,:legend)
        haskey(kwargs,key) && (p.attributes[key]=kwargs[key])
    end
    points=[(Float64(a),Float64(b)) for (a,b) in zip(x,y) if !ismissing(a) && !ismissing(b) && isfinite(a) && isfinite(b)]
    push!(p.series,(points=points,attributes=Dict{Symbol,Any}(kwargs)))
    p
end
scatter!(p,x,y;kwargs...) = plot!(p,x,y;seriestype=:scatter,kwargs...)
hline!(p::SVGPlot,y;kwargs...) = (push!(p.lines,(values=Float64.(y),attributes=Dict{Symbol,Any}(kwargs)));p)
hspan!(p::SVGPlot,y;kwargs...) = (length(y)==2 || throw(ArgumentError("band needs two endpoints"));push!(p.bands,(values=Float64.(y),attributes=Dict{Symbol,Any}(kwargs)));p)
esc(x)=replace(string(x),'&'=>"&amp;",'<'=>"&lt;",'>'=>"&gt;",'"'=>"&quot;",'\''=>"&apos;")
const PALETTE=("#193d4b","#c46a00","#00897b","#7756a4","#606970")
function text(io,x,y,s;anchor="start",size=12,extra="")
    print(io,"<text x=\"$x\" y=\"$y\" text-anchor=\"$anchor\" font-size=\"$size\" $extra>",esc(s),"</text>")
end
function bounds(values,logarithmic)
    v=filter(x->isfinite(x) && (!logarithmic || x>0),values)
    isempty(v) && return (0.,1.)
    lo,hi=extrema(logarithmic ? log10.(v) : v)
    if lo==hi;lo-=.5;hi+=.5;end
    pad=.04*(hi-lo)
    (lo-pad,hi+pad)
end
function panel(io,p,x0,y0,width,height,id)
    a=p.attributes
    xl=get(a,:xscale,:identity)==:log10;yl=get(a,:yscale,:identity)==:log10
    customticks=get(a,:yticks,nothing)
    left=customticks===nothing ? 90. : 215.
    right=30.;top=46.;bottom=100.
    pw=width-left-right;ph=height-top-bottom
    pw>30 && ph>30 || throw(ArgumentError("plot panel too small"))
    xs=Float64[q[1] for s in p.series for q in s.points]
    ys=Float64[q[2] for s in p.series for q in s.points]
    for l in p.lines;append!(ys,l.values);end
    for b in p.bands;append!(ys,b.values);end
    xmin,xmax=bounds(xs,xl);ymin,ymax=bounds(ys,yl)
    if haskey(a,:ylims)
        limits=a[:ylims];ymin,ymax=yl ? log10.(Float64.(limits)) : Float64.(limits)
    end
    X(x)=x0+left+((xl ? log10(x) : x)-xmin)/(xmax-xmin)*pw
    Y(y)=y0+top+ph-((yl ? log10(y) : y)-ymin)/(ymax-ymin)*ph
    clip="panel-$id"
    print(io,"<defs><clipPath id=\"$clip\"><rect x=\"$(x0+left)\" y=\"$(y0+top)\" width=\"$pw\" height=\"$ph\"/></clipPath></defs>")
    text(io,x0+width/2,y0+23,get(a,:title,"");anchor="middle",size=16)
    for k in 0:4
        xx=xmin+k*(xmax-xmin)/4;px=x0+left+k*pw/4
        print(io,"<line x1=\"$px\" y1=\"$(y0+top)\" x2=\"$px\" y2=\"$(y0+top+ph)\" stroke=\"#e4e9ec\"/>")
        label=xl ? "10^"*string(round(xx;digits=2)) : string(round(xx;sigdigits=4))
        text(io,px,y0+top+ph+21,label;anchor="middle",size=11)
    end
    ticks=customticks===nothing ? [(ymin+k*(ymax-ymin)/4,nothing) for k in 0:4] : collect(zip(customticks[1],customticks[2]))
    for (yy,label) in ticks
        py=customticks===nothing ? y0+top+ph-(yy-ymin)/(ymax-ymin)*ph : Y(yy)
        print(io,"<line x1=\"$(x0+left)\" y1=\"$py\" x2=\"$(x0+left+pw)\" y2=\"$py\" stroke=\"#e4e9ec\"/>")
        s=label===nothing ? (yl ? "10^"*string(round(yy;digits=2)) : string(round(yy;sigdigits=4))) : label
        text(io,x0+left-9,py+4,s;anchor="end",size=11)
    end
    text(io,x0+left+pw/2,y0+top+ph+45,get(a,:xlabel,"");anchor="middle")
    text(io,0,0,get(a,:ylabel,"");anchor="middle",extra="transform=\"translate($(x0+20),$(y0+top+ph/2)) rotate(-90)\"")
    print(io,"<g clip-path=\"url(#$clip)\">")
    for b in p.bands
        lo,hi=extrema(b.values)
        print(io,"<rect x=\"$(x0+left)\" y=\"$(Y(hi))\" width=\"$pw\" height=\"$(Y(lo)-Y(hi))\" fill=\"#00897b\" opacity=\"0.08\"/>")
    end
    for l in p.lines, value in l.values
        print(io,"<line x1=\"$(x0+left)\" y1=\"$(Y(value))\" x2=\"$(x0+left+pw)\" y2=\"$(Y(value))\" stroke=\"#b44a42\" stroke-dasharray=\"5 4\"/>")
    end
    for (i,s) in enumerate(p.series)
        color=PALETTE[mod1(i,length(PALETTE))]
        points=filter(q->(!xl || q[1]>0) && (!yl || q[2]>0),s.points)
        isempty(points) && continue
        scatter=get(s.attributes,:seriestype,:line)==:scatter
        step=get(s.attributes,:seriestype,:line)==:steppost
        if !scatter
            commands=String["M $(X(points[1][1])) $(Y(points[1][2]))"]
            for j in 2:length(points)
                step && push!(commands,"L $(X(points[j][1])) $(Y(points[j-1][2]))")
                push!(commands,"L $(X(points[j][1])) $(Y(points[j][2]))")
            end
            print(io,"<path d=\"",join(commands," "),"\" fill=\"none\" stroke=\"$color\" stroke-width=\"1.8\"/>")
        end
        if scatter || haskey(s.attributes,:marker)
            for (x,y) in points;print(io,"<circle cx=\"$(X(x))\" cy=\"$(Y(y))\" r=\"3\" fill=\"$color\"/>");end
        end
    end
    print(io,"</g>")
    if get(a,:legend,true)!==false
        labels=[(PALETTE[mod1(i,length(PALETTE))],string(get(s.attributes,:label,""))) for (i,s) in enumerate(p.series) if !isempty(string(get(s.attributes,:label,"")))]
        append!(labels,[("#b44a42",string(l.attributes[:label])) for l in p.lines if haskey(l.attributes,:label)])
        append!(labels,[("#00897b",string(b.attributes[:label])) for b in p.bands if haskey(b.attributes,:label)])
        for (j,(color,label)) in enumerate(labels)
            px=x0+left+(j-1)*min(155.,pw/max(length(labels),1));py=y0+top+ph+72
            print(io,"<line x1=\"$px\" y1=\"$(py-4)\" x2=\"$(px+18)\" y2=\"$(py-4)\" stroke=\"$color\" stroke-width=\"2\"/>")
            text(io,px+23,py,label;size=11)
        end
    end
end
function svg(p::SVGPlot)
    svg(SVGFigure([p],Dict(:size=>get(p.attributes,:size,(850,430)),:layout=>(1,1))))
end
function svg(f::SVGFigure)
    width,height=get(f.attributes,:size,(850,430));rows,cols=get(f.attributes,:layout,(1,length(f.panels)))
    rows*cols>=length(f.panels) || throw(ArgumentError("not enough plot panels"))
    io=IOBuffer();print(io,"<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"$width\" height=\"$height\" viewBox=\"0 0 $width $height\" role=\"img\"><rect width=\"100%\" height=\"100%\" fill=\"white\"/><g font-family=\"Arial,sans-serif\" fill=\"#19323c\">")
    offset=haskey(f.attributes,:plot_title) ? 32. : 0.
    offset>0 && text(io,width/2,22,f.attributes[:plot_title];anchor="middle",size=17)
    for (i,p) in enumerate(f.panels)
        row,col=divrem(i-1,cols)
        panel(io,p,col*width/cols,offset+row*(height-offset)/rows,width/cols,(height-offset)/rows,i)
    end
    print(io,"</g></svg>");String(take!(io))
end
Base.show(io::IO,::MIME"image/svg+xml",p::Union{SVGPlot,SVGFigure})=print(io,svg(p))
Base.show(io::IO,::MIME"text/plain",p::Union{SVGPlot,SVGFigure})=print(io,"Julia SVG chart (display as image/svg+xml)")
function savefig(p,path)
    endswith(lowercase(path),".svg") || throw(ArgumentError("lightweight renderer exports SVG only"))
    write(path,svg(p));path
end
end
