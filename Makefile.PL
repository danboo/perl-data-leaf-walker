use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Hash::Deep::Iterator',
    AUTHOR              => q{Dan Boorstein <danboo@cpan.org>},
    VERSION_FROM        => 'lib/Hash/Deep/Iterator.pm',
    ABSTRACT_FROM       => 'lib/Hash/Deep/Iterator.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Hash-Deep-Iterator-*' },
);
