#!/usr/bin/env perl
# USAGE: perl pcm2au.pl inputFile outputFile

$usage = "Usage: 'perl $0 <Source PCM File> <Destination AU File>' ";

$srcFile = shift or die $usage;
$dstFile = shift or die $usage;

open(SRCFILE, "$srcFile") or die "Unable to open file: $!\n";
binmode SRCFILE;

open(DSTFILE, "> $dstFile") or die "Unable to open file: $!\n";
binmode DSTFILE;

###################################
# Write the AU header
###################################

print DSTFILE  ".snd";

$foo = pack("CCCC", 0,0,0,24);
print DSTFILE  $foo;

$foo = pack("CCCC", 0xff,0xff,0xff,0xff);
print DSTFILE  $foo;

$foo = pack("CCCC", 0,0,0,3);
print DSTFILE  $foo;

$foo = pack("CCCC", 0,0,0x1f,0x40);
print DSTFILE  $foo;

$foo = pack("CCCC", 0,0,0,1);
print DSTFILE  $foo;

#############################
# swap the PCM samples
#############################

while (read(SRCFILE, $inWord, 2) == 2) {

    @bytes   = unpack('CC', $inWord);
    $outWord = pack('CC', $bytes[1], $bytes[0]);
    print DSTFILE  $outWord;
}

close(DSTFILE);
close(SRCFILE);
