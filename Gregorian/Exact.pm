# Copyright (c) 2001 Martin Hasch.  All rights reserved.
# This package is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.
#
# $Id: Exact.pm,v 1.3 2002/04/19 20:24:57 martin Stab $

package Date::Gregorian::Exact;

use strict;
no integer;
use Date::Gregorian;
use POSIX qw(floor);
use vars qw(@ISA $VERSION);

# ----- object definition -----

# Date::Gregorian::Exact=ARRAY(...) isa Date::Gregorian

# .......... index ..........				# ..... value .....
use constant F_SECONDS => Date::Gregorian::FIELDS;	# seconds past midnight
use constant FIELDS    => Date::Gregorian::FIELDS + 1;

# ----- predefined variables -----

@ISA = qw(Date::Gregorian);
$VERSION = 0.02;

# ----- private function -----

# return seconds for arbitrary Date::Gregorian object (0 unless Exact)
#
sub _get_seconds {
    my Date::Gregorian $ref = $_[0];
    return 0 unless $ref->isa('Date::Gregorian::Exact');
    return $ref->[F_SECONDS];
}

# ----- private method -----

# postcondition: 0 <= seconds < secondsperday
#
sub _normalize {
    my Date::Gregorian::Exact $self = $_[0];
    my $s = $self->[F_SECONDS] ||= 0;
    my $d;
    if ($s < 0 || 86400 <= $s) {
	$d = floor($s/86400);
	$s -= $d * 86400;
	$self->SUPER::add_days($d)->[F_SECONDS] = $s;
    }
    return $self;
}

# ----- extension-specific methods -----

sub set_hms {
    my Date::Gregorian::Exact $self = shift;
    my ($h, $m, $s) = @_;
    $self->[F_SECONDS] = ($h * 60 + $m) * 60 + $s;
    return $self->_normalize;
}

sub get_hms {
    my Date::Gregorian::Exact $self = $_[0];
    my $s = $self->[F_SECONDS];
    my $m = floor($s / 60);
    my $h = floor($m / 60);
    $s -= $m * 60;
    $m -= $h * 60;
    return ($h, $m, $s);
}

sub check_ymdhms {
    my Date::Gregorian::Exact $self = shift;
    my ($y, $m, $d, $H, $M, $S) = @_;
    if (
	0 <= $H && $H < 24 && $H == floor($H) &&
	0 <= $M && $M < 60 && $M == floor($M) &&
	0 <= $S && $S < 60 &&
	$self->check_ymd($y, $m, $d)
    ) {
	$self->[F_SECONDS] = 60 * (60 * $H + $M) + $S;
	return $self;
    }
    return undef;
}

sub get_seconds_since {
    my Date::Gregorian::Exact $self = $_[0];
    my Date::Gregorian $then = $_[1];
    return $self->SUPER::get_days_since($then) * 86400 +
	$self->[F_SECONDS] - _get_seconds($then);
}

sub add_seconds {
    my Date::Gregorian::Exact $self = $_[0];
    my $seconds = $_[1];
    $self->[F_SECONDS] += $seconds;
    return $self->_normalize;
}

sub set_localtime {
    my Date::Gregorian::Exact $self = $_[0];
    my $time = $_[1];
    my ($S, $M, $H, $d, $m, $y) = (localtime $time)[0..5];
    return $self->set_ymd(1900+$y, 1+$m, $d)->set_hms($H, $M, $S);
}

sub get_localtime {
    my Date::Gregorian::Exact $self = $_[0];
    my $seconds = floor($self->[F_SECONDS] || 0);

    # first shot: ignore TZ
    my $time = $self->SUPER::get_gmtime;
    return undef unless defined $time;
    $time += floor($self->[F_SECONDS] || 0);
    my $guess = $self->new;
    my ($S, $M, $H, $d, $m, $y) = localtime $time;
    # second shot: ignore DST change, error should be less than one day
    $guess->set_ymd(1900+$y, 1+$m, $d)->set_hms($H, $M, $S);
    $time -= $guess->get_seconds_since($self);
    ($S, $M, $H, $d, $m, $y) = localtime $time;
    # optional third shot: fix DST if second guess missed it
    if (($H * 60 + $M) * 60 + $S != $seconds) {
	$guess->set_ymd(1900+$y, 1+$m, $d)->set_hms($H, $M, $S);
	$time -= $guess->get_seconds_since($self);
    }
    return $time;
}

# ----- superclass methods -----

# configure    - inherited
# is_gregorian - inherited
# set_ymd      - inherited
# check_ymd    - inherited
# get_ymd      - inherited
# get_weekday  - inherited
# set_yd       - inherited
# set_ywd      - inherited
# get_yd       - inherited
# get_ywd      - inherited
# set_easter   - inherited
# set_weekday  - inherited
# DESTROY      - inherited

sub new {
    my $class = $_[0];
    my Date::Gregorian::Exact $self = $class->SUPER::new;
    $self->[F_SECONDS] ||= 0;
    return $self;
}

sub set_date {
    my Date::Gregorian::Exact $self = $_[0];
    my Date::Gregorian $ref = $_[1];
    $self->SUPER::set_date($ref)->[F_SECONDS] = _get_seconds($ref);
    return $self;
}

sub add_days {
    my Date::Gregorian::Exact $self = $_[0];
    my $days      = $_[1];
    my $wholedays = floor($days);
    $self->SUPER::add_days($wholedays) if $wholedays;
    $self->add_seconds(($days - $wholedays) * 86400) if $days != $wholedays;
    return $self;
}

sub get_days_since {
    my Date::Gregorian::Exact $self = $_[0];
    my Date::Gregorian $ref = $_[1];
    return
	$self->SUPER::get_days_since($ref) +
	($self->[F_SECONDS] - _get_seconds($ref)) / 86400;
}

sub set_gmtime {
    my Date::Gregorian::Exact $self = $_[0];
    my $time = $_[1];
    $self->SUPER::set_gmtime($time)->[F_SECONDS] = 0;
    $self->[F_SECONDS] = $time - $self->SUPER::get_gmtime;
    return $self;
}

sub get_gmtime {
    my Date::Gregorian::Exact $self = $_[0];
    return $self->SUPER::get_gmtime + $self->[F_SECONDS];
}

1;

__END__

=head1 NAME

Date::Gregorian::Exact - timestamp precision extension for Date::Gregorian

=head1 SYNOPSIS

  use Date::Gregorian::Exact;

  $date =
    Date::Gregorian::Exact->new->set_ymd(1999, 12, 31)->set_hms(23, 59, 59);
  ($hr, $min, $sec) = $date->get_hms;

  if ($date->check_ymdhms($year, $month, $day, $hour, $min, $sec)) {
    # valid, $date has new value
  }
  else {
    # not valid, $date keeps old value
  }

  $delta = $date->get_seconds_since($otherdate);
  $date->add_seconds($delta);
  $date->set_localtime($time);
  $time = $date->get_localtime;

=head1 DESCRIPTION

I<Date::Gregorian::Exact> is a subclass extending Date::Gregorian
towards higher precision (sufficient to deal with timestamps).

With Date::Gregorian::Exact objects, all methods of the base class
Date::Gregorian work exactly as described there, except where noted
below.  In particular, most parameters must still be integer values.

Exceptions to this rule are I<add_days> and I<get_days_since>, now
handling fractions of days as well as whole days, and I<set/get_gmtime>,
now no longer mapping any daytime to midnight.

=head2 Additional Methods

I<set/get_hms> access hours, minutes and seconds.  Non-integer
values of seconds are allowed but not recommended, as they might
introduce rounding errors.

I<check_ymdhms> checks and, if valid, sets an exact date.

I<add_seconds> and I<get_seconds_since> handle time intervals
much like add_days and get_days_since, only on a finer scale.

I<set/get_localtime> convert timestamps as they would be interpreted
in the current locale.  This means, local timezone and daylight
saving mode are taken into account like the localtime Perl function
does.

Note, however, that timezones and daylight saving settings are not
(yet) part of this module's data model.  Any arithmetic done on
these date objects assumes an ideal calendar with days of a uniform
length of 24 hours.  Guess why astronomers don't like daylight
saving time either.

=head1 AUTHOR

Martin Hasch <martin@mathematik.uni-ulm.de>, November 1999.

=head1 SEE ALSO

L<Date::Gregorian>.

=cut
