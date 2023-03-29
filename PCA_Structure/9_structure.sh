#!/bin/sh 
set -euo pipefail

file=lineageA484_nigra2.ale.snp.syn.final.vcf
#id_remove=nigra2_remove.id # if exists


prefix=${file/.vcf/}

## plink format transformation for Faststructure
plink --vcf $file --aec --set-missing-var-ids @_#  --double-id --out $prefix.faststr --make-bed
## plink formate transformation for admixture
plink --vcf $file --recode 12 --aec --set-missing-var-ids @_#  --double-id --out $prefix.admix

# prepare for the admixture software commands.
for i in `seq 2 15`
do
	echo "admixture --cv lineageC289_ole127.admix.ped $i >>log${i}.txt"
done >cmd.admixture.$prefix.sh

# prepare for the faststructure software commands.
####
#	faststructure needs to be run on py27 env
#####
for i in `seq 2 15`
do
	echo "structure.py -K $i --input=$prefix.faststr --output=$prefix.faststr.$i"
done >cmd.faststructure.$prefix.sh
