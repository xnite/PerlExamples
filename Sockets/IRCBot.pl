#!/usr/bin/perl
#
# Author: Robert Whitney <xnite@xnite.me>
# This is an example of an IRC bot in Perl
#

use strict;
use IO::Socket::INET;
 
my $nick = 'Person';
my $ident = 'person';
my $name = 'Person McPeople';
 
my $sock = new IO::Socket::INET(
	PeerAddr => 'irc.buddy.im',
	PeerPort => 6667,
	Proto => 'tcp',
	Timeout => 15
) or die("Could not connect to server: ".$!."\n");
 
## Establish connection to IRC server by entering nickname, and user information.
print $sock "NICK ".$nick."\r\n";
print $sock "USER ".$ident." ".$ident." 0 :".$name."\r\n";

while( my $buffer = <$sock> )
{
	if( $buffer =~ /^PING(.*)$/i )
	{
		print $sock "PONG ".$1."\r\n";
	} elsif( $buffer =~ /^(.*?) 376 (.*) :(.*)/i )
	{
		## Received end of MOTD, join a channel and say hi.
		print $sock "JOIN #Lobby\r\n";
		print $sock "PRIVMSG #Lobby :Hello everybody!\r\n";
	} else {
		print $buffer;
	}
}
exit;