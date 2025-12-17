using TensorKitAdapters
using Aqua: Aqua
using Test
using TestExtras

@testset "Code quality (Aqua.jl)" begin
    Aqua.test_all(TensorKitAdapters)
end
