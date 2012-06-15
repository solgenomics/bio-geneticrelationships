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


use Test::More tests => 15;
BEGIN {use_ok( 'Bio::GeneticRelationships::Pedigree' ); }
require_ok( 'Bio::GeneticRelationships::Pedigree' );
ok (my $pedigree = Bio::GeneticRelationships::Pedigree->new());

#test name method
ok ($pedigree->set_name('test_name'));
is ($pedigree->get_name(),'test_name');

#test methods for adding parents
ok (my $female_individual = Bio::GeneticRelationships::Individual->new());
ok (my $male_individual = Bio::GeneticRelationships::Individual->new());
ok ($female_individual->set_name('female_test_name'));
ok ($male_individual->set_name('male_test_name'));
ok ($pedigree->set_female_parent($female_parent_individual));
ok ($pedigree->set_male_parent($male_parent_individual));
is ($pedigree->get_female(parent),$female_parent_individual));
is ($pedigree->get_male(parent),$male_parent_individual));
is ($pedigree->get_female(parent)->get_name(),'female_test_name'));
is ($pedigree->get_male(parent)->get_name(),'male_test_name'));

