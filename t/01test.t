use lib qw(./lib ../lib);
use Test::More qw(no_plan);
use Sys::Filesystem;

use constant DEBUG => $ENV{DEBUG} ? 1 : 0;

chdir 't' if -d 't';

ok(my $fs = new Sys::Filesystem, 'Create new Sys::Filesystem object');

ok(my @mounted_filesystems = $fs->mounted_filesystems, 'Get list of mounted filesystems');
ok(my @unmounted_filesystems = $fs->unmounted_filesystems, 'Get list of unmounted filesystems');
ok(my @special_filesystems = $fs->special_filesystems, 'Get list of special filesystems');
ok(my @regular_filesystems = $fs->regular_filesystems, 'Get list of regular filesystems');

ok(my @filesystems = $fs->filesystems, 'Get list of filesystems');
DEBUG && warn "Filesystems are: @filesystems\n";

DEBUG && warn "\n\n";
for my $filesystem (@filesystems) {
	ok(my $device = $fs->device($filesystem), "Get device for $filesystem");
	DEBUG && warn "$filesystem -> device=$device\n";

	ok(my $options = $fs->options($filesystem), "Get options for $filesystem");
	DEBUG && warn "$filesystem -> options=$options\n";

	ok(my $type = $fs->type($filesystem), "Get type for $filesystem");
	DEBUG && warn "$filesystem -> type=$type\n";
	DEBUG && warn "\n";
}

