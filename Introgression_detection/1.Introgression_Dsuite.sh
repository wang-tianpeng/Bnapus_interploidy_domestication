#!/bin/sh 
# example dir /data/mg1/wangtp/data/202002_napus/12_introgression/1_lineageA
set -euo pipefail

script=$HOME/scripts/12_introgression
tree=LineageA_SPECIES_TREE_V1
prefix=lineagaA_tree
vcf=napus_final_R289_SNP.fil30.rm.als.quali08.recode_rapa_zs11_A_R199.SNP.raw.syn_nigra2.all.lineageA.vcf.gz
taxa=taxa_species.txt
napus_remain=taxa_plot_order_napus6.txt

# 1. Main process 
# 202201 keep the -c parameter
Dsuite Dtrios -n $prefix -t $tree $vcf $taxa 
# 2. Filter out the rapa group and only remain the napus subgroup 
perl $script/filter_napus.pl $napus_remain taxa_species_$prefix\_BBAA.txt >taxa_species_$prefix\_BBAA_napusONLY.txt

# 3. ruby plot based on the BBAA_ONLY.txt
### ruby plot_d.rb BBAA.TXT taxa_plot_order.txt 0.2 OUT_prefix.SVG
ruby plot_d.rb taxa_species_lineagaA_tree_BBAA_napusONLY.txt taxa_plot_order.txt 0.2 taxa_species_lineagaA_tree_BBAA_napusONLY.dplot.svg

## set d(0~0.1)
#ruby plot_d.rb taxa_species_RsemiALL_SKprecise_lineagaA_tree_BBAA_napusONLY.txt taxa_plot_order.txt 0.1 taxa_species_RsemiALL_SKprecise_lineagaA_tree_BBAA_napusONLY_d01.svg

# 3.2 ruby plot f4_ratio
ruby plot_f4ratio.rb taxa_species_lineagaA_tree_BBAA_napusONLY.txt taxa_plot_order_noSarson.txt 0.5 taxa_species_lineagaA_tree_BBAA_napusONLY.f4plot.svg

# 4. fbranch calculate and plot
Dsuite Fbranch LineageA_SPECIES_TREE_V2.txt taxa_species_lineagaA_tree_lineagaA_tree_napusONLY_tree.txt > taxa_species_lineagaA_tree_lineagaA_tree_napusONLY_treeV2_Franch.txt
### plot use the provided dtools.py
#### -n prefix name Fbranch.file Tree.newick
python ~/software/Dsuite/utils/dtools.py -n taxa_species_lineagaA_tree_lineagaA_tree_napusONLY_treeV2_Franch taxa_species_lineagaA_tree_lineagaA_tree_napusONLY_treeV2_Franch.txt LineageA_SPECIES_TREE_V2.txt



#### 12.4 Window-based Introgression signals

Dsuite Dinvestigate -w 100,50 napus_final_R289_SNP.fil30.rm.als.quali08.recode_rapa_zs11_A_R199.SNP.raw.syn_nigra2.all.lineageA.vcf.gz taxa_species.txt P1semiP2swP3TEU.id &


