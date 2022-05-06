### Solving an Aiyagari model
## Tristany Armangue-i-Jubert, 2022

## Model description
#=
HOUSEHOLDS:
Infinitely lived, on the unit interval, ex-ante identical but 
subject to idiosyncratic income shocks. 
Problem is:
max E[∑_{t}^{∞} β^t u(c_t)]
s.t. a_{t+1} + c_{t} = w z_{t} + (1+r)a_{t}

FIRMS:
Produce output by hiring capital and labor.
Problem is:
max A K_{t}^{α} N_{t}^{1-α} - (r+δ)K - w N

HH BELLMAN EQUATION:
V(a,z) = max u[wz+(1+r)a-a'] + β ∑_{z'} π_{z'|z} V(a', z')
=#

## Dependencies 
using Statistics, Distributions, LaTeXStrings, Plots, Random, DiscreteMarkovChains


## SETTINGS
size_grid_a = 50    # Size of grid for assets
size_grid_z = 2     # Size of grid for shocks
tolerance = 0.001    # Tolerance
max_iter = 2000     # Iteration limit

## PARAMETERS
const δ = 0.05      # Depreciation rate
const β = 0.96      # Discount rate
const α = 0.33      # Capital share
const A = 1         # Firm productivity multiplier
const N = 1         # Firm Employment (1 in eq)
const σ = 1         # Utility function parameter
const σ_e = 0.07    # Income AR1 shock variance
const ρ = 0.9       # Income AR1 shock persistence

## FUNCTIONS
# Utility function: log-utility if sigma = 1, CRRA otherwise
utility = σ == 1 ? x -> log(x) : x -> (x^(1 - σ) - 1) / (1 - σ)
wage(r) = A*(1-α)*(A*α/(r+δ))^(α/(1-α))
demand(r) = ((α*A)/(r+δ))^(1/(1-α))

## VFI
# Discretize state space 
grid_A = LinRange(0.1, 20, size_grid_a)
grid_Z = [0.1 1.0]
trans = [0.9 0.1; 
        0.1 0.9]

## Function to solve HH VF given r
function solveHHVF(r, bigP=1, prnt=0)
    # Initial guesses 
    global V = zeros(size_grid_a, size_grid_z)
    global p = zeros(size_grid_a, size_grid_z)
    w = wage(r)

    # Outer loop - Iterations 
    for iter = 1:max_iter
        # Print info every 10 iterations
        if iter % 10 == 0  && prnt == 1
            println("Iteration ", iter)
        end

        # Placeholde r for updated VF 
        global TV = zeros(size_grid_a, size_grid_z)

        # Inner loops - state space 
        for (idx_a, a) in enumerate(grid_A)
            for (idx_z, z) in enumerate(grid_Z)
                # Create empty array for all guesses
                U = zeros(size_grid_a)

                # Loop over possible choices a'
                for (idx_ap, ap) in enumerate(grid_A)
                    # Consumption
                    c = w * z + (1+r) * a - ap
                    # If consumption is non-negative, continue
                    if c >= 0
                        # Utility
                        iu = utility(c)
                        # Expected value
                        ev = β * sum(V[idx_ap,:] .* trans[idx_z,:])
                        # Store
                        U[idx_ap] = (iu + ev)
                    else
                        # non-valid consumption -> not optimal a'
                        U[idx_ap] = -9e8
                    end
                end

                # Select a' that attains maximum
                ax,bx = findmax(U)
                TV[idx_a, idx_z] = ax
                p[idx_a, idx_z] = bx
            end
        end

        # Compute deviation
        dev = maximum(abs.(TV-V))

        # Print every 10 iterations
        if iter % 10 == 0 && prnt == 1
            println("Deviation: ", dev)
        end

        # Assign for next period
        global V = deepcopy(TV)

        # Check convergence
        if dev <= tolerance && prnt == 1
            println("Model Converged!")
            break
        end
    end

    # Compute bigP 
    if bigP == 1
        # Indices for all states
        AX = collect(1:size_grid_a)
        ZX = collect(1:size_grid_z)
        # Vector with all possible joint states
        S = [(x,y) for y in ZX for x in AX]
        # Placeholder for P 
        P = zeros((size_grid_a*size_grid_z, size_grid_a*size_grid_z))
        # Fill 
        for i = 1:(size_grid_a*size_grid_z)
            for j = 1:(size_grid_a*size_grid_z)
                # state and state prime
                a = S[i][1]
                z = S[i][2]
                ap = S[j][1]
                zp = S[j][2]
                # prob of transition
                if p[a,z] == ap
                    P[i,j] = trans[z,zp]
                else
                    P[i,j] = 0
                end
            end
        end 
    end

    # Return VF and PF 
    if bigP == 1
        return V, p, P 
    else
        return V, p
    end
end

## Function to compute agg supply of capital 
function supply(r)
    ## Computes capital supply at a given r  
    # Solve the problem of the HH
    V, p, P = solveHHVF(r)

    # State vectors 
    ZX = collect(1:size_grid_z)
    S = [(x,y) for y in ZX for x in grid_A]
    SX = [x[1] for x in S]

    # Find steady distribution
    chain = DiscreteMarkovChain(P)
    d = stationary_distribution(chain)

    # Compute average a in stationary dist 
    k = sum(SX .* d)
    return k
end

## Function to simulate households 
function simHH(p,trans,n=200)
    # Make transition matrix cumulative 
    transC = cumsum(trans, dims=2)

    # Storage for A and Z distribution 
    A = zeros(Int,(n,200))
    Avals = zeros(n,200)
    Z = zeros(Int,(n,200))
    A[:,1] .= 1
    Avals[:,1] .= grid_A[1]
    Z[:,1] .= 1
    K = zeros(200)

    for t = 2:200
        # schocks
        shc = rand(n)

        # Households
        for h = 1:n
            # Pick z 
            for i = 1:size(transC,2)
                if shc[h] <= transC[Z[h,t-1], Int(i)]
                    Z[h,t] = Int(i)
                    break
                end
            end

            # Given a and z, pick a'
            A[h,t] = p[Int(A[h,t-1]), Int(Z[h,t-1])]
            Avals[h,t] = grid_A[Int(A[h,t])]
        end

        # Average K 
        K[t] = mean(Avals[:,t])
    end

    return mean(K[150:end])
end


## SOLVE EQUILIBRIUM
#=
Here I use Steady State distribution of Markov chain implied 
by the policy function to determine supply of capital given r.

Then I compute demand for capital using firm FOCs.

Iterate until convergence using Bisection.
=#
println("Solving for equilibrium interest rate...")

# Initial guesses
r = [0.02, 0.04]

# Solve for K demand 
K = map(demand, r)

# Solve for k supply 
k = map(supply, r)

# Loop
for iter = 1:max_iter
    # Compute distances
    if abs(K[1] - k[1]) < abs(K[2]-k[2])
        # Equilibrium closer to l than h,
        # update r_h and demand and supply
        global r[2] = (r[1]+r[2])/2
        global K[2] = demand(r[2])
        global k[2] = demand(r[2])
    else
        # Equilibrium closer to h than l,
        # update r_l and VF
        global r[1] = (r[1]+r[2])/2
        global K[1] = demand(r[1])
        global k[1] = demand(r[1])
    end

    # Check convergence
    if abs(r[1]-r[2]) < 0.0001
        global r_star = (r[1]+r[2])/2
        break
    end
end
println("Equilibrium found at: ", r_star)


## Plot optimal at r_star 
println("Plotting policy function at optimal interest rate...")
V, p = solveHHVF(r_star, 0, 0)
labels = [L"z = %$(grid_Z[1])" L"z = %$(grid_Z[2])"]
a_star = reshape([grid_A[Int(p[s_i])] for s_i in 1:(size_grid_a*size_grid_z)], size_grid_a, size_grid_z)
plot(grid_A, a_star, label = labels, lw = 2, alpha = 0.6)
plot!(grid_A, grid_A, label = "", color = :black, linestyle = :dash)
plot!(xlabel = "Current assets", ylabel = "Next period assets", grid = false)
savefig("policy_function.png")

# PLOT DEMAND AND SUPPLY OF CAPITAL 
println("Plotting supply and demand of capital...")
r = range(0.02, 0.04; length = 10)
plot(r, [supply, demand]; label = ["Supply" "Demand"])
plot!(xlabel = "Interest Rate", ylabel = "Capital", grid = true)
savefig("demand_supply.png")