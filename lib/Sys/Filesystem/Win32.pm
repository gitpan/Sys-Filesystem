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
$VERSION = sprintf('%d.%02d', q$Revision: 1.2 $ =~ /(\d+)/g);



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



__END__

###############################################################################
# CVS changelog

$Log: Win32.pm,v $
Revision 1.2  2004/09/28 16:43:21  nicolaw
*** empty log message ***

Revision 1.2  2004/09/28 16:42:40  nicolaw
*** empty log message ***


