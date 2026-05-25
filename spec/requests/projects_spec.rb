require 'rails_helper'

RSpec.describe "GET /projects.json", type: :request do
  describe "response structure" do
    it "returns a projects array and total_pages" do
      get "/projects.json"

      body = JSON.parse(response.body)
      expect(body).to include("projects", "total_pages")
      expect(body["projects"]).to be_an(Array)
    end
  end

  describe "archived filter" do
    it "returns only active projects by default" do
      active_project   = create(:project)
      archived_project = create(:project, archived: true)

      get "/projects.json"

      ids = JSON.parse(response.body)["projects"].map { |project| project["id"] }
      expect(ids).to contain_exactly(active_project.id)
    end

    it "returns only archived projects when archived=true" do
      active_project   = create(:project)
      archived_project = create(:project, archived: true)

      get "/projects.json", params: { archived: true }

      ids = JSON.parse(response.body)["projects"].map { |project| project["id"] }
      expect(ids).to contain_exactly(archived_project.id)
    end
  end

  describe "status filtering" do
    it "returns only live projects when live selected" do
      live_project = create(:project, :live)
      create(:project, :future)
      create(:project, :ended)

      get "/projects.json", params: { statuses: ["live"] }

      ids = JSON.parse(response.body)["projects"].map { |project| project["id"] }
      expect(ids).to contain_exactly(live_project.id)
    end

    it "returns only future projects when future selected" do
      future_project = create(:project, :future)
      create(:project, :live)
      create(:project, :ended)

      get "/projects.json", params: { statuses: ["future"] }

      ids = JSON.parse(response.body)["projects"].map { |project| project["id"] }
      expect(ids).to contain_exactly(future_project.id)
    end

    it "returns only ended projects when ended selected" do
      ended_project = create(:project, :ended)
      create(:project, :live)
      create(:project, :future)

      get "/projects.json", params: { statuses: ["ended"] }

      ids = JSON.parse(response.body)["projects"].map { |project| project["id"] }
      expect(ids).to contain_exactly(ended_project.id)
    end
  end

  describe "pagination" do
    it "returns maximum of 25 projects" do
      create_list(:project, 30)

      get "/projects.json"

      expect(JSON.parse(response.body)["projects"].length).to eq(25)
    end

    it "returns total_pages of 2 for 30 projects" do
      create_list(:project, 30)

      get "/projects.json"

      expect(JSON.parse(response.body)["total_pages"]).to eq(2)
    end

    it "returns total_pages of 1 when there are no projects" do
      get "/projects.json"

      expect(JSON.parse(response.body)["total_pages"]).to eq(1)
    end

    it "applies pagination after status filtering" do
      create_list(:project, 30, :live)
      create(:project, :ended)

      get "/projects.json", params: { statuses: ["live"] }

      body = JSON.parse(response.body)
      expect(body["total_pages"]).to eq(2)
      expect(body["projects"].length).to eq(25)
    end
  end

  describe "search function" do
    it "returns only projects whose name matches the search term" do
      matched_project     = create(:project, name: "Homer Simpsons' project")
      unmatched_project   = create(:project, name: "Bart Simpsons' project")

      get "/projects.json", params: { search: "homer" }

      ids = JSON.parse(response.body)["projects"].map { |project| project["id"] }
      expect(ids).to contain_exactly(matched_project.id)
    end

    it "is case-insensitive" do
      matched_project = create(:project, name: "Important Project")

      get "/projects.json", params: { search: "IMPORTANT" }

      ids = JSON.parse(response.body)["projects"].map { |project| project["id"] }
      expect(ids).to contain_exactly(matched_project.id)
    end

    it "returns all projects when search term is blank" do
      project_one = create(:project, name: "Expensive Project")
      project_two = create(:project, name: "Even More Expensive Project")

      get "/projects.json", params: { search: "" }

      ids = JSON.parse(response.body)["projects"].map { |project| project["id"] }
      expect(ids).to contain_exactly(project_one.id, project_two.id)
    end
  end
end
