# Copyright (c) 1999-2001 Martin Hasch.  All rights reserved.
# This package is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl exact.t'

######################### We start with some black magic to print on failure.

BEGIN { $| = 1; print "1..47\n"; }
END {print "not ok 1\n" unless $loaded;}
use Date::Gregorian;
use Date::Gregorian::Exact;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

use strict;

sub test {
    my ($n, $bool) = @_;
    print $bool? (): 'not ', 'ok ', $n, "\n";
}

sub test_ymd {
    my ($n, $date, @ymd) = @_;
    my $date2 = ref($date) && $date->new->check_ymd(@ymd);
    test $n, $date2 && 0 == $date2->get_days_since($date);
}

sub test_ymdhms {
    my ($n, $date, @ymdhms) = @_;
    my $date2 = ref($date) && $date->new->check_ymdhms(@ymdhms);
    test $n, $date2 && 0 == $date2->get_seconds_since($date);
}


my $date = Date::Gregorian->new;
my $offset = $date->set_ymd(1970, 1, 1)->get_gmtime;
my ($y, $m, $d);

my $edate = Date::Gregorian::Exact->new;
test 2, 'Date::Gregorian::Exact' eq ref($edate);
test 3, $edate->isa('Date::Gregorian');

test 4, $edate->check_ymdhms(1999, 12, 31, 23, 59, 59);
test 5, ! $edate->check_ymdhms(1999, 12, 31, 23, 59, 60);
test 6, ! $edate->check_ymdhms(1999, 12, 31, -0.5, 59, 59);
test 7, ! $edate->check_ymdhms(1582, 10, 14, 0, 0, 0);

$edate->set_ymd(2001, 10, 16)->set_hms(9, 15, 43);
test_ymdhms 8, $edate, 2001, 10, 16, 9, 15, 43;

$edate->set_hms(9, 17, 11)->set_ymd(2001, 10, 16);
test_ymdhms 9, $edate, 2001, 10, 16, 9, 17, 11;

my $xdate = $edate->new;
test 10, 0 == $xdate->get_days_since($edate);
test 11, 0 == $xdate->get_seconds_since($edate);
test 12, $edate != $xdate;

$date->set_date($xdate);
test_ymd 13, $xdate, 2001, 10, 16;

$date->set_ymd(2001, 10, 14);
$edate->set_date($date);
test_ymdhms 14, $edate, 2001, 10, 14, 0, 0, 0;

$xdate->add_days(1.25);
test_ymdhms 15, $xdate, 2001, 10, 17, 15, 17, 11;

$edate->set_ymd(2001, 10, 15)->set_hms(22, 43, 29)->add_seconds(123456);
test_ymdhms 16, $edate, 2001, 10, 17, 9, 1, 5;

my @hms = $edate->get_hms;
test 17, 3 == @hms && 9 == $hms[0] && 1 == $hms[1] && 5 == $hms[2];

test 18, 291665 == $edate->get_seconds_since($date);
test 19, -22566 == $edate->get_seconds_since($xdate);

test 20, 3.3828125  == $edate->set_hms(9, 11, 15)->get_days_since($date);
test 21, -3         == $date->get_days_since($edate);
test 22, -0.2578125 == $edate->set_hms(9, 5, 56)->get_days_since($xdate);

$edate->set_ymd(1963, 10, 7)->set_hms(15, 50+20000000, 0);
test_ymdhms 23, $edate, 2001, 10, 16, 13, 10, 0;

$edate->set_easter(2001);
test_ymdhms 24, $edate, 2001, 4, 15, 13, 10, 0;

my $time = 1003224282 + $offset;
my @tvec = gmtime($time);
test 25,
    42  == $tvec[0] &&
    24  == $tvec[1] &&
    9   == $tvec[2] &&
    16  == $tvec[3] &&
    9   == $tvec[4] &&
    101 == $tvec[5] &&
    2   == $tvec[6] &&
    288 == $tvec[7];

$edate->set_gmtime($time);
test_ymdhms 26, $edate, 2001, 10, 16, 9, 24, 42;
test 27, $time == $edate->get_gmtime;
test 28, 1 == $edate->get_weekday;
($y, $d) = $edate->get_yd;
test 29, 2001 == $y && 289 == $d;

$xdate->set_ymd(1970, 1, 1)->set_hms(0, 0, $time);
test 30, 0 == $edate->get_seconds_since($xdate);

@tvec = localtime($time);
$xdate->set_localtime($time);
test 31, 1 >= abs($xdate->get_days_since($edate));
test 32, $time == $xdate->get_localtime;
($y, $m, $d) = $xdate->get_ymd;
test 33, 1900+$tvec[5] == $y && 1+$tvec[4] == $m && $tvec[3] == $d;
@hms = $xdate->get_hms;
test 34, $tvec[2] == $hms[0] && $tvec[1] == $hms[1] && $tvec[0] == $hms[2];
test 35, (6 + $tvec[6]) % 7 == $xdate->get_weekday;
($y, $d) = $xdate->get_yd;
test 36, 1900+$tvec[5] == $y && 1+$tvec[7] == $d;


$edate = Date::Gregorian::Exact->new;
test 37, $edate->set_ymd(2000, 2, 29)->is_gregorian;
test 38, $edate->set_ymd(1582, 10, 15)->is_gregorian;
test 39, ! $edate->set_ymd(1582, 10, 4)->is_gregorian;
test 40, ! $edate->set_ymd(-4712, 1, 1)->is_gregorian;

$edate = Date::Gregorian::Exact->new->set_ymd(2002, 5, 2);
$edate->set_hms(13, 30, 15.6875);
test 41, 13 == $edate->get_hour;
test 42, 30 == $edate->get_minute;
test 43, 15.6875 == $edate->get_second;

$edate->round_seconds;
test_ymdhms(44, $edate, 2002, 5, 2, 13, 30, 16);

$edate->round_minutes;
test_ymdhms(45, $edate, 2002, 5, 2, 13, 30, 0);

$edate->round_hours;
test_ymdhms(46, $edate, 2002, 5, 2, 14, 0, 0);

$edate->round_days;
test_ymdhms(47, $edate, 2002, 5, 3, 0, 0, 0);

__END__
