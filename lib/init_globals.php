<?php
// Only initialize if not already set
if (!isset($GLOBALS['FUNCTIONS_ARE_ENABLED'])) {
    $GLOBALS['FUNCTIONS_ARE_ENABLED'] = true;
}

if (!isset($GLOBALS['TTS_FFMPEG_FILTERS'])) {
    $GLOBALS['TTS_FFMPEG_FILTERS'] = '';
}

if (!isset($GLOBALS['SCRIPTLINE_LISTENER'])) {
    $GLOBALS['SCRIPTLINE_LISTENER'] = '';
}

if (!isset($GLOBALS['SCRIPTLINE_EXPRESSION'])) {
    $GLOBALS['SCRIPTLINE_EXPRESSION'] = '';
}

if (!isset($GLOBALS['gameRequest'])) {
    $GLOBALS['gameRequest'] = array();
}

// Initialize game request array with default values only if not set
if (!isset($GLOBALS['gameRequest']) || empty($GLOBALS['gameRequest'])) {
    $GLOBALS['gameRequest'] = array(
        0 => '',  // Command
        1 => '',  // First parameter
        2 => '',  // Second parameter
        3 => ''   // Third parameter
    );
}