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
$VERSION = sprintf('%d.%02d', q$Revision: 1.5 $ =~ /(\d+)/g);



##############################################################################
# Public methods

sub new {
        # Check we're being called correctly with a class name
        ref(my $class = shift) && croak 'Class name required';
        my %args = @_;
        my $self = { };

	# Defaults
	$args{fstab} ||= '/etc/vfstab';
	#$args{mtab} ||= '/etc/mtab';
	#$args{xtab} ||= '/etc/lib/nfs/xtab';

	# Default fstab and mtab layout
	my @keys = qw(device device_to_fsck mount_point fs_vfstype fs_freq fs_passno fs_mntops);

	# Read the fstab
	my $fstab = new FileHandle;
	if ($fstab->open($args{fstab})) {
		while (<$fstab>) {
			next if /^\s*#/;
			next if /^\s*$/;
			my @vals = split(/\s+/, $_);
			for (my $i = 0; $i < @keys; $i++) {
				$vals[$i] = '' unless defined $vals[$i];
			}
#			$self->{$vals[2]}->{unmounted} = 1;
			$self->{$vals[2]}->{special} = 1 if grep(/^$vals[3]$/,qw(swap proc));
			for (my $i = 0; $i < @keys; $i++) {
				$self->{$vals[2]}->{$keys[$i]} = $vals[$i];
			}
		}
		$fstab->close;
	} else {
		croak "Unable to open fstab file ($args{fstab})\n";
	}

##device         device          mount           FS      fsck    mount   mount
##to mount       to fsck         point           type    pass    at boot options
##
#fd      -       /dev/fd fd      -       no      -
#/proc   -       /proc   proc    -       no      -
#/dev/dsk/c0t0d0s3       -       -       swap    -       no      -
#/dev/dsk/c0t0d0s0       /dev/rdsk/c0t0d0s0      /       ufs     1       no      -
#/dev/dsk/c0t0d0s6       /dev/rdsk/c0t0d0s6      /usr    ufs     1       no      logging


#	# Read the mtab
#	my $mtab = new FileHandle;
#	if ($mtab->open($args{mtab})) {
#		while (<$mtab>) {
#			next if /^\s*#/;
#			my @vals = split(/\s+/, $_);
#			delete $self->{$vals[1]}->{unmounted} if exists $self->{$vals[1]}->{unmounted};
#			$self->{$vals[1]}->{mounted} = 1;
#			$self->{$vals[1]}->{mount_point} = $vals[1];
#			$self->{$vals[1]}->{device} = $vals[0];
#			for (my $i = 0; $i < @keys; $i++) {
#				$self->{$vals[1]}->{$keys[$i]} = $vals[$i];
#			}
#		}
#		$mtab->close;
#	} else {
#		croak "Unable to open mtab file ($args{mtab})\n";
#	}

        # Bless and return
        bless($self,$class);
        return $self;
}

1;



__END__

###############################################################################
# CVS changelog

$Log: Solaris.pm,v $
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


