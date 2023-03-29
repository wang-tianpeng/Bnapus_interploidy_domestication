
## prepare for the comparing file
grep "Swede" taxa_species.txt |cut -f 1 >swede.id
grep -v -e "SamA" -e "Outgroup" -e "Swede" -e "MISTAKE" taxa_species.txt >swede_non.id

## using xpclr py3 version to conduct xpclr analysis. Use the absolute path
cat linkage_A.stat |
perl -pe 's/scaffold//'| 
perl -alne 'print "xpclr --format vcf --input /data/mg1/wangtp/data/202002_napus/13_selection_XPCLR/1_lineageA/napus_final_R289_SNP.fil30.rm.als.quali08.recode_rapa_zs11_A_R199.SNP.raw.syn.vcf.vcf --samplesA ~/data/202002_napus/13_selection_XPCLR/1_lineageA/swede.id --samplesB ~/data/202002_napus/13_selection_XPCLR/1_lineageA/swede_non.id --phased --chr scaffold$F[0] --ld 0.95 --size 100000 --step 10000 --out res/xpclr_py3_SW2NON.$F[0] --rrate $F[1]"' >cmd.sh

ParaFly -c cmd.sh -CPU 10

### after the SHAPIT process

cat linkage_A.stat | perl -pe 's/scaffold//; s/-06/-08/'|  perl -alne 'print "xpclr --format vcf --input /data/mg1/wangtp/data/202002_napus/13_selection_XPCLR/1_lineageA/shapeit_phased/napus_final_R289_SNP.fil30.rm.als.quali08.recode_rapa_zs11_A_R199.SNP.raw.syn.scaffold$F[0].phased.vcf --samplesA ~/data/202002_napus/13_selection_XPCLR/1_lineageA/shapeit_phased/siberiankale.id --samplesB ~/data/202002_napus/13_selection_XPCLR/1_lineageA/shapeit_phased/siberiankale_non.id --phased --chr scaffold$F[0] --ld 0.95 --size 100000 --step 10000 --out res/xpclr_py3_SK2NON.$F[0] --rrate $F[1]"' >cmd_sk2non.sh

## change to lineage C
cd ~/data/202002_napus/13_selection_XPCLR/2_lineageC/shapeit_phased

cat ../linkage_C.stat | perl -alne 'print "xpclr --format vcf --input /data/mg1/wangtp/data/202002_napus/13_selection_XPCLR/2_lineageC/shapeit_phased/napus_final_R289_SNP.fil30.rm.als.quali08.recode_ole_zs11C_R127.final.fil30.rm.als.syn.$F[0].phased.vcf --samplesA ~/data/202002_napus/13_selection_XPCLR/2_lineageC/shapeit_phased/siberiankale.id --samplesB ~/data/202002_napus/13_selection_XPCLR/2_lineageC/shapeit_phased/siberiankale_non.id --phased --chr scaffold$F[0] --ld 0.95 --size 100000 --step 10000 --out res/xpclr_py3_SK2NON.$F[0] --rrate $F[1]"' >cmd_sk2non.sh


## 整合
cat *SW2WEU* |perl -lne 'print if $.==1; print unless (/^id/) ' > xpclr_py3_lineageA_SW2WEU.ALL


## XPEHH calculation

#!/bin/sh 
set -euo pipefail

### dir: /data/mg1/wangtp/data/202002_napus/13_selection_XPEHH/1_lineageA

script=~/scripts/13_selection



# prepare for the map for each chr.
for i in *.vcf
do 
    i=${i/.vcf/}
    plink --vcf ${i}.vcf --recode --aec --double-id --set-missing-var-ids @:# --out ${i} & 
done

# use calcu_genedis.pl to calculate the putative map file.
for i in *.map
do
    perl $script/calcu_genedis.pl linkage_A.stat $i >1
    mv 1 $i
done

## altenative . mainly for the plink id format
perl -lne 'print "$_\t$_"' $group1 >1 ; mv 1 $group1
perl -lne 'print "$_\t$_"' $group2 >1 ; mv 2 $group2


# compare group1 to group2
group1=RSA
group2=winterEU
DIR=data_RSA2WEU

mkdir $DIR

for i in *.vcf; do i=${i/.vcf/}; plink --vcf ${i}.vcf --keep $group1.id --recode vcf-iid --aec --double-id --set-missing-var-ids @:# --out $DIR/${i}.$group1; done
for i in *.vcf; do i=${i/.vcf/}; plink --vcf ${i}.vcf --keep $group2.id --recode vcf-iid --aec --double-id --set-missing-var-ids @:# --out $DIR/${i}.$group2; done

cd $DIR

for i in *.$group1.vcf; do i=${i/.$group1.vcf/}; n=${i/.phased/};n=${n/napus_final_R289_SNP.fil30.rm.als.quali08.recode_rapa_zs11_A_R199.SNP.raw.syn./}; echo "selscan --xpehh --vcf ${i}.$group1.vcf --vcf-ref ${i}.$group2.vcf --map ../$i.map --threads 2 --out ../res/lineageA.$group1\2$group2\.xpehh.$n"; done >cmd_RSA2WEU.sh

ParaFly -c cmd_RSA2WEU.sh -CPU 10




