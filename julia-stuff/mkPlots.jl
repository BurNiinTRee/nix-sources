using LaTeXStrings
using Plots

pgfplotsx()

const GI = Complex{Int}


function circleShape(z, r)
    theta = LinRange(0, 2 * pi, 500)
    r * sin.(theta) + im * r * cos.(theta) .+ z
end

function ex1()
    alpha = 5 + 3im
    beta = 2 + 2im
    q = [2 2 - im]
    qhat = alpha / beta
    beta_q = beta * q
    points = [alpha beta qhat q beta_q]
    # return points
    p = scatter(points, label=[L"\alpha" L"\beta" L"\hat{q}" L"q_1" L"q_2" L"\beta q_1" L"\beta q_2"], aspect_ratio=1)
    plot!(p, circleShape(alpha, sqrt(8) / 2), label=[], seriestype=:shape, fillalpha=0)
    plot!(p, circleShape(qhat, 1 / 2), label=[], seriestype=:shape, fillalpha=0)
    savefig(p, "/tmp/ex1.tikz")
    p
end


ex1()
