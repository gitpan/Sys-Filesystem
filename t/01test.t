use lib qw(./lib ../lib);
use Test::More qw(no_plan);
use Sys::Filesystem;

chdir 't' if -d 't';

ok(my $fs = new Sys::Filesystem, 'Create new Sys::Filesystem object');

ok(my @mounted_filesystems = $fs->mounted_filesystems, 'Get list of mounted filesystems');
ok(my @unmounted_filesystems = $fs->unmounted_filesystems, 'Get list of unmounted filesystems');
ok(my @special_filesystems = $fs->special_filesystems, 'Get list of special filesystems');
ok(my @regular_filesystems = $fs->regular_filesystems, 'Get list of regular filesystems');

ok(my @filesystems = $fs->filesystems, 'Get list of filesystems');
#warn "Filesystems are: @filesystems\n";

#warn "\n\n";
for my $filesystem (@filesystems) {
        ok(my $device = $fs->device($filesystem), "Get device for $filesystem");
#        warn "$filesystem -> device=$device\n";

        ok(my $options = $fs->options($filesystem), "Get options for $filesystem");
#        warn "$filesystem -> options=$options\n";

        ok(my $type = $fs->type($filesystem), "Get type for $filesystem");
#        warn "$filesystem -> type=$type\n";
#	warn "\n";
}

