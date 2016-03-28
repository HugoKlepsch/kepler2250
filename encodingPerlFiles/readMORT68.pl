#!/usr/bin/perl
use strict;
use warnings;

#
#  readMORT.pl
#     Author: Deborah Stacey
#     Date of Last Update: Sunday, February 21, 2016.
#
#     Summary
#
#     Parameters on the commandline:
#        $ARGV[0] = name of the input file, i.e. the unprocessed MORT file
#
#     References
#        Should work for files after 2002.
#

#
#  Check that you have the right number of parameters
#
if ($#ARGV != 0 ) {
   print "Usage: readMORT.pl <file name>\n";
   exit;
}

#
#  Open the input file - assign a file handle
#
open my $mortFH, '<', $ARGV[0]
   or die "Unable to open the file: $ARGV[0]";

#
#  Read in each record (one per line) until the end of the file
#
my $race              = "";
my $mortRecord;

while ( $mortRecord = <$mortFH> ) {
#
#  Chop off the end of line character(s)
#
   chomp ( $mortRecord );

#
#  Extract each field from the record as delimited by column position
#

   $race              = substr( $mortRecord, 58, 4 );

   if ($race >= 950){
       print "yes!!!!!\n"
   }

   print $race."\n";

}

#
#  Close the file
#
close ($mortFH);

#
#  End of Script
#
