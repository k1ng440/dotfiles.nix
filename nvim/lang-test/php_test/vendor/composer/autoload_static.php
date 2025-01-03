<?php

// autoload_static.php @generated by Composer

namespace Composer\Autoload;

class ComposerStaticInit364f5a3bda9a46c5674f98c38553e3dc
{
    public static $prefixLengthsPsr4 = array (
        'K' => 
        array (
            'K1ng\\PhpTest\\' => 13,
        ),
    );

    public static $prefixDirsPsr4 = array (
        'K1ng\\PhpTest\\' => 
        array (
            0 => __DIR__ . '/../..' . '/src',
        ),
    );

    public static $classMap = array (
        'Composer\\InstalledVersions' => __DIR__ . '/..' . '/composer/InstalledVersions.php',
    );

    public static function getInitializer(ClassLoader $loader)
    {
        return \Closure::bind(function () use ($loader) {
            $loader->prefixLengthsPsr4 = ComposerStaticInit364f5a3bda9a46c5674f98c38553e3dc::$prefixLengthsPsr4;
            $loader->prefixDirsPsr4 = ComposerStaticInit364f5a3bda9a46c5674f98c38553e3dc::$prefixDirsPsr4;
            $loader->classMap = ComposerStaticInit364f5a3bda9a46c5674f98c38553e3dc::$classMap;

        }, null, ClassLoader::class);
    }
}
