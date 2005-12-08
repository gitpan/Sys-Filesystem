package Sys::Filesystem::Unix;

###############################################################################
# Modules

use strict;
use warnings;
use FileHandle;
use Carp qw(croak);



###############################################################################
# Globals and constants

use vars qw($VERSION);
$VERSION = sprintf('%d.%02d', q$Revision: 1.4 $ =~ /(\d+)/g);



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
			next if /^\s*$/;

			my @vals = split(/\s+/, $_);
			$self->{$vals[1]}->{mount_point} = $vals[1];
			$self->{$vals[1]}->{device} = $vals[0];
			$self->{$vals[1]}->{unmounted} = 1;
			$self->{$vals[1]}->{special} = 1 if grep(/^$vals[2]$/,qw(swap proc));
			for (my $i = 0; $i < @keys; $i++) {
				$self->{$vals[1]}->{$keys[$i]} = $vals[$i];
			}
		}
		$fstab->close;
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
			$self->{$vals[1]}->{mount_point} = $vals[1];
			$self->{$vals[1]}->{device} = $vals[0];
			for (my $i = 0; $i < @keys; $i++) {
				$self->{$vals[1]}->{$keys[$i]} = $vals[$i];
			}
		}
		$mtab->close;
	}

	# Bless and return
	bless($self,$class);
	return $self;
}

1;



=pod

=head1 NAME

Sys::Filesystem::Unix - Return generic Unix filesystem information to Sys::Filesystem

=head1 SYNOPSIS

See L<Sys::Filesystem>.

=head1 VERSION

$Id: Unix.pm,v 1.4 2005/12/08 15:44:12 nicolaw Exp $

=head1 AUTHOR

Nicola Worthington <nicolaw@cpan.org>

http://perlgirl.org.uk

=head1 COPYRIGHT

(c) Nicola Worthington 2004, 2005. This program is free software; you can
redistribute it and/or modify it under the GNU GPL.

See the file COPYING in this distribution, or
http://www.gnu.org/licenses/gpl.txt 

=cut


