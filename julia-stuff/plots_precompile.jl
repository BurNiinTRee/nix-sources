using Plots

p = plot(rand(5), rand(5))
display(p)

pgfplotsx()
p = plot(rand(5), rand(5))
savefig(p, "/tmp/plot.tikz")
