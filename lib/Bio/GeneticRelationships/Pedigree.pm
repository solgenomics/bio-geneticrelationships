package Bio::GeneticRelationships::Pedigree;
use strict;
use warnings;

use Moose;
use MooseX::FollowPBP;
use Moose::Util::TypeConstraints;
use Bio::GeneticRelationships::Individual;

=head1 NAME

    Pedigree - Representation of a pedigree

=head1 SYNOPSIS

    my $variable = Bio::GeneticRelationships::Pedigree->new();

=head1 DESCRIPTION

    This class stores pedigree information.

=head2 Methods

=over 

=cut

subtype 'CrossType',
    as 'Str',
    where { 
	$_ eq 'single_cross' ||
	$_ eq 'double_cross' ||
	$_ eq 'three_way_cross' ||
	$_ eq 'backcross' ||
	$_ eq 'self' ||
	$_ eq 'mixed_population' ||
	$_ eq 'doubled_haploid' ||
	$_ eq 'unknown' };
	

has 'name' => (isa => 'Str',is => 'rw', predicate => 'has_name');
has 'female_parent' => (isa =>'Bio::GeneticRelationships::Individual', is => 'rw', predicate => 'has_female_parent');
has 'male_parent' => (isa =>'Bio::GeneticRelationships::Individual', is => 'rw', predicate => 'has_male_parent');
has 'cross_type' => (isa =>'CrossType', is => 'rw', predicate => 'has_cross_type');

###
1;#do not remove
###

=pod

=back

=head1 LICENSE

    Same as Perl.

=head1 AUTHORS

    Jeremy D. Edwards <jde22@cornell.edu>   

=cut
