package Sys::Filesystem::Win32;

###############################################################################
# Modules

use strict;
use warnings;
use FileHandle;
use Carp qw(croak);



###############################################################################
# Globals and constants

use vars qw($VERSION);
$VERSION = sprintf('%d.%02d', q$Revision: 1.3 $ =~ /(\d+)/g);



##############################################################################
# Public methods

sub new {
        # Check we're being called correctly with a class name
        ref(my $class = shift) && croak 'Class name required';
        my %args = @_;
        my $self = { };

        # Bless and return
        bless($self,$class);
        return $self;
}

1;




=pod

=head1 NAME

Sys::Filesystem::Win32 - Return Win32 filesystem information to Sys::Filesystem

=head1 SYNOPSIS

See L<Sys::Filesystem>.

=head1 VERSION

$Id: Win32.pm,v 1.3 2005/12/08 15:44:12 nicolaw Exp $

=head1 AUTHOR

Nicola Worthington <nicolaw@cpan.org>

http://perlgirl.org.uk

=head1 COPYRIGHT

(c) Nicola Worthington 2004, 2005. This program is free software; you can
redistribute it and/or modify it under the GNU GPL.

See the file COPYING in this distribution, or
http://www.gnu.org/licenses/gpl.txt 

=cut


