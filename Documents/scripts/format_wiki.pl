#!/usr/bin/perl
#
# Small program that parses the text sent by \062.
#

use warnings;
use strict;

use Data::Dumper;

my @column_lengths;
my $regexp	= "";
my $min_row_len = 0;

#
# Subroutine that recursively calculates column length
# in characters on the first row.
#

sub get_column_length {
    my $current_row = shift;
    my $array_len   = scalar @column_lengths;

    if ( $current_row ) {
	$current_row =~ /^(\S+\s*)\S*/;    
	push @column_lengths, length $1;
	$min_row_len += $column_lengths[ $array_len ];
	get_column_length( substr( $current_row, 
				   $column_lengths[ $array_len ] ) );
    }
}

#
# Main loop that iterates over STDIN.
#

while ( <> ) {

    #
    # Enters only on first iteration since 
    # @column_lengths is empty.
    #

    unless ( scalar @column_lengths > 0 ) {

	#
	# Get column lengths and store in @column_lengths.
	#

	get_column_length( $_ );

	#
	# Remove last element since it's the only column
	# with a variable length. We will fix this later.
	#

	pop @column_lengths;

	#
	# Parse regexp to extract text parts for
	# every column but last.
	#

	$regexp .= "(.{$_})" for @column_lengths;

	#
	# Add last expression to capture last column.
	#

	$regexp .= "(.*)\$";
    }

    my $current_row = $_;

    #
    # Get length of current row
    #

    my $row_len = length $current_row;

    #
    # Add characters to row if row length is too small.
    # This ensures that the regular expression will work.
    #

    $current_row .= "-" x ( $min_row_len - $row_len );

    my @matches = ( $current_row =~ /$regexp/ );   
    print length $current_row . "\n";
    print $current_row;
    print Dumper( \@matches );
    #print $_ for @matches;
    print "\n";
    
}
