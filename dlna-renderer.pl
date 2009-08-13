#!/usr/bin/perl -w

use strict;
use warnings;
use Data::Dumper;
use Net::UPnP::ControlPoint;
use Getopt::Long;

my %opts = ();
my $renderer;
my $cnt_mng;

GetOptions(\%opts, 'cmd=s', 'url=s');

&init();

if ( $opts{cmd} eq 'set' ){
    &set_av_transport_uri();
} elsif( $opts{cmd} eq 'start' ){
    &start();
} elsif( $opts{cmd} eq 'stop' ){
    &stop();
} elsif( $opts{cmd} eq 'gettransportinfo' ){
    &get_transport_info();
} elsif( $opts{cmd} eq 'getdevicecapabilities' ){
    &get_device_capabilities();
} elsif( $opts{cmd} eq 'getprotocolinfo' ){
    &get_protocol_info();
}

sub init {
    my $obj = Net::UPnP::ControlPoint->new();

    my @dev_list = $obj->search(st =>'upnp:rootdevice', mx => 3);
    my $devNum= 0;
    foreach my $dev (@dev_list) {
        my $device_type = $dev->getdevicetype();
        if  ($device_type ne 'urn:schemas-upnp-org:device:MediaRenderer:1') {
            next;
        }
        print "[$devNum] : " . $dev->getfriendlyname() . "\n";
        #unless ($dev->getservicebyname('urn:schemas-upnp-org:service:AVTransport:1')) {
	#    next;
        #}
        $renderer = $dev->getservicebyname('urn:schemas-upnp-org:service:AVTransport:1');
	$cnt_mng =  $dev->getservicebyname('urn:schemas-upnp-org:service:ConnectionManager:1');
    }
}

sub set_av_transport_uri {
    my %action_in_arg = (
	'InstanceID' => 0,
	'CurrentURI' => $opts{url},
	#'CurrentURI' =>  'http://192.168.10.43/~yuki/dlna.jpg',
	'CurrentURIMetaData' => '',
	);

    my $res = $renderer->postcontrol('SetAVTransportURI', \%action_in_arg);
}

sub start {
    my %action_in_arg = (
	'InstanceID' => 0,
	'Speed' => '1',
	);
    my $res = $renderer->postcontrol('Play', \%action_in_arg);
}

sub stop {
    my %action_in_arg = (
	'InstanceID' => 0,
	);
    my $res = $renderer->postcontrol('Stop', \%action_in_arg);
}

sub get_transport_info {

    #&start();

    my %action_in_arg = (
	'InstanceID' => 0,
	);
    my $res = $renderer->postcontrol('GetTransportInfo', \%action_in_arg);
    warn Dumper( $res );
}

sub get_device_capabilities {
    my %action_in_arg = (
	'InstanceID' => 0,
	);
    my $res = $renderer->postcontrol('GetDeviceCapabilities', \%action_in_arg);
    warn Dumper( $res );
}

sub get_protocol_info {

    my $res = $cnt_mng->postcontrol('GetProtocolInfo', );
    warn Dumper( $res );
}
