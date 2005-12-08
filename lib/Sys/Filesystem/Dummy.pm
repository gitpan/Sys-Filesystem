package Sys::Filesystem::Dummy;

###############################################################################
# Modules

use strict;
use warnings;
use FileHandle;
use Carp qw(croak);



###############################################################################
# Globals and constants

use vars qw($VERSION);
$VERSION = sprintf('%d.%02d', q$Revision: 1.5 $ =~ /(\d+)/g);



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



###############################################################################
# POD

=pod

=head1 NAME

Sys::Filesystem::Dummy - Returns nothing to Sys::Filesystem

=head1 SYNOPSIS

See L<Sys::Filesystem>.

=head1 VERSION

$Id: Dummy.pm,v 1.5 2005/12/08 15:44:12 nicolaw Exp $

=head1 AUTHOR

Nicola Worthington <nicolaw@cpan.org.uk>

http://perlgirl.org.uk

=head1 COPYRIGHT

(c) Nicola Worthington 2004, 2005. This program is free software; you can
redistribute it and/or modify it under the GNU GPL.

See the file COPYING in this distribution, or
http://www.gnu.org/licenses/gpl.txt 

=cut


