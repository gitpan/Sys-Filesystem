use lib qw(./lib ../lib);
use Test::More qw(no_plan);
use Sys::Filesystem;

chdir 't' if -d 't';

ok(my $fs = new Sys::Filesystem, 'Create new Sys::Filesystem object');

ok(my @filesystems = $fs->filesystems, 'Get list of filesystems');
#warn "Filesystems are: @filesystems\n";

for my $filesystem (@filesystems) {
	ok(my $device = $fs->device($filesystem), "Get device for $filesystem");
#	warn "$filesystem is mounted on $device\n";
}

