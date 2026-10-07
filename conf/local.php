<?php
/**
 * Bcivil wiki settings. Overrides DokuWiki defaults.
 * Full option list: https://www.dokuwiki.org/config
 */
$conf['title']       = 'Bcivil Wiki';
$conf['tagline']     = 'The official guide to the Bcivil Minecraft server';
$conf['start']       = 'start';
$conf['lang']        = 'en';
$conf['template']    = 'dokuwiki';
$conf['license']     = 'cc-by-sa';
$conf['useacl']      = 1;    // enable logins
$conf['superuser']   = '@admin';
$conf['disableactions'] = 'register'; // staff create accounts; change to '' to allow sign-ups
$conf['userewrite']  = 1;    // pretty URLs (/server:rules)
$conf['useslash']    = 1;
$conf['sneaky_index'] = 0;
$conf['breadcrumbs'] = 0;
$conf['youarehere']  = 1;
