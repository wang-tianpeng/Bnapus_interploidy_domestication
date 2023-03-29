#!/usr/bin/env perl

# dir: ~/data/202002_napus/13_selection_XPEHH/1_lineageA
# cmd: perl calcu_genedis.pl linkage_A.stat lineageA.map >1; mv 1 lineageA.map
# 2021-03

open LINK, "$ARGV[0]" or die "$!";
open IN2, "$ARGV[1]" or die "$!";

while(<LINK>){
	chomp;
	@F=split;
	$hash{$F[0]}=$F[1];
}

while(<IN2>){
	chomp;
	@f=split;
	$dis=$f[3]*$hash{$f[0]};
	print "$f[0]\t$f[1]\t$dis\t$f[3]\n";
}
