#!/usr/bin/env perl

use strict;
use warnings;

use Gtk3 -init;
use Gtk3::WebKit ':node_types';

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

    # Show which elements match the given CSS rules
    find_elements_for_selectors(
        $view->get_dom_document->get_body,
        'div.featpostcard', 'td.c2name > a.hotelname'
    );
});

sub find_elements_for_selectors {
    my ($node, @selectors) = @_;

    # Check if the current element matches the CSS rules
    if ($node->get_node_type == ELEMENT_NODE) {
        foreach my $selector (@selectors) {
            next unless $node->webkit_matches_selector($selector);
            printf "%s matches %s\n", $node->get_tag_name, $selector;
        }
    }

    # Recurse through the child nodes
    my $child_nodes = $node->get_child_nodes;
    my $length = $child_nodes->get_length;
    for (my $i = 0; $i < $length; ++$i) {
        my $child = $child_nodes->item($i);
        find_elements_for_selectors($child, @selectors);
    }
}

Gtk3->main();
