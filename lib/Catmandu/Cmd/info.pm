package Catmandu::Cmd::info;

use Catmandu::Sane;

our $VERSION = '0.9505';

use parent 'Catmandu::Cmd';
use Catmandu::Importer::Modules;
use Catmandu::Store::Hash;
use Catmandu::Util qw(pod_section);
use namespace::clean;

sub command_opt_spec {
    (
        ["all"       , "show all module on this server"],
        ["exporters" , "show all catmandu exporters"],
        ["importers" , "show all catmandu importers"],
        ["fixes"     , "show all catmandu fixes"],
        ["stores"    , "show all catmandu stores"],
        ["namespace=s", "search by namespace"],
        ["max_depth=i", "maximum depth to search for modules"],
        ["inc=s@", 'override included directories (defaults to @INC)', {default => [@INC]}],
        ["verbose|v", ""]
    );
}

sub add_about {
    my $item = shift;
    my $name = pod_section($item->{file}, 'NAME');
    $name =~ s/[^-]+(\s*-?\s*)?//;
    $name =~ s/\n/ /mg;
    chomp $name;
    $item->{about} = $name; 
    $item;
}

sub command {
    my ($self, $opts, $args) = @_;
    my $verbose = $opts->verbose;

    if (defined $opts->{namespace}) {
    }
    elsif ($opts->{all}) {
        delete $opts->{all};
    }
    elsif ($opts->{exporters}) {
        delete $opts->{exporters};
        $opts->{namespace} = 'Catmandu::Exporter';
    }
    elsif ($opts->{importers}) {
        delete $opts->{importers};
        $opts->{namespace} = 'Catmandu::Importer';
    }
    elsif ($opts->{fixes}) {
        delete $opts->{fixes};
        $opts->{namespace} = 'Catmandu::Fix';
    }
    elsif ($opts->{stores}) {
        delete $opts->{stores};
        $opts->{namespace} = 'Catmandu::Store';
    }
    else {
        $opts->{namespace} = [qw(Catmandu::Exporter Catmandu::Fix Catmandu::Importer Catmandu::Store)];
    }

    my $from_opts = { fix => [sub{add_about(@_)}] };
    
    for my $key (qw(inc namespace max_depth)) {
        $from_opts->{$key} = $opts->$key if defined $opts->$key;
    }

    my $from = Catmandu::Importer::Modules->new($from_opts);

    my $into_args = [];
    my $into_opts = {};
    my $into;

    if (@$args && $args->[0] eq 'to') {
        # TODO: don't duplicate argument parsing
        for (my $i = 1; $i < @$args; $i++) {
            my $arg = $args->[$i];
            if ($arg =~ s/^-+//) {
                $arg =~ s/-/_/g;
                if ($arg eq 'fix') {
                    push @{$into_opts->{$arg} ||= []}, $args->[++$i];
                } else {
                    $into_opts->{$arg} = $args->[++$i];
                }
            } else {
                push @$into_args, $arg;
            }
        }
    }

    if (@$into_args || %$into_opts) {
        $into = Catmandu->exporter($into_args->[0], $into_opts);
        $into->add_many($from);
        $into->commit;
    } else {
        my $cols = [qw(name version about)];
        push @$cols, 'file' if $opts->verbose;
        $from->format(cols => $cols);
    }
}

1;

__END__

=pod

=head1 NAME

Catmandu::Cmd::info - list installed Catmandu modules

=head1 DESCRIPTION

This L<Catmandu::Cmd> uses L<Catmandu::Importer::Modules> to list all modules.

=head1 EXAMPLES

  catmandu info --exporters
  catmandu info --importers
  catmandu info --fixes
  catmandu info --stores
  catmandu info --namespace=Catmandu
  catmandu info --all
  
=cut
