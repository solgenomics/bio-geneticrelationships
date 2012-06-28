package Bio::GeneticRelationships::Individual;
use strict;
use warnings;

use Moose;
use MooseX::FollowPBP;
use Moose::Util::TypeConstraints;
use Bio::GeneticRelationships::Pedigree;

=head1 NAME

    Indvidual - An individual organism with genetic relationships to other individuals

=head1 SYNOPSIS

    my $variable = Bio::GeneticRelationships::Individual->new();

=head1 DESCRIPTION

    This class stores information about an individual organism and its genetic relationships to other individuals.

=head2 Methods

=over 

=cut

has 'name' => (isa => 'Str',is => 'rw', predicate => 'has_name');
has 'pedigree' => (isa =>'Bio::GeneticRelationships::Pedigree', is => 'rw', predicate => 'has_pedigree');








# sub draw_pedigree_graphviz {
#     my $self = shift;
#     my $current_node_name;

#     if ($self->has_name()){
# 	$current_node_name = $self->get_name();
#     }
#     else {
# 	$current_node_name = shift;
#     }
    
#     #create graphviz header
#     my $graphviz_string;
#     my $current_node = $self->get_name(); 
#     my %nodes;
#     my %joins;


    




#     if ($self->has_pedigree()){
	
	
#     }


#     my $pedigree_str = '';
#     $pedigree_str = $pedigree_str."(";
#     if ($self->has_pedigree()){

# 	#create graphviz header
# 	my $graphviz_string;
# 	my $current_node = $self->get_name(); 
# 	my %nodes;
# 	my %joins;

# 	$

# 	if ($self->get_pedigree()->has_female_parent()){
# 	    my $female_node_name = "female_parent_of_".$current_node_name;
	    
# 	    if ($self->get_pedigree()->get_female_parent()->has_name()){

# 		#add node with name

# 		$nodes{$female_node_name} = $self->get_pedigree()->get_female_parent()->get_name();
# 	    }
# 	    else {
# 		#add node with blank name
# 		$nodes{$female_node_name}->'';
# 	    }
	    


# 	    if ($self->get_pedigree()->get_female_parent()->has_pedigree()){
		
# 		$pedigree_str = $pedigree_str.$self->get_pedigree()->get_female_parent()->get_pedigree_string();
# 	    }
# 	    else {
# 		$pedigree_str = $pedigree_str.$self->get_pedigree()->get_female_parent()->get_name();
# 	    }
# 	}
# 	else {
# 	    $pedigree_str = $pedigree_str."?";
# 	}


# 	$pedigree_str = $pedigree_str." X ";

# 	if ($self->get_pedigree->has_male_parent()){
# 	    if ($self->get_pedigree()->get_male_parent()->has_pedigree()){
# 		$pedigree_str = $pedigree_str.$self->get_pedigree()->get_male_parent()->get_pedigree_string();
# 	    }
# 	    else {
# 		$pedigree_str = $pedigree_str.$self->get_pedigree->get_male_parent()->get_name();
# 	    }
# 	}
# 	else {
# 	    $pedigree_str = $pedigree_str."?";
# 	}
# 	$pedigree_str = $pedigree_str.")";
#     }
#     else {
# 	return undef;
#     }

# }



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
