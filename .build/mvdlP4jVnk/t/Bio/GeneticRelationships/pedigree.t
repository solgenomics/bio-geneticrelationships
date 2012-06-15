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

use Test::More tests => 3;
BEGIN {use_ok( 'Bio::GeneticRelationships::Pedigree' ); }
require_ok( 'Bio::GeneticRelationships::Pedigree' );
ok my $pedigree = Bio::GeneticRelationships::Pedigree->new();


