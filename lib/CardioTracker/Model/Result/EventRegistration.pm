#<<<
use utf8;
package CardioTracker::Model::Result::EventRegistration;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CardioTracker::Model::Result::EventRegistration

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::Relationship::Predicate>

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::InflateColumn::Time>

=back

=cut

__PACKAGE__->load_components(
  "Relationship::Predicate",
  "InflateColumn::DateTime",
  "InflateColumn::Time",
);

=head1 TABLE: C<event_registration>

=cut

__PACKAGE__->table("event_registration");

=head1 ACCESSORS

=head2 event_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 fee

  data_type: 'decimal'
  is_nullable: 1
  size: [6,2]

=head2 fundraising_minimum

  data_type: 'decimal'
  is_nullable: 1
  size: [6,2]

=head2 registered

  data_type: 'enum'
  default_value: 'N'
  extra: {list => ["Y","P","N"]}
  is_nullable: 1

=head2 bib_no

  data_type: 'integer'
  is_nullable: 1

=head2 is_public

  data_type: 'enum'
  default_value: 'Y'
  extra: {list => ["Y","N"]}
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "event_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "fee",
  { data_type => "decimal", is_nullable => 1, size => [6, 2] },
  "fundraising_minimum",
  { data_type => "decimal", is_nullable => 1, size => [6, 2] },
  "registered",
  {
    data_type => "enum",
    default_value => "N",
    extra => { list => ["Y", "P", "N"] },
    is_nullable => 1,
  },
  "bib_no",
  { data_type => "integer", is_nullable => 1 },
  "is_public",
  {
    data_type => "enum",
    default_value => "Y",
    extra => { list => ["Y", "N"] },
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</event_id>

=item * L</user_id>

=back

=cut

__PACKAGE__->set_primary_key("event_id", "user_id");

=head1 RELATIONS

=head2 donations

Type: has_many

Related object: L<CardioTracker::Model::Result::Donation>

=cut

__PACKAGE__->has_many(
  "donations",
  "CardioTracker::Model::Result::Donation",
  {
    "foreign.event_id" => "self.event_id",
    "foreign.user_id"  => "self.user_id",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 event

Type: belongs_to

Related object: L<CardioTracker::Model::Result::Event>

=cut

__PACKAGE__->belongs_to(
  "event",
  "CardioTracker::Model::Result::Event",
  { id => "event_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 user

Type: belongs_to

Related object: L<CardioTracker::Model::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "CardioTracker::Model::Result::User",
  { id => "user_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-08-02 13:17:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:m7shR4WDcid+LpnVVqg5Uw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
use DateTime;

use List::Util qw(sum0);

use DCS::Constants qw(:boolean);

sub sequence {
  my $self = shift;

  return $self->result_source->schema->resultset('EventRegistration')->in_sequence($self->event->event_group->event_sequence_id)
    ->for_user($self->user);
}

sub to_hash {
  my $self   = shift;
  my %params = @_;

  my $er = {
    event_id  => $self->event_id,
    user      => $self->user->to_hash,
    fee       => $self->fee,
    bib_no    => $self->bib_no,
    is_public => ($self->is_public eq 'Y'),
  };

  my @donations = $self->donations;
  if (@donations || $self->fundraising_minimum) {
    $er->{fundraising} = {
      minimum => $self->fundraising_minimum,
      total   => sum0(map {$_->amount} @donations)
    };
    $er->{fundraising}->{donations} = [map {$_->to_hash} @donations] if (!exists($params{donations}) || $params{donations});
  }

  $er->{registered} = $self->registered eq 'Y' if ($self->registered);

  if ($params{complete}) {
    my $h = {
      registration => $er,
      event        => $self->event->to_hash
    };
    if (my $activity = $self->event->activities->search({user_id => $self->user_id})->first) {
      $h->{activity} = $activity->to_hash(event => $FALSE);

      if (my @results = $activity->result->event_results) {
        $h->{results} = [map {$_->to_hash} @results];
      }
    }
    return $h;
  }

  return $er;
}

1;
