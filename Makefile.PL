# Copyright (c) 1999-2000 Martin Hasch.  All rights reserved.
# This package is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.
#
# $Id: Makefile.PL,v 1.1 2002/04/19 20:32:15 martin Exp $

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'Date::Gregorian',
    'VERSION_FROM' => 'Gregorian.pm', # finds $VERSION
);
