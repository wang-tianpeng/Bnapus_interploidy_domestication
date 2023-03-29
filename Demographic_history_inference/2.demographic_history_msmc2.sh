## pwd: $Home/data/napus/8_1_Demographic_history_MSMC2
## $Home/demography_learning/msmc2_scripts-master

### use the tutorial and scripts from Github: https://github.com/jessicarick/msmc2_scripts

# 0. change the msmc_params files
vi msmc_params.sh
source msmc_params.sh

# 0. Create Mappability Mask by SNPable
## download from http://lh3lh3.users.sourceforge.net/snpable.shtml && make
### the main program: 
splitfa $GENOME $k | split -l 20000000
cat x* >> ${prefix}_split.$k

bwa aln -t 8 -R 1000000 -O 3 -E 3 ${GENOME} ${prefix}_split.${k} > ${prefix}_split.${k}.sai
bwa samse -f ${prefix}_split.${k}.sam $GENOME ${prefix}_split.${k}.sai ${prefix}_split.${k}

gen_raw_mask.pl ${prefix}_split.${k}.sam > ${prefix}_rawMask.${k}.fa
gen_mask -l ${k} -r 0.5 ${prefix}_rawMask.${k}.fa > ${prefix}_mask.${k}.50.fa


# step1. use the msmc_1_call.sh and bamCaller.py 
mdkir vcf
mkdir mask

bcftools mpileup -q 20 -Q 20 -Ou -r ${s} --threads 16 -f $GENOME $BAMFILE | bcftools call -c --threads 16 -V indels | bamCaller.py $MEANCOV $MASK_IND > ${VCF}

### after get the mask.bed and vcf file. go to ../vcf/ and vcf_index.sh {}
cd ../vcf/
ls -1 *.vcf |xargs -i vcf_index.sh {}

# step2. Use generate_multihetsep.py to generate pop input file for MSMC2
## pwd /40t_1/wangtp/data/202002_napus/8_1_Demographic_history_MSMC2/8_1_Demographic_history_msmc/5_msmc_step2

### generate individual input file
cat taxa_msmc.id |cut -f 1|tail -n +2 |xargs -i echo sh msmc_2_generateInput_singleInd.sh {} >cmd.msmc_2_generateInput_single


mkdir input

nohup sh msmc_2_generateInput_multiInd.sh taxa_swede_ind.id Swede &
nohup sh msmc_2_generateInput_multiInd.sh taxa_sk_ind.id Siberiankale &
nohup sh msmc_2_generateInput_multiInd.sh taxa_reu_ind.id REU &
nohup sh msmc_2_generateInput_multiInd.sh taxa_rsp_ind.id RSP &
nohup sh msmc_2_generateInput_multiInd.sh taxa_rsemi_ind.id RSEMI &

# step3 msmc2 calculation

nohup msmc2 -t 20 -s -p 1*2+25*1+1*2+1*3 -i 50 -o /40t_1/wangtp/data/202002_napus/8_1_Demographic_history_MSMC2/8_1_Demographic_history_msmc/output/msmc_output.Swede.msmc_Swede_Diff_IS -I 0-1,2-3,4-5,6-7 ../input/msmc_input.Swede.scaffold* &
nohup msmc2 -t 20 -s -p 1*2+25*1+1*2+1*3 -i 50 -o /40t_1/wangtp/data/202002_napus/8_1_Demographic_history_MSMC2/8_1_Demographic_history_msmc/output/msmc_output.SK.msmc_SK_Diff_IS -I 0-1,2-3,4-5,6-7 ../input/msmc_input.Siberiankale.scaffold* &
nohup msmc2 -t 20 -s -p 1*2+25*1+1*2+1*3 -i 50 -o /40t_1/wangtp/data/202002_napus/8_1_Demographic_history_MSMC2/8_1_Demographic_history_msmc/output/msmc_output.SK.msmc_REU_Diff_IS -I 0-1,2-3,4-5,6-7 ../input/msmc_input.REU.scaffold* &
nohup msmc2 -t 20 -s -p 1*2+25*1+1*2+1*3 -i 50 -o /40t_1/wangtp/data/202002_napus/8_1_Demographic_history_MSMC2/8_1_Demographic_history_msmc/output/msmc_output.SK.msmc_RSP_Diff_IS -I 0-1,2-3,4-5,6-7 ../input/msmc_input.RSP.scaffold* &
nohup msmc2 -t 20 -s -p 1*2+25*1+1*2+1*3 -i 50 -o /40t_1/wangtp/data/202002_napus/8_1_Demographic_history_MSMC2/8_1_Demographic_history_msmc/output/msmc_output.SK.msmc_RSEMI_Diff_IS -I 0-1,2-3,4-5,6-7 ../input/msmc_input.RSEMI.scaffold* &

