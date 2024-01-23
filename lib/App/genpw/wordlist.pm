package App::genpw::wordlist;

use 5.010001;
use strict 'subs', 'vars';
use warnings;

use App::genpw ();
use App::wordlist ();
use List::Util qw(shuffle);

# AUTHORITY
# DATE
# DIST
# VERSION

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
        #%App::wordlist::argspecopt_wordlists,
        wordlists => {
            'x.name.is_plural' => 1,
            'x.name.singular' => 'wordlist',
            schema => ['array*' => {
                of => 'perl::wordlist::modname_with_optional_args*', # for the moment we need to use 'str' instead of 'perl::wordlist::modname_with_optional_args' due to Perinci::Sub::GetArgs::Argv limitation
                'x.perl.coerce_rules'=>[ ['From_str_or_array::expand_perl_modname_wildcard'=>{ns_prefix=>"WordList"}] ],
            }],
            cmdline_aliases => {w=>{}},
        },
    },
    examples => [
        {
            summary=>'Generate some passwords from the default English (EN::Enable) wordlist',
            argv => [qw/-w ID::KBBI -n8/],
            test => 0,
            'x.doc.show_result' => 0, # TODO: currently result generation fails with obscure error
        },
        {
            summary=>'Generate some passwords from Indonesian words',
            argv => [qw/-w ID::KBBI -n8/],
            test => 0,
            'x.doc.show_result' => 0, # TODO: currently result generation fails with obscure error
        },
        {
            summary=>'Generate some passwords with specified pattern (see genpw documentation for details of pattern)',
            argv => [qw/-w ID::KBBI -n5 -p/, '%w%8$10d-%w%8$10d-%8$10d%w'],
            test => 0,
            'x.doc.show_result' => 0, # TODO: currently result generation fails with obscure error
        },
    ],
};
sub genpw {
    my %args = @_;

    my $wordlists = delete($args{wordlists}) // ['EN::Enable'];
    my $patterns = delete($args{patterns}) // $default_patterns;

    my ($words, $wl);
    unless ($args{action} && $args{action} eq 'list-patterns') {
        # optimize: when there is only one wordlist, pass wordlist object to
        # App::wordlist so it can use pick() which can be more efficient than
        # getting all the words first
        if (@$wordlists == 1) {
            my $mod = "WordList::$wordlists->[0]";
            (my $modpm = "$mod.pm") =~ s!::!/!g;
            require $modpm;
            if (!${"$mod\::DYNAMIC"}) {
                $wl = $mod->new;
                goto GENPW;
            }
        }

        my $res = App::wordlist::wordlist(
            (wordlists => $wordlists) x !!defined($wordlists),
            random => 1,
        );

        return $res unless $res->[0] == 200;
        $words = $res->[2];
    }

  GENPW:
    App::genpw::genpw(
        %args,
        patterns => $patterns,
        ($words ? (_words => $words) : ()),
        ($wl    ? (_wl    => $wl   ) : ()),
    );
}

1;
# ABSTRACT:

=head1 SYNOPSIS

See the included script L<genpw-wordlist>.


=head1 SEE ALSO

L<genpw> (from L<App::genpw>)
