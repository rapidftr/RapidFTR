module HistoriesHelper

  def history_wording(from, to)
    return "initially set to #{to}" if from.blank?
    "changed from #{from} to #{to}"
  end
end