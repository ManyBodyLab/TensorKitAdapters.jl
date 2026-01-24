# <!-- <img src="./docs/src/assets/logo_readme.svg" width="150"> -->

# # TensorKitAdapters.jl

# `TensorKitAdapters.jl` provides adapters to convert between the `TensorMap` type of [`TensorKit.jl`](https://github.com/QuantumKitHub/TensorKit.jl) and other tensor libraries like [`ITensors.jl`](https://github.com/ITensor/ITensors.jl).


# ## Installation

# The package is registered in the Julia general registry. It can be installed trough the package manager with the following command:

# ```julia-repl
# pkg> add TensorKitAdapters
# ```

# ## Code Samples

# ```julia
# julia> using TensorKitAdapters, TensorKit
# julia> using ITensors
# julia> i = Index([QN("Sz"=>-1)=>2, QN("Sz"=>0)=>1]);
# julia> A = random_itensor(Float64, i, dag(prime(i)));
# julia> T = TensorMap(A);
# julia> A_reconstructed = ITensor(T; ids = ITensors.id.(inds(A)), plevs = plev.(inds(A)));
# julia> T_reconstructed = TensorMap(A_reconstructed);
# julia> A ≈ A_reconstructed
# true
# julia> T ≈ T_reconstructed
# true
# ```

# ## License

# `TensorKitAdapters.jl` is licensed under the MIT License. By using or interacting with this software in any way, you agree to the license of this software.
