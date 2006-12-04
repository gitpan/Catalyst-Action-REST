#
# Catalyst::Action::Serialize::Data::Serializer
# Created by: Adam Jacob, Marchex, <adam@marchex.com>
#
# $Id$

package Catalyst::Action::Serialize::Data::Serializer;

use strict;
use warnings;

use base 'Catalyst::Action';
use Data::Serializer;

sub execute {
    my $self = shift;
    my ( $controller, $c, $serializer ) = @_;

    my $stash_key = $controller->config->{'serialize'}->{'stash_key'} || 'rest';
    my $sp = $serializer;
    $sp =~ s/::/\//g;
    $sp .= ".pm";
    eval {
        require $sp
    };
    if ($@) {
        $c->log->debug("Could not load $serializer, refusing to serialize: $@");
        return 0;
    }
    my $dso = Data::Serializer->new( serializer => $serializer );
    my $data;
    eval {
       $data = $dso->raw_serialize($c->stash->{$stash_key});
    };
    if ($@) {
        return $@;
    } 
    $c->response->output( $data );
    return 1;
}

1;