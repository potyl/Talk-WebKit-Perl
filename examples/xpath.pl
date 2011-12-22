#!/usr/bin/env perl

use strict;
use warnings;

use Gtk3 -init;
use Gtk3::WebKit ':xpath_results';

my $view = Gtk3::WebKit::WebView->new();
my $window = Gtk3::Window->new('toplevel');
my $scrolls = Gtk3::ScrolledWindow->new();
$scrolls->add($view);
$window->add($scrolls);
$window->set_default_size(800, 600);
$window->show_all();
$window->signal_connect(destroy => sub { Gtk3->main_quit() });
$view->load_uri('http://search.cpan.org/perldoc?Gtk3::WebKit');

# Walk the DOM
$view->signal_connect('notify::load-status' => sub {
    return unless $view->get_uri and $view->get_load_status eq 'finished';

    my $doc = $view->get_dom_document;
    my $xpath_results = $doc->evaluate(
        '//style | //link[@rel="stylesheet" and @type="text/css" and @href]',
        $doc,
        $doc->create_ns_resolver($doc),
        ORDERED_NODE_SNAPSHOT_TYPE,
        undef
    );

    my $length = $xpath_results->get_snapshot_length;
    for (my $i = 0; $i < $length; ++$i) {
        my $element = $xpath_results->snapshot_item($i);

        my $tag_name = $element->get_tag_name;
        if ($tag_name eq 'STYLE') {
            my $css_content = $element->get_first_child->get_text_content;
            print "CSS: $css_content\n";
        }
        elsif ($tag_name eq 'LINK')  {
            my $href = $element->get_attribute('href');
            print "LINK: $href\n";
        }
    }
});

Gtk3->main();
