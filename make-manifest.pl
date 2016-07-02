#!perl

use strict;
use warnings;
use File::Find;
use File::Spec::Functions qw( splitpath splitdir );
use Digest::SHA;
use MIME::Base64;

my $CRLF = "\r\n";

#print "Signature-Version: 1.0", $CRLF;
print "Manifest-Version: 1.0", $CRLF;

print "Created-By: 1.0 (Android SignApk)", $CRLF, $CRLF;

my $target_dir = shift;

find(\&each_node, $target_dir);

exit;

sub each_node {
    my $file = $_;
    
    return if ! -f $file;
    
    my ($vol, $d, $f) = splitpath $File::Find::name;
    my @dirs = grep { $_ ne '' } splitdir $d;
    my $name = join '/', @dirs, $f;
    
    $name =~ s{\A \Q$target_dir\E /? }{}xms;
    
    return if $name eq 'META-INF/MANIFEST.MF';
    return if $name eq 'META-INF/CERT.SF';
    return if $name eq 'META-INF/CERT.RSA';
    
    printf "Name: %s%s", $name, $CRLF;
    printf "SHA1-Digest: %s%s", sha1_for_file($file), $CRLF;
    print $CRLF;
}

sub sha1_for_file {
    my $file = shift;
    
    my $sha = Digest::SHA->new("SHA1");
    $sha->addfile($file);
    return encode_base64($sha->digest(), "");
}
