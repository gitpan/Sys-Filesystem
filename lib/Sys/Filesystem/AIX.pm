package Sys::Filesystem::AIX;

###############################################################################
# Modules

use strict;
use warnings;
use FileHandle;
use Carp qw(croak);



###############################################################################
# Globals and constants

use vars qw($VERSION);
$VERSION = sprintf('%d.%02d', q$Revision: 1.1 $ =~ /(\d+)/g);



##############################################################################
# Public methods

sub new {
	# Check we're being called correctly with a class name
	ref(my $class = shift) && croak 'Class name required';
	my %args = @_;
	my $self = { };

	# Defaults
	$args{fstab} ||= '/etc/filesystems';

	# Default fstab and mtab layout
	my @fstab_keys = qw(account boot check dev free mount nodename size type vfs vol log);

	# Read the fstab
	my $fstab = new FileHandle;
	if ($fstab->open($args{fstab})) {
		my $current_filesystem = '*UNDEFINED*';
		while (<$fstab>) {
			next if /^\s*#/;
			next if /^\s*$/;

			# This doesn't allow for a mount point with a space in it
			if (/^(\S+):\s*$/) {
				$current_filesystem = $1;
				$self->{$current_filesystem}->{filesystem} = $1;

			# This matches a filesystem attribute
			} elsif (my ($key,$value) = $_ =~ /^\s*([a-z]{3,8})\s+=\s+"?(.+)"?\s*$/) {
				$self->{$current_filesystem}->{$key} = $value;
				$self->{$current_filesystem}->{unmounted} = -1; # Unknown mount state?
				
				if ($key eq 'type' && grep(/^$value$/, qw(swap proc tmpfs nfs mntfs autofs))) {
					$self->{$current_filesystem}->{special} = 1;
				}
			}
		}
		$fstab->close;
	} else {
		croak "Unable to open fstab file ($args{fstab})\n";
	}

	# Bless and return
	bless($self,$class);
	return $self;
}

1;


###############################################################################
# POD

=pod

=head1 NAME

Sys::Filesystem::AIX - Return AIX filesystem information to Sys::Filesystem

=head1 VERSION

$Revision: 1.1 $

=head1 FILESYSTEM PROPERTIES

The following is a list of filesystem properties which may
be queried as methods through the parent Sys::Filesystem object.

=over 4

=item account

Used by the dodisk command to determine the filesystems to be
processed by the accounting system.

=item boot

Used by the mkfs command to initialize the boot block of a new
filesystem.

=item check

Used by the fsck command to determine the default filesystems
to be checked.

=item dev

Identifies, for local mounts, either the block special file
where the filesystem resides or the file or directory to be
mounted. 

=item free

This value can be either true or false. (Obsolete and ignored).

=item mount

Used by the mount command to determine whether this file
system should be mounted by default.

=item nodename

Used by the mount command to determine which node contains
the remote filesystem.

=item size

Used by the mkfs command for reference and to build the file
system.

=item type

Used to group related mounts.

=item vfs

Specifies the type of mount. For example, vfs=nfs specifies
the virtual filesystem being mounted is an NFS filesystem.

=item vol

Used by the mkfs command when initializing the label on a new
filesystem. The value is a volume or pack label using a
maximum of 6 characters.

=item log

The LVName must be the full path name of the filesystem logging
logical volume name to which log data is written as this file
system is modified. This is only valid for journaled filesystems.

=back

=head1 ACKNOWLEDGEMENTS

http://publib.boulder.ibm.com/infocenter/pseries/index.jsp?topic=/com.ibm.aix.doc/files/aixfiles/filesystems.htm

=head1 SEE ALSO

Sys::Filesystem

=head1 BUGS

Probably. Please email me a patch if you find something ghastly.

=head1 AUTHOR

Nicola Worthington <nicolaworthington@msn.com>

http://www.nicolaworthington.com/

$Author: nicolaw $

=head1 CHANGELOG

    $Log: AIX.pm,v $
    Revision 1.1  2005/01/30 18:10:49  nicolaw
    Added first revision











