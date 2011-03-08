#! /usr/bin/perl

use strict;


my %data;

# load scientific names for each tax ID

open NAMES, "<taxonomy/names.dmp" or die "Couldn't open names.dmp";

while ( my $line = <NAMES> )
{
	my ($id, $name, $uniqueName, $class) = split /\t\|\t/, $line;
	
	if ( $class =~ /scientific name/ )
	{
		if ( ! defined $data{$id} )
		{
			$data{$id} = ();
		}
		
		$data{$id}->{'name'} = $name;
	}
}

close NAMES;

# load parents and ranks for each tax ID

open NODES, "<taxonomy/nodes.dmp" or die "Couldn't open nodes.dmp";

while ( my $line = <NODES> )
{
	$line =~ /(\d+)\t\|\t(\d+)\t\|\t([^\t]+)/;
	
	my $id = $1;
	
	if ( ! defined $data{$id} )
	{
		$data{$id} = ();
	}
	
	$data{$id}->{'parent'} = $2;
	$data{$id}->{'rank'} = $3;
}

close NODES;

open OUT, ">taxonomy/taxonomy.tab" or die "Couldn't write to taxonomy.tab";

foreach my $id ( sort {$a <=> $b} keys %data )
{
	print OUT join "\t",
	(
		$id,
		depth($id),
		$data{$id}->{'parent'},
		$data{$id}->{'rank'},
		$data{$id}->{'name'}
	);
	print OUT "\n";
}

close OUT;


sub depth
{
	my ($id) = @_;
	
	if ( $id == 1 )
	{
		return 0;
	}
	else
	{
		return depth($data{$id}->{'parent'}) + 1;
	}
}
