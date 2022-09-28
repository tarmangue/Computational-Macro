# Dependencies 
using CSV, DataFrames, Metal

# Settings 
maxiter::UInt32 = 200
tolerance::Float32 = 0.00001
grid_size_K = 10

# Parameters
β::Float32 = 0.9
α::Float32 = 0.75
δ::Float32 = 0.3
const k̲ = 0.001
const k̅ = 10

# Discretize the state space 
grid_K = MtlArray(Array{Float32}(collect(LinRange(k̲, k̅, grid_size_K))))

# GPU kernel for state evaluation
function eval_state(array, V, alpha, beta, delta, SIZE)
    idx = thread_position_in_grid_1d()
    tmp_max = Float32(-Inf)
    if idx <= length(array)
      @inbounds begin
        for i = 1:SIZE
            # Consumption at this kprime
            c = array[idx]^(alpha) + (1-delta)*array[idx] - array[i]

            # Check for positive consumption
            if c > 0
                tmp_i = log(c) + beta * V[i]
                if tmp_i > tmp_max
                    tmp_max = tmp_i
                end
            end
        end
        V[idx] = tmp_max
      end
    end
    return
end

# Solve VFI using GPU 
function gpu_vfi(grid::MtlArray, alpha::Float32, beta::Float32, delta::Float32, maxiter::UInt32,
                tolerance::Float32)
    # Size of grid 
    SIZE = size(grid,1)

    # Init V and TV
    V = MtlArray{Float32}(zeros(SIZE,1))
    TV = MtlArray{Float32}(zeros(SIZE,1))

    # Outer loop, things here handled by CPU 
    for iter = 1:maxiter 
        # Set TV 
        TV = deepcopy(V) 

        # Call kernel
        @metal threads=512 grid=2 eval_state(grid_K, V, alpha, beta, delta, SIZE)

        # Evaluate distance 
        if maximum(abs.(TV-V)) <= tolerance
            break 
        end
    end
end

gpu_vfi(grid_K, α, β, δ, maxiter, tolerance)

# # Test kernel 
# function memset_kernel(array, value)
#     i = thread_position_in_grid_1d()
#     if i <= length(array)
#       @inbounds array[i] = value
#     end
#     return
# end

# @metal threads=512 grid=2 memset_kernel(grid_K, 42)






# # Function to solve model in GPU
# function gpu_vfi(grid_::Array{Float32}, α::Float32, β::Float32, δ::Float32, maxiter::UInt32)
#     # Unpack grid 
#     SIZE_GRID = size(grid,1)

#     # Start V and pass grid to GPU 
#     V = zeros(MtlArray{Float32}, SIZE_GRID, 1)
#     grid = MtlArray(Array{Float32}(grid_))

#     # Outer loop - iterations 
#     for iter = 1:maxiter 
#         # GPU kernel 
#         gpu(grid, (grid, V, Float32(α), Float32(β), Float32(δ), UInt32(SIZE_GRID))) do state, grid, V, α, β, SIZE_GRID
#             idx = @linearidx grid
#             tmp_max = Float32(-Inf);
#             @inbounds begin
#                 for i = 1:SIZE_GRID
#                     tmp_i = log(grid[idx]^alpha - grid[i]) + beta*V[i];
#                     if tmp_i > tmp_max
#                         tmp_max = tmp_i;
#                     end
#                 end
#                 V[idx] = tmp_max;
#             end   
#             return
#         end
#     end
#     return Array{Float32}(V)
# end

