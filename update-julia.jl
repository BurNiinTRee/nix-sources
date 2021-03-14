using PackageCompiler
using Pkg

Pkg.update()

create_sysimage([:OhMyREPL, :Plots, :CodeTracking, :Revise],
                precompile_statements_file="./julia-stuff/repl_precompile.jl", 
                precompile_execution_file=["./julia-stuff/plots_precompile.jl", "./julia-stuff/mkPlots.jl"],
                sysimage_path="./julia-stuff/sysimage.so")
