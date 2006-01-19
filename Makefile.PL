# Copyright (c) 1999-2005 Martin Hasch.  All rights reserved.
# This package is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.
#
# $Id: Makefile.PL,v 1.2 2006/01/19 18:02:21 martin Stab $

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

my $with_author = 6.0603 <= $ExtUtils::MakeMaker::VERSION;
my $guard_meta  = 6.1003 <= $ExtUtils::MakeMaker::VERSION;

WriteMakefile(
    'NAME'	   => 'Date::Gregorian',
    'VERSION_FROM' => 'lib/Date/Gregorian.pm', # finds $VERSION
    $with_author? (
	'AUTHOR'   => 'Martin Hasch (hasch-cpan-dg@cozap.com)',
	'ABSTRACT' => 'Gregorian calendar',
    ): (),
    $guard_meta? (
	'NO_META'  => 1,
    ): (),
);
