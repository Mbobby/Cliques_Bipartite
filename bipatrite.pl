#!/usr/bin/perl
use strict;
use warnings;
use bipatriteSubs;

my $file = "Breast_Cancer800.txt";

my $start = time();
my ($cliquesRef, $noOfNodes, $noOfInteractions) = findCliques($file);
my $end = time();

print "Time take to find cliques is: ", $end - $start, "\n";
print "Number of nodes is: ", $noOfNodes, "\n";
print "Number of Interactions is: ", $noOfInteractions, "\n";

$start = time();
my @cliques = keys %$cliquesRef;

my $ppis = getPPI($file);

my $cliqueLength = scalar @cliques;
my $count = 0;

unless (open(FHO, ">Bipatrites.txt"))
{	
	print "Could not open file Bipatrites.txt \n";
	exit;
}

#Loop on the Cliques and check if they are bipatrite
for (my $i = 0; $i < $cliqueLength - 1; $i++) 
{
	my $a = $cliques[$i];
	my @clique1 = split("\t", $a);
	for (my $j = $i + 1; $j < $cliqueLength; $j++) 
	{
		my $b = $cliques[$j];
		my @clique2 = split("\t", $b);
		
		if (distinct(\@clique1, \@clique2))
		{
			if(bipatrite(\@clique1, \@clique2, $ppis))
			{
				print FHO "$a\t$b\n";
				$count++;
			}
		}
	}
}
$end = time();

print "$count\n";
print "Time taken to find all Bipartite cliques is: ", $end - $start, "\n";
exit;