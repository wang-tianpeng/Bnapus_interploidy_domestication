#!/usr/bin/env perl
use strict;

my $usage=<<USAGE;
	perl $0 vcf_file cpu
	~/data/202002_napus/rapa_zs11_A/9_pca_structure/napus_zs11A_filter_mac3mis08

USAGE

die $usage if @ARGV==0;

my $cpu=$ARGV[1];
$ARGV[0]=~/(.*)\.vcf/;
my $name=$1;
unless(-e "plink_prepare.ok"){
	my $command="plink --vcf $ARGV[0] --recode 12 --out $name.plink --allow-extra-chr --double-id 2>$name.admix.plink.log";
	system($command)==0 or die "$!";

	my $command = "plink --vcf $ARGV[0] --out $name.plink --allow-extra-chr --double-id 2>$name.faststr.plink.log";
	system($command)==0 or die "$!";
	open OUT, ">plink_prepare.ok" or die;
}else{
	print "plink prepareation is OK\n";
}
### admixture preparation
mkdir "structure_results" unless -e "structure_results";
open OUT1,">$name.admixture.command";
open OUT2,">$name.faststructure.command";
unless(-e "structure.ok"){
	for(my $i=2;$i<=12;$i++){
		print OUT1 "admixture --cv $name.plink.ped $i >>structure_results/$name.admixture.$i.log\n";
		print OUT2 "~/miniconda3/envs/py27/bin/structure.py -K $i --input=$name.plink --out=structure_results/$name.faststructure\n";
	}
	my $command="ParaFly -c $name.faststructure.command -CPU $cpu";
	system($command)==0 or die "$!";
	my $command="ParaFly -c $name.admixture.command -CPU $cpu";
	system($command)==0 or die "$!";
	open OUT3,">structure.ok" or die "$!";
}else{
	print "structure result is OK\n";
}

### run PCA
mkdir "pca_results" unless -e "pca_results";
unless(-e "pca.ok"){
	my $command="plink --vcf $ARGV[0] --pca --out pca_results/$name.pca.plink --allow-extra-chr --double-id";
	system($command)==0 or die "$!";
	open OUT4,">pca.ok";
}

print "All command finished with no BUG\n";
