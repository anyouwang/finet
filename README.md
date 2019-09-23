<H2>FINET: Fast Inferring NETwork </H2>

Copyright@  Anyou Wang 

FINET is a software to infer any network (1). Implemented by Julia with algorithms of stability selection and elastic-net, plus parameter optimization, finet can infer a network fast and accurately from a big data. Additionally, finet is user-friendly, only one single command line to complete all computational processes. Developed under Linux, but finet should work in any OS system. Installing and using finet becomes simple by using following instructions. 

Any comments, please contact anyou dot wang dot 2012 at google mail

<H2>Install Julia and FINET</H2> 

<H4>1.Installing julia or upgrade julia to the latest version</H4>

<H5>Install new julia</H5>

git clone git://github.com/JuliaLang/julia.git

cd julia

git checkout v1.0.3

make



<H5>Upgrade from old version</H5>

cd /path/to/julia

git pull

git checkout v1.0.3

make




<H4>2.Install packages</H4>

type julia from terminal

julia> import Pkg; Pkg.add("StatsBase")

julia> import Pkg; Pkg.add("ArgParse")

julia> import Pkg; Pkg.add("GLMNet")

julia> import Pkg; Pkg.add("SharedArrays")




<H4>3.Download FINET</H4>

git clone https://github.com/anyouwang/finet.git

cd finet


<H2>Running FINET</H2>

Only input file and output name are required. Other arguments as optional. Any question type --help as shown below

an example of running

julia finet.jl -c 40 -k 5 -n 300 -m 8 -a 0.5 -p 0.95 -i mydata.txt -o mynetwork

An input file is a normalized matrix, with each column as a gene and a row as an observation

<H2>Please note: without stability-selection, elastic-net produced mostly noise. Increasing m value (e.g. m=8) and p (e.g. 0.95) will dramatically improve selection true positive ratio (true positives/total true callings), yet increasing iterations to a large number like 10000 does not help much as shown in our report (1) <H2>. 

<H2>For help</H2>

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
  


(1)Wang, A. & Hai, R. FINET: Fast Inferring NETwork. bioRxiv 733683 (2019). doi:10.1101/733683
