<?php
$enginePath =__DIR__.DIRECTORY_SEPARATOR."..".DIRECTORY_SEPARATOR."..".DIRECTORY_SEPARATOR;
$libPath = __DIR__ . DIRECTORY_SEPARATOR . ".." . DIRECTORY_SEPARATOR . ".." . DIRECTORY_SEPARATOR . "lib" . DIRECTORY_SEPARATOR;
require_once($libPath . "db_helper.php");

$dbparams = get_db_params();

$conn = pg_connect(get_db_connection_string());

if (!$conn) {
    echo "Failed to connect to database.\n";
    die();
}

$schema = $dbparams['schema'];
$Q[]="DROP SCHEMA IF EXISTS $schema CASCADE";
$Q[]="DROP EXTENSION IF EXISTS vector CASCADE";
$Q[]="CREATE SCHEMA $schema";
$Q[]="CREATE EXTENSION vector";

foreach ($Q as $QS) {
  $r = pg_query($conn, $QS);
  if (!$r) {
    echo pg_last_error($conn);
    die();
  } else {
    echo "$QS ok<br/>";
  }
  
}


// Path to SQL file to import
$sqlFile = $enginePath.'/data/database_default.sql';

// Command to import SQL file using psql
$psqlCommand = "PGPASSWORD=" . escapeshellarg($dbparams['password']) . 
               " psql -h " . escapeshellarg($dbparams['host']) . 
               " -p " . escapeshellarg($dbparams['port']) . 
               " -U " . escapeshellarg($dbparams['user']) . 
               " -d " . escapeshellarg($dbparams['dbname']) . 
               " -f " . escapeshellarg($sqlFile);
// Execute psql command
$output = [];
$returnVar = 0;
exec($psqlCommand, $output, $returnVar);

if ($returnVar !== 0) {
    echo "Failed to import SQL file.\n";
    echo implode("\n", $output) . "\n";
    exit;
}

echo "SQL file imported successfully.\n";
echo implode("\n", $output) . "\n";

echo "Import completed.\n";



?>
