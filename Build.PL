use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Hash::Deep::Iterator',
    license             => 'perl',
    dist_author         => q{Dan Boorstein <danboo@cpan.org>},
    dist_version_from   => 'lib/Hash/Deep/Iterator.pm',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'Hash-Deep-Iterator-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
