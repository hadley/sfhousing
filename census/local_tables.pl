#!/usr/common/bin/perl -w
#
# Take a URL and parse it for HTML tables and print the output as
# pipe delimited ascii. Based on Simon Byers' original tables.pl.
#
# Remember to quote urls with special characters in them.

use strict;
use LWP 5.000;
use URI::URL;
use HTML::TableExtract;

sub main {
    my ($url, $browser, $webdoc);
    my ($table, $row, $column, $cells);
    my $table_extractor = new HTML::TableExtract();

## Use browser to retrieve the document
    $browser = LWP::UserAgent->new();
    $browser->timeout(2);
    
    foreach $url (@ARGV) {

## Get the document using browser
	$webdoc = $browser->request(HTTP::Request->new(GET => $url));
	next unless $webdoc->is_success;
	next unless $webdoc->content_type eq 'text/html';
	
	$table_extractor->parse($webdoc->content());
	
	foreach $table ($table_extractor->table_states ) {
	    
	    foreach $row ($table->rows) {
		
		$cells = join('|', @$row);
		    
## Clean up the cell's content before printing
		$cells =~ s/[^a-zA-Z0-9\.,\/\&\n:\\ \|\-()]//g;
		$cells =~ s/\n/ /g;
		$cells =~ s/  / /g;
		print $cells . "\n";
	    }
	}
    }
}

main ();





