require 5.005;
use strict;
use ExtUtils::MakeMaker qw(WriteMakefile);

WriteMakefile(
   NAME          => 'Sys::Filesystem',
   VERSION_FROM  => 'lib/Sys/Filesystem.pm',
   ABSTRACT_FROM => 'lib/Sys/Filesystem.pm',
   AUTHOR        => 'Nicola Worthington <nicolaworthington@msn.com>',
   PREREQ_PM     => { 'FileHandle'  => 0,
                      'Carp'        => 0,
                     },
);

