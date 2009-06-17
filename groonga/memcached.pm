package groonga::memcached;

use base qw(groonga);

sub get
{
	my $self = shift || return;
	my $key  = shift || return;

	unless ($self->{'connect'}) {
		return;
	}

	&groonga::send($self, '(<cache> : ?).value');
	&groonga::recv($self);

	&groonga::send($self, $key);
	my $recv = &groonga::recv($self);

	$recv =~ s/^"|"$//g;
	return $recv;
}

sub set
{
	my $self  = shift || return;
	my $key   = shift || return;
	my $value = shift || return;

	unless ($self->{'connect'}) {
		return;
	}

	&groonga::send($self, '(<cache> ::new ? :value ?)');
	&groonga::recv($self);

	&groonga::send($self, $key);
	&groonga::recv($self);

	&groonga::send($self, $value);
	&groonga::recv($self);

	return;
}

sub replace
{
	my $self  = shift || return;
	my $key   = shift || return;
	my $value = shift || return;

	unless ($self->{'connect'}) {
		return;
	}

	&groonga::send($self, '((<cache> : ?) :value ?)');
	&groonga::recv($self);

	&groonga::send($self, $key);
	&groonga::recv($self);

	&groonga::send($self, $value);
	&groonga::recv($self);

	return;
}

sub add
{
	my $self  = shift || return;
	my $key   = shift || return;
	my $value = shift || return;

	unless ($self->{'connect'}) {
		return;
	}

	&groonga::send($self, '(or (<cache> : ?) (<cache> ::new ? :value ?))');
	&groonga::recv($self);

	&groonga::send($self, $key);
	&groonga::recv($self);

	&groonga::send($self, $key);
	&groonga::recv($self);

	&groonga::send($self, $value);
	&groonga::recv($self);

	return;
}

sub delete
{
	my $self  = shift || return;
	my $key   = shift || return;

	unless ($self->{'connect'}) {
		return;
	}

	&groonga::send($self, '(<cache> ::del ?)');
	&groonga::recv($self);

	&groonga::send($self, $key);
	&groonga::recv($self);

	return;
}

1;
