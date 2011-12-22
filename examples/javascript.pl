#!/usr/bin/env perl

use strict;
use warnings;

use Gtk3 -init;
use Gtk3::WebKit;

# Build a WebKit frame
my $view = Gtk3::WebKit::WebView->new();
$view->load_uri('http://search.cpan.org/perldoc?Gtk3::WebKit');

# Widget packing
my $window = Gtk3::Window->new('toplevel');
my $scrolls = Gtk3::ScrolledWindow->new();
$scrolls->add($view);
$window->add($scrolls);
$window->set_default_size(800, 600);
$window->show_all();
$window->signal_connect(destroy => sub { Gtk3->main_quit() });

# Execute a JavaScript command as soon as the page is loaded
$view->signal_connect('notify::load-status' => sub {

    # Wait for the page to be loaded
    return unless $view->get_uri and $view->get_load_status eq 'finished';

    # Execute jQuery (the page must have jQuery loaded already)
    $view->execute_script(q{
        $('img').hide();
    });
});

# Main loop
Gtk3->main();
