class ProjectsController < ApplicationController
  PER_PAGE = 25

  LIFECYCLE_STATUS_SQL = <<~SQL
    CASE
      WHEN start_date IS NOT NULL AND end_date IS NOT NULL
           AND CURRENT_DATE BETWEEN start_date AND end_date THEN 'live'
      WHEN start_date IS NOT NULL AND CURRENT_DATE < start_date THEN 'future'
      WHEN end_date IS NOT NULL AND CURRENT_DATE > end_date THEN 'ended'
      ELSE 'not_set'
    END
  SQL

  def index
    respond_to do |format|
      format.html
      format.json do
        projects = params[:archived] == "true" ? Project.archived : Project.active
        statuses = Array(params[:statuses]).map(&:to_s).reject(&:empty?)
        
        if statuses.any?
          projects = projects.where("(#{LIFECYCLE_STATUS_SQL}) IN (?)", statuses)
        end

        total      = projects.count
        page       = (params[:page] || 1).to_i
        total_pages = [(total.to_f / PER_PAGE).ceil, 1].max

        @projects    = projects.offset((page - 1) * PER_PAGE).limit(PER_PAGE)
        @total_pages = total_pages
      end
    end
  end
end
