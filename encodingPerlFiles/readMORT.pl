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
my $mortRecord        = "";
my $residentStatus    = "";
my $education89       = "";
my $education03       = "";
my $monthDeath        = "";
my $sex               = "";
my $reportedAge       = "";
my $placeDeath        = "";
my $maritalStatus     = "";
my $DoWDeath          = "";
my $currentDataYear   = "";
my $injuryWork        = "";
my $mannerDeath       = "";
my $methodDisposition = "";
my $autopsy           = "";
my $ICD               = "";
my $race              = "";

while ( $mortRecord = <$mortFH> ) {
#
#  Chop off the end of line character(s)
#
   chomp ( $mortRecord );

#
#  Extract each field from the record as delimited by column position
#

   $residentStatus    = substr( $mortRecord, 19, 1 );
   $education89       = substr( $mortRecord, 60, 2 );
   $education03       = substr( $mortRecord, 62, 1 );
   $monthDeath        = substr( $mortRecord, 64, 2 );
   $sex               = substr( $mortRecord, 68, 1 );
   $reportedAge       = substr( $mortRecord, 69, 4 );
   $placeDeath        = substr( $mortRecord, 82, 1 );
   $maritalStatus     = substr( $mortRecord, 83, 1 );
   $DoWDeath          = substr( $mortRecord, 84, 1 );
   $currentDataYear   = substr( $mortRecord, 101, 4 );
   $injuryWork        = substr( $mortRecord, 105, 1 );
   $mannerDeath       = substr( $mortRecord, 106, 1 );
   $methodDisposition = substr( $mortRecord, 107, 1 );
   $autopsy           = substr( $mortRecord, 108, 1 );
   $ICD               = substr( $mortRecord, 145, 4 );
   $race              = substr( $mortRecord, 444, 2 );

   print "$currentDataYear,$monthDeath,$DoWDeath,$reportedAge,$sex,$race,$maritalStatus,$education89,$education03,$residentStatus,$placeDeath,$injuryWork,$mannerDeath,$methodDisposition,$autopsy,$ICD\n";

}

#
#  Close the file
#
close ($mortFH);

#
#  End of Script
#
