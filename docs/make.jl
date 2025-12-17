using TensorKitAdapters
using Documenter: Documenter, DocMeta, deploydocs, makedocs

DocMeta.setdocmeta!(
    TensorKitAdapters, :DocTestSetup, :(using TensorKitAdapters); recursive = true
)

include("make_index.jl")

makedocs(;
    modules = [TensorKitAdapters],
    authors = "Andreas Feuerpfeil <development@manybodylab.com>",
    sitename = "TensorKitAdapters.jl",
    format = Documenter.HTML(;
        canonical = "https://manybodylab.github.io/TensorKitAdapters.jl",
        edit_link = "main",
        assets = [#"assets/logo.png", 
            "assets/extras.css"],
    ),
    pages = ["Home" => "index.md", "Reference" => "reference.md"],
)

deploydocs(;
    repo = "github.com/ManyBodyLab/TensorKitAdapters.jl", devbranch = "main", push_preview = true
)
