#pwd: 44:/45t/wangtp/data/202002_brassica/11_treemix/1_lineageA

VCF_RAW=napus_final_R289_SNP.fil30.rm.als.quali08.recode_rapa_zs11_A_R199.SNP.raw.syn_nigra2.all.lineageA.vcf.gz
LINEAGE=napus_treemix_lineageA

plink --vcf $VCF_RAW --make-bed --aec --double-id --recode vcf-iid --out ${LINEAGE} --set-missing-var-ids @__#

plink --bfile $LINEAGE --aec --snps-only --double-id --indep-pairwise 100 100 0.3 --geno 0.1 --out ${LINEAGE}_ld1kb --set-missing-var-ids @__#

plink --bfile $LINEAGE --aec --snps-only --double-id --extract ${LINEAGE}_ld1kb.prune.in --recode vcf-iid --out ${LINEAGE}_ld100bp --set-missing-var-ids @__#

#modify the vcf2treemix.sh to the plink style
vcf2treemix.sh ${LINEAGE}_ld100bp.vcf taxa_treemix.txt

## prepare the zero migration
treemix -i napus_treemix_lineageA_ld100bp.treemix.frq.gz -m 0 -o napus_treemix_lineageA.0 -bootstrap -k 500 -noss > treemix_0_log

seq 0 12 |xargs -i echo "treemix -i ${LINEAGE}_ld100bp.treemix.frq.gz -m {} -o $LINEAGE.{} -root Outgroup -bootstrap -k 500 -noss > treemix_{}_log" >cmd.treemix.sh

nohup ParaFly -c cmd.treemix.sh -CPU 6 &


cd ../output_treemix_v2/
### v2 set the tree -g tree_lineageA.0.vertices.gz tree_lineageA.0.edges.gz
seq 0 20 |xargs -i echo "treemix -i ${LINEAGE}_ld100bp.treemix.frq.gz -m {} -o $LINEAGE.{} -root Outgroup -g tree_lineageA.0.vertices.gz tree_lineageA.0.edges.gz -bootstrap -k 500 -noss > treemix_{}_log" >cmd.treemix.sh

seq 0 20 |xargs -i echo "treemix -i ${LINEAGE}_ld100bp.treemix.frq.gz -m {} -o $LINEAGE.{} -g tree.vertices.gz tree.edges.gz -bootstrap -k 500 -noss > treemix_{}_log" >cmd.treemix.sh
