<?php
session_start();
error_reporting(E_ALL);
ini_set('display_errors', '1');

$libPath = __DIR__ . DIRECTORY_SEPARATOR . ".." . DIRECTORY_SEPARATOR . ".." . DIRECTORY_SEPARATOR . "lib" . DIRECTORY_SEPARATOR;
require_once($libPath . "db_helper.php");
$conn = pg_connect(get_db_connection_string());

if (!$conn) {
    echo "Failed to connect to the database: " . pg_last_error();
    exit;
}

// Delete all entries from memory_summary
$query = "DELETE FROM {$schema}.memory_summary;";
$result = pg_query($conn, $query);

if ($result) {
    echo "All entries in the memory_summary table have been deleted successfully.";
} else {
    echo "Error deleting entries from memory_summary: " . pg_last_error($conn);
}

// Close the connection
pg_close($conn);
?>
