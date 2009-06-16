#!/usr/bin/perl

use groonga;

$g = new groonga;
$g->connect('127.0.0.1', 10041);

$g->send('(define x 1)');
print $g->recv(), "\n";

$g->send('(+ x 1)');
print $g->recv(), "\n";

$g->send('hogehoge');
print $g->recv(), "\n";

$g->exit;
