#!perl
# ciphersaber.pl
# 18:55 03/09/2005
# tweaked - Wed 14 Mar 2007 16:51:43 GMT 
# this is uses ciphersaber 2, unlike the C implementation in this directory 

use strict;
use Crypt::CipherSaber;
use Digest::MD5 qw{ md5_hex };

if (!defined $ARGV[0])
{
&usage;
}

my $c_d = $ARGV[0];
my $filename = $ARGV[1];
my $key	= $ARGV[2];

open (file, "<$filename") or die "$!";
binmode(file);
my $N = 10;
my $cipher = Crypt::CipherSaber->new($key, $N);

#key hardening
if ( length($key) <= (128/8) ) { $key = md5_hex($key); }


if ($c_d eq 'c')
 {
	#crypt
	my $filedata;
	while (<file>)
		{
		$filedata .= $_;
		}
	close file;
	my $filename_out = $filename;
	$filename_out =~ s{\.\w+}{\.crypt_out};
	if (-e $filename_out)
        	 {
		 print "$filename_out exists, overwrite?[y/n]:";
		 chomp($_ = <stdin>);
			 if (/^n/i) { print "Roger, out\n"; exit; }
 		 open (cryptout, "+>$filename_out");
		 }
	else { open (cryptout, "+>$filename_out"); }
	binmode(cryptout);
	print cryptout $cipher->encrypt($filedata);
	print "obliterate original?[y/n]: ";
	chomp($_ = <stdin>);
	if (/^n/i) { print "Roger, out\n"; exit; }
	&obliterate($filename);
 }
	
elsif ($c_d eq 'd')
 {
	#decrypt
	my $filedata;
	while (<file>)
		{
		$filedata .= $_;
		}
	close file;
	my $filename_out = $filename;
	$filename_out =~ s{\.\w+}{\.decrypt_out};
	if (-e $filename_out)
        	 {
		 print "$filename_out exists, overwrite?[y/n]:";
		 chomp($_ = <stdin>);
			 if (/^n/i) { print "Roger, out\n"; exit; }
 		 open (decryptout, "+>$filename_out");
		 }
	else { open (decryptout, "+>$filename_out"); }
	binmode(decryptout);
	print decryptout $cipher->decrypt($filedata); #NO checking if correct $key !
	print "obliterate original?[y/n]: ";
	chomp($_ = <stdin>);
	if (/^n/i) { print "Roger, out\n"; exit; }
	&obliterate($filename)	
 }

else { &usage }




sub usage {
print "Usage: \n";
print "ciphersaber.pl c|d file.ext key\n";
print "example: \n";
print "ciphersaber d cryptme.txt mysecretkey\n";
exit;
}

sub obliterate {
my $toshred = @_[0];
my $size = -s $toshred;
#get a big enough stick
my $stick;
for (0..$size)
	{
	$stick .= "x";
	}
#bang it some
open (shredme, "+<$toshred");
binmode(shredme);
for (0..9)
	{
	print shredme $stick;
	seek(shredme, 0, 0);
	}
close shredme;
#put it out of its mizery
unlink $toshred;

}



print "Completed.\n\a";
