package Bio::GeneticRelationships::Pedigree;
use strict;
use warnings;

use Moose;
use MooseX::FollowPBP;
use Moose::Util::TypeConstraints;
use Bio::GeneticRelationships::Individual;

=head1 NAME

    Bio::GeneticRelationships::Pedigree - Pedigree of an individual

=head1 SYNOPSIS

    my $variable = Bio::GeneticRelationships::Pedigree->new();

=head1 DESCRIPTION

    This class stores an individual's pedigree.

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


sub get_pedigree_string {
    my $self = shift;
    my $pedigree_str = '';
    $pedigree_str = $pedigree_str."(";
    if ($self->has_female_parent()){
	if ($self->get_female_parent()->has_pedigree()){
	    $pedigree_str = $pedigree_str.$self->get_female_parent()->get_pedigree_string();
	}
	else {
	    $pedigree_str = $pedigree_str.$self->get_female_parent()->get_name();
	}
    }
    else {
	$pedigree_str = $pedigree_str."?";
    }


    $pedigree_str = $pedigree_str." X ";

    if ($self->has_male_parent()){
	if ($self->get_male_parent()->has_pedigree()){
	    $pedigree_str = $pedigree_str.$self->get_male_parent()->get_pedigree_string();
	}
	else {
	    $pedigree_str = $pedigree_str.$self->get_male_parent()->get_name();
	}
    }
    else {
	$pedigree_str = $pedigree_str."?";
    }
    $pedigree_str = $pedigree_str.")";
}



sub traverse_pedigree {
    #my $self = shift;
    my $trav_ped = shift; #female pedigree
    my $current_node_id = shift; #female ID
    my $current_node_name = shift;
    my %nodes;
    my %joins;
    my $female_parent_id = "female_parent_of_$current_node_id";
    my $male_parent_id = "male_parent_of_$current_node_id";
    my $female_parent_name;
    my $male_parent_name;
   
    if ($trav_ped->has_female_parent()){
	$joins{$female_parent_id} = $current_node_id;
	if ($trav_ped->get_female_parent()->has_name()){
	    $female_parent_name =  $trav_ped->get_female_parent()->get_name();
	    
	}
	else {
	    $female_parent_name = '';
	}
	if ($trav_ped->get_female_parent()->has_pedigree()) {
	    my (%returned_nodes,%returned_joins) = traverse_pedigree($trav_ped->get_female_parent()->get_pedigree(),$female_parent_id,$female_parent_name);
	    @nodes{keys %returned_nodes} = values %returned_nodes;
	    @joins{keys %returned_joins} = values %returned_joins;
	}
    }
    else {
	 $female_parent_name = '?';
    }

    if ($trav_ped->has_male_parent()){
	$joins{$male_parent_id} = $current_node_id;
	if ($trav_ped->get_male_parent()->has_name()){
	    $male_parent_name =  $trav_ped->get_male_parent()->get_name();
	    
	}
	else {
	    $male_parent_name = '';
	}
	if ($trav_ped->get_male_parent()->has_pedigree()) {
	    my (%returned_nodes,%returned_joins) = traverse_pedigree($trav_ped->get_male_parent()->get_pedigree(),$male_parent_id,$male_parent_name);
	    @nodes{keys %returned_nodes} = values %returned_nodes;
	    @joins{keys %returned_joins} = values %returned_joins;
	}
    }
    else {
	 $male_parent_name = '?';
    }

    
    
    $nodes{$female_parent_id} = $female_parent_name;
    $nodes{$male_parent_id} = $male_parent_name;

    return (\%nodes,\%joins);
}

sub draw_graphviz {
    my $self = shift;
    my $current_node_id = shift;
    my $current_node_name = shift;
    my %nodes;
    my %joins;
    my $graphviz_text;
    #write graphviz header - append lines to $graphviz_text
    my $female_parent_id = "female_parent_of_$current_node_id";
    my $male_parent_id = "male_parent_of_$current_node_id";
    my $female_parent_name;
    my $male_parent_name;

    $nodes{$current_node_id} = $current_node_name;
    
    if ($self->has_female_parent()) {
	$joins{$female_parent_id} = $current_node_id;    
        
	if ($self->get_female_parent()->has_name()){
	    $female_parent_name = $self->get_female_parent()->get_name();
	}
	else {
	    $female_parent_name = '';
	}
	$nodes{$female_parent_id} = $female_parent_name;
	if ($self->get_female_parent()->has_pedigree()){
	    my ($returned_nodes,$returned_joins) = traverse_pedigree($self->get_female_parent()->get_pedigree(),$female_parent_id,$female_parent_name);
	    @nodes{keys %$returned_nodes} = values %$returned_nodes;
	    @joins{keys %$returned_joins} = values %$returned_joins;
	}
    }


    if ($self->has_male_parent()) {
	$joins{$male_parent_id} = $current_node_id;    
        
	if ($self->get_male_parent()->has_name()){
	    $male_parent_name = $self->get_male_parent()->get_name();
	}
	else {
	    $male_parent_name = '';
	}
	$nodes{$male_parent_id} = $male_parent_name;
	if ($self->get_male_parent()->has_pedigree()){
	    my ($returned_nodes,$returned_joins) = traverse_pedigree($self->get_male_parent()->get_pedigree(),$male_parent_id,$male_parent_name);
	    @nodes{keys %$returned_nodes} = values %$returned_nodes;
	    @joins{keys %$returned_joins} = values %$returned_joins;
	}
    }


    
    #write nodes to graphviz
    foreach my $node_key (keys %nodes) {
	#print STDERR "Node: $node_key $nodes{$node_key} \n";
    }
     #write joins to graphviz
    foreach my $join_key (keys %joins){
	#print STDERR "Join: $join_key $joins{$join_key} \n";

   }

    #write graphviz footer if needed

   1;
}



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
