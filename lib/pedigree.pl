#! /usr/bin/perl

use strict;
use warnings;
use Bio::GeneticRelationships::Pedigree;
use Bio::GeneticRelationships::Individual;

my @array = ();

my $walter = Bio::GeneticRelationships::Individual->new(name => "Walter");
my $mh11 = Bio::GeneticRelationships::Individual->new(name => "MH_11");
my $cl11d = Bio::GeneticRelationships::Individual->new(name => "Cl_11d");
my $campbell28 = Bio::GeneticRelationships::Individual->new(name => "Campbell_28");
my $a645 = Bio::GeneticRelationships::Individual->new(name => "645");
my $Hawaii997 = Bio::GeneticRelationships::Individual->new(name => "Hawaii_997");
my $Neptune = Bio::GeneticRelationships::Individual->new(name => "Neptune");
my $pluto = Bio::GeneticRelationships::Individual->new(name => "Pluto");


$array[0]= Bio::GeneticRelationships::Pedigree->new(name => "Walter");
$array[1]= Bio::GeneticRelationships::Pedigree->new(name => "MH_11");
$array[2]= Bio::GeneticRelationships::Pedigree->new(name => "Cl_11d");
$array[3]= Bio::GeneticRelationships::Pedigree->new(name => "Campbell_28");
$array[4]= Bio::GeneticRelationships::Pedigree->new(name => "645");
$array[5]= Bio::GeneticRelationships::Pedigree->new(name => "Hawaii_997");
$array[6]= Bio::GeneticRelationships::Pedigree->new(name => "Neptune");
$array[7]= Bio::GeneticRelationships::Pedigree->new(name => "Pluto");


$array[2]->set_female_parent($mh11);
$array[2]->set_male_parent($walter);
$array[3]->set_female_parent($cl11d);
$array[3]->set_male_parent($cl11d);
$array[4]->set_female_parent($Hawaii997);
$array[4]->set_male_parent($Hawaii997);
$array[6]->set_male_parent($campbell28);
$array[6]->set_female_parent($a645);
$array[7]->set_female_parent($mh11);
$array[7]->set_male_parent($walter);

$walter->set_pedigree($array[0]);
$mh11->set_pedigree($array[1]);
$cl11d->set_pedigree($array[2]);
$campbell28->set_pedigree($array[3]);
$a645->set_pedigree($array[4]);
$Hawaii997->set_pedigree($array[5]);
$Neptune->set_pedigree($array[6]);
$pluto->set_pedigree($array[7]);



foreach my $i (0..6) {
	$array[$i]->set_cross_type('single_cross');
}
$array[6]->draw_graphviz("Neptune","Neptune")





