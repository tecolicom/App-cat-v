package App::cat::v;

our $VERSION = "0.01";

use 5.014;
use warnings;

use utf8;
use Encode;
use charnames ':full';
use Data::Dumper;
{
    no warnings 'redefine';
    *Data::Dumper::qquote = sub { qq["${\(shift)}"] };
    $Data::Dumper::Useperl = 1;
}
use open IO => 'utf8', ':std';
use charnames ':loose';
use Pod::Usage;
use List::Util qw(max pairmap);
use Hash::Util qw(lock_keys);
use Getopt::EX;
use Text::ANSI::Tabs qw(ansi_expand);

my %control  = (
    nul  => [ 's', "\000", "\x{2400}" ], # ␀ SYMBOL FOR NULL
    soh  => [ 's', "\001", "\x{2401}" ], # ␁ SYMBOL FOR START OF HEADING
    stx  => [ 's', "\002", "\x{2402}" ], # ␂ SYMBOL FOR START OF TEXT
    etx  => [ 's', "\003", "\x{2403}" ], # ␃ SYMBOL FOR END OF TEXT
    eot  => [ 's', "\004", "\x{2404}" ], # ␄ SYMBOL FOR END OF TRANSMISSION
    enq  => [ 's', "\005", "\x{2405}" ], # ␅ SYMBOL FOR ENQUIRY
    ack  => [ 's', "\006", "\x{2406}" ], # ␆ SYMBOL FOR ACKNOWLEDGE
    bel  => [ 's', "\007", "\x{2407}" ], # ␇ SYMBOL FOR BELL
    bs   => [ 's', "\010", "\x{2408}" ], # ␈ SYMBOL FOR BACKSPACE
    ht   => [ 's', "\011", "\x{2409}" ], # ␉ SYMBOL FOR HORIZONTAL TABULATION
    nl   => [ '0', "\012", "\x{240A}" ], # ␊ SYMBOL FOR LINE FEED
    vt   => [ 's', "\013", "\x{240B}" ], # ␋ SYMBOL FOR VERTICAL TABULATION
    np   => [ 's', "\014", "\x{240C}" ], # ␌ SYMBOL FOR FORM FEED
    cr   => [ 's', "\015", "\x{240D}" ], # ␍ SYMBOL FOR CARRIAGE RETURN
    so   => [ 's', "\016", "\x{240E}" ], # ␎ SYMBOL FOR SHIFT OUT
    si   => [ 's', "\017", "\x{240F}" ], # ␏ SYMBOL FOR SHIFT IN
    dle  => [ 's', "\020", "\x{2410}" ], # ␐ SYMBOL FOR DATA LINK ESCAPE
    dc1  => [ 's', "\021", "\x{2411}" ], # ␑ SYMBOL FOR DEVICE CONTROL ONE
    dc2  => [ 's', "\022", "\x{2412}" ], # ␒ SYMBOL FOR DEVICE CONTROL TWO
    dc3  => [ 's', "\023", "\x{2413}" ], # ␓ SYMBOL FOR DEVICE CONTROL THREE
    dc4  => [ 's', "\024", "\x{2414}" ], # ␔ SYMBOL FOR DEVICE CONTROL FOUR
    nak  => [ 's', "\025", "\x{2415}" ], # ␕ SYMBOL FOR NEGATIVE ACKNOWLEDGE
    syn  => [ 's', "\026", "\x{2416}" ], # ␖ SYMBOL FOR SYNCHRONOUS IDLE
    etb  => [ 's', "\027", "\x{2417}" ], # ␗ SYMBOL FOR END OF TRANSMISSION BLOCK
    can  => [ 's', "\030", "\x{2418}" ], # ␘ SYMBOL FOR CANCEL
    em   => [ 's', "\031", "\x{2419}" ], # ␙ SYMBOL FOR END OF MEDIUM
    sub  => [ 's', "\032", "\x{241A}" ], # ␚ SYMBOL FOR SUBSTITUTE
    esc  => [ '0', "\033", "\x{241B}" ], # ␛ SYMBOL FOR ESCAPE
    fs   => [ 's', "\034", "\x{241C}" ], # ␜ SYMBOL FOR FILE SEPARATOR
    gs   => [ 's', "\035", "\x{241D}" ], # ␝ SYMBOL FOR GROUP SEPARATOR
    rs   => [ 's', "\036", "\x{241E}" ], # ␞ SYMBOL FOR RECORD SEPARATOR
    us   => [ 's', "\037", "\x{241F}" ], # ␟ SYMBOL FOR UNIT SEPARATOR
    sp   => [ 's', "\040", "\x{2420}" ], # ␠ SYMBOL FOR SPACE
    del  => [ 's', "\177", "\x{2421}" ], # ␡ SYMBOL FOR DELETE
    nbsp => [ 's', "\240", "\x{2423}" ], # ␣ OPEN BOX
);

my %flag   = pairmap { $a => $b->[0] }      %control;
my %symbol = pairmap { $b->[1] => $b->[2] } %control;
my %code   = pairmap { $a => $b->[1] }      %control;
lock_keys %flag;

my $default_tabstyle = 'pin';
if ($default_tabstyle) {
    Text::ANSI::Tabs->configure(tabstyle => $default_tabstyle);
}

sub list_tabstyle {
    my %style = %Text::ANSI::Fold::TABSTYLE;
    my $max = max map length, keys %style;
    for my $name (sort keys %style) {
	my($head, $space) = @{$style{$name}};
	my $tab = $head . $space x 7;
	printf "%*s %s\n", $max, $name, $tab x 3;
    }
}

use Getopt::EX::Hashed; {
    Getopt::EX::Hashed->configure(DEFAULT => [ is => 'rw' ]);
    has visible    => ' c  =s@ ' ;
    has reset      => ' n      ' ;
    has expand     => ' t  !   ' , default => 1 ;
    has repeat     => '    =s  ' , default => 'nl' ;
    has debug      => ' d      ' ;
    has tabstop    => ' x  =i  ' , default => 8, min => 1 ;
    has tabhead    => '    =s  ' ;
    has tabspace   => '    =s  ' ;
    has tabstyle   => ' ts :s  ' , default => $default_tabstyle ;
    has help       => ' h      ' ;
    has version    => ' v      ' ;

    # -n
    has '+reset' => sub {
	$flag{$_} = '0' for keys %flag;
    };

    has [ keys %control ] => ':s', action => sub {
	my($name, $c) = map "$_", @_;
	$c = '1' if $c eq '';
	$c = charnames::string_vianame($c) || die "$c: invalid name\n"
	    if length($c) > 1;
	$flag{$name} = $c;
    };

    #  -T negate -t
    has T => '!', action => sub {
	$_->expand = ! $_[1];
    };

    ### --tabstop, --tabstyle
    has [ qw(+tabstop +tabstyle) ] => sub {
	my($name, $val) = map "$_", @_;
	if ($val eq '') {
	    list_tabstyle();
	    exit;
	}
	Text::ANSI::Tabs->configure($name => $val);
    };

    ### --tabhead, --tabspace
    has [ qw(+tabhead +tabspace) ] => sub {
	my($name, $c) = map "$_", @_;
	$c = charnames::string_vianame($c) || die "$c: invalid name\n"
	    if length($c) > 1;
	Text::ANSI::Tabs->configure($name => $c);
    };

    has '+visible' => sub {
	my $param = $_[1];
	$param =~ s{ \ball\b }{ join('=', keys %flag) }xe;
	push @{$_->visible}, $param;
    };

    has '+help' => sub {
	pod2usage
	    -verbose  => 99,
	    -sections => [ qw(SYNOPSIS VERSION) ];
    };

    has '+version' => sub {
	say "Version: $VERSION";
	exit;
    };

} no Getopt::EX::Hashed;

sub run {
    my $app = shift;
    local @ARGV = splice @_;
    $app->options->doit;
    return 0;
}

sub options {
    my $app = shift;
    for (@ARGV) {
	$_ = decode 'utf8', $_ unless utf8::is_utf8($_);
    }
    use Getopt::EX::Long qw(:DEFAULT ExConfigure Configure);
    ExConfigure BASECLASS => [ __PACKAGE__, 'Getopt::EX' ];
    Configure qw(bundling);
    $app->getopt || pod2usage();

    require Getopt::EX::LabeledParam;
    Getopt::EX::LabeledParam
	->new(HASH => \%flag, NEWLABEL => 0, DEFAULT => 1)
	->load_params(@{$app->visible});

    return $app;
}

sub doit {
    my $app = shift;
    my(@control, @symbol);
    for my $name (keys %flag) {
	if ($flag{$name} eq 'c') {
	    push @control, $code{$name};
	}
	elsif (my $c = $flag{$name}) {
	    push @symbol, $code{$name};
	    if ($flag{$name} =~ /^([^a-z\d\s])$/i) {
		$symbol{$code{$name}} = $1;
	    }
	}
    }
    local $" = '';
    my @repeat = map { $code{$_} } $app->repeat =~ /\w+/g;
    my $repeat_re = qr/[@repeat]/;
    while (<>) {
	$_ = ansi_expand($_) if $app->expand;
	s{(?=(${repeat_re}?))([@symbol]|(?#bug?)(?!))}{$symbol{$2}$1}g
	    if @symbol;
	s{(?=(${repeat_re}?))([@control]|(?#bug?)(?!))}{
	    '^' . pack('c',ord($2)+64) . $1
	}ge if @control;
	print;
    }
}

1;

__END__

=encoding utf-8

=head1 NAME

App::cat::v - cat-v command implementation

=head1 SYNOPSIS

    use  App::cat::v;
    exit App::cat::v->new->run(splice @ARGV);

    perl -MApp::cat::v -E 'App::cat::v->new->run(@ARGV)' --

=head1 DESCRIPTION

Document is included in the executable script.
Use `perldoc cat-v`.

=head1 AUTHOR

Kazumasa Utashiro

=head1 LICENSE

Copyright ©︎ 2024- Kazumasa Utashiro.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

