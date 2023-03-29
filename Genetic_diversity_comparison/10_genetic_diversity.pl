#!/usr/bin/env perl -w
use strict;

my $usage=<<USAGE;
	perl $0 napus_info.csv napus_R414.vcf
USAGE

die $usage if @ARGV==0;

my($info,$vcf,%hash);

open IN1,$ARGV[0] or die "$!";
<IN1>;
while(<IN1>){
	s/\r\n//;
	my @line=split/,/;
	$hash{$line[4]}.="$line[0]"."\n";
}
foreach my $group (keys %hash){
	open OUTPUT,">$group.id";
	print OUTPUT "$hash{$group}\n";
	my $command_pi = "vcftools --gzvcf $ARGV[1] --keep $group.id --site-pi --out $group\_pi 2>$group\_pi.log";
	my $command_window= "vcftools --gzvcf $ARGV[1] --keep $group.id --window-pi 100000 --window-pi-step 10000 --out $group\_win100st10 2>$group\_win100st10.log";
	my $command_window3= "vcftools --gzvcf $ARGV[1] --keep $group.id --window-pi 200000 --window-pi-step 10000 --out $group\_win200st10 2>$group\_win200st10.log";
	my $command_window2="vcftools --gzvcf $ARGV[1] --keep $group.id --window-pi 10000 --out $group\_win10 2>$group\_win10.log";
	print "$command_pi\n$command_window\n$command_window3\n$command_window2\n";
}
