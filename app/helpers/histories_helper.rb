module HistoriesHelper

  def history_wording(from, to)
    formatted_to = field_value_for_display to
		formatted_from = field_value_for_display from
		return "initially set to #{formatted_to}" if from.blank?
    "changed from #{formatted_from} to #{formatted_to}"
  end

  def flag_change_message(history)
    begin
      history['changes']['flag_message']['to']
    rescue
      ''
    end
  end
end
