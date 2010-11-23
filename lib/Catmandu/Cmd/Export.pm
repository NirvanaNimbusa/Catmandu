package Catmandu::Cmd::Export;

use 5.010;
use Moose;
use Plack::Util;
use Catmandu;
use lib Catmandu->lib;

with 'Catmandu::Command';

has exporter => (
    traits => ['Getopt'],
    is => 'rw',
    isa => 'Str',
    lazy => 1,
    cmd_aliases => 'O',
    default => 'JSON',
    documentation => "The Catmandu::Exporter class to use. Defaults to JSON.",
);

has exporter_arg => (
    traits => ['Getopt'],
    is => 'rw',
    isa => 'HashRef',
    lazy => 1,
    cmd_aliases => 'o',
    default => sub { +{} },
    documentation => "Pass params to the exporter constructor. " .
                     "The file param can also be the 1st non-option argument.",
);

has store => (
    traits => ['Getopt'],
    is => 'rw',
    isa => 'Str',
    lazy => 1,
    cmd_aliases => 'S',
    default => 'Simple',
    documentation => "The Catmandu::Store class to use. Defaults to Simple.",
);

has store_arg => (
    traits => ['Getopt'],
    is => 'rw',
    isa => 'HashRef',
    lazy => 1,
    cmd_aliases => 's',
    default => sub { +{} },
    documentation => "Pass params to the store constructor.",
);

has load => (
    traits => ['Getopt'],
    is => 'rw',
    isa => 'Str',
    cmd_aliases => 'l',
    documentation => "The id of a single object to load and export.",
);

sub _usage_format {
    "usage: %c %o [file]";
}

sub BUILD {
    my $self = shift;

    $self->exporter =~ /::/ or $self->exporter("Catmandu::Exporter::" . $self->exporter);
    $self->store =~ /::/ or $self->store("Catmandu::Store::" . $self->store);

    if (my $file = shift @{$self->extra_argv}) {
        $self->exporter_arg->{file} = $file;
    }
}

sub run {
    my $self = shift;

    Plack::Util::load_class($self->exporter);
    Plack::Util::load_class($self->store);
    my $exporter = $self->exporter->new($self->exporter_arg);
    my $store = $self->store->new($self->store_arg);

    if ($self->load) {
        $exporter->dump($store->load_strict($self->load));
    } else {
        $exporter->dump($store);
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;
__PACKAGE__;
