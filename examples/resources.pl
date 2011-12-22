#!/usr/bin/env perl

use strict;
use warnings;

use Gtk3 -init;
use Gtk3::WebKit;
use HTTP::Soup;

my $view = Gtk3::WebKit::WebView->new();
$view->load_uri('http://search.cpan.org/perldoc?Gtk3::WebKit');

# Get the session that's responsible for all HTTP access made by WebKit GTK
my $session = Gtk3::WebKit->get_default_session();

# Track all download requests
$session->signal_connect('request-started' => sub {
    my ($session, $message, $socket, $resources) = @_;

    # A new download request starts
    my $url = $message->get_uri->to_string(0);
    my $start = time;

    # Track the when the download finishes
    $message->signal_connect(finished => sub {
        my $elapsed = time - $start;
        my $status_code = $message->get('status-code') // 'N/A';
        print "$url $elapsed seconds, status code $status_code\n";
    });
});

Gtk3->main();
