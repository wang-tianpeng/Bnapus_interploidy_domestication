#!/usr/bin/env perl
use strict;

my $usage=<<USAGE;

	perl $0 tree_order.txt plink_order.txt file.meanQ
	/data/mg1/wangtp/data/202002_napus/rapa_zs11_A/9_pca_structure/napus_zs11A_filter_mac3mis08/new_R261_R199/structure_results
USAGE

die $usage if @ARGV==0;

my $plink_order=$ARGV[1];
my $meanq=$ARGV[2];
my $tree_order=$ARGV[0];
my (%hash,%order_meanq );

$meanq=~/(.*?)\.Q/;
my $name=$1;
open OUT, ">$name.reorder.Q";

open IN,$plink_order or die "$!";
while(<IN>){
	chomp;
	$hash{$.}=$_;
}

open IN1, $meanq or die "$!";
while(<IN1>){
	chomp;
	$order_meanq{$hash{$.}}=$_;
}

open IN2, $tree_order or die "$!";
while(<IN2>){
	chomp;
	print OUT "$order_meanq{$_}\n";
}
