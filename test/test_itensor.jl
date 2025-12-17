using TensorKitAdapters
using Test
using TestExtras
using ITensors
using TensorKit 

@testset "ITensor" begin
    for T in [ComplexF64,ComplexF64, Float64]
        for tag in [missing, "Link","Site,c=2,n=1"]
            for plev in Iterators.product(0:2,0:4)
                plev[1] == plev[2] && continue

                tags = ismissing(tag) ? missing : [tag, tag]
                if ismissing(tag) 
                    i = Index(10;dir=ITensors.Out)
                    iqn = ITensors.combineblocks(Index([QN(("N",2))=>5, QN("N",0)=>5]))[1]
                    iqn2 = ITensors.combineblocks(Index([QN(("N",2))=>3, QN(("N",0),("P",3))=>7]))[1]
                    ## This guarantees consistent sorting of the blocks for the comparison
                    ## Here, we test combining blocks with the same QN:
                    iqn3 = Index([QN("Sz",-1)=>2, QN("Sz",1)=>14,QN("Sz",-1)=>4])
                else
                    i = Index(10;dir=ITensors.Out,tags=tag)
                    iqn = ITensors.combineblocks(Index([QN(("N",2))=>5, QN("N",0)=>5];tags=tag))[1]
                    iqn2 = ITensors.combineblocks(Index([QN(("N",2))=>3, QN(("N",0),("P",3))=>7];tags=tag))[1]
                    iqn3 = Index([QN("Sz",-1)=>2, QN("Sz",1)=>14,QN("Sz",-1)=>4]; tags=tag)
                end

                i_p1 = prime(i, plev[1])
                iqn_p1 = prime(iqn, plev[1])
                iqn2_p1 = prime(iqn2, plev[1]) 
                iqn3_p1 = prime(iqn3, plev[1])

                i_p2 = dag(prime(i, plev[2]))
                iqn_p2 = dag(prime(iqn, plev[2]))
                iqn2_p2 = dag(prime(iqn2, plev[2]))
                iqn3_p2 = dag(prime(iqn3, plev[2]))

                A = random_itensor(T,i_p1, i_p2)
                B = random_itensor(T,iqn_p1, iqn_p2)
                C = random_itensor(T,iqn2_p1, iqn2_p2)
                D = random_itensor(T,iqn3_p1, iqn3_p2)

                x = TensorMap(A)
                y = TensorMap(B)
                z = TensorMap(C)
                w = TensorMap(D)

                if ismissing(tag)
                    A2 = ITensor(x;ids=ITensors.id.(inds(A)),plevs=plev,qn_names=["N","P"])
                    B2 = ITensor(y;ids=ITensors.id.(inds(B)),plevs=plev,qn_names=["N"])
                    C2 = ITensor(z;ids=ITensors.id.(inds(C)),plevs=plev,qn_names=["N","P"])
                else
                    A2 = ITensor(x;ids=ITensors.id.(inds(A)),tags=tags,plevs=plev,qn_names=["N","P"])
                    B2 = ITensor(y;ids=ITensors.id.(inds(B)),tags=tags,plevs=plev,qn_names=["N"])
                    C2 = ITensor(z;ids=ITensors.id.(inds(C)),tags=tags,plevs=plev,qn_names=["N","P"])
                end
                @test isapprox(norm(A2-A),0;atol=1.0e-10)
                @test isapprox(norm(B2-B),0;atol=1.0e-10)
                @test isapprox(norm(C2-C),0;atol=1.0e-10)


                x2 = TensorMap(A2)
                y2 = TensorMap(B2)
                z2 = TensorMap(C2)
                w2 = TensorMap(ITensor(w;ids=ITensors.id.(inds(D)),plevs=plev,qn_names=["N","P"]))
                @test isapprox(norm(x2 - x), 0; atol=1.0e-10)
                @test isapprox(norm(y2 - y), 0; atol=1.0e-10)
                @test isapprox(norm(z2 - z), 0; atol=1.0e-10)
                @test isapprox(norm(w2 - w), 0; atol=1.0e-10)
            end
        end
    end
end
