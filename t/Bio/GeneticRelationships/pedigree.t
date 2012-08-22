#!/usr/bin/perl

=head1 NAME

pedigree.t
A test for Bio::GeneticRelationships::Pedigree class

=cut

=head1 SYNOPSIS

perl pedigree.t


=head1 DESCRIPTION



=head2 Author

Jeremy Edwards <jde22@cornell.edu>
=cut

use strict;
use warnings;
use autodie;


use Test::More tests => 36;
BEGIN {use_ok( 'Bio::GeneticRelationships::Pedigree' ); }
require_ok( 'Bio::GeneticRelationships::Pedigree' );
ok (my $pedigree = Bio::GeneticRelationships::Pedigree->new());
ok (my $pedigree_selfed = Bio::GeneticRelationships::Pedigree->new());
ok (my $pedigree_2 = Bio::GeneticRelationships::Pedigree->new());

#test name method
ok ($pedigree->set_name('test_name'));
is ($pedigree->get_name(),'test_name');

#test methods for adding parents
ok (my $female_individual = Bio::GeneticRelationships::Individual->new());
ok (my $male_individual = Bio::GeneticRelationships::Individual->new());
ok (my $individual_s = Bio::GeneticRelationships::Individual->new());
ok (my $female_individual_2 = Bio::GeneticRelationships::Individual->new());
ok (my $male_individual_2 = Bio::GeneticRelationships::Individual->new());
#test name methods for individuals
ok ($female_individual->set_name('female_A'));
ok ($male_individual->set_name('male_B'));
ok ($female_individual_2->set_name('female_C'));
ok ($male_individual_2->set_name('male_D'));
#test methods for adding parents to a pedigree
ok ($pedigree->set_female_parent($female_individual));
ok ($pedigree->set_male_parent($male_individual));
is ($pedigree->get_female_parent(),$female_individual);
is ($pedigree->get_male_parent(),$male_individual);
is ($pedigree->get_female_parent()->get_name(),'female_A');
is ($pedigree->get_male_parent()->get_name(),'male_B');
ok ($pedigree_selfed->set_female_parent($individual_s));
ok ($pedigree_selfed->set_male_parent($individual_s));
ok ($pedigree_2->set_female_parent($female_individual_2));
ok ($pedigree_2->set_male_parent($male_individual_2));
#test methods for adding pedigrees to individuals
ok ($female_individual->set_pedigree($pedigree_selfed));
ok ($individual_s->set_pedigree($pedigree_2));
is ($pedigree->get_female_parent(),$female_individual);
is ($pedigree->get_male_parent(),$male_individual);
#test methods with selfing
ok ($pedigree_selfed->set_cross_type('self'));
ok ($pedigree_selfed->set_selection_name('1'));
#test cross type method
ok ($pedigree->set_cross_type('single_cross'));
is ($pedigree->get_cross_type(),'single_cross');
#test pedigree string methods
ok (print STDERR "\n\n".$pedigree->get_pedigree_string()."\n\n");
#ok (my $pedigree_as_purdy = $pedigree->get_pedigree_string_purdy());
#ok (print STDERR "\n\nPurdy:\n".$pedigree_as_purdy."\n\n");
#test graphviz methods
ok ($pedigree->draw_graphviz("root","root","svg","test.svg"));
