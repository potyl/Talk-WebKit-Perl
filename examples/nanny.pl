#!/usr/bin/env perl

use strict;
use warnings;

use Gtk3 -init;
use Gtk3::WebKit;
use URI;

# Build a WebKit frame
my $view = Gtk3::WebKit::WebView->new();

# Widget packing
my $window = Gtk3::Window->new('toplevel');
my $scrolls = Gtk3::ScrolledWindow->new();
$scrolls->add($view);
$window->add($scrolls);
$window->set_default_size(800, 600);
$window->show_all();
$window->signal_connect(destroy => sub { Gtk3->main_quit() });


my $uri = 'http://search.cpan.org/perldoc?Gtk3::WebKit';
$view->load_uri($uri);

my $allowed_dest = URI->new($uri)->host_port;

# Intercept all web pages requests and reject all requests that will bring us
# to an external web site. This works only for the iframes and links that have
# been clicked by the user.
# *** JavaScript and CSS are not blocked! ***
$view->signal_connect('navigation-policy-decision-requested' => sub {
    my ($view, $frame, $request, $action, $decision) = @_;

    my $uri = $request->get_uri or return;
    return if $uri eq 'about:blank';

    # Accept the request only if we stay in the same site
    my $dest = URI->new($uri)->host_port;
    return if $dest eq $allowed_dest;

    # Reject all requests going to a different site
    print "Access denied $dest\n";
    $decision->ignore();
    return 1;
});

Gtk3->main();
