############################################################
# $Id: Filesystem.pm,v 1.18 2005/12/29 18:02:09 nicolaw Exp $
# Sys::Filesystem - Retrieve list of filesystems and their properties
# Copyright: (c)2004,2005 Nicola Worthington. All rights reserved.
############################################################
# This file is part of Sys::Filesystem.
#
# Sys::Filesystem is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# Sys::Filesystem is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Sys::Filesystem; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
############################################################

package Sys::Filesystem;
# vim:ts=4:sw=4:tw=78

###############################################################################
# Modules

use strict;
use warnings;
use English;
use FileHandle;
use Carp qw(croak cluck confess);



###############################################################################
# Globals and constants

use constant DEBUG => $ENV{DEBUG} ? 1 : 0;
use vars qw($VERSION $AUTOLOAD);
$VERSION = sprintf('%d.%02d', q$Revision: 1.18 $ =~ /(\d+)/g);



###############################################################################
# Public methods

sub new {
	# Check we're being called correctly with a class name
	ref(my $class = shift) && croak 'Class name required';

	# Check we've got something sane passed
	croak 'Odd number of elements passed when even number was expected' if @_ % 2;
	my %args = @_;

	# Double check the key pairs for stuff we recognise
	while (my ($k,$v) = each %args) {
		unless (grep(/^$k$/i, qw(fstab mtab xtab))) {
			croak "Unrecognised paramater '$k' passed to module $class";
		}
	}

	# How to query
	my $self = { %args };
	$self->{osname} = $OSNAME;
	my @query_order = ($self->{osname});
	push @query_order, $self->{osname} eq 'MSWin32' ? 'Win32' : 'Unix';
	push @query_order, 'Dummy';

	# Try and query
	for (@query_order) {
		$self->{filesystems} ||= eval sprintf('require %s::%s; %s::%s->new(%%args);',
						__PACKAGE__, _caps($_),
						__PACKAGE__, _caps($_)
					);
		cluck($@) if $@;
	}

	# Filesystem property aliases
	$self->{aliases} = {
			device          => [ qw(fs_spec dev) ],
			filesystem      => [ qw(fs_file mount_point) ],
			mount_point     => [ qw(fs_file filesystem) ],
			type            => [ qw(fs_vfstype) ],
			format          => [ qw(fs_vfstype vfs) ],
			options         => [ qw(fs_mntops) ],
			check_frequency => [ qw(fs_freq) ],
			check_order     => [ qw(fs_passno) ],
			boot_order      => [ qw(fs_mntno) ],
			volume          => [ qw(fs_volume fs_vol vol) ],
			label           => [ qw(fs_label) ],
		};

	# Information
	$self->{software} = {
			Caller => [ caller ],
			Package => __PACKAGE__,
			Version => $VERSION,
			Author => '$Author: nicolaw $',
			Revision => '$Revision: 1.18 $',
			Id => '$Id: Filesystem.pm,v 1.18 2005/12/29 18:02:09 nicolaw Exp $',
		};

	# Debug
	DUMP('$self',$self);

	# Maybe upchuck a little
	croak "Unable to create object for OS type '$self->{osname}'" unless $self->{filesystems};

	# Bless and return
	bless($self,$class);
	return $self;
}

sub filesystems {
	my $self = shift;
	unless(ref $self eq __PACKAGE__ || UNIVERSAL::isa($self, __PACKAGE__)) {
		unshift @_, $self;
		$self = new __PACKAGE__;
	}

	# Check we've got something sane passed
	croak 'Odd number of elements passed when even number was expected' if @_ % 2;
	my $params = { @_ };
	for my $param (keys %{$params}) {
		croak "Illegal paramater '$param' passed to filesystems() method"
			unless grep(/^$param$/, qw(mounted unmounted special device));
	}

	my @filesystems = ();

	# Return list of all filesystems
	unless (keys %{$params}) {
		@filesystems = sort(keys(%{$self->{filesystems}}));

	# Return list of specific filesystems
	} else {
		for my $fs (sort(keys(%{$self->{filesystems}}))) {
			for my $requirement (keys %{$params}) {
				if ((defined $params->{$requirement} && exists $self->{filesystems}->{$fs}->{$requirement}) &&
				    $self->{filesystems}->{$fs}->{$requirement} eq $params->{$requirement} ||
				    (!defined $params->{$requirement} && !exists $self->{filesystems}->{$fs}->{$requirement})) {
					push @filesystems, $fs;
					last;
				}
			}
		}
	}

	# Return
	return @filesystems;
}

sub mounted_filesystems {
	my $self = shift;
	return $self->filesystems(mounted => 1);
}

sub unmounted_filesystems {
	my $self = shift;
	return $self->filesystems(unmounted => 1);
}

sub special_filesystems {
	my $self = shift;
	return $self->filesystems(special => 1);
}

sub regular_filesystems {
	my $self = shift;
	return $self->filesystems(special => undef);
}

sub DESTROY {}

sub AUTOLOAD {
	my $self = shift;
	my $type = ref($self) || croak "$self is not an object";

	my $fs = shift;
	croak "No filesystem passed where expected" unless $fs;

	(my $name = $AUTOLOAD) =~ s/.*://;

	# No such filesystem
	unless (exists $self->{filesystems}->{$fs}) {
		croak "No such filesystem";

	# Look for the property
	} else {
		# Found the property
		if (exists $self->{filesystems}->{$fs}->{$name}) {
			return $self->{filesystems}->{$fs}->{$name};

		# Didn't find the property, but check any aliases
		} elsif (exists $self->{aliases}->{$name}) {
			for my $alias (@{$self->{aliases}->{$name}}) {
				# Found the Alias
				if (exists $self->{filesystems}->{$fs}->{$alias}) {
					return $self->{filesystems}->{$fs}->{$alias};
				}
			}
		}
	}

	return undef;
}



###############################################################################
# Private methods

sub _caps {
	my $str = shift;
	$str =~ s/\b(\w)/\U$1\E/g;
	return $str;
}

sub TRACE {
	return unless DEBUG;
	warn(shift());
}
sub DUMP {
	return unless DEBUG;
	eval {
		require Data::Dumper;
		warn(shift().': '.Data::Dumper::Dumper(shift()));
	}
}



1;



###############################################################################
# POD

=pod

=head1 NAME

Sys::Filesystem - Retrieve list of filesystems and their properties

=head1 SYNOPSIS

    use strict;
    use warnings;
    use Sys::Filesystem ();
    
    # Method 1
    my $fs = new Sys::Filesystem;
    my @filesystems = $fs->filesystems();
    for (@filesystems) {
        printf("%s is a %s filesystem mounted on %s\n",
                          $fs->mount_point($_),
                          $fs->format($_),
                          $fs->device($_)
                   );
    }
    
    # Method 2
    my $weird_fs = Sys::Filesystem->new(
                          fstab => "/etc/weird/vfstab.conf",
                          mtab => "/etc/active_mounts",
                          xtab => "/etc/nfs/mounts"
                    );
    my @weird_filesystems = $weird_fs->filesystems();
    
    # Method 3 (nice but naughty)
    my @filesystems = Sys::Filesystem->filesystems();

=head1 DESCRIPTION

Sys::Filesystem is intended to be a portable interface to list and query
filesystem names and their properties. At the time of writing there were only
Solaris and Win32 modules available on CPAN to perform this kind of operation.
This module hopes to provide a consistant API to list all, mounted, unmounted
and special filesystems on a system, and query as many properties as possible
with common aliases wherever possible.

=head1 METHODS

=over 4

=item new()

Creates a new Sys::Filesystem object. new() accepts 3 optional key pair values
to help or force where mount information is gathered from. These values are
not otherwise defaulted by the main Sys::Filesystem object, but left to the
platform specific helper modules to determine as an exercise of common sense.

=over 4

=item fstab

Specify the full path and filename of the filesystem table (or fstab for
short).

=item mtab

Specify the full path and filename of the mounted filesystem table (or mtab
for short). Not all platforms have such a file and so this option may be
ignored on some systems.

=item xtab

Specify the full path and filename of the mounted NFS filesystem table
(or xtab for short). This is usually only pertinant to Unix bases systems.
Not all helper modules will query NFS mounts as a seperate exercise, and
therefore this option may be ignored on some systems.

=back

=back

=head2 Listing Filesystems

=over 4

=item filesystems()

Returns a list of all filesystem. May accept an optional list of key pair
values in order to filter/restrict the results which are returned. Valid
values are as follows:

=over 4

=item device => "string"

Returns only filesystems that are mounted using the device of "string".
For example:

    my $fdd_filesytem = Sys::Filesystem->filesystems(device => "/dev/fd0");

=item mounted => 1

Returns only filesystems which can be confirmed as actively mounted.
(Filesystems which are mounted).

The mounted_filesystems() method is an alias for this syntax.

=item unmounted => 1

Returns only filesystems which cannot be confirmed as actively mounted.
(Filesystems which are not mounted).

The unmounted_filesystems() method is an alias for this syntax.

=item special => 1

Returns only filesystems which are regarded as special in some way. A
filesystem is marked as special by the operating specific helper
module. For example, a tmpfs type filesystem on one operating system
might be regarded as a special filesystem, but not on others. Consult
the documentation of the operating system specific helper module for
further information about your system. (Sys::Filesystem::Linux for Linux
or Sys::Filesystem::Solaris for Solaris etc).

The special_filesystems() method is an alias for this syntax.

=item regular => undef

Returns only fileystems which are not regarded as special. (Normal
filesystems).

The regular_filesystems() method is an alias for this syntax.

=back

=item mounted_filesystems()

Returns a list of all filesystems which can be verified as currently
being mounted.

=item unmounted_filesystems()

Returns a list of all filesystems which cannot be verified as currently
being mounted.

=item special_filesystems()

Returns a list of all fileystems which are considered special. This will
usually contain meta and swap partitions like /proc and /dev/shm on Linux.

=item regular_filesystems()

Returns a list of all filesystems which are not considered to be special.

=back

=head2 Filesystem Properties

Available filesystem properties and their names vary wildly between platforms.
Common aliases have been provided wherever possible. You should check the
documentation of the specific platform helper module to list all of the
properties which are available for that platform. For example, read the
Sys::Filesystem::Linux documentation for a list of all filesystem properties
available to query under Linux.

=over 4

=item mount_point() or filesystem()

Returns the friendly name of the filesystem. This will usually be the same
name as appears in the list returned by the filesystems() method.

=item label()

Returns the fileystem label.

This functionality may need to be retrofitted to some original OS specific
helper modules as of Sys::Filesystem 1.12.

=item volume()

Returns the volume that the filesystem belongs to or is mounted on.

This functionality may need to be retrofitted to some original OS specific
helper modules as of Sys::Filesystem 1.12.

=item device()

Returns the physical device that the filesystem is connected to.

=item type() or format()

Returns the type of filesystem format. fat32, ntfs, ufs, hpfs, ext3, xfs etc.

=item options()

Returns the options that the filesystem was mounted with. This may commonly
contain information such as read-write, user and group settings and
permissions.

=item mount_order()

Returns the order in which this filesystem should be mounted on boot.

=item check_order()

Returns the order in which this filesystem should be consistancy checked
on boot.

=item check_frequency()

Returns how often this filesystem is checked for consistancy.

=back

=head1 OS SPECIFIC HELPER MODULES

=head2 Dummy

The Dummy module is there to provide a default failover result to the main
Sys::Filesystem module if no suitable platform specific module can be found
or sucessfully loaded. This is the last module to be tried, in order of
platform, Unix (if not on Win32), and then Dummy.

Maintained by Nicola Worthington.

=head2 Unix

The Unix module is intended to provide a "best guess" failover result to the
main Sys::Filesystem module if no suitable platform specific module can be
found, and the platform is not 'MSWin32'.

This module requires additional work to improve it's guestimation abilities.

=head2 Linux

Maintained by Nicola Worthington.

=head2 Darwin

Written and maintained by Christian Renz <crenz@web42.com>.

=head2 Solaris

Initial revision written by Nicola Worthington. Please contact me if you
would like to maintain this.

=head2 AIX

Initial revision written by Nicola Worthington. Please contact me if you
would like to maintain this.

=head2 Win32

Initial revision written by Nicola Worthington. Please contact me if you
would like to maintain this.

This isn't written yet. It's on the top of the (very slow) TODO list.

=head2 OS Identifiers

The following list is taken from L<perlport>. Please refer to the original
source for the most up to date version. This information should help anyone
who wishes to write a helper module for a new platform. Modules should have
the same name as ^O in title caps. Thus 'openbsd' becomes 'Openbsd.pm'.

=head1 TODO

Add support for Windows, FreeBSD, HP-UX and Tru64. Please contact me
if you would like to provide code for these operating systems.

=head1 SEE ALSO

L<perlport>, L<Solaris::DeviceTree>, L<Win32::DriveInfo>

=head1 VERSION

$Id: Filesystem.pm,v 1.18 2005/12/29 18:02:09 nicolaw Exp $

=head1 AUTHOR

Nicola Worthington <nicolaw@cpan.org>

L<http://perlgirl.org.uk>

=head1 ACKNOWLEDGEMENTS

Christian Renz <crenz@web42.com> is the maintainer
of L<Sys::Filesystem::Darwin>.

Brad Greenlee <brad@footle.org> for suggesting and patching for the
filesystem(device => "string") method functionality.

L<http://publib.boulder.ibm.com/infocenter/pseries/index.jsp?topic=/com.ibm.aix.doc/files/aixfiles/filesystems.htm>

L<http://www.unixguide.net/unixguide.shtml>

=head1 COPYRIGHT

(c) Nicola Worthington 2004,2005. This program is free software; you can
redistribute it and/or modify it under the GNU GPL.

See the file COPYING in this distribution, or
L<http://www.gnu.org/licenses/gpl.txt>

=cut



###############################################################################
# End

__DATA__

__END__
 


###############################################################################
# CVS changelog

$Log: Filesystem.pm,v $
Revision 1.18  2005/12/29 18:02:09  nicolaw
*** empty log message ***

Revision 1.17  2005/12/08 17:30:29  nicolaw
*** empty log message ***

Revision 1.16  2005/12/08 15:44:11  nicolaw
Modified POD

Revision 1.15  2005/12/02 16:06:51  nicolaw
Updated for revision number and email address

Revision 1.14  2005/01/30 18:10:41  nicolaw
Added some new filesystem property aliases and reference to AIX helper module

Revision 1.13  2005/01/26 14:25:45  nicolaw
Added extra documentation and the device option for the filesystems
method.

Revision 1.12  2005/01/13 23:37:07  nicolaw
Updated POD.

Revision 1.11  2004/10/06 16:24:58  nicolaw
*** empty log message ***

Revision 1.10  2004/10/06 15:25:00  nicolaw
Fix from Win32 to MSWin32

Revision 1.9  2004/10/05 14:12:38  nicolaw
POD whitespace fix

Revision 1.8  2004/09/30 14:03:43  nicolaw
Added the regular_filesystems() method

Revision 1.7  2004/09/30 13:12:00  nicolaw
Added a DESTROY stub so that AUTO_LOAD doesn't catch it and complain that
it doesn't have a filename to play with

Revision 1.6  2004/09/29 12:01:23  nicolaw
Added aliases and condition of Unix module not if Win32

Revision 1.5  2004/09/29 10:43:12  nicolaw
Added POD

Revision 1.4  2004/09/28 16:35:31  nicolaw
*** empty log message ***

Revision 1.3  2004/09/28 16:01:22  nicolaw
*** empty log message ***

Revision 1.2  2004/09/28 14:30:18  nicolaw
*** empty log message ***

Revision 1.1  2004/09/28 13:53:20  nicolaw
*** empty log message ***



