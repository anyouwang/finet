FINET: Fast Inferring NETwork 
Copyright@  Anyou Wang 

FINET is a software to infer any network. Implemented by Julia with algorithms of stability selection and elastic-net, plus parameter optimization, finet can infer a network fast and accurately from a big data. Additionally, finet is user-friendly, only one single command line to complete all computational processes. Developed under Linux, but finet should work in any OS system. Installing and using finet becomes simple by using following instructions. 

Any comments, please contact anyou dot wang dot 2012 at google mail

A, Install

1) Installing julia or upgrade julia to the latest version

install new julia
git clone git://github.com/JuliaLang/julia.git
cd julia
git checkout v1.0.3
make

upgrade from old version
cd /path/to/julia
git pull
git checkout v1.0.3
make

2) Install packages

type julia from terminal

julia> import Pkg; Pkg.add("StatsBase")
julia> import Pkg; Pkg.add("ArgParse")
julia> import Pkg; Pkg.add("GLMNet")
julia> import Pkg; Pkg.add("SharedArrays")

3)Download finet

done!
