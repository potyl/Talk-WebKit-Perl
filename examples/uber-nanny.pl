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

# Block ANY resource that goes to an external site. This works for all resources.
# Even for resources that are built at runtime through JavaScript.
$view->signal_connect('resource-request-starting' => sub {
    my ($view, $frame, $resource, $request, $response) = @_;

    my $uri = $request->get_uri or return;
    return if $uri eq 'about:blank';

    my $dest = URI->new($uri)->host_port;
    return if $dest eq $allowed_dest or $dest =~ /\.(ultra)?bstatic\.com:/;

    # Block requests to an external URI, 'about:blank' is never downloaded.
    print "Access denied $dest\n\n";
    $request->set_uri('about:blank');
});

Gtk3->main();
