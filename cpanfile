requires 'perl', '5.014';

requires 'Hash::Util';
requires 'List::Util', '1.29';
requires 'Pod::Usage';
requires 'Getopt::Long';
requires 'Getopt::EX';
requires 'Getopt::EX::Hashed';
requires 'Text::ANSI::Tabs', '1.04';

on 'test' => sub {
    requires 'Test::More', '0.98';
};
