class ProjectsController < ApplicationController
  PER_PAGE = 25

  STATUS_ORDER_SQL = <<~SQL
    CASE
      WHEN start_date IS NOT NULL AND end_date IS NOT NULL
           AND CURRENT_DATE BETWEEN start_date AND end_date THEN 1
      WHEN start_date IS NOT NULL AND CURRENT_DATE < start_date THEN 2
      WHEN end_date IS NOT NULL AND CURRENT_DATE > end_date THEN 3
      ELSE 4
    END
  SQL

  def index
    respond_to do |format|
      format.html
      format.json do
        projects = params[:archived] == "true" ? Project.archived : Project.active

        if params[:search].present?
          projects = projects.where("name ILIKE ?", "%#{params[:search]}%")
        end

        statuses = Array(params[:statuses]).map(&:to_s).reject(&:empty?)

        if statuses.any?
          scopes = statuses.filter_map do |status|
            case status
            when "live"    then projects.live
            when "future"  then projects.future
            when "ended"   then projects.ended
            when "not_set" then projects.not_set
            end
          end
          projects = scopes.reduce(:or)
        end

        if params[:sort_order].in?(%w[asc desc])
          projects = projects.order(name: params[:sort_order])
        else
          projects = projects.order(Arel.sql(STATUS_ORDER_SQL))
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
