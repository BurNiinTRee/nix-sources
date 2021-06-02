# using Pkg
# Pkg.add("PackageCompiler")

# for pkg in [
# "OhMyREPL" 
# "Plots" 
# "CodeTracking" 
# "Revise" 
# "LaTeXStrings" 
# "Latexify" 
# "Pluto" 
# "Symbolics" 
# "Images" 
# "LanguageServer"
# "PGFPlotsX"
# ]
#     Pkg.add(pkg)
# end


# Pkg.update()

using PackageCompiler

create_sysimage([:OhMyREPL, :Plots, :CodeTracking, :Revise, :LaTeXStrings, :Latexify, :Symbolics, :Images, :LanguageServer],
                precompile_statements_file="./julia-stuff/repl_precompile.jl", 
                precompile_execution_file=["./julia-stuff/plots_precompile.jl", "./julia-stuff/mkPlots.jl"],
                sysimage_path="./julia-stuff/sysimage.so")
