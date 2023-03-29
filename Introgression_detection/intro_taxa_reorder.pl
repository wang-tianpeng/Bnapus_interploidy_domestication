#!usr/bin/env perl

open IN1,"$ARGV[0]" or die;
open IN2,"$ARGV[1]" or die;

while(<IN1>){
	s/\r?\n//;
	@F=split/\s+/;
	$hash{$F[0]}=$F[1];
}

while(<IN2>){
	chomp;
	@line=split/\s+/;
	print"$line[0]\t$line[1]\t$hash{$line[0]}\n";
}

