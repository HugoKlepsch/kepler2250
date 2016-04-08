#!/usr/bin/perl

#
#  plot.pl
#     Author: Hugo Klepsch
#     Date of Last Update: Sunday, April 06, 2016.
#
#     Parameters on the commandline:
#        $ARGV[0] = name of the input file, 
#        $ARGV[1] = the name of the output pdf file (or blank)
#



use strict;
use warnings;
use version;         our $VERSION = qv('5.16.0');   # This is the version of Perl to be used
use Text::CSV  1.32;   # We will be using the CSV module (version 1.32 or higher)
use Statistics::R;

my $infilename;
my $pdffilename;
my $t1; #meta-data tier 1
my $t2; #meta-data tier 2
my $yearString; #meta-data year range 
my $csv          = Text::CSV->new({ sep_char => ',' });

#
#   Check that you have the right number of parameters
#   Either two parameters: one infilename one outfilename,
#       or one parameter: one infilename (the out is assumed)
#
if ($#ARGV != 1 ) {
    if ($#ARGV == 0) {
        print "Only one filename given, assuming that wanted pdf file output is $ARGV[0].pdf\n";
        $infilename = $ARGV[0];
        $pdffilename = $infilename.".pdf"; #just append .pdf, assume that the user wants this
    } else {
        #totally wrong inputs
        print "Usage: plot.pl <input file name> <pdf file name>\n" or
        die "Print failure\n";
        exit;
    }
} else {
    $infilename = $ARGV[0];
    $pdffilename = $ARGV[1];
}  

print "input file = $infilename\n";
print "pdf file = $pdffilename\n";


##############################################################
#########MAGIC parsing RIGHT HERE#############################
##############################################################
#this copies the meta-data that is in the first line of the 
#input file, then writes a new file called
#$inputfile.temp, with all the same lines except for the first 
#line. This temp file is used later for R

#open the original
my @fileRecords;
open my $plot_fh, '<', $infilename or die "Unable to open file: $infilename\n";

@fileRecords = <$plot_fh>; #copy it into memory
close $plot_fh or die "Unable to close file: $infilename\n";

#parse search.pl metadata
if ($csv->parse($fileRecords[0])) {
    my @master_fields = $csv->fields();
    $t1 = $master_fields[0];
    $t2 = $master_fields[1];
    $yearString = $master_fields[2];
}

#open the new .temp file
open my $newplot_fh, '>', $infilename.".temp" or die "Unable to open file: $infilename\n";
#write every line except the first
for my $number (1 .. $#fileRecords){
    print $newplot_fh "$fileRecords[$number]";
}
close $newplot_fh or die "Unable to close file: $infilename\n";

##############################################################
#########End of magic parsing#################################
##############################################################

# Create a communication bridge with R and start R
my $R = Statistics::R->new();

# Set up the PDF file for plots
$R->run(qq`pdf("$pdffilename" , paper="letter")`);

# Load the plotting library
$R->run(q`library(ggplot2)`);

# read in data from the .temp CSV file
$R->run(qq`data <- read.csv("$infilename.temp")`);

##############################################################
##########START OF QUESTION-SPECIFIC PLOTTING#################
##############################################################

#now we use the meta-data we collected to format each plot especially for it's question
#I'm not going to explain what each of these plot lines do. 
#If you want to know how they work, use google
if ($t1 eq "Race" && $t2 eq "workDeath") {
    $R->run(qq`ggplot(data, aes(x=CATEGORY, y=VALUE, color=XLABEL)) + geom_bar(stat="identity", position="dodge") + ggtitle("Workplace deaths by race during $yearString")  + ylab("Deaths") + xlab("Race") + theme(axis.text.x=element_text(angle=50, size=10, vjust=1))`);
} elsif ($t1 eq "Race" && $t2 eq "eduLvl") {
    $R->run(qq`ggplot(data, aes(x=CATEGORY, y=VALUE, color=XLABEL)) + geom_bar(stat="identity", position="dodge") + ggtitle("Education level by race during $yearString")  + ylab("Number with x level") + xlab("Races") + theme(axis.text.x=element_text(angle=50, size=10, vjust=1))`);
} elsif ($t1 eq "Gender" && $t2 eq "workDeath") {
    $R->run(qq`ggplot(data, aes(x=CATEGORY, y=VALUE, color=XLABEL)) + geom_bar(stat="identity", position="dodge") + ggtitle("Workplace deaths by gender during $yearString")  + ylab("Deaths") + xlab("Gender") + theme(axis.text.x=element_text(angle=50, size=10, vjust=1))`);
} elsif ($t1 eq "Gender" && $t2 eq "eduLvl") {
    $R->run(qq`ggplot(data, aes(x=CATEGORY, y=VALUE, color=XLABEL)) + geom_bar(stat="identity", position="dodge") + ggtitle("Education level by gender during $yearString")  + ylab("Number with x level") + xlab("Genders") + theme(axis.text.x=element_text(angle=50, size=10, vjust=1))`);
} elsif($t1 eq "Funeral" && $t2 eq "deathMonth") {
    $R->run(qq`ggplot(data, aes(x=CATEGORY, y=VALUE, color=XLABEL)) + geom_bar(stat="identity", position="dodge") + ggtitle("Deaths per month during $yearString") +scale_x_continuous(breaks=c(01,02,03,04,05,06,07,08,09,10,11,12), labels=c("Jan","Feb","Mar","Apr","May","June","July","August","Sept","Oct","Nov","Dec")) + ylab("Deaths") + xlab("Month") + theme(axis.text.x=element_text(angle=50, size=10, vjust=1))`);
} elsif($t1 eq "School" && $t2 eq "birthMonth") {
    $R->run(qq`ggplot(data, aes(x=CATEGORY, y=VALUE, color=XLABEL)) + geom_bar(stat="identity", position="dodge") + ggtitle("Births per month during $yearString") +scale_x_continuous(breaks=c(01,02,03,04,05,06,07,08,09,10,11,12), labels=c("Jan","Feb","Mar","Apr","May","June","July","August","Sept","Oct","Nov","Dec")) + ylab("Births") + xlab("Month") + theme(axis.text.x=element_text(angle=50, size=10, vjust=1))`);
} elsif($t1 eq "BabyToy" && $t2 eq "genderMonth") {
    $R->run(qq`ggplot(data, aes(x=CATEGORY, y=VALUE, color=XLABEL)) + geom_bar(stat="identity", position="dodge") + ggtitle("Births per month by gender during $yearString") +scale_x_continuous(breaks=c(01,02,03,04,05,06,07,08,09,10,11,12), labels=c("Jan","Feb","Mar","Apr","May","June","July","August","Sept","Oct","Nov","Dec")) + ylab("Births") + xlab("Month") + theme(axis.text.x=element_text(angle=50, size=10, vjust=1))`);
} elsif($t1 eq "MentalHealth" && $t2 eq "maritalSuicide") {
    $R->run(qq`ggplot(data, aes(x=CATEGORY, y=VALUE, color=XLABEL)) + geom_bar(stat="identity", position="dodge") + ggtitle("Deaths for different marital statuses during $yearString") + ylab("Suicides") + xlab("Marital status") + theme(axis.text.x=element_text(angle=50, size=10, vjust=1))`);
} else {
    #if the meta-data that we scraped is not one of the questions it supports, do nothing
    exit;
}
##############################################################
###########END OF QUESTION-SPECIFIC PLOTTING##################
##############################################################

#finishes writing to pdf
$R->run(q`dev.off()`);

$R->stop();
