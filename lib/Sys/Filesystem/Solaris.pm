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
$VERSION = sprintf('%d.%02d', q$Revision: 1.6 $ =~ /(\d+)/g);



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
	my @fstab_keys = qw(device device_to_fsck mount_point fs_vfstype fs_freq fs_passno fs_mntops);
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
			$self->{$vals[2]}->{special} = 1 if grep(/^$vals[3]$/,qw(swap proc tmpfs nfs));
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



__END__

###############################################################################
# CVS changelog

$Log: Solaris.pm,v $
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


