use lib qw(./lib ../lib);
use Test::More qw(no_plan);
use Sys::Filesystem;

use constant DEBUG => $ENV{DEBUG} ? 1 : 0;

chdir 't' if -d 't';

{
	ok(my $fs = new Sys::Filesystem, 'Create new Sys::Filesystem object');

	ok(my @mounted_filesystems   = $fs->mounted_filesystems, 'Get list of mounted filesystems');
	ok(my @unmounted_filesystems = $fs->unmounted_filesystems, 'Get list of unmounted filesystems');
	ok(my @special_filesystems   = $fs->special_filesystems, 'Get list of special filesystems');
	ok(my @regular_filesystems   = $fs->regular_filesystems, 'Get list of regular filesystems');
	ok(my @filesystems           = $fs->filesystems, 'Get list of all filesystems');

	for my $filesystem (@filesystems) {
		ok(my $device  = $fs->device($filesystem), "Get device for $filesystem");
		ok(my $options = $fs->options($filesystem), "Get options for $filesystem");
		ok(my $type    = $fs->type($filesystem), "Get type for $filesystem");
		ok(my $volume  = $fs->volume($filesystem) || 1, "Get volume type for $filesystem");
		ok(my $label   = $fs->label($filesystem) || 1, "Get label for $filesystem");
	}

	{
		my $filesystem = $filesystems[0];
		my $device = $fs->device($filesystems[0]);
	
		ok(my $foo_filesystem = Sys::Filesystem::filesystems(device => $device),
				, "Get filesystem attached to $device");
	}
}

