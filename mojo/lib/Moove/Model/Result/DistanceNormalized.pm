#<<<
use utf8;
package Moove::Model::Result::DistanceNormalized;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Moove::Model::Result::DistanceNormalized - VIEW

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
__PACKAGE__->table_class("DBIx::Class::ResultSource::View");

=head1 TABLE: C<DistanceNormalized>

=cut

__PACKAGE__->table("DistanceNormalized");
__PACKAGE__->result_source_instance->view_definition("select `d`.`id` AS `id`,case when `uom`.`inverted` = 'Y' then 1 / (`d`.`value` * `uom`.`normalization_factor`) else `d`.`value` * `uom`.`normalization_factor` end AS `value`,coalesce(`uom`.`normal_unit_id`,`d`.`unit_of_measure_id`) AS `unit_of_measure_id` from (`moove_dev`.`Distance` `d` join `moove_dev`.`UnitOfMeasure` `uom` on(`d`.`unit_of_measure_id` = `uom`.`id`)) order by `d`.`id`");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 value

  data_type: 'decimal'
  is_nullable: 1
  size: [27,13]

=head2 unit_of_measure_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "value",
  { data_type => "decimal", is_nullable => 1, size => [27, 13] },
  "unit_of_measure_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
);
#>>>
use v5.38;

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-07-09 12:32:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ELJKw0iM49NG3RCiu1A6Uw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->set_primary_key("id");

1;
