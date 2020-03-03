<?php

$active_group = 'default';
$query_builder = TRUE;

$db['default'] = array(
        'dsn'   => '',
        'hostname' => 'MYSQL_HOSTNAME',
        'username' => 'MYSQL_USERNAME',
        'password' => 'MYSQL_PASSWORD',
        'database' => 'MYSQL_DATABASE',
        'dbdriver' => 'mysqli',
        'dbprefix' => 'ospos_',
        'pconnect' => FALSE,
        'db_debug' => TRUE,
        'cache_on' => FALSE,
        'cachedir' => '',
        'char_set' => 'utf8',
        'dbcollat' => 'utf8_general_ci',
        'swap_pre' => '',
        'encrypt' => FALSE,
        'compress' => FALSE,
        'stricton' => FALSE,
        'failover' => array(),
        'save_queries' => TRUE,
);
