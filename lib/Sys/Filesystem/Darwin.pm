package Sys::Filesystem::Darwin;

use strict;
use warnings;
use Carp qw(croak);

use vars qw($VERSION);
$VERSION = "0.1";

sub new {
	my $class = shift;

	my %args = @_;
	my $self = { };

	# Defaults
	$args{disktool} ||= '/usr/sbin/disktool';

	my @fslist = `$args{disktool} -l`;
	croak "Cannot execute $args{disktool}: $!\n" unless ($! == 0);

	foreach (@fslist) {
		# For mounted FTP servers, fsType and volName are empty on Mac OS X 10.3
		# However, Mountpoint should not be empty.
		next unless /Disk Appeared \('([^']+)',Mountpoint = '([^']+)', fsType = '([^']*)', volName = '([^']*)'\)/;
		my ($device, $mount_point, $fstype, $name) = ($1, $2, $3, $4);
	   
		$self->{$mount_point}->{mounted} = 1;
		$self->{$mount_point}->{special} = 0;
		$self->{$mount_point}->{device} = $device;
		$self->{$mount_point}->{mount_point} = $mount_point;
		$self->{$mount_point}->{fs_vfstype} = $fstype;
		$self->{$mount_point}->{label} = $name;
	}

	# Bless and return
	bless($self,$class);
	return $self;
}

1;

=head1 NAME

Sys::Filesystem::Darwin - Return Darwin (Mac OS X) filesystem information to Sys::Filesystem

=head1 DESCRIPTION

The filesystem information is taken from diskutil, the system utility supplied on Mac OS X.

=head1 VERSION

$Revision: 1.2 $

=head1 FILESYSTEM PROPERTIES

The following is a list of filesystem properties which may
be queried as methods through the parent Sys::Filesystem object.

The property 'label' is also set, but cannot be queried by Sys::Filesystem yet.

=over 4

=item mount_point

The mount point (usually either '/' or '/Volumes/...').

=item device

The mounted device

=item format

Describes the type of the filesystem. So far I encountered the following types:

=over 4

=item hfs

The standard Mac OS X HFS(+) filesystem. Disk images (.dmg) and 
Mac Software DVDs normally also use the HFS(+) format.

=item msdos

DOS image files (e.g. floppy disk images)

=item cd9660

CD-ROM image files or real CD-ROMs

=item cddafs

Audio CDs

=item udf

UDF filesystem (e.g. DVDs)

=back

=item (empty)

For mounted FTP servers, disktool returns an empty filesystem type (ie, '').

=back

=head1 SEE ALSO

Sys::Filesystem diskutil

=head1 BUGS

Doesn't take /etc/fstab or /etc/xtab into account right now, since they are 
normally not used. Contact me if you need this.

=head1 AUTHOR

Christian Renz <crenz@web42.com>

=head1 CHANGES

$Log: Darwin.pm,v $
Revision 1.2  2005/12/02 16:05:04  nicolaw
Fixed tabulation, ^M's and skipping of empty lines in footab files

Revision 1.1  2005/01/13 23:37:28  nicolaw
Initial revision.


