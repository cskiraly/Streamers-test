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

    my $prefix = join($sep,@fields[0..$meancolumn-1]);
    my $postfix = join($sep,@fields[($meancolumn+1) .. (scalar(@fields)-1)]);

    print "$prefix$sep$sep$postfix\n";

  } else {
    print "$line\n"; # to preserve the header
  }
}

