package Sys::Filesystem::Linux;

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
	$args{fstab} ||= '/etc/fstab';
	$args{mtab} ||= '/etc/mtab';
	$args{xtab} ||= '/etc/lib/nfs/xtab';

	# Default fstab and mtab layout
	my @keys = qw(fs_spec fs_file fs_vfstype fs_mntops fs_freq fs_passno);

	# Read the fstab
	my $fstab = new FileHandle;
	if ($fstab->open($args{fstab})) {
		while (<$fstab>) {
			next if /^\s*#/;
			my @vals = split(/\s+/, $_);
			$self->{$vals[1]}->{mount_point} = $vals[1];
			$self->{$vals[1]}->{device} = $vals[0];
			$self->{$vals[1]}->{unmounted} = 1;
			$self->{$vals[1]}->{special} = 1 if grep(/^$vals[2]$/,qw(swap proc devpts tmpfs));
			for (my $i = 0; $i < @keys; $i++) {
				$self->{$vals[1]}->{$keys[$i]} = $vals[$i];
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
			next if /^\s*\#/;
			my @vals = split(/\s+/, $_);
			delete $self->{$vals[1]}->{unmounted} if exists $self->{$vals[1]}->{unmounted};
			$self->{$vals[1]}->{mounted} = 1;
			$self->{$vals[1]}->{mount_point} = $vals[1];
			$self->{$vals[1]}->{device} = $vals[0];
			$self->{$vals[1]}->{special} = 1 if grep(/^$vals[2]$/,qw(swap proc devpts tmpfs));
			for (my $i = 0; $i < @keys; $i++) {
				$self->{$vals[1]}->{$keys[$i]} = $vals[$i];
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

Sys::Filesystem::Linux - Return Linux filesystem information to Sys::Filesystem

=head1 VERSION

$Revision: 1.10 $

=head1 FILESYSTEM PROPERTIES

The following is a list of filesystem properties which may
be queried as methods through the parent Sys::Filesystem object.

=over 4

=item fs_spec

Dscribes the block special device or remote filesystem to be mounted.

For  ordinary  mounts  it  will hold (a link to) a block special device
node (as created by mknod(8))  for  the  device  to  be  mounted,  like
/dev/cdrom’   or   ‘/dev/sdb7’.    For   NFS   mounts  one  will  have
<host>:<dir>, e.g., ‘knuth.aeb.nl:/’.  For procfs, use ‘proc’.

Instead of giving the device explicitly, one may indicate the (ext2  or
xfs)  filesystem that is to be mounted by its UUID or volume label (cf.
e2label(8) or  xfs_admin(8)),  writing  LABEL=<label>  or  UUID=<uuid>,
e.g.,   ‘LABEL=Boot’   or  ‘UUID=3e6be9de-8139-11d1-9106-a43f08d823a6’.
This will make the system more robust: adding or removing a  SCSI  disk
changes the disk device name but not the filesystem volume label.


=item fs_file

Describes the mount point for the filesystem. For swap partitions,
this field should be specified as‘none. If the name of the mount
point contains spaces these can be escaped as‘\040.

=item fs_vfstype

Dscribes the type  of  the  filesystem.
Linux  supports  lots  of filesystem types, such as adfs, affs, autofs,
coda, coherent, cramfs, devpts, efs, ext2, ext3,  hfs,  hpfs,  iso9660,
jfs,  minix,  msdos,  ncpfs,  nfs,  ntfs,  proc, qnx4, reiserfs, romfs,
smbfs, sysv, tmpfs, udf, ufs, umsdos, vfat, xenix,  xfs,  and  possibly
others.  For more details, see mount(8).  For the filesystems currently
supported by the running kernel, see /proc/filesystems.  An entry  swap
denotes a file or partition to be used for swapping, cf. swapon(8).  An
entry ignore causes the line to be ignored.  This  is  useful  to  show
disk partitions which are currently unused.

=item fs_mntops

Describes the mount options associated with the filesystem.

It is formatted as a comma separated list of options.  It  contains  at
least  the type of mount plus any additional options appropriate to the
filesystem type.  For documentation on the available options  for  non-
nfs  file systems, see mount(8).  For documentation on all nfs-specific
options have a look at nfs(5).  Common for all types of file system are
the options ‘‘noauto’’ (do not mount when 'mount -a' is given, e.g., at
boot time), ‘‘user’’ (allow a user  to  mount),  and  ‘‘owner’’  (allow
device  owner to mount), and ‘‘_netdev’’ (device requires network to be
available).  The ‘‘owner’’ and ‘‘_netdev’’ options are  Linux-specific.
For more details, see mount(8).

=item fs_freq

Used  for  these filesystems by the
dump(8) command to determine which filesystems need to be  dumped.   If
the  fifth  field  is not present, a value of zero is returned and dump
will assume that the filesystem does not need to be dumped.

=item fs_passno

Used by the fsck(8) program to  determine the order in which filesystem
checks are done at reboot time.  The
root filesystem should be specified with a fs_passno of  1,  and  other
filesystems  should  have a fs_passno of 2.  Filesystems within a drive
will be checked sequentially, but filesystems on different drives  will
be  checked  at  the  same time to utilize parallelism available in the
hardware.  If the sixth field is not present or zero, a value  of  zero
is  returned  and fsck will assume that the filesystem does not need to
be checked.

=back

=head1 SEE ALSO

Sys::Filesystem Sys::Filesystem::Unix fstab(5)

=head1 BUGS

Probably. Please email me a patch if you find something ghastly.

=head1 AUTHOR

Nicola Worthington <nicolaworthington@msn.com>

http://www.nicolaworthington.com/

$Author: nicolaw $

=head1 CHANGELOG

    $Log: Linux.pm,v $
    Revision 1.10  2004/12/01 11:16:38  nicolaw
    *** empty log message ***

    Revision 1.9  2004/10/06 15:34:58  nicolaw
    *** empty log message ***

    Revision 1.8  2004/10/06 15:33:49  nicolaw
    Added POD to document accessor methods for filesystem properties

    Revision 1.7  2004/10/05 14:23:38  nicolaw
    tempfs (tmpfs) typo
    
    Revision 1.6  2004/10/05 14:12:49  nicolaw
    Fixed detection of some special filesystem types
    
    Revision 1.5  2004/09/28 16:45:11  nicolaw
    *** empty log message ***
    
    Revision 1.4  2004/09/28 16:35:32  nicolaw
    *** empty log message ***
    
    Revision 1.3  2004/09/28 16:25:34  nicolaw
    *** empty log message ***


