<?php
// Router for php -S: maps pretty URLs (/guides/claims) onto doku.php?id=guides:claims
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$file = $_SERVER['DOCUMENT_ROOT'] . $path;
if ($path !== '/' && is_file($file)) return false;       // real file: serve as-is
if ($path === '/' ) { $_GET['id'] = 'start'; }
else { $_GET['id'] = trim(str_replace('/', ':', $path), ':'); }
$_REQUEST = array_merge($_REQUEST, $_GET);
chdir($_SERVER['DOCUMENT_ROOT']);
require $_SERVER['DOCUMENT_ROOT'] . '/doku.php';
