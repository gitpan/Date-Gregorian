# Copyright (c) 1999-2001 Martin Hasch.  All rights reserved.
# This package is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.
#
# $Id: Gregorian.pm,v 1.3 2002/04/19 20:01:37 martin Stab $

package Date::Gregorian;

use strict;
use integer;
use vars qw($VERSION);

# ----- object definition -----

# Date::Gregorian=ARRAY(...)

# .......... index ..........	# .......... value ..........
use constant F_DAYNO   => 0;	# contiguos day number, "March ...th, 1 BC"
use constant F_TR_DATE => 1;	# first Gregorian date in dayno format
use constant F_TR_EYR  => 2;	# first Gregorian easter year
use constant F_YMD     => 3;	# [year, month, day] (on demand, memoized)
use constant F_YDYW    => 4;	# [yearday, year, week] (on demand, memoized)
use constant FIELDS    => 5;

# ----- predefined variables -----

$VERSION = 0.05;

my @m2d      = map +($_ * 153 + 2) / 5, (0..11);
my $epoch    = _ymd2dayno( 1970, 1, 1, 0);
my @defaults = (
    $epoch,				# F_DAYNO
    _ymd2dayno(1582, 10, 15, 0),	# F_TR_DATE
    1583,				# F_TR_EYR
    undef,				# F_YMD
    undef,				# F_YDYW
);

# ----- private functions -----

# ($div, $mod) = _divmod($numerator, $denominator)
#
sub _divmod {
    no integer;
    my $mod = $_[0] % $_[1];
    return (($_[0] - $mod) / $_[1], $mod);
}

# $dayno = _ymd2dayno($year, $month, $day, $tr_date)
#
sub _ymd2dayno {
    my ($y, $m, $d, $s) = @_;

    if    (15 <= $m) { $m -= 3;      $y += $m / 12; $m %= 12;          }
    elsif ( 3 <= $m) { $m -= 3;                                        }
    elsif (-9 <= $m) { $m += 9;      $y --;                            }
    else             { $m = 14 - $m; $y -= $m / 12; $m = 11 - $m % 12; }

    $d += $m2d[$m] + $y * 365 + ($y >> 2) - 1;
    if ($s <= $d) {
	$y = 0 <= $y? $y / 100: -((99 - $y) / 100);
	$d -= $y - ($y >> 2) - 2;
    }
    return $d;
}

# ($year, $month, $day) = _dayno2dmy($dayno, $tr_date)
#
sub _dayno2ymd {
    my ($n, $s) = @_;
    my ($d, $m, $y);
    my $c;
    if ($s <= $n) {
	($c, $n) = _divmod($n - 2, 146097);
	$c *= 400;
	$n += (($n << 2) + 3) / 146097;
    }
    else {
	($c, $n) = _divmod($n, 1461);
	$c <<= 2;
    }
    $y = (($n << 2) + 3) / 1461;
    $n = ($n - $y * 365 - ($y >> 2)) * 5 + 2;
    $m = $n / 153 + 3;
    $d = $n % 153 / 5 + 1;
    $y ++, $m -= 12 if 12 < $m;
    return ($c + $y, $m, $d);
}

# ($dayno, $ymd) = _easter($year, $tr_date, $tr_eyr)
#
sub _easter {
    my ($y, $s, $e) = @_;
    my $m = 3;
    my $d;
    my $n = $y * 365 + ($y >> 2);
    if ($e <= $y) {
	my $g = 0 <= $y? $y / 100: -((99 - $y) / 100);
	$n -= $g - ($g >> 2) - 2;
	{ no integer; $g %= 3000 };
	my $h = 15 + $g - (($g << 3) + 13) / 25 - ($g >> 2);
	$g = do { no integer; $y % 19 };
	$d = ($g * 19 + $h) % 30;
	--$d if 28 <= $d && (28 < $d || 11 <= $g);
    }
    else {
	$d = do { no integer; ($y % 19 * 19 + 15) % 30 };
    }
    $d += do { no integer; 28 - ($n + $d) % 7 };
    $n += $d - 1;
    $d -= 31, $m ++ if 31 < $d;
    return ($n, ($s <= $n xor $e <= $y)? undef: [$y, $m, $d]);
}

# $dayno = _dec31dayno($year, $tr_date)
#
sub _dec31dayno {
    my ($y, $s) = @_;

    my $n = 306 + $y * 365 + ($y >> 2) - 1;
    if ($s <= $n) {
	$y = 0 <= $y? $y / 100: -((99 - $y) / 100);
	$n -= $y - ($y >> 2) - 2;
    }
    return $n;
}

# $ydyw = _ydyw($dayno, $tr_date, $year)
#
sub _ydyw {
    my ($n, $s, $y) = @_;
    my $base = _dec31dayno($y-1, $s);
    my $yd = $n - $base;
    $base += 4;
    { no integer; $base -= $base % 7 };
    if ($n < $base) {
	$y --;
	$base = _dec31dayno($y-1, $s) + 4;
	{ no integer; $base -= $base % 7 };
    }
    my $yw = ($n - $base) / 7 + 1;
    return [$yd, $y, $yw];
}

# ----- public methods -----

sub new {
    my $class = $_[0];
    my Date::Gregorian $self;
    if (ref $class) {			# called as obj method: clone it
	$self = bless [@{$class}], ref($class);
    }
    else {				# called as class method: create
	$self = bless [@defaults], $class;
    }
    return $self;
}

sub configure {
    my Date::Gregorian $self = shift;
    my ($y, $m, $d, $e) = @_;
    @{$self}[F_TR_DATE, F_YMD, F_YDYW] =
	( _ymd2dayno($y, $m, $d, 0), undef, undef );
    $self->[F_TR_EYR] = $e if defined $e;
    return $self;
}

sub is_gregorian {
    my Date::Gregorian $self = $_[0];
    return $self->[F_TR_DATE] <= $self->[F_DAYNO];
}

sub set_date {
    my Date::Gregorian ($self, $ref) = @_;
    @{$self}[F_DAYNO, F_YMD, F_YDYW] = ( $ref->[F_DAYNO], undef, undef );
    return $self;
}

sub set_ymd {
    my Date::Gregorian $self = shift;
    my ($y, $m, $d) = @_;
    @{$self}[F_DAYNO, F_YMD, F_YDYW] =
	( _ymd2dayno($y, $m, $d, $self->[F_TR_DATE]), undef, undef );
    return $self;
}

sub check_ymd {
    my Date::Gregorian $self = shift;
    my ($y, $m, $d) = @_;
    my ($dayno, $yy, $mm, $dd);
    if (defined($d) && 1 <= $d && $d <= 31 &&
	defined($m) && 1 <= $m && $m <= 12 &&
	defined($y) && -1469871 <= $y && $y <= 5879489
    ) {
	$dayno = _ymd2dayno($y, $m, $d, $self->[F_TR_DATE]);
	($yy, $mm, $dd) = _dayno2ymd($dayno, $self->[F_TR_DATE]);
	if ($dd == $d && $mm == $m && $yy == $y) {
	    @{$self}[F_DAYNO, F_YMD, F_YDYW] =
		( $dayno, [$yy, $mm, $dd], undef );
	    return $self;
	}
    }
    return undef;
}

sub get_ymd {
    my Date::Gregorian $self = $_[0];
    my $ymd = $self->[F_YMD] ||=
	[ _dayno2ymd($self->[F_DAYNO], $self->[F_TR_DATE]) ];
    return @{$ymd};
}

sub get_weekday {
    no integer;
    my Date::Gregorian $self = $_[0];
    return $self->[F_DAYNO] % 7;
}

sub set_yd {
    my Date::Gregorian $self = shift;
    my ($y, $d) = @_;
    return $self->set_ymd($y, 1, $d);
}

sub set_ywd {
    no integer;
    my Date::Gregorian $self = shift;
    my ($y, $w, $d) = @_;
    my $n = _dec31dayno($y-1) - 3;
    $n += $w * 7 + $d - $n % 7;
    @{$self}[F_DAYNO, F_YMD, F_YDYW] = ($n, undef, undef);
    return $self;
}

sub get_yd {
    my Date::Gregorian $self = $_[0];
    my ($y, $m, $d) = $self->get_ymd;
    return ($y, $d) if 1 == $m;
    my $ydyw = $self->[F_YDYW] ||= _ydyw(@{$self}[F_DAYNO, F_TR_DATE], $y);
    return ($y, $ydyw->[0]);
}

sub get_ywd {
    no integer;
    my Date::Gregorian $self = $_[0];
    my $y = ($self->get_ymd)[0];
    my $ydyw = $self->[F_YDYW] ||= _ydyw(@{$self}[F_DAYNO, F_TR_DATE], $y);
    return (@{$ydyw}[1, 2], $self->[F_DAYNO] % 7);
}

sub add_days {
    my Date::Gregorian $self = $_[0];
    $self->[F_DAYNO] += $_[1];
    @{$self}[F_YMD, F_YDYW] = (undef, undef);
    return $self;
}

sub get_days_since {
    my Date::Gregorian ($self, $then) = @_;
    return $self->[F_DAYNO] - $then->[F_DAYNO];
}

sub set_easter {
    my Date::Gregorian $self = $_[0];
    @{$self}[F_DAYNO, F_YMD, F_YDYW] =
	( _easter($_[1], @{$self}[F_TR_DATE, F_TR_EYR]), undef );
    return $self;
}

sub set_gmtime {
    my Date::Gregorian $self = $_[0];
    my $time = $_[1];
    @{$self}[F_DAYNO, F_YMD, F_YDYW] = (
	0 <= $time? $epoch + $time / 86400: $epoch - (86399 - $time) / 86400,
	undef, undef,
    );
    return $self;
}

sub get_gmtime {
    my Date::Gregorian $self = $_[0];
    my $d = $self->[F_DAYNO] - $epoch;
    return -24855 <= $d && $d <= 24855? 86400 * $d: undef;
}

sub set_weekday {
    no integer;
    my Date::Gregorian $self = shift;
    my ($wd, $rel) = @_;
    my $delta = ($wd - $self->[F_DAYNO]) % 7;
    if (defined($rel) && '>=' ne $rel) {
	$delta = 7 if !$delta && '>' eq $rel;
	$delta -= 7 if '<' eq $rel || $delta && '<=' eq $rel;
    }
    $self->[F_DAYNO] += $delta;
    @{$self}[F_YMD, F_YDYW] = (undef, undef);
}

sub DESTROY {}				# nothing to clean up

1;
__END__

=head1 NAME

Date::Gregorian - Gregorian calendar

=head1 SYNOPSIS

  use Date::Gregorian;

  $date = Date::Gregorian->new->set_ymd(1999, 12, 31);

  if ($date->check_ymd($y, $m, $d)) {
    # valid, $date has new value
  }
  else {
    # not valid, $date keeps old value
  }

  ($y, $m, $d) = $date->get_ymd;

  $wd = (qw(Mon Tue Wed Thu Fri Sat Sun))[$date->get_weekday];
  $date->set_yd(2000, 366);           # Dec 31, 2000
  ($y, $d) = $date->get_yd;
  $date->set_ywd(1998, 53, 6);        # Sun Jan 3, 1999
  ($y, $w, $d) = $date->get_ywd;
  $date->add_days($delta);
  $delta = $date->get_days_since($otherdate);
  $date->set_easter($y);
  $date->set_gmtime($time);
  $time = $date->get_gmtime;
  $date->configure(1752, 9, 14);
  $date->configure(1752, 9, 14, 1753);        # United Kingdom
  $date->set_date($otherdate);        # change date, keep configuration
  $date = $otherdate->new;            # copy date, propagate config.

  if ($date->is_gregorian) {
    # date is past configured calendar reformation, thus in Gregorian notation
  }
  else {
    # date is before configured calendar reformation, thus in Julian notation
  }

  # get the first sunday in October:
  $date->set_ymd($year, 10,  1)->set_weekday(6, '>=');
  # get the last sunday in October:
  $date->set_ymd($year, 11,  1)->set_weekday(6, '<');

=head1 DESCRIPTION

Calendars define some notation to identify days in history.  The
Gregorian calendar, now in wide use, was established by Pope
Gregory XIII in AD 1582 as an improvement over the less accurate
Julian calendar that had been in use before.  Both of these calendars
also determine certain holidays.  Unfortunately, the new one was
not adopted everywhere at the same time.  Thus, the correct date
for a given historic event can depend on its location.  Astronomers
usually expand the official Julian/Gregorian calendar backwards
beyond AD 1 using zero and negative numbers, so that year 0 is
1 BC, year -1 is 2 BC, etc.

This module provides an object class representing days in history.
You can get earlier or later dates by way of adding days to them,
determine the difference in days between two of them, and read out
the day, month and year number as the (astronomic) Gregorian calendar
defines them (numbers 1 through 12 representing January through
December).  Moreover, you can find out weekdays, easter sundays,
week in year and day in year numbers.

For convenience, it is also possible to define the switching day
from Julian to Gregorian dates and the switching year from Julian
to Gregorian easter schedule.  Use configure with the first valid
date of the new calendar and optionally the first year the new
easter schedule was used (default 1583).

The module is based on an algorithm devised by C. F. Gauss (1777-1855).
It is completely written in Perl for maximum portability.

All methods except get_* return their object.  This allows for
shortcuts like:

  $pentecost = Date::Gregorian->new->set_easter(2000)->add_days(49);

The optional relation parameter for set_weekday may be one of '>=',
'>', '<=', or '<'.  Default is '>='.  This method finds the nearest
date that is "not earlier", later, "not later", or earlier,
respectively, than the given date and matches the given weekday.

Numbers 0 through 6 represent weekdays Monday through Sunday.  Day
in month ranges from 1 to 31, day in year from 1 to 366, week in
year from 1 to 53.  Weeks are supposed to start on Monday.  The
first week of a year is the one containing January 4th.  These
definitions are slightly closer to ISO/R 2015-1971 than to Perl's
builtin time conversion functions.  Weekday numbers, however, are
zero-based for Perl's sake, i.e. ease of use as array indices.

=head1 AUTHOR

Martin Hasch <martin@mathematik.uni-ulm.de>, November 1999.

=head1 CAVEATS

Does not work with non-integer values.

=head1 SEE ALSO

The sci.astro Calendar FAQ, L<Date::Calc>, L<Date::Gregorian::Exact>.

=cut
