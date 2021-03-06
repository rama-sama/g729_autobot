#!/usr/bin/perl

use Net::Pcap;

die "Usage: $0 infile outfile" unless scalar(@ARGV) > 1;

my $err;

open(my $out, '>', $ARGV[1]) or die "cannot open in file: $!";

my $pcap = Net::Pcap::open_offline($ARGV[0], \$err);
Net::Pcap::dispatch($pcap, 0, \&process_pkt, $out);
Net::Pcap::close($pcap);
close($out);

sub process_pkt {
# skip first 54 octets and write rest to $out
    my($out, $hdr, $pkt) = @_;
    my $payload = substr($pkt, 54);
    print $out $payload;
}
