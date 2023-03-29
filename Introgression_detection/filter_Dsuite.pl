#!/usr/bin/env perl -w

####### only remain the selected groups from the P1 & P2
# perl filter_dsuite.pl taxa_plot_order_napus6.txt taxa_species_lineagaA_intro_BBAA.txt
#
open SELECT, "$ARGV[0]" or die;

while(<SELECT>){
	chomp;
	$hash{$_}=1;
}

open ALL, "$ARGV[1]" or die;
$head=<ALL>;
print "$head";
while(<ALL>){
	chomp;
	@F=split;
	if (exists($hash{$F[0]})){
		print "$_\n" if exists($hash{$F[1]})
	}
}
