class Project < ApplicationRecord
  has_many :personnels

  scope :active, -> { where(archived: false) }
  scope :archived, -> { where(archived: true) }
  scope :live,    -> { where("start_date IS NOT NULL AND end_date IS NOT NULL AND CURRENT_DATE BETWEEN start_date AND end_date") }
  scope :future,  -> { where("start_date IS NOT NULL AND CURRENT_DATE < start_date") }
  scope :ended,   -> { where("end_date IS NOT NULL AND CURRENT_DATE > end_date") }
  scope :not_set, -> { where.not(id: live).where.not(id: future).where.not(id: ended) }

  def lifecycle_status
    [:live, :future, :ended].find {|method| send(:"#{method}?") } || :not_set
  end

  private

  def live?
    [start_date, end_date].all?(&:present?) && Date.today.between?(start_date, end_date)
  end

  def future?
    start_date.present? && Date.today < start_date
  end

  def ended?
    end_date.present? && Date.today > end_date
  end
end
