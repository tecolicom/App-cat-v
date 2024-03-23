[![Actions Status](https://github.com/tecolicom/App-cat-v/workflows/test/badge.svg)](https://github.com/tecolicom/App-cat-v/actions) [![MetaCPAN Release](https://badge.fury.io/pl/App-cat-v.svg)](https://metacpan.org/release/App-cat-v)
# NAME

cat-v - visualize non-printing characters

# SYNOPSIS

cat-v \[ options \] args ...

Command Options:

    -v, --visible=#    Specify visualize characters
    --repeat=#         Specify repeated characters
    -t, --[no-]expand  Expand tabs or not
    --tabstyle=#       Set tab style
    --tabstop=#        Set tab width
    --tabhead=#        Set tab-head character
    --tabspace=#       Set tab-space character
    --help             Print this message
    --version          Print version

# VERSION

Version 0.01

# DESCRIPTION

The `cat -v` command is commonly used to display non-displayable
characters, but it is not suitable for viewing multilingual
application output because it also converts Unicode characters.  It
also converts escape characters, so output colored with ANSI sequences
will also be corrupted.

<div>
    <p><img width="750" src="https://raw.githubusercontent.com/tecolicom/App-cat-v/main/images/corrupted.png">
</div>

The `cat-v` command was created to solve such problems. Only control
characters are targeted for conversion.  Also, by default, newline and
escape characters are not converted.

<div>
    <p><img width="750" src="https://raw.githubusercontent.com/tecolicom/App-cat-v/main/images/visualized.png">
</div>

Sometimes it is desirable to visualize whitespace characters.  The
`cat -t` command can visualize tab characters, but the problem is
that it breaks the visual format.  Sometimes we want to see which
parts are tabs and which parts are whitespace characters while
preserving the format.  Extra whitespace characters at the end of a
line can also be noticed by visualizing them.

Using `cat-v`, tab characters are visualized in such a way that the
space on the display does not change.

<div>
    <p><img width="750" src="https://raw.githubusercontent.com/tecolicom/App-cat-v/main/images/tabstyle-pin.png">
</div>

Control characters can be displayed in control format and Unicode
symbol characters.  By default, control characters other than newline
and escape characters are displayed as corresponding Unicode symbols.

    nul  \000  \x{2400}  ␀  SYMBOL FOR NULL
    soh  \001  \x{2401}  ␁  SYMBOL FOR START OF HEADING
    stx  \002  \x{2402}  ␂  SYMBOL FOR START OF TEXT
    etx  \003  \x{2403}  ␃  SYMBOL FOR END OF TEXT
    eot  \004  \x{2404}  ␄  SYMBOL FOR END OF TRANSMISSION
    enq  \005  \x{2405}  ␅  SYMBOL FOR ENQUIRY
    ack  \006  \x{2406}  ␆  SYMBOL FOR ACKNOWLEDGE
    bel  \007  \x{2407}  ␇  SYMBOL FOR BELL
    bs   \010  \x{2408}  ␈  SYMBOL FOR BACKSPACE
    ht   \011  \x{2409}  ␉  SYMBOL FOR HORIZONTAL TABULATION
    nl   \012  \x{240A}  ␊  SYMBOL FOR LINE FEED
    vt   \013  \x{240B}  ␋  SYMBOL FOR VERTICAL TABULATION
    np   \014  \x{240C}  ␌  SYMBOL FOR FORM FEED
    cr   \015  \x{240D}  ␍  SYMBOL FOR CARRIAGE RETURN
    so   \016  \x{240E}  ␎  SYMBOL FOR SHIFT OUT
    si   \017  \x{240F}  ␏  SYMBOL FOR SHIFT IN
    dle  \020  \x{2410}  ␐  SYMBOL FOR DATA LINK ESCAPE
    dc1  \021  \x{2411}  ␑  SYMBOL FOR DEVICE CONTROL ONE
    dc2  \022  \x{2412}  ␒  SYMBOL FOR DEVICE CONTROL TWO
    dc3  \023  \x{2413}  ␓  SYMBOL FOR DEVICE CONTROL THREE
    dc4  \024  \x{2414}  ␔  SYMBOL FOR DEVICE CONTROL FOUR
    nak  \025  \x{2415}  ␕  SYMBOL FOR NEGATIVE ACKNOWLEDGE
    syn  \026  \x{2416}  ␖  SYMBOL FOR SYNCHRONOUS IDLE
    etb  \027  \x{2417}  ␗  SYMBOL FOR END OF TRANSMISSION BLOCK
    can  \030  \x{2418}  ␘  SYMBOL FOR CANCEL
    em   \031  \x{2419}  ␙  SYMBOL FOR END OF MEDIUM
    sub  \032  \x{241A}  ␚  SYMBOL FOR SUBSTITUTE
    esc  \033  \x{241B}  ␛  SYMBOL FOR ESCAPE
    fs   \034  \x{241C}  ␜  SYMBOL FOR FILE SEPARATOR
    gs   \035  \x{241D}  ␝  SYMBOL FOR GROUP SEPARATOR
    rs   \036  \x{241E}  ␞  SYMBOL FOR RECORD SEPARATOR
    us   \037  \x{241F}  ␟  SYMBOL FOR UNIT SEPARATOR
    sp   \040  \x{2420}  ␠  SYMBOL FOR SPACE
    del  \177  \x{2421}  ␡  SYMBOL FOR DELETE
    nbsp \240  \x{2423}  ␣  OPEN BOX

# OPTIONS

- **-v**, **--visible** _name_=_flag_,...

    Give the character type and flags as parameters to specify the
    character to be visualized and the conversion format.

        c  control style
        s  symbol style
        0  do not convert
        1  convert
        *  anything else is used as a replacement

    Option `-v nl=1` can also be used to visualize newline characters.
    For newline characters only, after displaying the result of the
    conversion, the original character is output at the same time.

    Use the names in the list above to specify by character type.  If you
    want to convert escapes without converting tabs, use the following

        -v tab=0 -v esc=1

    Multiple items can be specified at the same time.  The following
    example sets `tab` and `bel` to 0 and `esc` to 1.

        -v tab=bel=0,esc=1

    If `all` is specified for the name, the value applies to all
    character types.  You can enable all and then exclude only escapes as
    follows

        -v all=1,esc=0

- **--repeat**=_name_\[,_name_...\]

    Specifies the character type for outputting the original character at
    the same time as the converted character.  The default setting is
    `nl`.  The following will correctly output the original ANSI sequence
    with the escape character visualized.

        -v esc --repeat esc,nl

- **--tabstop**=# (DEFAULT: 8)

    Set tab width.

- **-t**, **--expand**, **--no-expand**

    Tab characters are expanded by default. To explicitly disable it, use
    the **--no-expand** option.

    By default, the style `bar` is applied, which can be changed with
    `--tabstyle`. If the `--tabstyle` option is specified with no
    arguments, a list of available styles is displayed.

    You can disable tab expansion by default by putting the following
    setting in your `~/.cat-vrc` file.

        option default --no-expand

    In such cases, tab expansion can be temporarily enabled by the `-t`
    option.

- **--tabhead**=#
- **--tabspace**=#

    Set head and following space characters.
    If the option value is longer than single character, it is evaluated
    as unicode name.

- **--tabstyle**, **--ts**
- **--tabstyle**=_style_, **--ts**=...
- **--tabstyle**=_head-style_,_space-style_ **--ts**=...

    Set the style how tab is expanded.  Select `symbol` or `shade` for
    example.  If two style names are combined, like
    `squat-arrow,middle-dot`, use `squat-arrow` for tabhead and
    `middle-dot` for tabspace.

    Show available style list if called without parameter.  Styles are
    defined in [Text::ANSI::Fold](https://metacpan.org/pod/Text%3A%3AANSI%3A%3AFold) library.

# INSTALL

## CPANMINUS

From CPAN archive:

    cpanm App::cat::v

From GIT repository:

    cpanm https://github.com/tecolicom/App-cat-v.git

# SEE ALSO

[https://github.com/tecolicom/App-cat-v.git](https://github.com/tecolicom/App-cat-v.git)

# AUTHOR

Kazumasa Utashiro

# LICENSE

Copyright © 2024 Kazumasa Utashiro.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
