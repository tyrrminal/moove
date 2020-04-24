#<<<
use utf8;
package Moove::Model::Result::GoalSpan;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Moove::Model::Result::GoalSpan

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::Relationship::Predicate>

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::InflateColumn::Time>

=item * L<DBIx::Class::Stash>

=back

=cut

__PACKAGE__->load_components(
  "Relationship::Predicate",
  "InflateColumn::DateTime",
  "InflateColumn::Time",
  "Stash",
);

=head1 TABLE: C<goal_span>

=cut

__PACKAGE__->table("goal_span");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 description

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "description",
  { data_type => "varchar", is_nullable => 0, size => 45 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<description_UNIQUE>

=over 4

=item * L</description>

=back

=cut

__PACKAGE__->add_unique_constraint("description_UNIQUE", ["description"]);

=head1 RELATIONS

=head2 goals

Type: has_many

Related object: L<Moove::Model::Result::Goal>

=cut

__PACKAGE__->has_many(
  "goals",
  "Moove::Model::Result::Goal",
  { "foreign.goal_span_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2020-04-24 13:28:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:AMQhAC7SNk/21YWGGSbFEA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
use DCS::Constants qw(:boolean);

sub datetimes_share_span {
  my $self = shift;
  my ($a1,@activities) = @_;

  foreach my $a2 (@activities) {
    if($self->description eq 'day') {
      return $FALSE unless($a1->truncate(to => 'day') == $a2->truncate(to => 'day'));

    } elsif($self->description eq 'week') {
      return $FALSE unless($a1->year == $a2->year && $a1->week_number == $a2->week_number);

    } elsif($self->description eq 'month') {
      return $FALSE unless($a1->year == $a2->year && $a1->month == $a2->month);

    } elsif($self->description eq 'quarter') {
      return $FALSE unless($a1->year == $a2->year && $a1->quarter == $a2->quarter);

    } elsif($self->description eq 'year') {
      return $FALSE unless($a1->year == $a2->year);
    }
  }

  return $TRUE;
}

sub sql_comp_func {
  my %map = (
    day   => [qw(YEAR MONTH DAYOFMONTH)],
    week  => [qw(YEAR WEEK)],
    month => [qw(YEAR MONTH)],
    year  => [qw(YEAR)]
  );
  return $map{shift->description};
}

1;
