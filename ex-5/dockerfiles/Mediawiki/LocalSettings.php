<?php
if ( !defined( "MEDIAWIKI" ) ) {
    exit;
}
$wgSitename = "Clouds Lecture Wiki";
$wgMetaNamespace = "Clouds_Lecture_Wiki";
$wgScriptPath = "/wiki";
$wgServer = "http://$YOUR_FLOATING_IP/";
$wgResourceBasePath = $wgScriptPath;
$wgEnableEmail = false;
$wgEnableUserEmail = true; # UPO
$wgEmergencyContact = "";
$wgPasswordSender = "";
$wgEnotifUserTalk = false; # UPO
$wgEnotifWatchlist = false; # UPO
$wgEmailAuthentication = true;
$wgDBtype = "mysql";
$wgDBserver = "database";
$wgDBname = "wikidb";
$wgDBuser = "wikiuser";
$wgDBpassword = "geheim";
$wgDBprefix = "";
$wgDBTableOptions = "ENGINE=InnoDB, DEFAULT CHARSET=binary";
$wgDBmysql5 = false;
$wgMainCacheType = CACHE_NONE;
$wgMemCachedServers = [];
$wgEnableUploads = false;
$wgUseInstantCommons = false;
$wgPingback = true;
$wgShellLocale = "en_US.utf8";
$wgLanguageCode = "en";
$wgSecretKey = "fd2307b3fe875e4c9ce2774a1465b0bc979ec433e66aba29f7a76293acc8f5b4";
$wgAuthenticationTokenVersion = "1";
$wgUpgradeKey = "24749ee8bf5621a2";
$wgRightsPage = ""; # Set to the title of a wiki page that describes your license/copyright
$wgRightsUrl = "";
$wgRightsText = "";
$wgRightsIcon = "";
$wgDiff3 = "/usr/bin/diff3";
$wgDefaultSkin = "vector";
wfLoadSkin( "CologneBlue" );
wfLoadSkin( "Modern" );
wfLoadSkin( "MonoBook" );
wfLoadSkin( "Vector" );
?>