package Sys::Filesystem::Cygwin;

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

	# Default mtab and mtab layout
	my @keys = qw(fs_spec fs_file fs_vfstype fs_mntops);

	# Read the mtab
	my $mtab = new FileHandle;
	if ($mtab->open('mount|')) {
		while (<$mtab>) {
			next if /^\s*#/;
			next if /^\s*$/;
			if (my @vals = $_ =~ /^\s*(.+?) on (\/.+?) type (\S+) \((\S+)\)\s*$/) {
				$self->{$vals[1]}->{mounted} = 1;
				$self->{$vals[1]}->{special} = 1 if grep(/^$vals[2]$/,qw(swap proc devpts tmpfs));
				for (my $i = 0; $i < @keys; $i++) {
					$self->{$vals[1]}->{$keys[$i]} = $vals[$i];
				}
			}
		}
		$mtab->close;
	} else {
		croak "Unable to open pipe handle for mount command\n";
	}

	# Bless and return
	bless($self,$class);
	return $self;
}

1;



#worthn01@PC-L438082~ $ mount
#d:\cygwin\bin on /usr/bin type user (binmode)
#d:\cygwin\lib on /usr/lib type user (binmode)
#d:\cygwin on / type user (binmode)
#c: on /cygdrive/c type user (binmode,noumount)
#d: on /cygdrive/d type user (binmode,noumount)
#f: on /cygdrive/f type user (binmode,noumount)
#i: on /cygdrive/i type user (binmode,noumount)
#j: on /cygdrive/j type user (binmode,noumount)
#l: on /cygdrive/l type user (binmode,noumount)
#s: on /cygdrive/s type user (binmode,noumount)
#z: on /cygdrive/z type user (binmode,noumount)
#worthn01@PC-L438082~ $



###############################################################################
# POD

=pod

=head1 NAME

Sys::Filesystem::Cygwin - Return Cygwin filesystem information to Sys::Filesystem

=head1 VERSION

$Revision: 1.5 $

=head1 FILESYSTEM PROPERTIES

The following is a list of filesystem properties which may
be queried as methods through the parent Sys::Filesystem object.

=over 4

=item device

Device mounted.

=item mount_point

Mount point.

=item fs_vfstype

Filesystem type.

=item fs_mntops

Mount options.

=back

=head1 SEE ALSO

Sys::Filesystem Sys::Filesystem::Unix http://cygwin.com/cygwin-ug-net/using.html

=head1 BUGS

Probably. Please email me a patch if you find something ghastly.

=head1 AUTHOR


Nicola Worthington <nicolaworthington@msn.com>

http://www.nicolaworthington.com/

$Author: nicolaw $

=head1 CHANGELOG

    $Log: Cygwin.pm,v $
    Revision 1.5  2005/12/02 16:05:03  nicolaw
    Fixed tabulation, ^M's and skipping of empty lines in footab files

    Revision 1.4  2004/10/06 16:14:27  nicolaw
    Fixed some typos

    Revision 1.3  2004/10/06 16:03:53  nicolaw
    Updated around mount command pipe

    Revision 1.2  2004/10/06 15:42:13  nicolaw
    Added dummy skel to finish up on shortly


