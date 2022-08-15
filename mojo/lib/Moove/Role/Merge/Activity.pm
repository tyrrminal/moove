package Moove::Role::Merge::Activity;
use v5.36;

use Role::Tiny;
use DateTime;
use List::Util qw(max min);

use DCS::Constants qw(:symbols);

sub merge_notes ($self, @activities) {
  return join($NEWLINE x 2, map {$_->note} grep {$_->note} @activities),;
}

sub merge_group_nums ($self, @activities) {
  return max(map {$_->group_num} @activities) + 1;
}

sub merge_set_nums ($self, @activities) {
  return 1;
}

sub merge_visibility_types ($self, @activities) {
  return min(map {$_->visibility_type_id // 3} @activities),;
}

sub merge_created_ats ($self, @activities) {
  return min(map {$_->created_at} @activities);
}

sub merge_updated_ats ($self, @activities) {
  return DateTime->now;
}

1;
