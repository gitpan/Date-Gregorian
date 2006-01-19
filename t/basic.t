# Copyright (c) 1999-2001 Martin Hasch.  All rights reserved.
# This package is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl basic.t'

######################### We start with some black magic to print on failure.

BEGIN { $| = 1; print "1..127\n"; }
END {print "not ok 1\n" unless $loaded;}
use Date::Gregorian;
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

sub test_ymdg {
    my ($n, $date, $y, $m, $d, $g) = @_;
    my $date2 = ref($date) && $date->new;
    my @ymd = $date2? $date2->get_ymd: ();
    test $n,
	$date2 &&
	$y == $ymd[0] &&
	$m == $ymd[1] &&
	$d == $ymd[2] &&
	!$g == !$date->is_gregorian;
}


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
test_ymd 20, $bate, 1701, 4, 20;
test 21, 35 == $bate->get_days_since($date);

my $ref = $date->new->set_ymd(1600, 3, 1);
test 22, 36915 == $date->get_days_since($ref);

$date = Date::Gregorian->new;
$date2 = $date->check_ymd(1500, 2, 29);
test 23, $date2;
test 24, $date2 == $date;

test 25, ! $date->check_ymd(1700, 2, 29);
test 26, $date2 == $date;
test_ymd 27, $date, 1500, 2, 29;

test 28, $date->check_ymd(1582, 10, 4);
test 29, ! $date->check_ymd(1582, 10, 5);
test 30, ! $date->check_ymd(1582, 10, 14);
test 31, $date->check_ymd(1582, 10, 15);
test 32, $date->check_ymd(1600, 2, 29);
test 33, ! $date->check_ymd(1600, 2, 30);

test 34, $bate->check_ymd(1500, 2, 29);
test 35, $bate->check_ymd(1700, 2, 29);
test 36, $bate->check_ymd(1582, 10, 4);
test 37, $bate->check_ymd(1582, 10, 5);
test 38, $bate->check_ymd(1582, 10, 14);
test 39, $bate->check_ymd(1582, 10, 15);
test 40, $bate->check_ymd(1600, 2, 29);
test 41, ! $bate->check_ymd(1600, 2, 30);

test 42, $bate->check_ymd(1752, 9, 2);
test 43, ! $bate->check_ymd(1752, 9, 3);
test 44, ! $bate->check_ymd(1752, 9, 13);
test 45, $bate->check_ymd(1752, 9, 14);
test 46, $bate->check_ymd(1800, 2, 28);
test 47, ! $bate->check_ymd(1800, 2, 29);
test 48, ! $bate->check_ymd(1999, 2, 29);
test 49, $bate->check_ymd(1999, 3, 1);
test 50, $bate->check_ymd(2000, 2, 29);
test 51, ! $bate->check_ymd(2000, 2, 30);

$date2 = $date->set_ymd(1581, 12, 31);
test 52, $date2 == $date;
test_ymd 53, $date, 1581, 12, 31;

my ($y, $m, $d) = $date->get_ymd;
test 54, 1581 == $y && 12 == $m && 31 == $d;

$date2 = $date->new->set_ymd(1582, 12, 31);
test 55, 355 == $date2->get_days_since($date);

($y, $m, $d) = $date2->get_ymd;
test 56, 1582 == $y && 12 == $m && 31 == $d;

$date2->set_ymd(1582, 10, 15);
test 57, 278 == $date2->get_days_since($date);

$date2->set_ymd(1582, 10, 4);
test 58, 277 == $date2->get_days_since($date);

$date->add_days(277);
($y, $m, $d) = $date->get_ymd;
test 59, 1582 == $y && 10 == $m && 4 == $d;

$date2 = $date->add_days(1);
test 60, $date2 == $date;
test_ymd 61, $date, 1582, 10, 15;

$date->add_days(-1);
test_ymd 62, $date, 1582, 10, 4;

test 63, 3 == $date->set_ymd(1999, 11, 18)->get_weekday;

($y, $d) = $date->get_yd;
test 64, 1999 == $y && 322 == $d;

my $w;
($y, $w, $d) = $date->get_ywd;
test 65, 1999 == $y && 46 == $w && 3 == $d;

($y, $w, $d) = $date->set_ymd(1999, 1, 1)->get_ywd;
test 66, 1998 == $y && 53 == $w && 4 == $d;

($y, $w, $d) = $date->set_ymd(1999, 1, 3)->get_ywd;
test 67, 1998 == $y && 53 == $w && 6 == $d;

($y, $w, $d) = $date->set_ymd(1999, 1, 4)->get_ywd;
test 68, 1999 == $y && 1 == $w && 0 == $d;

($y, $m, $d) = $date->set_yd(1999, 322)->get_ymd;
test 69, 1999 == $y && 11 == $m && 18 == $d;

($y, $m, $d) = $date->new->set_ywd(1999, 46, 3)->get_ymd;
test 70, 1999 == $y && 11 == $m && 18 == $d;

my $offset = $date->set_ymd(1970, 1, 1)->get_gmtime();
test 71, defined($offset);

$date2 = $date->new->set_gmtime(942950958 + $offset);
test_ymd 72, $date2, 1999, 11, 18;

my $t = $date->set_ymd(1999, 11, 18)->get_gmtime;
test 73, 942883200 + $offset == $t;

$date2 = $date->new->configure(9999, 12, 31)->set_ymd(1600, 1, 1);
test 74, 'Date::Gregorian' eq ref($date2->set_date($date));
test_ymd 75, $date2, 1999, 11, 5;
test 76, 0 == $date2->get_days_since($date);

test 77, $date->check_ymd(-1469870, 3, 1);

$date = Date::Gregorian->new->set_easter(1701);
$date2 = $date->new->set_easter(5701701);
test_ymd 78, $date2, 5701701, 3, 27;
test 79, 2081882250 == $date2->get_days_since($date);

$date->set_easter(532);
test_ymd 80, $date, 532, 4, 11;
$date2 = $date->new->set_easter(0);
test_ymd 81, $date2, 0, 4, 11;
test 82, 194313 == $date->get_days_since($date2);

$date = $date2->new->set_easter(-53200);
test_ymd 83, $date, -53200, 4, 11;
test 84, -19431300 == $date->get_days_since($date2);

$date->set_ymd(-53200, 4, 11);
test_ymd 85, $date, -53200, 4, 11;
test 86, -19431300 == $date->get_days_since($date2);

test_ymd 87, $date->set_ymd(-4712, 1, 1)->add_days(2451545), 2000, 1, 1;

$date->set_ymd(1999, 11, 15)->set_weekday(0);
test_ymd(88, $date, 1999, 11, 15);

$date->set_ymd(1999, 11, 15)->set_weekday(0, '>=');
test_ymd(89, $date, 1999, 11, 15);

$date->set_ymd(1999, 11, 15)->set_weekday(0, '>');
test_ymd(90, $date, 1999, 11, 22);

$date->set_ymd(1999, 11, 15)->set_weekday(0, '<');
test_ymd(91, $date, 1999, 11, 8);

$date->set_ymd(1999, 11, 15)->set_weekday(0, '<=');
test_ymd(92, $date, 1999, 11, 15);

$date->set_ymd(1999, 11, 16)->set_weekday(6);
test_ymd(93, $date, 1999, 11, 21);

$date->set_ymd(1999, 11, 16)->set_weekday(6, '>=');
test_ymd(94, $date, 1999, 11, 21);

$date->set_ymd(1999, 11, 16)->set_weekday(6, '>');
test_ymd(95, $date, 1999, 11, 21);

$date->set_ymd(1999, 11, 16)->set_weekday(6, '<');
test_ymd(96, $date, 1999, 11, 14);

$date->set_ymd(1999, 11, 16)->set_weekday(6, '<=');
test_ymd(97, $date, 1999, 11, 14);

$date->set_ymd(1999, 11, 14)->set_weekday(1, '>=');
test_ymd(98, $date, 1999, 11, 16);

$date->set_ymd(1999, 11, 14)->set_weekday(1, '>');
test_ymd(99, $date, 1999, 11, 16);

$date->set_ymd(1999, 11, 21)->set_weekday(1, '<');
test_ymd(100, $date, 1999, 11, 16);

$date->set_ymd(1999, 11, 21)->set_weekday(1, '<=');
test_ymd(101, $date, 1999, 11, 16);


$date = Date::Gregorian->new;
test 102, $date->set_ymd(2000, 2, 29)->is_gregorian;
test 103, $date->set_ymd(1582, 10, 15)->is_gregorian;
test 104, ! $date->set_ymd(1582, 10, 4)->is_gregorian;
test 105, ! $date->set_ymd(-4712, 1, 1)->is_gregorian;
$date->set_ymd(1582, 10, 15)->configure(10000, 1, 1);
test 106, ! $date->is_gregorian;


my $time1 = time;
$date = Date::Gregorian->new->set_today;
my $time2 = time;
$date2 = $date->new->set_ymd(1999, 12, 31);
my $delta1 = $date2->set_localtime($time1)->get_days_since($date);
my $delta2 = $date2->set_localtime($time2)->get_days_since($date);
test 107, $date->isa('Date::Gregorian');
test 108, 0 == $delta1 || 0 == $delta2;

$date->set_ymd(12002, 6, 5);
$time2 = $date->get_gmtime;
test 109, !defined($time2) || 316592755200 == $time2 - $offset;

test 110, 366 == $date->get_days_in_year(2000);
test 111, 365 == $date->get_days_in_year(1999);
test 112, 365 == $date->get_days_in_year(1998);
test 113, 365 == $date->get_days_in_year(1997);
test 114, 366 == $date->get_days_in_year(1996);
test 115, 365 == $date->get_days_in_year(1900);
test 116, 365 == $date->get_days_in_year(1800);
test 117, 365 == $date->get_days_in_year(1700);
test 118, 366 == $date->get_days_in_year(1600);
test 119, 355 == $date->get_days_in_year(1582);
test 120, 366 == $date->get_days_in_year(1500);

$date->configure(2100, 1, 5);
test 121, 356 == $date->get_days_in_year(2099);
test 122, 361 == $date->get_days_in_year(2100);

$date->set_yd(2100, 1);
test_ymd(123, $date, 2100, 1, 5);

# A reformation date before March 1, 100, creates ambiguities.
# Here we check whether these are handled gracefully.
$date->configure(-5000, 1, 1);
test 124, 405 == $date->get_days_in_year(-5000);
my $result = $date->check_ymd(-5001, 12, 31);
test 125, $result;
$date->set_ymd(-5001, 12, 31)->add_days(40);
test_ymdg(126, $date, -5000, 2, 9, 0);
$date->add_days(1);
test_ymdg(127, $date, -5000, 1, 1, 1);

__END__
