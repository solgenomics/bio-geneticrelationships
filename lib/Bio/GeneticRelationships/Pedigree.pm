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
has 'selection_name' => (isa => 'Str',is => 'rw', predicate => 'has_selection_name');


sub get_pedigree_string_purdy {
    my $self = shift;
    my ($depth,$purdy,$bcount) = $self->get_pedigree_string_purdy_with_depth();
    return $purdy;
}

sub get_pedigree_string_purdy_with_depth {
    my $self = shift;
    my $previous = shift;
    my $female_pedigree;
    my $male_pedigree;
    my $current_pedigree;
    my $female_pedigree_depth = 1;
    my $male_pedigree_depth = 1;
    my $deepest_depth;
    my $cross_indicator;
    my $is_selfed;
    my $is_backcross;
    my $backcross_count = 0;
    my $previous_was_selfed = 0;
    my $previous_was_backcrossed = 0;
    my $recurrent_parent;
    my $recurrent_parent_isa;

    if (defined($previous)){
	if ($previous->get_cross_type() eq 'self') {
    	   $previous_was_selfed  = 1;
	}
	if ($previous->get_cross_type() eq 'backcross') {
	    $previous_was_backcrossed = 1;
	    if ($self->get_cross_type() eq 'backcross') {
		if ($self->get_female_parent()->get_name() eq $previous->get_female_parent->get_name()){
		    $recurrent_parent = $self->get_female_parent->get_name();
		    $recurrent_parent_isa = 'female';
		}
		elsif ($self->get_male_parent()->get_name() eq $previous->get_male_parent->get_name()){
		    $recurrent_parent = $self->get_male_parent->get_name();
		    $recurrent_parent_isa = 'male';
		}
		else {
		    #
		}
	    }
	}
    }



    if ($self->get_cross_type() eq "self" ){
	$is_selfed = 1;
    }
    if ($self->get_cross_type() eq "backcross"){
	$is_backcross = 1;
	$backcross_count = 1;
    }


    if ($self->has_female_parent()){
	if ($self->get_female_parent()->has_pedigree()){
	    my ($depth, $returned_pedigree, $b_count) = $self->get_female_parent()->get_pedigree()->get_pedigree_string_purdy_with_depth($self);
	    $female_pedigree = $returned_pedigree;
	    $female_pedigree_depth += $depth;
	    $backcross_count += $b_count; 
	    if ($self->get_female_parent()->has_name()) {
		$female_pedigree = $female_pedigree.'('.$self->get_female_parent()->get_name().')';
	    }
	}
	else {
	    $female_pedigree = $self->get_female_parent()->get_name();
	}
    }
    else {
	$female_pedigree = "?";
    }


    if ($self->has_male_parent()){
	if ($self->get_male_parent()->has_pedigree()){
	    my ($depth, $returned_pedigree) = $self->get_male_parent()->get_pedigree()->get_pedigree_string_purdy_with_depth($self);
	    $male_pedigree = $returned_pedigree;
	    $male_pedigree_depth += $depth;
	    if ($self->get_male_parent()->has_name()) {
		$male_pedigree = $male_pedigree.'('.$self->get_male_parent()->get_name().')';
	    }
	}
	else {
	    $male_pedigree = $self->get_male_parent()->get_name();
	}
    }
    else {
	$male_pedigree = "?";
    }
    

    if ($female_pedigree_depth > $male_pedigree_depth) {
	$deepest_depth = $female_pedigree_depth;
    }
    else {
	$deepest_depth = $male_pedigree_depth;
    }
    if ($deepest_depth == 1) {
	$cross_indicator = '/';
    }
    elsif ($deepest_depth == 2) {
	$cross_indicator = '//';
    }
    else {
	$cross_indicator = '/'.$deepest_depth.'/';
    }


    if ($self->get_cross_type() eq "self" ){
	my $selection_name;
	
	if ($self->has_selection_name()){
	    $selection_name = $self->get_selection_name();
	}
	else {
	    $selection_name = '?';
	}
	if ($previous_was_selfed == 1){
	    $current_pedigree = $female_pedigree.'-'.$selection_name;
	}
	else {
	    $current_pedigree = '['.$female_pedigree.']-'.$selection_name;
	}
	$deepest_depth -= 1;
    }
    elsif ($self->get_cross_type() eq "backcross") {
	#deal with backcrosses
    }
    else {
	$current_pedigree = $female_pedigree.$cross_indicator.$male_pedigree;
    }

    return ($deepest_depth,$current_pedigree,$backcross_count);
}


sub get_pedigree_string {
    my $self = shift;
    my $pedigree_str = '';
    $pedigree_str = $pedigree_str."(";
    if ($self->has_female_parent()){
	if ($self->get_female_parent()->has_pedigree()){
	    $pedigree_str = $pedigree_str.$self->get_female_parent()->get_pedigree()->get_pedigree_string();
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
	    $pedigree_str = $pedigree_str.$self->get_male_parent()->get_pedigree()->get_pedigree_string();
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
