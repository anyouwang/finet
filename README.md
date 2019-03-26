FINET: Fast Inferring NETwork 
Copyright@  Anyou Wang 

FINET is a software to infer any network. Implemented by Julia with algorithms of stability selection and elastic-net, plus parameter optimization, finet can infer a network fast and accurately from a big data. Additionally, finet is user-friendly, only one single command line to complete all computational processes. Developed under Linux, but finet should work in any OS system. Installing and using finet becomes simple by using following instructions. 

Any comments, please contact anyou dot wang dot 2012 at google mail

Install

1) Installing julia or upgrade julia to the latest version

Install new julia

git clone git://github.com/JuliaLang/julia.git

cd julia

git checkout v1.0.3

make



Upgrade from old version

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

git clone https://github.com/anyouwang/finet.git
cd finet


Running finet

Only input file and output name are required. Other arguments as optional. Any question type --help as shown below

an example of running

julia finet.jl -c 40 -k 3 -n 300 -m 4 -a 0.5 -p 0.95 -i mydata.txt -o mynetwork  

For help

julia finet.jl --help

usage: finet.jl [-c CPUS] [-n ITERATION] [-m SUBSAMPLING]
                        [-k KFOLDS] [-a ALPHA] [-p PERCENTCUTOFF]
                        [-i I] -o O [-h]




arguments:

  -c, --cpus CPUS       CPU number for parallel computation (type:
                        Int64, default: 8)
                        
  -n, --iteration ITERATION
                          Iteration times (type: Int64, default: 100)
                        
  -m, --subsampling SUBSAMPLING
                        Numbers of subgroups, subsampling for
                        stablility selection, pleaase keep default for
                        most users (type: Int64, default: 2)
                        
  -k, --kfolds KFOLDS   K-fold cross validation for Elastic net (type:
                        Int64, default: 5)
                        
  -a, --alpha ALPHA     alpha value (0<alpha <=1.0) for Elastic net
                        (type: Float64, default: 0.5)
                        
  -p, --percentcutoff PERCENTCUTOFF
                          Ranking frequency percentage for cutoff (0-1)
                        (type: Float64, default: 0.9)
                        
  -i I                  Input file name, required
  
  -o O                  Output file name, required
  
  -h, --help            show this help message and exit
  




