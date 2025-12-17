using Literate: Literate
using TensorKitAdapters

Literate.markdown(
    joinpath(pkgdir(TensorKitAdapters), "docs", "files", "README.jl"),
    joinpath(pkgdir(TensorKitAdapters), "docs", "src");
    flavor = Literate.DocumenterFlavor(),
    name = "index",
)
