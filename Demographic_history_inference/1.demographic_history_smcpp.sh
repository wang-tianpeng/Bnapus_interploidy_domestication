#!/bin/sh
set -euo pipefail

pop=Rapeseed_Winter_in_Europe
shuf ${pop}.id |head -30 >${pop}.id.30
pop_list=`perl -alne '$samples.=$F[0].","; END{print"$samples"}' ${pop}.id.30 | perl -alne 's/,$//;print'`
mkdir -p out/${pop}.30

for chromosome in {01..10}; do for sample in `less ${pop}.id.30`; do echo "~/miniconda3/envs/wgs/bin/smc++ vcf2smc -d ${sample} ${sample} napus289.AC.syn_${pop}.vcf.gz out/${pop}.30/scaffoldA${chromosome}.${pop}.${sample}.smc.gz scaffoldA${chromosome} ${pop}:${pop_list}"; done; done >cmd.${pop}.sh.30
for chromosome in {01..09}; do for sample in `less ${pop}.id.30`; do echo "~/miniconda3/envs/wgs/bin/smc++ vcf2smc -d ${sample} ${sample} napus289.AC.syn_${pop}.vcf.gz out/${pop}.30/scaffoldC${chromosome}.${pop}.${sample}.smc.gz scaffoldC${chromosome} ${pop}:${pop_list}"; done; done >>cmd.${pop}.sh.30

ParaFly -c cmd.${pop}.sh.30 -CPU 20
cd out/${pop}.30

~/miniconda3/envs/wgs/bin/smc++ estimate --em-iterations 50 --thinning 2000 --timepoints 1 1000000 --knots 20 -o model.new.v1 -v 1.5e-8 *.smc.gz


##  FOR two populations and split
#!/bin/bash
set -euo pipefail

### please notice the bim file and the pop1/po2 modol files directories.

pop1=$1 #Swede
pop2=$2 #Rapeseed_Winter_in_Europe

cat smc_${pop1}.id smc_${pop2}.id >smc_${pop1}_${pop2}.txt
#perl -i.bak -alne 'print"$F[0]\t$F[0]"' ${pop1}_${pop2}.txt

plink --bfile napus_demo_select.vcf --aec --double-id --recode vcf-iid --keep smc_${pop1}_${pop2}.txt --geno 0.2 --out smc\_${pop1}_${pop2}
vcf_index.sh smc\_${pop1}_${pop2}.vcf

mkdir -p out/${pop1}_${pop2}
pop1_list=`perl -alne '$samples.=$F[0].","; END{print"$samples"}' smc_$pop1.id | perl -alne 's/,$//;print'`
pop2_list=`perl -alne '$samples.=$F[0].","; END{print"$samples"}' smc_$pop2.id | perl -alne 's/,$//;print'`
for chromosome in {01..10}; do echo "~/miniconda3/envs/wgs/bin/smc++ vcf2smc --mask mask_out_out/$pop1.mask.scaffoldA$chromosome.bed.gz smc\_${pop1}_${pop2}.vcf.gz out/${pop1}_${pop2}/scaffoldA${chromosome}.${pop1}.${pop2}.smc.gz scaffoldA${chromosome} ${pop1}:${pop1_list} ${pop2}:${pop2_list} &"; echo "~/miniconda3/envs/wgs/bin/smc++ vcf2smc --mask mask_out_out/$pop1.mask.scaffoldA$chromosome.bed.gz smc\_${pop1}_${pop2}.vcf.gz out/${pop1}_${pop2}/scaffoldA${chromosome}.${pop2}.${pop1}.smc.gz scaffoldA${chromosome} ${pop2}:${pop2_list} ${pop1}:${pop1_list} &"; done | sh #>cmd.${pop1}_${pop2}.sh

for chromosome in {01..09}; do echo "~/miniconda3/envs/wgs/bin/smc++ vcf2smc --mask mask_out_out/$pop1.mask.scaffoldC$chromosome.bed.gz smc\_${pop1}_${pop2}.vcf.gz out/${pop1}_${pop2}/scaffoldC${chromosome}.${pop1}.${pop2}.smc.gz scaffoldC${chromosome} ${pop1}:${pop1_list} ${pop2}:${pop2_list} &"; echo "~/miniconda3/envs/wgs/bin/smc++ vcf2smc --mask mask_out_out/$pop1.mask.scaffoldC$chromosome.bed.gz smc\_${pop1}_${pop2}.vcf.gz out/${pop1}_${pop2}/scaffoldC${chromosome}.${pop2}.${pop1}.smc.gz scaffoldC${chromosome} ${pop2}:${pop2_list} ${pop1}:${pop1_list} &"; done | sh#>>cmd.${pop1}_${pop2}.sh
ParaFly -c cmd.${pop1}_${pop2}.sh -CPU 10

cd out/${pop1}_${pop2}
~/miniconda3/envs/wgs/bin/smc++ split -o split_v1/ ../${pop1}/model_final/model.final.json ../${pop2}/model_final/model.final.json *.gz 2>split.log1

