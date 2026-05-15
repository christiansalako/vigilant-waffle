class ProjectsController < ApplicationController
  def index
    respond_to do |format|
      format.html
      format.json do
        projects = params[:archived] == "true" ? Project.archived : Project.active
        statuses = Array(params[:statuses]).map(&:to_s).reject(&:empty?)
        projects = projects.select { |p| statuses.include?(p.lifecycle_status.to_s) } if statuses.any?
        @projects = projects
      end
    end
  end
end
