#!/usr/bin/perl
use strict;

if ($#ARGV+1 != 1) {
  printf(STDERR "Usage: mean.pl <column>\n");
  exit 1;
}

my $sep_pattern = ",";
my $sep = ",";

my $meancolumn = $ARGV[0];

my $colcount;
my %sums = ();
my %cnt = ();
while( my $line = <STDIN> ){
  chomp($line);
  if ($line !~ /^\s*#/) {
    my @fields = split(/$sep_pattern/,$line);
    if (scalar(@fields) < $meancolumn) { next;}

    if (! defined($colcount)) {
      $colcount = scalar(@fields);
    } else {
      if (scalar(@fields) != $colcount) {
        printf(STDERR "Warning: skipping line with wrong column count: $line\n");
        next;
      }
    }

    my $others = join($sep, @fields[0..$meancolumn-1], @fields[($meancolumn+1)..(scalar(@fields)-1)]);

print "others: $others\n";

    $sums{$others} += @fields[$meancolumn];
    $cnt{$others}++;
  } else {
    print "$line\n"; # to preserve the header
  }
}

foreach my $others (keys %sums) {
  my @fields = split(/$sep_pattern/,$others);
  print join($sep,@fields[0..$meancolumn-1], $sums{$others}/$cnt{$others}, @fields[($meancolumn) .. (scalar(@fields)-1)])."\n";
}

close MYDATA;

