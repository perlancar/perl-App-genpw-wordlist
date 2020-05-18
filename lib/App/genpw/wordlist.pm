package App::genpw::wordlist;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use App::genpw ();
use App::wordlist ();
use List::Util qw(shuffle);

our %SPEC;

my $default_patterns = [
    '%w %w %w',
    '%w %w %w %w',
    '%w %w %w %w %w',
    '%w %w %w %w %w %w',
    '%w%4d%w',
    '%w%6d%s',
];

my %args = %{$App::genpw::SPEC{genpw}{args}};
delete $args{min_len};
delete $args{max_len};
delete $args{len};

$SPEC{genpw} = {
    v => 1.1,
    summary => 'Generate password with words from WordList::*',
    description => <<'_',

Using password from dictionary words (in this case, from WordList::*) can be
useful for humans when remembering the password. Note that using a string of
random characters is generally better because of the larger space (combination).
Using a password of two random words from a 5000-word wordlist has a space of
only ~25 million while an 8-character of random uppercase letters/lowercase
letters/numbers has a space of 62^8 = ~218 trillion. To increase the space
you'll need to use more words (e.g. 3 to 5 instead of just 2). This is important
if you are using the password for something that can be bruteforced quickly e.g.
for protecting on-disk ZIP/GnuPG file and the attacker has access to your file.
It is then recommended to use a high number of rounds for hashing to slow down
password cracking (e.g. `--s2k-count 65011712` in GnuPG).

_
    args => {
        %args,
        %App::wordlist::arg_wordlists,
    },
    examples => [
    ],
};
sub genpw {
    my %args = @_;

    my $wordlists = delete($args{wordlists}) // ['EN::Enable'];
    my $patterns = delete($args{patterns}) // $default_patterns;

    my $res = App::wordlist::wordlist(
        (wordlists => $wordlists) x !!defined($wordlists),
    );
    return $res unless $res->[0] == 200;

    my @words; while (defined(my $word = $res->[2]->())) { push @words, $word }
    @words = shuffle @words;
    App::genpw::genpw(
        %args,
        patterns => $patterns,
        _words => \@words,
    );
}

1;
# ABSTRACT:

=head1 SYNOPSIS

See the included script L<genpw-wordlist>.


=head1 SEE ALSO

L<genpw> (from L<App::genpw>)
