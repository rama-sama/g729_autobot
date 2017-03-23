# g729_autobot.rb

## Purpose
To extract the forward and reverse g729 RTP stream from a pcap
and convert them to audio (.au) files.

## Usage
```
./g729_autobot.rb -f <pcap path> -s <source udp port> -d <dest udp port>
    -s, --source PORT                UDP Source Port
    -d, --dest PORT                  UDP Dest Port
    -f, --file NAME                  Path to pcap with two way RTP stream
```

## Output
Creates two directories, `audio_files` and `filtered_pcaps`.

`audio_files` will contain the exported .au files.

`filtered_pcaps` will have a pcap with the uni-directional RTP streams

## Dependencies
CodecPro offers Free Open G.729 Implementation and can be downloaded via URL below.
The offering is necessary for decoding the raw extract and converting to PCM.

http://www.codecpro.com/LicenseG729.php

Also, there are a couple of Perl scripts that are in use for the conversion process.
One of them requires `Net::Pcap`. To install run `cpan install Net::Pcap`.

There is also an `.exe` that needs to run. `wine` is used to run it in a Linux/Unix environment.
`brew install wine`
