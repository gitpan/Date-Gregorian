# Copyright (c) 1999-2001 Martin Hasch.  All rights reserved.
# This package is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

BEGIN { $| = 1; print "1..144\n"; }
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

my @days = qw(Mon Tue Wed Thu Fri Sat Sun);
my @months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);


my $date = Date::Gregorian->new;
test 2, 'Date::Gregorian' eq ref($date);

my $date2 = $date->new;
test 3, 'Date::Gregorian' eq ref($date2);
test 4, $date2 != $date;

$date = $date2->set_easter(1701);
test 5, 'Date::Gregorian' eq ref($date2);
test 6, $date2 == $date;
test_ymd 7, $date, 1701, 3, 27;

my $kate = $date->new->configure(1752, 9, 14);
test_ymd 8, $kate, 1701, 3, 16;
test 9, 0 == $kate->get_days_since($date);

my $bate = $date->new->configure(1752, 9, 14, 1753);
test_ymd 10, $bate, 1701, 3, 16;
test 11, 0 == $bate->get_days_since($date);

my $bate2 = $bate->new;
test 12, 'Date::Gregorian' eq ref($bate2);
test 13, $bate2 != $bate;

$date2 = $bate2->configure(1582, 10, 14);
test_ymd 14, $date2, 1701, 3, 27;
test 15, 0 == $date2->get_days_since($date);

$date2 = $bate2->configure(1582, 10, 14, 1583);
test_ymd 16, $date2, 1701, 3, 27;
test 17, 0 == $date2->get_days_since($date);

$kate->set_easter(1701);
test_ymd 18, $kate, 1701, 3, 16;
test 19, 0 == $date->get_days_since($kate);

$bate->set_easter(1701);
test_ymd 19, $bate, 1701, 4, 20;
test 20, 35 == $bate->get_days_since($date);

my $ref = $date->new->set_ymd(1600, 3, 1);
test 21, 36915 == $date->get_days_since($ref);

$date = Date::Gregorian->new;
$date2 = $date->check_ymd(1500, 2, 29);
test 22, $date2;
test 23, $date2 == $date;

test 24, ! $date->check_ymd(1700, 2, 29);
test 25, $date2 == $date;
test_ymd 26, $date, 1500, 2, 29;

test 27, $date->check_ymd(1582, 10, 4);
test 28, ! $date->check_ymd(1582, 10, 5);
test 29, ! $date->check_ymd(1582, 10, 14);
test 30, $date->check_ymd(1582, 10, 15);
test 31, $date->check_ymd(1600, 2, 29);
test 32, ! $date->check_ymd(1600, 2, 30);

test 33, $bate->check_ymd(1500, 2, 29);
test 34, $bate->check_ymd(1700, 2, 29);
test 35, $bate->check_ymd(1582, 10, 4);
test 36, $bate->check_ymd(1582, 10, 5);
test 37, $bate->check_ymd(1582, 10, 14);
test 38, $bate->check_ymd(1582, 10, 15);
test 39, $bate->check_ymd(1600, 2, 29);
test 40, ! $bate->check_ymd(1600, 2, 30);

test 41, $bate->check_ymd(1752, 9, 2);
test 42, ! $bate->check_ymd(1752, 9, 3);
test 43, ! $bate->check_ymd(1752, 9, 13);
test 44, $bate->check_ymd(1752, 9, 14);
test 45, $bate->check_ymd(1800, 2, 28);
test 46, ! $bate->check_ymd(1800, 2, 29);
test 47, ! $bate->check_ymd(1999, 2, 29);
test 48, $bate->check_ymd(1999, 3, 1);
test 49, $bate->check_ymd(2000, 2, 29);
test 50, ! $bate->check_ymd(2000, 2, 30);

$date2 = $date->set_ymd(1581, 12, 31);
test 51, $date2 == $date;
test_ymd 52, $date, 1581, 12, 31;

my ($y, $m, $d) = $date->get_ymd;
test 53, 1581 == $y && 12 == $m && 31 == $d;

$date2 = $date->new->set_ymd(1582, 12, 31);
test 54, 355 == $date2->get_days_since($date);

($y, $m, $d) = $date2->get_ymd;
test 55, 1582 == $y && 12 == $m && 31 == $d;

$date2->set_ymd(1582, 10, 15);
test 56, 278 == $date2->get_days_since($date);

$date2->set_ymd(1582, 10, 4);
test 57, 277 == $date2->get_days_since($date);

$date->add_days(277);
($y, $m, $d) = $date->get_ymd;
test 58, 1582 == $y && 10 == $m && 4 == $d;

$date2 = $date->add_days(1);
test 59, $date2 == $date;
test_ymd 60, $date, 1582, 10, 15;

$date->add_days(-1);
test_ymd 61, $date, 1582, 10, 4;

test 62, 3 == $date->set_ymd(1999, 11, 18)->get_weekday;

($y, $d) = $date->get_yd;
test 63, 1999 == $y && 322 == $d;

my $w;
($y, $w, $d) = $date->get_ywd;
test 64, 1999 == $y && 46 == $w && 3 == $d;

($y, $w, $d) = $date->set_ymd(1999, 1, 1)->get_ywd;
test 65, 1998 == $y && 53 == $w && 4 == $d;

($y, $w, $d) = $date->set_ymd(1999, 1, 3)->get_ywd;
test 66, 1998 == $y && 53 == $w && 6 == $d;

($y, $w, $d) = $date->set_ymd(1999, 1, 4)->get_ywd;
test 67, 1999 == $y && 1 == $w && 0 == $d;

($y, $m, $d) = $date->set_yd(1999, 322)->get_ymd;
test 68, 1999 == $y && 11 == $m && 18 == $d;

($y, $m, $d) = $date->new->set_ywd(1999, 46, 3)->get_ymd;
test 69, 1999 == $y && 11 == $m && 18 == $d;

$date2 = $date->new->set_gmtime(942950958);
test 70, 'Date::Gregorian' eq ref($date2);
test_ymd 71, $date2, 1999, 11, 18;

my $t = $date->set_ymd(1999, 11, 18)->get_gmtime;
test 72, 942883200 == $t;

$date2 = $date->new->configure(9999, 12, 31)->set_ymd(1600, 1, 1);
test 73, 'Date::Gregorian' eq ref($date2->set_date($date));
test_ymd 74, $date2, 1999, 11, 5;
test 75, 0 == $date2->get_days_since($date);

test 76, $date->check_ymd(-1469870, 3, 1);

$date = Date::Gregorian->new->set_easter(1701);
$date2 = $date->new->set_easter(5701701);
test_ymd 77, $date2, 5701701, 3, 27;
test 78, 2081882250 == $date2->get_days_since($date);

$date->set_easter(532);
test_ymd 79, $date, 532, 4, 11;
$date2 = $date->new->set_easter(0);
test_ymd 80, $date2, 0, 4, 11;
test 81, 194313 == $date->get_days_since($date2);

$date = $date2->new->set_easter(-53200);
test_ymd 82, $date, -53200, 4, 11;
test 83, -19431300 == $date->get_days_since($date2);

$date->set_ymd(-53200, 4, 11);
test_ymd 84, $date, -53200, 4, 11;
test 85, -19431300 == $date->get_days_since($date2);

test_ymd 86, $date->set_ymd(-4712, 1, 1)->add_days(2451545), 2000, 1, 1;

$date->set_ymd(1999, 11, 15)->set_weekday(0);
test_ymd(87, $date, 1999, 11, 15);

$date->set_ymd(1999, 11, 15)->set_weekday(0, '>=');
test_ymd(88, $date, 1999, 11, 15);

$date->set_ymd(1999, 11, 15)->set_weekday(0, '>');
test_ymd(89, $date, 1999, 11, 22);

$date->set_ymd(1999, 11, 15)->set_weekday(0, '<');
test_ymd(90, $date, 1999, 11, 8);

$date->set_ymd(1999, 11, 15)->set_weekday(0, '<=');
test_ymd(91, $date, 1999, 11, 15);

$date->set_ymd(1999, 11, 16)->set_weekday(6);
test_ymd(92, $date, 1999, 11, 21);

$date->set_ymd(1999, 11, 16)->set_weekday(6, '>=');
test_ymd(93, $date, 1999, 11, 21);

$date->set_ymd(1999, 11, 16)->set_weekday(6, '>');
test_ymd(94, $date, 1999, 11, 21);

$date->set_ymd(1999, 11, 16)->set_weekday(6, '<');
test_ymd(95, $date, 1999, 11, 14);

$date->set_ymd(1999, 11, 16)->set_weekday(6, '<=');
test_ymd(96, $date, 1999, 11, 14);

$date->set_ymd(1999, 11, 14)->set_weekday(1, '>=');
test_ymd(97, $date, 1999, 11, 16);

$date->set_ymd(1999, 11, 14)->set_weekday(1, '>');
test_ymd(98, $date, 1999, 11, 16);

$date->set_ymd(1999, 11, 21)->set_weekday(1, '<');
test_ymd(99, $date, 1999, 11, 16);

$date->set_ymd(1999, 11, 21)->set_weekday(1, '<=');
test_ymd(100, $date, 1999, 11, 16);

my $edate = Date::Gregorian::Exact->new;
test 101, 'Date::Gregorian::Exact' eq ref($edate);
test 102, $edate->isa('Date::Gregorian');

test 103, $edate->check_ymdhms(1999, 12, 31, 23, 59, 59);
test 104, ! $edate->check_ymdhms(1999, 12, 31, 23, 59, 60);
test 105, ! $edate->check_ymdhms(1999, 12, 31, -0.5, 59, 59);
test 106, ! $edate->check_ymdhms(1582, 10, 14, 0, 0, 0);

$edate->set_ymd(2001, 10, 16)->set_hms(9, 15, 43);
test_ymdhms 107, $edate, 2001, 10, 16, 9, 15, 43;

$edate->set_hms(9, 17, 11)->set_ymd(2001, 10, 16);
test_ymdhms 108, $edate, 2001, 10, 16, 9, 17, 11;

my $xdate = $edate->new;
test 109, 0 == $xdate->get_days_since($edate);
test 110, 0 == $xdate->get_seconds_since($edate);
test 111, $edate != $xdate;

$date->set_date($xdate);
test_ymd 112, $xdate, 2001, 10, 16;

$date->set_ymd(2001, 10, 14);
$edate->set_date($date);
test_ymdhms 113, $edate, 2001, 10, 14, 0, 0, 0;

$xdate->add_days(1.25);
test_ymdhms 114, $xdate, 2001, 10, 17, 15, 17, 11;

$edate->set_ymd(2001, 10, 15)->set_hms(22, 43, 29)->add_seconds(123456);
test_ymdhms 115, $edate, 2001, 10, 17, 9, 1, 5;

my @hms = $edate->get_hms;
test 116, 3 == @hms && 9 == $hms[0] && 1 == $hms[1] && 5 == $hms[2];

test 117, 291665 == $edate->get_seconds_since($date);
test 118, -22566 == $edate->get_seconds_since($xdate);

test 119, 3.3828125  == $edate->set_hms(9, 11, 15)->get_days_since($date);
test 120, -3         == $date->get_days_since($edate);
test 121, -0.2578125 == $edate->set_hms(9, 5, 56)->get_days_since($xdate);

$edate->set_ymd(1963, 10, 7)->set_hms(15, 50+20000000, 0);
test_ymdhms 122, $edate, 2001, 10, 16, 13, 10, 0;

$edate->set_easter(2001);
test_ymdhms 123, $edate, 2001, 4, 15, 13, 10, 0;

my $time = 1003224282;
my @tvec = gmtime($time);
test 124,
    42  == $tvec[0] &&
    24  == $tvec[1] &&
    9   == $tvec[2] &&
    16  == $tvec[3] &&
    9   == $tvec[4] &&
    101 == $tvec[5] &&
    2   == $tvec[6] &&
    288 == $tvec[7];

$edate->set_gmtime($time);
test_ymdhms 125, $edate, 2001, 10, 16, 9, 24, 42;
test 126, $time == $edate->get_gmtime;
test 127, 1 == $edate->get_weekday;
($y, $d) = $edate->get_yd;
test 128, 2001 == $y && 289 == $d;

$xdate->set_ymd(1970, 1, 1)->set_hms(0, 0, $time);
test 129, 0 == $edate->get_seconds_since($xdate);

@tvec = localtime($time);
$xdate->set_localtime($time);
test 130, 1 >= abs($xdate->get_days_since($edate));
test 131, $time == $xdate->get_localtime;
($y, $m, $d) = $xdate->get_ymd;
test 132, 1900+$tvec[5] == $y && 1+$tvec[4] == $m && $tvec[3] == $d;
@hms = $xdate->get_hms;
test 133, $tvec[2] == $hms[0] && $tvec[1] == $hms[1] && $tvec[0] == $hms[2];
test 134, (6 + $tvec[6]) % 7 == $xdate->get_weekday;
($y, $d) = $xdate->get_yd;
test 135, 1900+$tvec[5] == $y && 1+$tvec[7] == $d;

$date = Date::Gregorian->new;
test 136, $date->set_ymd(2000, 2, 29)->is_gregorian;
test 137, $date->set_ymd(1582, 10, 15)->is_gregorian;
test 138, ! $date->set_ymd(1582, 10, 4)->is_gregorian;
test 139, ! $date->set_ymd(-4712, 1, 1)->is_gregorian;
$date->set_ymd(1582, 10, 15)->configure(10000, 1, 1);
test 140, ! $date->is_gregorian;
$edate = Date::Gregorian::Exact->new;
test 141, $edate->set_ymd(2000, 2, 29)->is_gregorian;
test 142, $edate->set_ymd(1582, 10, 15)->is_gregorian;
test 143, ! $edate->set_ymd(1582, 10, 4)->is_gregorian;
test 144, ! $edate->set_ymd(-4712, 1, 1)->is_gregorian;

__END__
