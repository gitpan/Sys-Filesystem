############################################################
#
#   $Id: Aix.pm 368 2006-03-23 17:38:56Z nicolaw $
#   Sys::Filesystem - Retrieve list of filesystems and their properties
#
#   Copyright 2004,2005,2006 Nicola Worthington
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
############################################################

package Sys::Filesystem::Aix;
# vim:ts=4:sw=4:tw=78

use strict;
use FileHandle;
use Carp qw(croak);

use vars qw($VERSION);
$VERSION = '1.04' || sprintf('%d', q$Revision: 368 $ =~ /(\d+)/g);

sub new {
	ref(my $class = shift) && croak 'Class name required';
	my %args = @_;
	my $self = { };

	$args{fstab} ||= '/etc/filesystems';

	my @fstab_keys = qw(account boot check dev free mount nodename size type vfs vol log);
	my @special_fs = qw(swap proc tmpfs nfs mntfs autofs);

	# Read the fstab
	my $fstab = new FileHandle;
	if ($fstab->open($args{fstab})) {
		my $current_filesystem = '*UNDEFINED*';
		while (<$fstab>) {
			next if (/^\s*#/ || /^\s*$/);

			# This doesn't allow for a mount point with a space in it
			if (/^(\S+):\s*$/) {
				$current_filesystem = $1;
				$self->{$current_filesystem}->{filesystem} = $1;

			# This matches a filesystem attribute
			} elsif (my ($key,$value) = $_ =~ /^\s*([a-z]{3,8})\s+=\s+"?(.+)"?\s*$/) {
				$self->{$current_filesystem}->{$key} = $value;
				$self->{$current_filesystem}->{unmounted} = -1; # Unknown mount state?

				if ($key eq 'type' && grep(/^$value$/, @special_fs)) {
					$self->{$current_filesystem}->{special} = 1;
				}
			}
		}
		$fstab->close;
	} else {
		croak "Unable to open fstab file ($args{fstab})\n";
	}

	bless($self,$class);
	return $self;
}

1;

=pod

=head1 NAME

Sys::Filesystem::Aix - Return AIX filesystem information to Sys::Filesystem

=head1 SYNOPSIS

See L<Sys::Filesystem>.

=head1 METHODS

The following is a list of filesystem properties which may
be queried as methods through the parent L<Sys::Filesystem> object.

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

=head1 SEE ALSO

L<Sys::Filesystem>

=head1 VERSION

$Id: Aix.pm 368 2006-03-23 17:38:56Z nicolaw $

=head1 AUTHOR

Nicola Worthington <nicolaw@cpan.org>

L<perlgirl.org.uk>

=head1 COPYRIGHT

Copyright 2004,2005,2006 Nicola Worthington.

This software is licensed under The Apache Software License, Version 2.0.

L<http://www.apache.org/licenses/LICENSE-2.0>

=cut


