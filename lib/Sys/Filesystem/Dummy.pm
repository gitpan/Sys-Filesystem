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
$VERSION = sprintf('%d.%02d', q$Revision: 1.4 $ =~ /(\d+)/g);



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

=head1 VERSION

$Revision: 1.4 $

=head1 SEE ALSO

Sys::Filesystem Sys::Filesystem::Unix Sys::Filesystem::Win32

=head1 BUGS

Probably. Please email me a patch if you find something ghastly.

=head1 AUTHOR

Nicola Worthington <nicolaworthington@msn.com>

http://www.nicolaworthington.com/

$Author: nicolaw $

=head1 CHANGELOG

    $Log: Dummy.pm,v $
    Revision 1.4  2004/10/06 15:44:12  nicolaw
    Added POD

    Revision 1.3  2004/09/28 16:43:21  nicolaw
    *** empty log message ***
    
    Revision 1.2  2004/09/28 16:42:40  nicolaw
    *** empty log message ***


