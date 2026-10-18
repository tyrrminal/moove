package Moove::Import::Event::MercuryTiming;
use v5.38;
use Moose;
with 'Moove::Import::Event::Base';

use Readonly;
use Moove::Util::Unit::Normalization qw(normalize_times);

use JSON::Validator::Joi qw(joi);

Readonly::Scalar my $RESULTS_PAGE => 'https://live.rr.mercurytiming.com/?event=%s';
Readonly::Scalar my $RESULTS_BASE_URL => 'https://%s/functions/v1/live-results?slug=%s';

sub _build_import_param_schemas($class) {
    return {
        event => JSON::Validator->new()->schema(
            joi->object->strict->props(
                host => joi->string->required,
                event_id => joi->string->required,
            )->compile
        ),
        eventactivity => JSON::Validator->new()->schema(
            joi->object->strict->props(
                race_id => joi->string->required
            )->compile
        )
    }
}

sub url($self) {
    return undef unless (defined($self->event_id));
    return sprintf($RESULTS_PAGE, $self->event_id);
}

sub _build_results ($self) {
    my $url = sprintf($RESULTS_BASE_URL, $self->resolve_field_value('host'), $self->event_id);

    my $results = $self->ua->get($url)->result->json;

    my @results = map { $self->make_participant($_) }
        grep { $_->{race} eq $self->race_id } 
        values($results->{results}->@*);

    return [@results];
}

sub make_participant($self, $d) {
    my $gender;
    $gender = 'M' if ($d->{sex} eq 'Male');
    $gender = 'F' if ($d->{sex} eq 'Female');

    my $p = {
        bib_no        => $d->{bib},
        first_name    => $d->{firstName},
        last_name     => $d->{lastName},

        overall_place => $d->{overall},
        net_time      => $d->{chipTime},
        gross_time    => $d->{gunTime},
        pace          => $d->{pace},

        gender        => $gender,
        divison       => $d->{sex} . ' ' . $d->{ageGroup},
    };

    normalize_times($p);

    return $p;    
}
