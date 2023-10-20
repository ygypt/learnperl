#!/bin/perl

use strict;
use warnings;
use 5.38.0;

my ($file) = @ARGV or die;

open(my $data, "<", $file) or die;

my @header = (
  "\"LatD\"",
  "\"LatM\"",
  "\"LatS\"",
  "\"NS\"",
  "\"LonD\"",
  "\"LonM\"",
  "\"LonS\"",
  "\"EW\"",
  "\"City\"",
  "\"State\""
);
my $header_size = @header;

# extract data into a 2d matrix. first dimension is table, second is tuple.
my @table = ();
my $line = 0;
while (my $text = <$data>) {
  $line++;

  # remove trailing newline
  chomp $text;

  # split text into tuple, comma as delimiter, NOT ESCAPE SAFE YET!!
  my @tuple = split(',', $text);

  # don't add a tuple if it doesnt have the right amount of tuple
  my $tuple_size = @tuple;
  unless ($tuple_size == $header_size) {
    say("line $line has $tuple_size tuple. expected $header_size. line $line excluded");
    next;
  }
  
  # trim left and right whitespace
  for (@tuple) {
    $_ = remove_whitespace($_);
  }

  # @table is an array of references to each @tuple array. dereference with @$_ in foreach
  push(@table, \@tuple);
}

# --- execute checks and manipulations ---
check_header();
@table = remove_tuple_unless_cell_contains_string(8, "\"Springcell\"");
@table = remove_tuple_if_cell_contains_string(9, "MA");
@table = remove_tuple_if_cell_less_than(4, 85);
@table = remove_tuple_from_table();
print_table();


# print table to term
sub print_table {
  say("------ table output:");
  foreach (@table) {
    foreach (@$_) {
      print("$_,");
    }
    #chomp
    print("\n");
  }
  say("------ table eof\n");
}

# make sure that the header is what it should be. dereference hell :(
sub check_header {
  say("------ checking header:");
  foreach my $tuple ($table[0]) {
    for (my $i = 0; $i < @header; $i++) {
      say("testing $tuple->[$i]");
      unless ($tuple->[$i] eq $header[$i]) {
        die "header cell $i: $tuple->[$i] does not match the expected $header[$i]";
      }
    } 
  }
  say("------ header checks out\n");
}

# ($cell_id, $str) remove table unless a cell contains the passed string
sub remove_tuple_unless_cell_contains_string {
  my ($cell_id, $str) = @_ or die "invalid arguments. expected: int, string";
  my @new_table = ();
  foreach my $tuple (@table) {
    unless ($tuple->[$cell_id] eq $str) { next; }
    push(@new_table, $tuple);
  }
  return @new_table
}

# ($cell_id, $str) remove table if a cell contains the passed string
sub remove_tuple_if_cell_contains_string {
  my ($cell_id, $str) = @_ or die "invalid arguments. expected: int, string";
  my @new_table = ();
  foreach my $tuple (@table) {
    if ($tuple->[$cell_id] eq $str) { next; }
    push(@new_table, $tuple);
  }
  return @new_table
}

# ($cell_id, $num) remove table if a cell is greater than passed number
sub remove_tuple_if_cell_greater_than {
  my ($cell_id, $num) = @_ or die "invalid arguments. expected: int, num";
  my @new_table = ();
  foreach my $tuple (@table) {
    if ($tuple->[$cell_id] > $num) { next; }
    push(@new_table, $tuple);
  }
  return @new_table
}

# ($cell_id, $num) remove table if a cell is less than passed number
sub remove_tuple_if_cell_less_than {
  my ($cell_id, $num) = @_ or die "invalid arguments. expected: int, num";
  my @new_table = ();
  foreach my $tuple (@table) {
    if ($tuple->[$cell_id] < $num) { next; }
    push(@new_table, $tuple);
  }
  return @new_table
}

sub remove_column_from_table {
  my ($col_id) = @_ or die "invalid arguments. expected: int";
  my @new_table = ();
  foreach my $tuple (@table) {
    my @new_tuple = ();
    my $tuple_len = @$tuple;
    for (my $i = 0, $i < @$tuple)
  }
}

# regex sorcery
sub remove_whitespace {
  my ($str) = @_;
  $str =~ s/^\s+|\s+$//g;
  return $str
}

