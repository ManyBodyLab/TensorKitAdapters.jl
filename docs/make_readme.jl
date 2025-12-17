using Literate: Literate
using TensorKitAdapters

Literate.markdown(
    joinpath(pkgdir(TensorKitAdapters), "docs", "files", "README.jl"),
    joinpath(pkgdir(TensorKitAdapters));
    flavor = Literate.CommonMarkFlavor(),
    name = "README",
)
