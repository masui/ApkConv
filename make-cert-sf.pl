#!perl

use strict;
use warnings;
use Digest::SHA;

my $manifest = shift;

my $CRLF = "\r\n";

print "Signature-Version: 1.0", $CRLF;
print "Created-By: 1.0 (Android SignApk)", $CRLF;

my $md = Digest::SHA->new('SHA1');

$md->addfile($manifest);

print "SHA1-Digest-Manifest: ", base64($md->digest), $CRLF, $CRLF;

open my $file, '<', $manifest or die $!;

while (my $line = <$file>) {
    chomp $line;
    last if $line =~ m{\A \s* \z}xmso;
}

my $name = "";
while (my $line = <$file>) {
    $line =~ s{ [\r\n]+ $}{}gxmso;      # custom chomp

    if ($line eq "") {
	$md->add($CRLF);

	print "Name: $name", $CRLF;
	print "SHA1-Digest: ", base64($md->digest), $CRLF, $CRLF;
	next;
    }

    die $line if $line !~ m{^ (\S+) \s* : \s* (.*?) \s* $}xmso;
    my ($key, $data) = ($1, $2);

    if (lc $key eq 'name') {
	$name = $data;
    }

    $md->add("$key: $data" . $CRLF);
}

close $file;

exit;

use MIME::Base64;

sub base64 {
    return encode_base64($_[0], "");
}
