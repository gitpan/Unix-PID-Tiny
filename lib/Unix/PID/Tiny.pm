package Unix::PID::Tiny;

$Unix::PID::Tiny::VERSION = 0.7;

sub new {
    my ( $self, $args_hr ) = @_;
    $args_hr->{'minimum_pid'} = 11 if !exists $args_hr->{'minimum_pid'} || $args_hr->{'minimum_pid'} !~ m{\A\d+\z}ms;    # this does what one assumes m{^\d+$} would do

    if ( defined $args_hr->{'ps_path'} ) {
        $args_hr->{'ps_path'} .= '/' if $args_hr->{'ps_path'} !~ m{/$};
        if ( !-d $args_hr->{'ps_path'} || !-x "$args_hr->{'ps_path'}ps" ) {
            $args_hr->{'ps_path'} = '';
        }
    }
    else {
        $args_hr->{'ps_path'} = '';
    }

    return bless { 'ps_path' => $args_hr->{'ps_path'} }, $self;
}

sub kill {
    my ( $self, $pid ) = @_;
    $pid = int $pid;
    my $min = int $self->{'minimum_pid'};
    if ( $pid < $min ) {

        # prevent bad args from killing the process group (IE '0')
        # or general low level ones
        warn "kill() called with integer value less than $min";
        return;
    }

    # CORE::kill 0, $pid : may be false but still running, see `perldoc -f kill`
    if ( $self->is_pid_running($pid) ) {

        # RC from CORE::kill is not a boolean of if the PID was killed or not, only that it was signaled
        # so it is not an indicator of "success" in killing $pid
        CORE::kill( 15, $pid );    # TERM
        CORE::kill( 2,  $pid );    # INT
        CORE::kill( 1,  $pid );    # HUP
        CORE::kill( 9,  $pid );    # KILL
        return if $self->is_pid_running($pid);
    }
    return 1;
}

sub is_pid_running {
    my ( $self, $check_pid ) = @_;
    
    return 1 if $> == 0 && CORE::kill(0, $check_pid); # if we are superuser we can avoid the the system call. For details see `perldoc -f kill`
    
    # even if we are superuser, go ahead and call ps just in case CORE::kill 0's false RC was erroneous
    my @outp = $self->_raw_ps( 'u', '-p', $check_pid );
    chomp @outp;
    return 1 if defined $outp[1];
    return;
}

sub pid_info_hash {
    my ( $self, $pid ) = @_;
    my @outp = $self->_raw_ps( 'u', '-p', $pid );
    chomp @outp;
    my %info;
    @info{ split( /\s+/, $outp[0], 11 ) } = split( /\s+/, $outp[1], 11 );
    return wantarray ? %info : \%info;
}

sub _raw_ps {
    my ( $self, @ps_args ) = @_;
    my $psargs = join( ' ', @ps_args );
    my @res = `$self->{'ps_path'}ps $psargs`;
    return wantarray ? @res : join '', @res;
}

1;

__END__

=head1 NAME

Unix::PID::Tiny - Subset of Unix::PID functionality with smaller memory footprint

=head1 VERSION

This document describes Unix::PID::Tiny version 0.7

=head1 SYNOPSIS

    use Unix::PID::Tiny;
    my $pid = Unix::PID::Tiny->new();
    
    print Dumper( $pid->pid_info_hash( $misc_pid ) );
    
    if ($pid->is_pid_running($misc_pid)) {
        $pid->kill( $misc_pid ) or die "Could not stop $misc_pid";
    }

=head1 DESCRIPTION

Like Unix::PID but supplies only a few key functions.

=head1 INTERFACE 

=head2 new()

See L<Unix::PID>'s new()

=head2 kill()

See L<Unix::PID>'s kill()

=head2 pid_info_hash()

See L<Unix::PID>'s pid_info_hash()

=head2 is_pid_running()

See L<Unix::PID>'s is_pid_running()

=head2 _raw_ps()

See L<Unix::PID>'s _raw_ps()

If $self->{'ps_path'} is ever set to anything invalid at any point it is simply not used and 'ps' by itself will be used.

=head1 DIAGNOSTICS

See L<Unix::PID>'s DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

Unix::PID::Tiny requires no configuration files or environment variables.

=head1 DEPENDENCIES

None.

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-unix-pid-tiny@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.

=head1 AUTHOR

Daniel Muey  C<< <http://drmuey.com/cpan_contact.pl> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2008, Daniel Muey C<< <http://drmuey.com/cpan_contact.pl> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
