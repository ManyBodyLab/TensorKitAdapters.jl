<!-- <img src="./docs/src/assets/logo_readme.svg" width="150"> -->

# TensorKitAdapters.jl

| **Documentation** | **Downloads** |
|:-----------------:|:-------------:|
| [![][docs-stable-img]][docs-stable-url] [![][docs-dev-img]][docs-dev-url] | [![Downloads][downloads-img]][downloads-url]

<!-- | **Documentation** | **Digital Object Identifier** | **Citation** | **Downloads** |
|:-----------------:|:-----------------------------:|:------------:|:-------------:|
| [![][docs-stable-img]][docs-stable-url] [![][docs-dev-img]][docs-dev-url] | [![DOI][doi-img]][doi-url] | | [![Downloads][downloads-img]][downloads-url] -->

| **Build Status** | **Coverage** | **Style Guide** | **Quality assurance** |
|:----------------:|:------------:|:---------------:|:---------------------:|
| [![CI][ci-img]][ci-url] | [![Codecov][codecov-img]][codecov-url] | [![code style: runic][codestyle-img]][codestyle-url] | [![Aqua QA][aqua-img]][aqua-url] |

[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-stable-url]: https://manybodylab.github.io/TensorKitAdapters.jl/stable

[docs-dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[docs-dev-url]: https://manybodylab.github.io/TensorKitAdapters.jl/dev

[doi-img]: https://zenodo.org/badge/DOI/
[doi-url]: https://doi.org/

[downloads-img]: https://img.shields.io/badge/dynamic/json?url=http%3A%2F%2Fjuliapkgstats.com%2Fapi%2Fv1%2Ftotal_downloads%2FTensorKitAdapters&query=total_requests&label=Downloads
[downloads-url]: http://juliapkgstats.com/pkg/TensorKitAdapters

[ci-img]: https://github.com/ManyBodyLab/TensorKitAdapters.jl/actions/workflows/Tests.yml/badge.svg
[ci-url]: https://github.com/ManyBodyLab/TensorKitAdapters.jl/actions/workflows/Tests.yml

[pkgeval-img]: https://JuliaCI.github.io/NanosoldierReports/pkgeval_badges/M/TensorKitAdapters.svg
[pkgeval-url]: https://JuliaCI.github.io/NanosoldierReports/pkgeval_badges/M/TensorKitAdapters.html

[codecov-img]: https://codecov.io/gh/ManyBodyLab/TensorKitAdapters.jl/branch/main/graph/badge.svg
[codecov-url]: https://codecov.io/gh/ManyBodyLab/TensorKitAdapters.jl

[aqua-img]: https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg
[aqua-url]: https://github.com/JuliaTesting/Aqua.jl

[codestyle-img]: https://img.shields.io/badge/code_style-%E1%9A%B1%E1%9A%A2%E1%9A%BE%E1%9B%81%E1%9A%B2-black
[codestyle-url]: https://github.com/fredrikekre/Runic.jl

`TensorKitAdapters.jl` provides adapters to convert between the `TensorMap` type of [`TensorKit.jl`](https://github.com/QuantumKitHub/TensorKit.jl) and other tensor libraries like [`ITensors.jl`](https://github.com/ITensor/ITensors.jl).


## Installation

The package is not yet registered in the Julia general registry. It can be installed trough the package manager with the following command:

```julia-repl
pkg> add git@github.com:ManyBodyLab/TensorKitAdapters.jl.git
```

<!-- ## Citation

See "Cite this repository" to the right or [`CITATION.cff`](CITATION.cff) for the relevant reference(s). -->

## Code Samples

```julia
julia> using TensorKitAdapters, TensorKit
julia> using ITensors
julia> i = Index([QN("Sz"=>-1)=>2, QN("Sz"=>0)=>1]);
julia> A = random_itensor(Float64, i, dag(prime(i)));
julia> T = TensorMap(A);
julia> A_reconstructed = ITensor(T; ids = ITensors.id.(inds(A)), plevs = plev.(inds(A)));
julia> T_reconstructed = TensorMap(A_reconstructed);
julia> A ≈ A_reconstructed
true
julia> T ≈ T_reconstructed
true
```

## License

`TensorKitAdapters.jl` is licensed under the [MIT License](LICENSE). By using or interacting with this software in any way, you agree to the license of this software.
