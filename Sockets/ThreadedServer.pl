#!/usr/bin/perl
#
# Author: Robert Whitney <xnite@xnite.me>
# This is an example of a multithreaded listening socket.
#
use strict;
use warnings;
use IO::Socket::INET;
use threads;

sub Main
{
	# flush after every write
	$| = 1;

	my ( $socket, $client_socket );
	
	# Bind to listening address and port
	$socket = new IO::Socket::INET (
		LocalHost => '127.0.0.1',
		LocalPort => '1337',
		Proto => 'tcp',
		Listen => 5,
		Reuse => 1
	) or die "Could not open socket: ".$!."\n";

	print "SERVER Waiting for client connections...\n";

	my @clients = ();
	while(1)
	{
		# Waiting for new client connection.
		$client_socket = $socket->accept();
		# Push new client connection to it's own thread
		push ( @clients, threads->create( \&clientHandler, $client_socket ) );
		foreach ( @clients ) 
		{
			if( $_->is_joinable() ) {
	    		$_->join();
	    	}
	    }
	}
	$socket->close();
	return 1;
}

sub clientHandler
{
	# Socket is passed to thread as first (and only) argument.
	my ($client_socket) = @_;

	# Create hash for user connection/session information and set initial connection information.
	my %user = ();
    $user{peer_address} = $client_socket->peerhost();
	$user{peer_port} = $client_socket->peerport();

	print "Accepted New Client Connection From:".$user{peer_address}.":".$user{peer_port}."\n";

	# Let client know that server is ready for commands.
	print $client_socket "> ";

	# Listen for commands while client socket remains open
	while( my $buffer = <$client_socket> )
	{
		# Accept the command `HELLO` from client with optional arguments
		if( $buffer =~ /^HELLO(\s|$)/i )
		{
			#Example reply
			print $client_socket "HELLO THERE!!\n";
			print $client_socket "Your IP:\t".$user{peer_address}."\n";
			print $client_socket "Your Port:\t".$user{peer_port}."\n";
		}

		# This will terminate the client connection to the server
		if( $buffer =~ /^QUIT(\s|$)/i )
		{
			# Print to client, and print to STDOUT then exit client connection & thread
			print $client_socket "GOODBYE\n";
			print "Client exit from ".$user{peer_address}.":".$user{peer_port}."\n";
			$client_socket->shutdown(2);
			threads->exit();
		}
		print $client_socket "> ";
	}
	print "Client exit from ".$user{peer_address}.":".$user{peer_port}."\n";

	# Client has exited so thread should exit too
	threads->exit();
}

# Start the Main loop
Main();