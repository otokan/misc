#! /usr/bin/perl

# author: bartlomiej@gmail.com
# Scripts pipes lines from stdin that doesn't mach given <regex> through given <command>

# example: pipe_parts.pl '^#' 'perl -lne "print uc;" ' < pipe_parts.pl
# above command will uppercase all lines that are not comments

use strict;
use warnings;
use IPC::Open2;

die "usage: $0 <regex> <command>" if @ARGV < 2;
my $separator = qr/$ARGV[0]/;
shift;
my @f_cmd = @ARGV;
@ARGV=();

my ($f_in, $f_out);
my $pid;

while (<>) {
    if ( $_ =~ $separator ) {
        if ($pid) {
            local $_;
            close $f_in;
            print while (<$f_out>);
            close $f_out;
            $pid = undef;
        }
        print $_;
    } else {
        $pid = open2($f_out, $f_in, @f_cmd) or die "$!" unless $pid;
        print {$f_in} $_;
    }
}
if ($pid) {
    close $f_in;
    print while (<$f_out>);
}

# eof
