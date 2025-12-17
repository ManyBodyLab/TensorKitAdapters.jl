module ITensorsExt 

using ITensors 
using TensorKit
import TensorKit: TensorMap 
import ITensors: ITensor

function TensorKit.TensorMap(src::ITensors.ITensor)
    if hasqns(src)
        return _blocksparse_tensormap(src)
    end 
    return _dense_tensormap(src)
end


include("itensor_utility.jl")
include("ToTensorKit/dense.jl")
include("ToTensorKit/blocksparse.jl")

include("ToITensor/itensor.jl")

end
