#!/usr/bin/perl

=head1 NAME

  descendants.t
  A test for Bio::GeneticRelationships::Descendants class

=cut

=head1 SYNOPSIS

 perl descendants.t


=head1 DESCRIPTION



=head2 Author

Jeremy Edwards <jde22@cornell.edu>
    
=cut

use strict;
use warnings;
use autodie;


use Test::More tests => 11;
BEGIN {use_ok( 'Bio::GeneticRelationships::Descendants' ); }
require_ok( 'Bio::GeneticRelationships::Descendants' );
ok (my $descendants = Bio::GeneticRelationships::Descendants->new());

#test name method
ok ($descendants->set_name('test_name'));
is ($descendants->get_name(),'test_name');

#test methods for adding parents
ok (my $first_individual = Bio::GeneticRelationships::Individual->new());
ok (my $second_individual = Bio::GeneticRelationships::Individual->new());
ok ($first_individual->set_name('first_test_name'));
ok ($second_individual->set_name('second_test_name'));
ok ($descendants->add_offspring($first_individual));
ok ($descendants->add_offspring($second_individual));

