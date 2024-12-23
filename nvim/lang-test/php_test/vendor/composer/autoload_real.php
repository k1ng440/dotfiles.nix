<?php

// autoload_real.php @generated by Composer

class ComposerAutoloaderInit364f5a3bda9a46c5674f98c38553e3dc
{
    private static $loader;

    public static function loadClassLoader($class)
    {
        if ('Composer\Autoload\ClassLoader' === $class) {
            require __DIR__ . '/ClassLoader.php';
        }
    }

    /**
     * @return \Composer\Autoload\ClassLoader
     */
    public static function getLoader()
    {
        if (null !== self::$loader) {
            return self::$loader;
        }

        spl_autoload_register(array('ComposerAutoloaderInit364f5a3bda9a46c5674f98c38553e3dc', 'loadClassLoader'), true, true);
        self::$loader = $loader = new \Composer\Autoload\ClassLoader(\dirname(__DIR__));
        spl_autoload_unregister(array('ComposerAutoloaderInit364f5a3bda9a46c5674f98c38553e3dc', 'loadClassLoader'));

        require __DIR__ . '/autoload_static.php';
        call_user_func(\Composer\Autoload\ComposerStaticInit364f5a3bda9a46c5674f98c38553e3dc::getInitializer($loader));

        $loader->register(true);

        return $loader;
    }
}