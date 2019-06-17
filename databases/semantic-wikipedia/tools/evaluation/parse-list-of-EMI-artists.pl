#!/usr/bin/perl
use strict;
use warnings;

if ( $#ARGV != 2 ) {
	print
"Usage: perl parse-list-of-EMI-artists.pl <ExtracedListsXml> <Query> <OutputName>\n";
	exit 1;
}

print "Parsing List of EMI artists now ... ";

my $count = 0;

# open output with append
open OUTPUT, ">>", $ARGV[2], or die $!;

# get contents of the XML.
open XML, "$ARGV[0]";
my $xml = do { local $/; <XML> };

# Select the correct list part.
if ( $xml =~ /(.*)List of EMI artists(.*?)<\/page>/s ) {
	my $list = $2;

	# Select the part from ===Pre-1960=== to ==See also==.
	if ( $list =~ /(.*)===Pre-1960===(.*?)==See also==(.*)/s ) {
		my $current = $2;

# Always select the wikipedia link directly after a * (plus possible non-word chars)
		while ( $current =~ /\*(\W*?)\[\[(.*?)[\|\]]/gs ) {

			# Eliminate entries that dont have their own wikipedia article
			if ( $2 !~ /#/ ) {

				# Increase the counter
				$count++;

				# Replace spaces by underscores
				my $entity = $2;
				$entity =~ s/ /_/g;

				# Append to the output in the form query<TAB>entity<NEWLINE>
				print OUTPUT "$ARGV[1]\t$entity\n";
			}
		}
	}
	else {
		print "Unexpected format of the list! \n";
		print "Failed to find an area between ===Pre-1960=== and ==See also==!\n";
	}

}
else {
	print "Couldn't find the list in the Xml file!\n";
}

# Close handles and be verbose to avoid errors when using this parser that APPENDS to a output!
close XML;
close OUTPUT;
print "Done. Added $count testcases to $ARGV[2].\n";

