#!/usr/bin/perl

=head1 NAME

  pedigree.t
  A test for Bio::GeneticRelationships::Individual class

=cut

=head1 SYNOPSIS

 perl individual.t


=head1 DESCRIPTION



=head2 Author

Jeremy Edwards <jde22@cornell.edu>
    
=cut

use strict;
use warnings;
use autodie;


use Test::More tests => 9;
BEGIN {use_ok( 'Bio::GeneticRelationships::Individual' ); }
require_ok( 'Bio::GeneticRelationships::Individual' );
BEGIN {use_ok( 'Bio::GeneticRelationships::Pedigree' ); }
require_ok( 'Bio::GeneticRelationships::Pedigree' );
ok (my $individual = Bio::GeneticRelationships::Individual->new());
ok ($individual->set_name('test_name'));
is ($individual->get_name(),'test_name');
ok (my $pedigree = Bio::GeneticRelationships::Pedigree->new());
ok (my $female_parent_individual = Bio::GeneticRelationships::Individual->new());
ok ($female_parent_individual->set_name('test_female_parent_name'));
ok ($pedigree->set_female_parent($female_parent_individual));
ok ($individual->set_pedigree($pedigree));
is ($individual->get_pedigree(),$pedigree));
is ($individual->get_pedigree()->get_female_parent(),$female_parent_individual);



