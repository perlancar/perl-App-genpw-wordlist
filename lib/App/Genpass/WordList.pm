package App::Genpass::WordList;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

require App::wordlist;

our %SPEC;

$SPEC{genpass} = {
    v => 1.1,
    summary => 'Generate password with words from WordList::*',
    args => {
        num => {
            schema => ['int*', min=>1],
            default => 1,
            cmdline_aliases => {n=>{}},
        },
        %App::wordlist::arg_wordlists,
    },
    examples => [
    ],
};
sub genpass {

    my %args = @_;

    my $num = $args{num} // 1;
    my $wordlists = $args{wordlists};
    my $min_len;
    if (!$wordlists || !@$wordlists) {
        $wordlists = ['EN::Enable'];
        $min_len = 6;
    }

    my $res = App::wordlist::wordlist(
        wordlists => $wordlists,
        random    => 1,
        num       => 2*$num,
        (min_len   => $min_len) x !!defined($min_len),
    );
    return $res unless $res->[0] == 200;

    my @pass;
    for my $i (1..$num) {
        my $w1 = shift @{$res->[2]};
        my $w2 = shift @{$res->[2]};
        my $num1 = 1000 + int(9000*rand());
        push @pass, $w1 . $num1 . $w2;
    }

    [200, "OK", \@pass];
}

1;
# ABSTRACT:

=head1 SYNOPSIS

See the included script L<genpass-wordlist>.
