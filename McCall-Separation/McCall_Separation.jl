#= 
McCall Search Model with Separation
Tristany Armangue-Jubert, 2022
=#

## Dependencies 
using Distributions, LaTeXStrings, Plots, Random, Statistics, CSV, DataFrames

## Settings
size_grid_w = 50
tolerance = 0.000001
max_iter = 10000

## Discretize state space 
grid_W = LinRange(10, 20, size_grid_w)

## VFI
function solve(β, λ, b)
    # Initial guesses 
    global V = zeros(size_grid_w)
    global U = zeros(size_grid_w)
    global Un = 0

    # Outer loop 
    for iter = 1:max_iter
        # Placeholders for updated value functions
        global TV = zeros(size_grid_w) 
        global TU = zeros(size_grid_w) 

        # Inner loop
        for (idx_w, w) in enumerate(grid_W)
            # Update V
            TV[idx_w] = w + β * (1-λ) * V[idx_w] + β * λ * mean(U)

            # Update U 
            TU[idx_w] = max(V[idx_w], b + β * mean(U))

            # Update Un 
            global Un = b + β * mean(U)

        end

        # Compute distance 
        dev = maximum(abs.(TV-V))

        # Assign for next period
        global V = deepcopy(TV)
        global U = deepcopy(TU)

        # Check convergence
        if dev <= tolerance
            break
        end
    end

    # Solve for reservation wage
    res = b*(1 - β + β*λ) + β * mean(U) * (1-β+λ*(β-1))

    return V, U, Un, res
end

## Solve with low lambda 
V_l,U_l,Un_l,res = solve(0.98, 0.1, 8.0)

## Solve with high lambda 
V_h,U_h,Un_h,res = solve(0.98, 0.2, 8.0)

## Plot  color = :black, linestyle = :dash
plot(grid_W, V_h, label = "V(w)", lw = 2, alpha = 0.6, dpi =600)
plot!(grid_W, vec(Un_h * ones(length(V))), label = "U", lw = 2, alpha = 0.6)
plot!(xlabel = "Wage", ylabel = "", grid = true)
plot!([res], seriestype="vline",label=L"\bar{w}",linestyle = :dash, color = :black)
plot!(title = "Solution with λ = 0.2")
savefig("solution.png")

## Save for plotting in Latex 
df = DataFrame()
df[!, "w"] = vec(grid_W)
df[!, "V_h"] = vec(V_h)
df[!, "V_l"] = vec(V_l)
df[!, "U_h"] = vec(Un_h * ones(length(V)))
df[!, "U_l"] = vec(Un_l * ones(length(V)))
CSV.write("ex1.csv", df)