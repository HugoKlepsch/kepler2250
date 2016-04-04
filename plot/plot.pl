#!/usr/bin/perl
#
#   Packages and modules
#
use strict;
use warnings;
use version;         our $VERSION = qv('5.16.0');   # This is the version of Perl to be used
use Text::CSV  1.32;   # We will be using the CSV module (version 1.32 or higher)
use Statistics::R;

my $infilename;
my $pdffilename;
my $t1;
my $t2;
my $yearString;
my $csv          = Text::CSV->new({ sep_char => ',' });

#
#   Check that you have the right number of parameters
#
if ($#ARGV != 1 ) {
   print "Usage: plot.pl <input file name> <pdf file name>\n" or
      die "Print failure\n";
   exit;
} else {
   $infilename = $ARGV[0];
   $pdffilename = $ARGV[1];
}  

print "input file = $infilename\n";
print "pdf file = $pdffilename\n";


##############################################################
#########MAGIC SHIT RIGHT HERE################################
##############################################################

my @fileRecords;
open my $plot_fh, '<', $infilename or die "Unable to open file: $infilename\n";

@fileRecords = <$plot_fh>;
close $plot_fh or die "Unable to close file: $infilename\n";

#parse search.pl metadata
if ($csv->parse($fileRecords[0])) {
    my @master_fields = $csv->fields();
    $t1 = $master_fields[0];
    $t2 = $master_fields[1];
    $yearString = $master_fields[2];
}


open my $newplot_fh, '>', $infilename.".temp" or die "Unable to open file: $infilename\n";
for my $number (1 .. $#fileRecords){
    print $newplot_fh "$fileRecords[$number]";
}
close $newplot_fh or die "Unable to close file: $infilename\n";

##############################################################
#########End of magic shit####################################
##############################################################

# Create a communication bridge with R and start R
my $R = Statistics::R->new();

# Name the PDF output file for the plot  
#my $Rplots_file = "./Rplots_file.pdf";

# Set up the PDF file for plots
$R->run(qq`pdf("$pdffilename" , paper="letter")`);

# Load the plotting library
$R->run(q`library(ggplot2)`);

# read in data from a CSV file
$R->run(qq`data <- read.csv("$infilename.temp")`);

# plot the data as a line plot with each point outlined
#$R->run(q`ggplot(data, aes(x=CATEGORY, y=VALUE, colour=XLABEL, group=XLABEL)) + geom_line() + geom_point(size=2) + ggtitle("Popularity of Names") + ylab("Ranking")`);
#$R->run(q`ggplot(data, aes(x=CATEGORY, y=VALUE, colour=XLABEL, group=XLABEL)) + geom_bar(stat="identity", position="dodge") + ggtitle("Popularity of Names") + ylab("Ranking")`);
$R->run(q`ggplot(data, aes(x=CATEGORY, y=VALUE)) + geom_bar(stat="identity", position="dodge") + ggtitle("Popularity of Names") + ylab("Ranking") + theme(axis.text.x=element_text(angle=50, size=10, vjust=0.5))`);
#$R->run(qq`ggplot(data, aes(x=CATEGORY, y=XLABEL)) + geom_bar(aes(fill=VALUE),stat="identity", binwidth=3) + ggtitle("asdf title") + ylab("Goal Differential") + xlab("Games") + scale_fill_manual(values=c("red", "blue")) + theme(axis.text.x=element_text(angle=50, size=10, vjust=0.5)) `); 
# close down the PDF device
$R->run(q`dev.off()`);

$R->stop();
