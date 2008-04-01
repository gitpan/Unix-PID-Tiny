package Unix::PID::Tiny;

use strict;
use vars qw($VERSION);
$VERSION = 0.3;

sub new { 
    my ($self, $args_hr) = @_;
    return bless { 'ps_path' => $args_hr->{'ps_path'} || '', }, $self; 
}

sub kill {
    my($self, $pid) = @_;
    $pid = int $pid;
    # kill 0, $pid : may be false but still running, see `perldoc -f kill`
    if( $self->is_pid_running($pid) ) {
        if(!kill 1, $pid) {
            kill 9, $pid or return;
        }
    }   
    return 1; 
}

sub is_pid_running {
    my($self, $check_pid) = @_;
    my @outp = $self->_raw_ps('u', '-p', $check_pid);
    chomp @outp;
    return 1 if defined $outp[1];
    return;
}

sub pid_info_hash {
    my ($self, $pid) = @_;
    my @outp = $self->_raw_ps('u', '-p', $pid);
    chomp @outp;
    my %info;
    @info{ split(/\s+/, $outp[0], 11) } = split(/\s+/, $outp[1], 11);
    return wantarray ? %info : \%info;
}

sub _raw_ps {
    my ($self, @ps_args) = @_;
    my $psargs = join(' ',@ps_args);
    $self->{'ps_path'} =~ s{/$}{}g;
    $self->{'ps_path'} = -d $self->{'ps_path'} && -x "$self->{'ps_path'}/ps" ? "$self->{'ps_path'}/" : '';
    my @res = `$self->{'ps_path'}ps $psargs`;
    return wantarray ? @res : join '', @res;
}

1; 

__END__

=head1 NAME

Unix::PID::Tiny - Subset of Unix::PID functionality with smaller memory footprint


=head1 VERSION

This document describes Unix::PID::Tiny version 0.3

=head1 SYNOPSIS

    use Unix::PID::Tiny;
    my $pid = Unix::PID::Tiny->new();
    
    print Dumper $pid->pid_info_hash( $misc_pid );
    
    if ($pid->is_running($misc_pid)) {
        $pid->kill( $misc_pid ) or die "Could not stop $misc_pid";
    }

=head1 DESCRIPTION

Like Unix::PID but using a simple hash based object instead of
Class::Std and supplying only a few key functions.

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