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

# extract data into a 2d matrix. first dimension is records, second is fields.
my @records = ();
my $line = 0;
while (my $text = <$data>) {
  $line++;

  # remove trailing newline
  chomp $text;

  # split text into fields, comma as delimiter, NOT ESCAPE SAFE YET!!
  my @fields = split(',', $text);

  # don't add a record if it doesnt have the right amount of fields
  my $fields_size = @fields;
  unless ($fields_size == $header_size) {
    say("line $line has $fields_size fields. expected $header_size. line $line excluded");
    next;
  }
  
  # trim left and right whitespace
  for (@fields) {
    $_ = remove_whitespace($_);
  }

  # @records is an array of references to each @fields array. dereference with @$_ in foreach
  push(@records, \@fields);
}

# --- execute checks and manipulations ---
check_header();
@records = remove_record_unless_field_contains_string(8, "\"Springfield\"");
@records = remove_record_if_field_contains_string(9, "MA");
@records = remove_record_if_field_less_than(4, 85);
print_records();


# print records to term
sub print_records {
  say("------ table output:");
  foreach (@records) {
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
  foreach my $fields ($records[0]) {
    for (my $i = 0; $i < @header; $i++) {
      say("testing $fields->[$i]");
      unless ($fields->[$i] eq $header[$i]) {
        die "header field $i: $fields->[$i] does not match the expected $header[$i]";
      }
    } 
  }
  say("------ header checks out\n");
}

# ($field_id, $str) remove records unless a field contains the passed string
sub remove_record_unless_field_contains_string {
  my ($field_id, $str) = @_ or die "invalid arguments. expected: int, string";
  my @new_records = ();
  foreach my $fields (@records) {
    unless ($fields->[$field_id] eq $str) { next; }
    push(@new_records, $fields);
  }
  return @new_records
}

# ($field_id, $str) remove records if a field contains the passed string
sub remove_record_if_field_contains_string {
  my ($field_id, $str) = @_ or die "invalid arguments. expected: int, string";
  my @new_records = ();
  foreach my $fields (@records) {
    if ($fields->[$field_id] eq $str) { next; }
    push(@new_records, $fields);
  }
  return @new_records
}

# ($field_id, $num) remove records if a field is greater than passed number
sub remove_record_if_field_greater_than {
  my ($field_id, $num) = @_ or die "invalid arguments. expected: int, num";
  my @new_records = ();
  foreach my $fields (@records) {
    if ($fields->[$field_id] > $num) { next; }
    push(@new_records, $fields);
  }
  return @new_records
}

# ($field_id, $num) remove records if a field is less than passed number
sub remove_record_if_field_less_than {
  my ($field_id, $num) = @_ or die "invalid arguments. expected: int, num";
  my @new_records = ();
  foreach my $fields (@records) {
    if ($fields->[$field_id] < $num) { next; }
    push(@new_records, $fields);
  }
  return @new_records
}

# regex sorcery
sub remove_whitespace {
  my ($str) = @_;
  $str =~ s/^\s+|\s+$//g;
  return $str
}

