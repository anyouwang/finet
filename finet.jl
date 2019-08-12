using Distributed
using ArgParse

#@everywhere using JLD
@everywhere using GLMNet
@everywhere using StatsBase
@everywhere using SharedArrays



function userArgs()
    arglist = ArgParseSettings()
    @add_arg_table arglist begin
        "--cpus","-c"
            help = "CPU number for parallel computation"
            arg_type = Int
            default = 8
        "--iteration","-n"
            help = "Iteration times"
            arg_type = Int
            default = 100
       "--subsampling","-m"
            help = "Numbers of subgroups, subsampling for stablility selection, pleaase keep default for most users"
            arg_type = Int
            default=2
      "--kfolds","-k"
            help = "K-fold cross validation for Elastic net"
            arg_type = Int
            default=5
       "--alpha","-a"
            help = "alpha value (0<alpha <=1.0) for Elastic net"
            arg_type = Float64
            default=0.5
       "--percentcutoff","-p"
            help = "Ranking frequency percentage for cutoff (0-1)"
            arg_type = Float64
            default=0.9
        "-i"
            help = "Input file name, required"
            arg_type = String
            required = true
        "-o"
            help = "Output file name, required"
            arg_type=String
            required =true
    end
    return parse_args(arglist)
end

##read in user input
pargs = userArgs()
addprocs(pargs["cpus"])


function read2array(ifname)
   a=Array{Float64}[]
   geneDic=Dict()
   ifile=open(ifname,"r")
   genes=readline(ifile)
   genes=split(strip(genes),"\t")
   [geneDic[i]=genes[i] for i in collect(1:length(genes))]
   for line in eachline(ifile)
        line=split(strip(line),"\t")
        x=[parse(Float64,i) for i in line]
        push!(a,x)
   end
  return(geneDic,a)
end


@everywhere function chunkSum(inode_dic,group_dic,xindex)
   for (key,coef) in group_dic
       for j in collect(1:length(xindex))  # read in coef for one repeat
           if coef[j] == 0
              continue
           end
           k=xindex[j]
           if !(k in keys(inode_dic))
              freq_dict=Dict()
              freq_dict["count"]=1
              freq_dict["coef"]= coef[j]
              inode_dic[k]= freq_dict
            else
            inode_dic[k]["count"] += 1
            inode_dic[k]["coef"] = (inode_dic[k]["coef"] + coef[j])/2
            end
      end
   end
   return inode_dic
end

@everywhere function chuckCoeff(split_index,inode)
    cv = glmnetcv(a[split_index,[collect(1:inode-1); collect(inode+1:end)]],a[split_index,inode],alpha=alpha1,nfolds=kfolds)
    coef= cv.path.betas[:, argmin(cv.meanloss)]
    return coef
end

@everywhere using StatsBase
@everywhere using GLMNet

@everywhere function runInode(inode,xindex)
   inode_dic=Dict()
   #repeats
   for r in collect(1:niteration) # one repeat in n repeats
      #subsampling for stable selection
      rand_index=sample(collect(1:size(a,1)),size(a,1),replace=false) #rand sample index
      g=Int(ceil(size(a,1)/split_groups))
      split_index=collect(Iterators.partition(rand_index, g)) #chunk to split_groups
      group_dic= Dict()
      @sync begin
          for i in collect(1:split_groups)
              @async group_dic[i] = chuckCoeff(split_index[i],inode)
          end
      end
      inode_dic=chunkSum(inode_dic,group_dic,xindex)
   end
   [inode_dic[k]["freq"]=inode_dic[k]["count"]/(niteration*split_groups) for k in keys(inode_dic)]
   filter_dic=Dict()
   [filter_dic[k]=inode_dic[k] for k in keys(inode_dic) if inode_dic[k]["freq"] >= percent_cutoff ]
   return filter_dic
end    # end on


@everywhere function subSet(sub_range)
   sleep(30)
   outfile = open(string(outfilename,"_",string(alpha1),"_",string(sub_range[1]),"_",string(sub_range[end]),".txt"), "w")
   sub_dic=Dict()
   for inode in sub_range #run i node
      xindex=union(collect(1:inode-1),collect(inode+1:size(a)[2])) #x matrix index
      inode_dic=runInode(inode,xindex)
      for k in keys(inode_dic)  #output gene #i interactions
         if inode_dic[k]["freq"] >= percent_cutoff
            println(outfile,k,"\t",inode,"\t",inode_dic[k]["count"],"\t",inode_dic[k]["freq"],"\t",inode_dic[k]["coef"])
         end
      end # end gene #i
      node_dic=Dict()
      node_dic[inode]=inode_dic
      sub_dic=merge(sub_dic,node_dic)
   end # end r1:r2
   close(outfile)
   return sub_dic
end


@everywhere using DelimitedFiles
function write2DelimitedFiles(results)
   aa = Array[]
   push!(aa,["source","target","frequency","coef"])
   [push!(aa, [gdic[sKey],gdic[iNode],vd["freq"],vd["coef"]]) for idic in results for (iNode, ikd) in idic for (sKey, vd) in ikd]
   sort!(aa,by= x-> (x[1],x[3]),rev=true)
   outfinalfile = open(string(outfilename,".",string(alpha1),".",string(niteration),".final.network",".txt"), "w")
   writedlm(outfinalfile,aa)
   close(outfinalfile)
end


#
#writedlm("/tmp/test.txt", numbers)

function main()

   println("In running, it might take a while!")
   n=Int(ceil(size(a,2)/cpus))
   x=collect(1:size(a,2))
   run_range=[x[i:min(i+n-1,length(x))] for i in 1:n:length(x)]
   results=pmap((sub_range)->subSet(sub_range),[sub_range for sub_range in run_range])
   write2DelimitedFiles(results)
end

split_groups =pargs["subsampling"]
@eval @everywhere split_groups = $split_groups
cpus=Int(floor(pargs["cpus"]))
@eval @everywhere cpus=$cpus
alpha1=pargs["alpha"]
@eval @everywhere alpha1=$alpha1
kfolds=pargs["kfolds"]
@eval @everywhere kfolds=$kfolds
percent_cutoff=pargs["percentcutoff"]
@eval @everywhere percent_cutoff = $percent_cutoff
niteration =pargs["iteration"]
@eval @everywhere niteration = $niteration

outfilename=pargs["o"]
@everywhere outfilename= $outfilename

ifname=pargs["i"]
println(ifname)
gdic,a=read2array(ifname)
@eval @everywhere gdic=$gdic
a=hcat(a...)
a=transpose(a)
#a=SharedArray(a[1:end,1:end],)
a = SharedArray{Float32,2}(a[1:end,1:end])
@eval @everywhere a=$a
println("your data, first 2 rows and columns")
println(a[1:2,1:2])

main()
