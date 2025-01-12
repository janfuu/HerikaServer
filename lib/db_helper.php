<?php
function get_db_params() {
    return array(
        'host' => getenv('DB_HOST') ?: 'localhost',
        'port' => getenv('DB_PORT') ?: '5432',
        'dbname' => getenv('DB_NAME') ?: 'dwemer',
        'user' => getenv('DB_USER') ?: 'dwemer',
        'password' => getenv('DB_PASSWORD') ?: 'dwemer',
        'schema' => getenv('DB_SCHEMA') ?: 'public'
    );
}

function get_db_connection_string() {
    $dbparams = get_db_params();
    return "host={$dbparams['host']} port={$dbparams['port']} dbname={$dbparams['dbname']} user={$dbparams['user']} password={$dbparams['password']}";
}

function get_db_schema() {
    $dbparams = get_db_params();
    return $dbparams['schema'];
}
?>