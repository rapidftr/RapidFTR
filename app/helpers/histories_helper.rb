module HistoriesHelper

  def history_wording(from, to)
    return "initially set to #{to}" if from.blank?
    "changed from #{from} to #{to}"
  end

  def flag_change_message(history)
    begin
      history['changes']['flag_message']['to']
    rescue
      ''
    end
  end
end