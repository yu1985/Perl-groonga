#!/usr/bin/perl

use groonga;

$g = new groonga;
$g->connect('127.0.0.1', 10041);

print '> ';
while (<STDIN>) {
	chomp($buf = $_);

	if ($buf =~ /exit|quit/) {
		$g->exit;
		last;
	}

	unless ($buf) {
		next;
	}

	$g->send($buf);
	print $g->recv(), "\n";

	print '> ';
}
