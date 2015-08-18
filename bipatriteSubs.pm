use strict;
use warnings;
use List::Util qw(min max);


#Subroutine to extract the ppi's from the data file and store them in a hash
#input: Filename
#output: Hash reference containing the ppi's

sub getPPI
{
	my ($fileName) = @_;

	unless (open( FH, $fileName))
	{
		print "Couldn't open the file!! :$fileName\nPlease try again with the correct file path or name\n";
		exit;
	}

	my @array = <FH>;

	#Initialize hash to store content
	my %hash;

	foreach (@array) 
	{
		my($p1, $p2) = split("\t", $_);
		$hash{join("\t", sort ($p1, $p2)) }++;
	}

	return \%hash;
}

#Subroutine to make sure that none of the elements of each clique are the same
#input: Two cliques stored as scalar values with each node seperated by a tab
#output: Boolean Value: 0 or 1

sub distinct
{
	my ($clique1, $clique2) = @_;

	my %hash = ();

	for(my $i = 0; $i < scalar @$clique1; $i++)
	{
		$hash{$$clique1[$i]}++;
		$hash{$$clique2[$i]}++;
	}

	foreach my $x (keys %hash) 
	{
		if( $hash{$x} > 1)
		{
			return 0;
		}
	}

	return 1;
}

#Subroutine to check that there is a bipartite connection between 2 cliques
#input: 2 cliques stored as arrays, and a reference to a hash
#output: 0 for False, 1 for True

sub bipatrite
{
	my ($clique1, $clique2, $hashRef) = @_;

	my %hash;

	for (my $i = 0; $i < scalar @$clique2; $i++) 
	{
		$hash{$$clique2[$i]} = 0;
		$hash{$$clique1[$i]} = 0;
	}

	for (my $i = 0; $i < scalar @$clique1; $i++) 
	{
		for(my $j = 0; $j < scalar @$clique2;$j++ )
		{
			my $c = join("\t", sort($$clique1[$i], $$clique2[$j]));
			if(exists $$hashRef{$c})
			{
				$hash{$$clique2[$j]}++;
				$hash{$$clique1[$i]}++;
			}
		}
	}

	if(min(values %hash) >= 1)
	{
		return 1;
	}

	
	return 0;
}

###############This code is specifically written to find the cliques################

#Subroutine to check that all of the elements are distinct
#input: all the proteins
#output: 0 for false, or 1 for true
sub notSame
{
	my ($p1, $p2, $p3, $p4) = @_;
	if(($p1 ne $p3) && ($p1 ne $p4) && ($p2 ne $p4) && ($p2 ne $p3))
	{
		return 1;
	}
	return 0;
}

#Check if Connection exists between the p1, p2, p3 and p4.
#input: 4 proteins, hash reference, array reference
#If connection exists, return 1, else return 0
sub conExists
{
	my ($p1, $p2, $p3, $p4, $hashRef, $arrayHash) = @_;
	my $p1p3 = join("\t", sort($p1, $p3));
	my $p1p4 = join("\t", sort($p1, $p4));
	my $p2p4 = join("\t", sort($p2, $p4));
	my $p2p3 = join("\t", sort($p2, $p3));

	if((exists $$hashRef{$p1p3})
		&& (exists $$hashRef{$p1p4})
		&& (exists $$hashRef{$p2p4})
		&& (exists $$hashRef{$p2p3}))
	{
		return 1;
	}
	return 0;
}

#Check to make sure that none of the cliques have already been found.
#if there is a duplicate, it returns 0, else returns 1.
sub noDuplicates
{
	my ($A, $B, $C, $D, $hash) = @_;

	my @array = ($A, $B, $C, $D);
	@array = sort @array;
	if(exists $$hash{join("\t", @array)})
	{
		return 0;
	}
	return 1;
}

#Subroutine to find cliques of size 4 from a give ppi data
sub findCliques
{
	my ($fileName) = @_;

	unless (open(FH, $fileName)) 
	{
		print "[!]File: ".$fileName." was not found or could not be opened";
		exit;
	}
	my @arr = <FH>;
	my %hash = ();
	my @split;
	my $join;
	for(my $i = 0; $i < scalar @arr; $i = $i + 1)
	{
		@split = split('\t', $arr[$i]);
		@split = sort ($split[0], $split[1]);
		$join = $split[0]."\t".$split[1];
		$arr[$i] = $join;
		$hash{$join} = $i;
	}

	close FH;

	my $outputFile = "Cliques.txt";
	my $count = 0;
	my %cliques = ();
	my %nodes = ();

	unless (open(FHW, ">$outputFile")) 
	{
		print "Couldn't open the output file\nAborting mission\n";
		exit;
	}

	for(my $i = 0; $i < scalar @arr; $i++)
	{
		my ($p1, $p2) = split('\t', $arr[$i]);
		for(my $j = $i + 1; $j < scalar @arr; $j++ )
		{
			my ($p3, $p4) = split('\t', $arr[$j]);
			$nodes{$p1}++;
			$nodes{$p2}++;
			$nodes{$p3}++;
			$nodes{$p4}++;
			if(notSame($p1, $p2, $p3, $p4))
			{
				if(conExists($p1, $p2, $p3, $p4, \%hash))
				{
					if(noDuplicates($p1, $p2, $p3, $p4, \%cliques))
					{
						$count += 1;
						my @cli = ($p1, $p2, $p3, $p4);
						@cli = sort @cli;

						my $hold = join("\t", @cli);
						$cliques{$hold}++;
						print FHW "$hold\n";

					}
				}
			}
		}
	}

	print "The total number of Cliques is: ", $count, "\n";
	my $noOfNodes = scalar keys %nodes;
	return (\%cliques, $noOfNodes, scalar @arr);
}


1;