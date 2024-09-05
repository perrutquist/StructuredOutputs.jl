using Structured
using Test
using JSON
using JSONSchema

struct Foo
    x::Int
    y::String
end

struct Bar
    foo::Foo
    next::Union{Bar, Nothing}
end

struct NoBar 
    foo::Foo
    next::Int
end

struct WhichBar
    tst::Union{Bar, NoBar}
end

@enum YN yes no

@testset "Structured.jl" begin
    o1 = Bar(Foo(42, "Hi"), Bar(Foo(0, "bye"), nothing))
    o2 = (x="Hello", y=:World)
    o3 = (answer=yes, guide=42.0f0, b=true, f=false, next=nothing)
    o4 = (it=WhichBar(Bar(Foo(3,"hi"), nothing)))
    o5 = (it=WhichBar(NoBar(Foo(3,"hi"), 42)))
    o6 = [1+2im, 0+0im, -3-4im]
    o7 = [:Hello, :World]
    o8 = (; o1, o2, o3, o4, o5, o6, o7)
    o9 = Dict("a" => 1, "b" => 2)
    o10 = Dict{String, Any}("a" => 1, "b" => "two", "c"=>3.0)
    o11 = Any[1, "two", 3.0]
    o12 = @NamedTuple{a::Int, b::Any}((1, "two"))

    noS = Schema(json(Structured.schema(typeof((invalid=true,)))))

    for o in (o1, o2, o3, o4, o5, o6, o7, o8, o9, o10, o11, o12)
        t = typeof(o)
        s = Structured.schema(t)
        js = json(s, 4) # schema as a JSON string
        jo = json(o, 4) # object as a JSON string
        #println("Schema:")
        #println(js)
        #println("Object:")
        #println(jo)
        S = Schema(js)
        pjo = JSON.parse(jo) # Object in Dict form
        @test validate(S, pjo) === nothing
        @test validate(noS, pjo) !== nothing
        r = Structured.to_type(t, pjo) # Object restored into type t.
        @test typeof(r) == t
        @test r == o
    end
end
