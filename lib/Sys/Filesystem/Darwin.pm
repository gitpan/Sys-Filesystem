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

=head1 SYNOPSIS

See L<Sys::Filesystem>.

=head1 DESCRIPTION

The filesystem information is taken from diskutil, the system utility
supplied on Mac OS X.

=head1 METHODS

The following is a list of filesystem properties which may
be queried as methods through the parent L<Sys::Filesystem> object.

The property 'label' is also set, but cannot be queried by L<Sys::Filesystem>
yet.

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

=head1 BUGS

Doesn't take /etc/fstab or /etc/xtab into account right now, since they are 
normally not used. Contact me if you need this.

=head1 SEE ALSO

L<Sys::Filesystem>, L<diskutil>

=head1 VERSION

$Id: Darwin.pm,v 1.3 2005/12/08 15:44:12 nicolaw Exp $

=head1 AUTHOR

Christian Renz <crenz@web42.com>

=head1 COPYRIGHT

(c) Christian Renz 2004, 2005. This program is free software; you can redistribute
it and/or modify it under the GNU GPL.

See the file COPYING in this distribution, or
http://www.gnu.org/licenses/gpl.txt 

=cut



