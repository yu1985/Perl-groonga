#!/usr/bin/perl

package groonga;

use Socket;

sub new
{
	my $class = shift || 'groonga';
	my $self  = {};

	&init($self);

	return(bless($self, $class));
}

sub init
{
	my $self = shift || {};

	$self->{'send_header'} = "\xc7" . "\x00" x 23;

	$self->{'header_length'} = {
		'proto'  => 1,
		'qtype'  => 1,
		'keylen' => 2,
		'level'  => 1,
		'flags'  => 1,
		'status' => 2,
		'size'   => 4,
		'opaque' => 4,
		'cas'    => 8,
	};

	$self->{'header_offset'} = {
		'proto'  => 0,
		'qtype'  => 1,
		'keylen' => 2,
		'level'  => 4,
		'flags'  => 5,
		'status' => 6,
		'size'   => 8,
		'opaque' => 12,
		'cas'    => 16,
	};

	$self->{'qtype'} = {
		'GET'        => "\x00",
		'SET'        => "\x01",
		'ADD'        => "\x02",
		'REPLACE'    => "\x03",
		'DELETE'     => "\x04",
		'INCREMENT'  => "\x05",
		'DECREMENT'  => "\x06",
		'QUIT'       => "\x07",
		'FLUSH'      => "\x08",
		'GETQ'       => "\x09",
		'NOOP'       => "\x0A",
		'VERSION'    => "\x0B",
		'GETK'       => "\x0C",
		'GETKQ'      => "\x0D",
		'APPEND'     => "\x0E",
		'PREPEND'    => "\x0F",
		'STAT'       => "\x10",
		'SETQ'       => "\x11",
		'ADDQ'       => "\x12",
		'REPLACEQ'   => "\x13",
		'DELETEQ'    => "\x14",
		'INCREMENTQ' => "\x15",
		'DECREMENTQ' => "\x16",
		'QUITQ'      => "\x17",
		'FLUSHQ'     => "\x18",
		'APPENDQ'    => "\x19",
		'PREPENDQ'   => "\x1A"
	}
}

sub connect
{
	my $self = shift || return;;

	$self->{'server'} = shift || 'localhost';
	$self->{'port'}   = shift || '10041';

	unless ($self->{'server'} && $self->{'port'}) {
		&server($self);
	}

	unless ($self->{'address'} = inet_aton($self->{'server'})) {
		return;
	}

	unless ($self->{'socketaddr'} = pack_sockaddr_in($self->{'port'}, $self->{'address'})) {
		return;
	}

	unless (socket($self->{'socket'}, PF_INET, SOCK_STREAM, 0)) {
		return;
	}

	my $timeout = 30;
	my $flag = '';

	local($SIG{'ALRM'} = sub { $flag = 'timeout(1)'; die; });

	eval {
		alarm($timeout);
		unless (connect($self->{'socket'}, $self->{'socketaddr'})) {
			$flag = "can't access";
		}
		alarm(0);
	};

	if ($flag || $@ || $!) {
		close($self->{'socket'});
		return;
	}
}

sub header_set
{
	(@_ == 4) or return;

	substr($_[1],
	       $_[0]->{'header_offset'}->{$_[2]},
	       $_[0]->{'header_length'}->{$_[2]}) = $_[3];
}

sub header_get
{
	(@_ == 3) or return;

	return substr($_[1],
	              $_[0]->{'header_offset'}->{$_[2]},
	              $_[0]->{'header_length'}->{$_[2]});
}

sub send
{
	my $self = shift || return;
	my $body = shift || return;

	my $header = $self->{'send_header'};

	&header_set($self, $header, 'qtype', "\x00");

	my $keylen = pack('n', length($body));
	&header_set($self, $header, 'keylen', $keylen);

	my $size = pack('N', length($body));
	&header_set($self, $header, 'size', $size);

	my $buffer = $header . $body;
	syswrite($self->{'socket'}, $buffer, length($buffer));
}

sub recv
{
	my $self = shift || return;;

	my $nLen = sysread($self->{'socket'}, my $buffer, 4096);
	($nLen <= 0) and return;

	$size = unpack('N', &header_get($self, $buffer, 'size'));

	return(substr($buffer, 24, $size));
}

sub exit
{
	my $self = shift || return;;

	close($self->{'socket'});
}

1;
