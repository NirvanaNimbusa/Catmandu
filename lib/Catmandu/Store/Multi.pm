package Catmandu::Store::Multi;

use Catmandu::Sane;

our $VERSION = '0.9505';

use Catmandu::Util qw(:is);
use Catmandu::Store::Multi::Bag;
use Moo;
use namespace::clean;

with 'Catmandu::Store';

has stores => (
    is => 'ro',
    default => sub { [] },
    coerce => sub {
        my $stores = $_[0];
        return [ map {
            if (is_string($_)) {
                Catmandu->store($_);
            } else {
                $_;
            }
        } @$stores ];
    },
);

1;

__END__

=pod

=head1 NAME

Catmandu::Store::Multi - A store that adds your data to multiple stores

=cut
