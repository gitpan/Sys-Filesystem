package Sys::Filesystem;

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
$VERSION = sprintf('%d.%02d', q$Revision: 1.4 $ =~ /(\d+)/g);



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
	for (($self->{osname},'Uinx','Dummy')) {
		$self->{filesystems} ||= eval sprintf('use %s::%s; %s::%s->new(%%args);',
						__PACKAGE__, _caps($_),
						__PACKAGE__, _caps($_)
					);
		cluck($@) if $@;
	}

	# Information
	$self->{software} = {
			Caller => [ caller ],
			Package => __PACKAGE__,
			Version => $VERSION,
			Author => '$Author: nicolaw $',
			Revision => '$Revision: 1.4 $',
			Id => '$Id: Filesystem.pm,v 1.4 2004/09/28 16:35:31 nicolaw Exp $',
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

	my @filesystems = ();

	# Return list of all filesystems
	unless (keys %{$params}) {
		@filesystems = sort(keys(%{$self->{filesystems}}));

	# Return list of specific filesystems
	} else {
		for my $fs (sort(keys(%{$self->{filesystems}}))) {
			for my $requirement (keys %{$params}) {
				if (exists $self->{filesystems}->{$fs}->{$requirement}) {
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
	return $self->filesystems(mount_point => 1);
}

sub unmounted_filesystems {
	my $self = shift;
	return $self->filesystems(unmounted => 1);
}

sub special_filesystems {
	my $self = shift;
	return $self->filesystems(special => 1);
}

sub AUTOLOAD {
	my $self = shift;
	my $type = ref($self) || croak "$self is not an object";

	my $fs = shift;
	croak "No filesystem passed where expected" unless $fs;

	(my $name = $AUTOLOAD) =~ s/.*://;

	unless (exists $self->{filesystems}->{$fs}) {
		croak "No such filesystem";
	} else {
		if (exists $self->{filesystems}->{$fs}->{$name}) {
			return $self->{filesystems}->{$fs}->{$name};
		} else {
			return undef;
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

=head1 VERSION

$Revision: 1.4 $

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=over 4

=over 4

=item new()

=item filesystems()

=item mounted_filesystems()

=item unmounted_filesystems()

=item special_filesystems()

=back

=back

=head1 ACKNOWLEDGEMENTS

http://www.unixguide.net/unixguide.shtml

=head1 SEE ALSO

Solaris::DeviceTree Win32::DriveInfo

=head1 TODO

Add support for Windows, AIX, FreeBSD, HP-UX, Linux, Solaris and Tru64.

=head1 BUGS

Probably

=head1 AUTHOR

Nicola Worthington <nicolaworthington@msn.com>

$Author: nicolaw $

=cut



###############################################################################
# End

__DATA__

__END__



###############################################################################
# CVS changelog

$Log: Filesystem.pm,v $
Revision 1.4  2004/09/28 16:35:31  nicolaw
*** empty log message ***

Revision 1.3  2004/09/28 16:01:22  nicolaw
*** empty log message ***

Revision 1.2  2004/09/28 14:30:18  nicolaw
*** empty log message ***

Revision 1.1  2004/09/28 13:53:20  nicolaw
*** empty log message ***



