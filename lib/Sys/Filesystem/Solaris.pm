package Sys::Filesystem::Solaris;

###############################################################################
# Modules

use strict;
use warnings;
use FileHandle;
use Carp qw(croak);



###############################################################################
# Globals and constants

use vars qw($VERSION);
$VERSION = sprintf('%d.%02d', q$Revision: 1.12 $ =~ /(\d+)/g);



##############################################################################
# Public methods

sub new {
	# Check we're being called correctly with a class name
	ref(my $class = shift) && croak 'Class name required';
	my %args = @_;
	my $self = { };

	# Defaults
	$args{fstab} ||= '/etc/vfstab';
	$args{mtab} ||= '/etc/mnttab';
	#$args{xtab} ||= '/etc/lib/nfs/xtab';

	# Default fstab and mtab layout
	my @fstab_keys = qw(device device_to_fsck mount_point fs_vfstype fs_freq mount_at_boot fs_mntops);
	my @mtab_keys = qw(device mount_point fs_vfstype fs_mntops time);

	# Read the fstab
	my $fstab = new FileHandle;
	if ($fstab->open($args{fstab})) {
		while (<$fstab>) {
			next if /^\s*#/;
			next if /^\s*$/;
			my @vals = split(/\s+/, $_);
			for (my $i = 0; $i < @fstab_keys; $i++) {
				$vals[$i] = '' unless defined $vals[$i];
			}
			$self->{$vals[2]}->{unmounted} = 1;
			$self->{$vals[2]}->{special} = 1 if grep(/^$vals[3]$/,qw(swap proc tmpfs nfs mntfs autofs));
			for (my $i = 0; $i < @fstab_keys; $i++) {
				$self->{$vals[2]}->{$fstab_keys[$i]} = $vals[$i];
			}
		}
		$fstab->close;
	} else {
		croak "Unable to open fstab file ($args{fstab})\n";
	}

	# Read the mtab
	my $mtab = new FileHandle;
	if ($mtab->open($args{mtab})) {
		while (<$mtab>) {
			next if /^\s*#/;
			next if /^\s*$/;
			my @vals = split(/\s+/, $_);
			delete $self->{$vals[1]}->{unmounted} if exists $self->{$vals[1]}->{unmounted};
			$self->{$vals[1]}->{mounted} = 1;
			$self->{$vals[1]}->{special} = 1 if grep(/^$vals[2]$/,qw(swap proc tmpfs nfs mntfs autofs));
			for (my $i = 0; $i < @mtab_keys; $i++) {
				$self->{$vals[1]}->{$mtab_keys[$i]} = $vals[$i];
			}
		}
		$mtab->close;
	} else {
		croak "Unable to open mtab file ($args{mtab})\n";
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

Sys::Filesystem::Solaris - Return Solaris filesystem information to Sys::Filesystem

=head1 SYNOPSIS

See L<Sys::Filesystem>.

=head1 METHODS

The following is a list of filesystem properties which may
be queried as methods through the parent L<Sys::Filesystem> object.

=over 4

=item device

Resource name.

=item device_to_fsck

The raw device to fsck.

=item mount_point

The default mount directory.

=item fs_vfstype

The  name of the file system type.

=item fs_freq

The number used by fsck to decide whether to check the file system
automatically.

=item mount_at_boot

Whether the file system should be mounted automatically by mountall.

=item fs_mntops

The file system mount options.

=item time

The time at which the file system was mounted.

=back

=head1 SEE ALSO

L<Solaris::DeviceTree>

=head1 VERSION

$Id: Solaris.pm,v 1.12 2005/12/08 15:44:12 nicolaw Exp $

=head1 AUTHOR

Nicola Worthington <nicolaworthington@msn.com>

http://perlgirl.org.uk

=head1 COPYRIGHT

(c) Nicola Worthington 2004, 2005. This program is free software; you can
redistribute it and/or modify it under the GNU GPL.

See the file COPYING in this distribution, or
http://www.gnu.org/licenses/gpl.txt 

=cut

