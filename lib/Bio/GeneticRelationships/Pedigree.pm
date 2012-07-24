package Bio::GeneticRelationships::Pedigree;
use strict;
use warnings;

use Moose;
use MooseX::FollowPBP;
use Moose::Util::TypeConstraints;
use Bio::GeneticRelationships::Individual;
use GraphViz2;
use File::Spec;
use Log::Handler;

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
    my $female_pedigree = '';
    my $male_pedigree = '';
    my $current_pedigree;
    my $female_pedigree_depth = 1;
    my $male_pedigree_depth = 1;
    my $deepest_depth;
    my $cross_indicator;
    my $is_selfed = 0;
    my $is_backcross = 1;
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

    if ($self->has_cross_type()){

	if ($self->get_cross_type() eq "self" ){
	    $is_selfed = 1;
	}
	if ($self->get_cross_type() eq "backcross"){
	    $is_backcross = 1;
	    $backcross_count = 1;
	}
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
	    if ($self->get_female_parent()->has_name()) {
		$female_pedigree = $self->get_female_parent()->get_name();
	    }
	    else {
		$female_pedigree = "?";
	    }
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

    #remove
    if (!defined($female_pedigree)) { $female_pedigree="undefined";}

    if ($is_selfed==1 ){
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
    elsif ($is_backcross==1) {
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
    my %joints;
    my %selfs;	
    my $female_parent_id = "female_parent_of_$current_node_id";
    my $male_parent_id = "male_parent_of_$current_node_id";
    my $female_parent_name;
    my $male_parent_name;
    my $joint_name;
   
    if ($trav_ped->has_female_parent()){
	$joins{$female_parent_id} = $current_node_id;
	if ($trav_ped->get_female_parent()->has_name()){
		$female_parent_name = $trav_ped->get_female_parent()->get_name();

	}
    	else {
		$female_parent_name = '';
	}
	if ($trav_ped->get_female_parent()->has_pedigree()) {
		my ($returned_nodes,$returned_joins,$returned_selfs) = traverse_pedigree($trav_ped->get_female_parent()->get_pedigree(),$female_parent_id,$female_parent_name);

		@nodes{keys %$returned_nodes} = values %$returned_nodes;
		@joins{keys %$returned_joins} = values %$returned_joins;
		@selfs{keys %$returned_selfs} = values %$returned_selfs;
	}

	$nodes{$female_parent_id} = $female_parent_name;

    }
    else {
	$female_parent_name = '?';
    }
 
    

    if ($trav_ped->has_male_parent()){
	$joins{$male_parent_id} = $current_node_id;
	if ($trav_ped->get_male_parent()->has_name()){
		$male_parent_name = $trav_ped->get_male_parent()->get_name();

	}
	else {
		$male_parent_name = '';
	}

	if ($female_parent_name ne $male_parent_name){
		if ($trav_ped->get_male_parent()->has_pedigree()) {
			my ($returned_nodes,$returned_joins,$returned_selfs) = traverse_pedigree($trav_ped->get_male_parent()->get_pedigree(),$male_parent_id,$male_parent_name);
			@nodes{keys %$returned_nodes} = values %$returned_nodes;
			@joins{keys %$returned_joins} = values %$returned_joins;
			@selfs{keys %$returned_selfs} = values %$returned_selfs;
			
		}
	}
	else {

		$selfs{$female_parent_name} = $current_node_name;	
	}


	$nodes{$male_parent_id} = $male_parent_name;

    }
    else {
	$male_parent_name = '?';
    }

#   if ($trav_ped->has_male_parent() && $trav_ped->has_female_parent()){
#	$joint_name = "joint_".$female_parent_name."_and_".$male_parent_name;
#	$joints{$joint_name} = $joint_name;
#    }

	

	
    #$nodes{$female_parent_id} = $female_parent_name;
    #$nodes{$male_parent_id} = $male_parent_name;


    return (\%nodes,\%joins,\%selfs);
}

sub draw_graphviz {
	my $self = shift;
	my $current_node_id = shift;
	my $current_node_name = shift;
	my %nodes;
	my %joins;
	my %joints;
	my %selfs;	
	my $graphviz_text;
	my $female_parent_id = "female_parent_of_$current_node_id";
	my $male_parent_id = "male_parent_of_$current_node_id";
	my $female_parent_name;
	my $male_parent_name;


	my($logger) = Log::Handler -> new;

	$logger -> add
		(
		 screen =>
		 {
			 maxlevel       => 'debug',
			 message_layout => '%m',
			 minlevel       => 'error',
		 }
		);

	my($graph) = GraphViz2 -> new
		(
		 edge   => {color => 'black'},
		 global => {directed => 0},
		 graph  => {rankdir => 'TB', bgcolor => '#FAFAFA', ranksep => 0.9, nodesep => 1.2},
		 logger => $logger,
		 node   => {color => 'red', fontsize => 11, fontname => 'Helvetica'},
		);


	# Graphviz header text	
	$graphviz_text .= "//Generated Graphviz dot file. May need to adjust nodesep or ranksep values for best look.\r\n";
	$graphviz_text .= "graph Pedigree {\r\n\r\n";

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
			my ($returned_nodes,$returned_joins,$returned_selfs) = traverse_pedigree($self->get_female_parent()->get_pedigree(),$female_parent_id,$female_parent_name);
			@nodes{keys %$returned_nodes} = values %$returned_nodes;
			@joins{keys %$returned_joins} = values %$returned_joins;
			@selfs{keys %$returned_selfs} = values %$returned_selfs;

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

		if ($female_parent_name ne $male_parent_name){
			if ($self->get_male_parent()->has_pedigree()) {
				my ($returned_nodes,$returned_joins,$returned_selfs) = traverse_pedigree($self->get_male_parent()->get_pedigree(),$male_parent_id,$male_parent_name);
				@nodes{keys %$returned_nodes} = values %$returned_nodes;
				@joins{keys %$returned_joins} = values %$returned_joins;
				@selfs{keys %$returned_selfs} = values %$returned_selfs;
		
			}
		}
		else {

			$selfs{$female_parent_name} = $current_node_name;	
		}

	}


	$graphviz_text .= "node [color = \"red\"]\r\nnode [fontsize=11, fontname=\"Helvetica\"]\r\ngraph [bgcolor=\"#FAFAFA\"]\r\nranksep= .9\r\nnodesep=1.2\r\n\r\n";
	$graphviz_text .= "//Node Declarations\r\n";

	#Quick way to stop making duplicate node declarations in the Graphviz file.
	my %hashcheck;

	#Makes node declarations in the Graphviz file.
	foreach my $node_key (keys %nodes) {

		unless ($hashcheck{$nodes{$node_key}}) {
			$hashcheck{$nodes{$node_key}} = $nodes{$node_key};	

			$graphviz_text .= $nodes{$node_key}." [href=\"#\" onmouseover=\"load_tooltip_text(\'\\N\')\" onmouseout=\"htm()\"]";
			if ($node_key lt "m"){
				$graph -> add_node(name => $nodes{$node_key},  href => '#',  onmouseover=>'load_tooltip_text(\'\N\')', onmouseout=>'htm()', shape=>'ellipse');
				$graphviz_text .= "[shape = \"ellipse\"]";
			}
			else {
				$graph -> add_node(name => $nodes{$node_key},  href => '#',  onmouseover=>'load_tooltip_text(\'\N\')', onmouseout=>'htm()', shape=>'box');
				$graphviz_text .= "[shape = \"box\"]";
			}

			$graphviz_text .= "\r\n";
			#print STDERR "Node: $node_key $nodes{$node_key} \n";
		}
	}

	$graphviz_text .= "//End Node Declarations\r\n\r\n";

	$graphviz_text .= "//Edge Relationships\r\n";


	# Hash that stores selfing edges already added in the loop
	my %self_joins;	

	foreach my $join_key (keys %joins){

		# Checks if an edge is a selfing-edge.
		if (($selfs{$nodes{$join_key}}) && ($selfs{$nodes{$join_key}} eq $nodes{$joins{$join_key}})){
			my $edge_combo = $nodes{$join_key}.$nodes{$joins{$join_key}};
			# Checks if a selfing edge was already added for two nodes. Selfing edges are denoted with a double line.
			unless ($self_joins{$edge_combo}){
				$graphviz_text .= $nodes{$join_key}." -- ".$nodes{$joins{$join_key}}." [color=\"black:black\"]\r\n";
				$graph ->add_edge(from => $nodes{$join_key}, to => $nodes{$joins{$join_key}}, color=>'black:black');
				$self_joins{$nodes{$join_key}.$nodes{$joins{$join_key}}} = 1;
			}
		}
		# Else it is just a normal edge with a child comprised of two different parents.
		else {
			$graphviz_text .= $nodes{$join_key}." -- ".$nodes{$joins{$join_key}}."\r\n";
			$graph ->add_edge(from => $nodes{$join_key}, to => $nodes{$joins{$join_key}});
	
		}
	}



	$graphviz_text .= "//End Edge Relationships\r\n";

	# Ending/Closing Graphviz text
	$graphviz_text .= "\r\n}";
	print STDERR $graphviz_text;


	my($format)      = shift || 'xdot';
	#my($suffix)      = $format eq 'png:gd' ? 'png' : $format;
	my($suffix) = 'gv';
	my($output_file) = shift || File::Spec -> catfile('.', "pedigree-out.$suffix");

	$graph -> run(format => $format, output_file => $output_file);

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
