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
$VERSION = sprintf('%d.%02d', q$Revision: 1.10 $ =~ /(\d+)/g);



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

=head1 VERSION

$Revision: 1.10 $

=head1 FILESYSTEM PROPERTIES

The following is a list of filesystem properties which may
be queried as methods through the parent Sys::Filesystem object.

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

Solaris::DeviceTree

=head1 BUGS

Probably. Please email me a patch if you find something ghastly.

=head1 AUTHOR

Nicola Worthington <nicolaworthington@msn.com>

http://www.nicolaworthington.com/

$Author: nicolaw $

=head1 CHANGELOG

    $Log: Solaris.pm,v $
    Revision 1.10  2004/10/06 15:27:37  nicolaw
    Type in POD

    Revision 1.9  2004/10/06 15:24:29  nicolaw
    Added some POD to document filesystem property access methods

    Revision 1.8  2004/09/30 14:13:04  nicolaw
    Copied special fs logic to the mnttab loop also
    
    Revision 1.7  2004/09/30 14:02:15  nicolaw
    Added mntfs and autofs as special filesystems
    
    Revision 1.6  2004/09/30 13:25:07  nicolaw
    Added mnttab support (see man mnttab)
    
    Revision 1.5  2004/09/28 17:01:17  nicolaw
    *** empty log message ***
    
    Revision 1.4  2004/09/28 16:58:51  nicolaw
    *** empty log message ***
    
    Revision 1.3  2004/09/28 16:55:19  nicolaw
    *** empty log message ***
    
    Revision 1.2  2004/09/28 16:52:30  nicolaw
    *** empty log message ***
    
    Revision 1.1  2004/09/28 16:47:11  nicolaw
    *** empty log message ***

