class LoincFieldRule < ActiveRecord::Base
  belongs_to :field_description
  belongs_to :loinc_item
  belongs_to :rule

  #  make sure all these keys are valid foreign keys
  validate :validate_instance
  def validate_instance
    errors.add(:base, "field_description_id is invalid!") unless field_description
    errors.add(:base, "loinc_item_id is invalid!") unless loinc_item
    errors.add(:base, "rule_id is invalid!") unless rule

    error_msg = "Cannot save duplicated record"
    cond = ["rule_id=? and loinc_item_id=? and field_description_id=?"]
    cond << rule_id
    cond << loinc_item_id
    cond << field_description_id
    if new_record? && rec = LoincFieldRule.where(cond).take
      # When saving a rule, associated loinc_field_rules will be replaced by
      # the ones generated by rule parser (rule.rb:line 504). The weird thing is
      # that has_many will try to save newly built loinc_field_rules
      # associations twice without updating their new_record? status value to
      # false in the second saving. This causes the failure in validating
      # duplicated loinc_field_rule records.
      #
      # Work around: remove the duplicated record before creating a new one as
      # the id of loinc_field_rules record is not used in this system, and the
      # operation will only accure when creating a new record.
      rec.destroy
      #errors.add(:base, "#{error_msg}: #{rec.display_name}")
    end
  end

  def display_name
    [ "rule:#{rule.name}",
      "loinc:#{loinc_item.loinc_num}",
      "field:#{field_description.target_field}"].join(" | ")
  end

end
