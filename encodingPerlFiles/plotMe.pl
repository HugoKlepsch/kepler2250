#!/usr/bin/perl
#
#   Packages and modules
#
use strict;
use warnings;
use version;         our $VERSION = qv('5.16.0');   # This is the version of Perl to be used
use Statistics::R;

my $infilename;
my $pdffilename;
my $yaxis;
my $label;

#
#   Check that you have the right number of parameters
#
if ($#ARGV != 3 ) {
   print "Usage: plotMe.pl <input file name> <pdf file name> <y-axis> <label>\n" or
      die "Print failure\n";
   exit;
} else {
   $infilename = $ARGV[0];
   $pdffilename = $ARGV[1];
   $yaxis = $ARGV[2];
   $label = $ARGV[3];
}  

print "input file = $infilename\n";
print "pdf file = $pdffilename\n";
print "y-axis = $yaxis\n";
print "label = $label\n";

# Create a communication bridge with R and start R
my $R = Statistics::R->new();

# Set up the PDF file for plots
$R->run(qq`pdf("$pdffilename" , paper="letter")`);

# Load the plotting library
$R->run(q`library(ggplot2)`);

# read in data from a CSV file
$R->run(qq`data <- read.csv("$infilename")`);

# plot the data as a line plot with each point outlined
$R->run(qq`ggplot(data, aes(x=Month, y=$yaxis, colour=Sex, group=Sex)) + geom_line() + geom_point(size=2) + ggtitle("$label") + ylab("Number") + theme(axis.text.x = element_text(angle = 90, hjust = 1)) `);
# close down the PDF device
$R->run(q`dev.off()`);

$R->stop();
