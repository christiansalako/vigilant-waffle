import React, { useState, useEffect } from "react";
import axios from "axios";
import { ArrowUp, ArrowDown, ListChevronsUpDown } from "lucide-react"; // responsible for iconography  

const navLinks = [
  { name: "Dashboard", icon: "🏠" },
  { name: "Projects", icon: "📁" },
  { name: "Personnel", icon: "👥" },
  { name: "Settings", icon: "⚙️" },
];

export default function ProjectsIndex() {
  const activeRoute = "Projects";

  const [projects, setProjects] = useState([]);
  const [archived, setArchived] = useState(false);
  const [selectedStatuses, setSelectedStatuses] = useState([]);
  const [sortingDirection, setSortingDirection] = useState(null); // null | "asc" | "desc"
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);

  // Re-fetch whenever filters or page changes.
  useEffect(() => {
    axios
      .get("/projects.json", {
        params: {
          archived,
          statuses: selectedStatuses,
          page,
        },
      })
      .then((res) => {
        setProjects(res.data.projects);
        setTotalPages(res.data.total_pages);
      });
  }, [archived, selectedStatuses, page]);

  function toggleStatus(status) {
    setPage(1);
    setSelectedStatuses((prev) =>
      prev.includes(status)
        ? prev.filter((s) => s !== status)
        : [...prev, status],
    );
  }

  // Cycles, on each click, through ascending, descending and null states
  function toggleSort() {
    setSortingDirection((prev) => {
      if (prev === null) return "asc";
      if (prev === "asc") return "desc";
      return null;
    });
  }

  const sortedProjects = [...projects].sort((a, b) => {
    // skips sorting unless sortDirection is set to 'asc'/'desc'
    if (!sortingDirection) return 0;

    // guards against null/empty project names 
    // returns empty string if so
    const nameA = a.name ?? "";
    const nameB = b.name ?? "";
    return sortingDirection === "asc"
      ? nameA.localeCompare(nameB)
      : nameB.localeCompare(nameA);
  });

  return (
    <div className="min-h-screen flex bg-gray-50">
      {/* Sidepanel */}
      <aside
        className="w-64 bg-primary text-white flex flex-col py-8 px-4 shadow-lg"
        aria-label="Sidebar"
      >
        <header className="mb-10 text-2xl font-bold tracking-tight flex items-center gap-2">
          <span className="text-3xl">🤝</span>
          <span>HandsHQ</span>
        </header>
        <nav className="flex flex-col gap-2" aria-label="Main navigation">
          {navLinks.map((link) => {
            const isActive = link.name === activeRoute;
            return (
              // eslint-disable-next-line jsx-a11y/anchor-is-valid
              <a
                key={link.name}
                href="#"
                className={`flex items-center gap-3 px-3 py-2 rounded-lg font-medium text-lg transition
                  ${
                    isActive
                      ? "bg-white text-primary shadow font-bold"
                      : "hover:bg-blue-600"
                  }
                `}
                aria-current={isActive ? "page" : undefined}
              >
                <span>{link.icon}</span>
                {link.name}
              </a>
            );
          })}
        </nav>
        <div className="mt-8 flex flex-col gap-6">
          <button
            onClick={() => { setArchived((prev) => !prev); setPage(1); }}
            className={`w-full px-3 py-2 rounded-lg font-medium text-sm transition text-left ${
              archived
                ? "bg-white text-primary font-bold shadow"
                : "bg-blue-100 bg-opacity-20 text-blue-100 hover:bg-blue-600"
            }`}
          >
            {archived ? "Viewing archived" : "View archived"}
          </button>

          <div>
            <p className="text-xs font-semibold uppercase text-blue-200 tracking-wider mb-2">
              Status
            </p>
            {[
              { value: "live", label: "Live" },
              { value: "future", label: "Future" },
              { value: "ended", label: "Ended" },
              { value: "not_set", label: "Not set" },
            ].map(({ value, label }) => (
              <label
                key={value}
                className="flex items-center gap-2 py-1 cursor-pointer text-sm text-white"
              >
                <input
                  type="checkbox"
                  checked={selectedStatuses.includes(value)}
                  onChange={() => toggleStatus(value)}
                  className="rounded"
                />
                {label}
              </label>
            ))}
          </div>
        </div>
      </aside>

      {/* Main content */}
      <main className="flex-1 flex flex-col items-center py-10">
        <header>
          <h1 className="text-3xl font-bold mb-8 text-primary">Projects</h1>
        </header>
        <section
          className="overflow-x-auto w-full max-w-4xl shadow-xl rounded-lg bg-white border border-gray-200"
          aria-labelledby="projects-table-title"
        >
          <table
            className="min-w-full divide-y divide-gray-200"
            role="table"
            aria-label="Projects table"
          >
            <thead className="bg-primary">
              <tr>
                <th
                  scope="col"
                  className="px-6 py-3 text-left text-xs font-semibold text-white uppercase tracking-wider"
                >
                  <button onClick={toggleSort} className="flex items-center gap-2" data-testid="sort-name-button">
                    Name
                    {sortingDirection === "asc" ? <ArrowUp size={12} /> : sortingDirection === "desc" ? <ArrowDown size={12} /> : <ListChevronsUpDown size={14} />} 
                  </button>
                </th>
                <th
                  scope="col"
                  className="px-6 py-3 text-left text-xs font-semibold text-white uppercase tracking-wider"
                >
                  Start date
                </th>
                <th
                  scope="col"
                  className="px-6 py-3 text-left text-xs font-semibold text-white uppercase tracking-wider"
                >
                  End date
                </th>
                <th
                  scope="col"
                  className="px-6 py-3 text-left text-xs font-semibold text-white uppercase tracking-wider"
                >
                  Status
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-100">
              {sortedProjects.map((project) => (
                <tr key={project.id} className="hover:bg-blue-50 transition">
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900 font-medium flex items-center gap-2">
                    <span className="inline-block w-2 h-2 rounded-full bg-green mr-2"></span>
                    {project.name}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-700">
                    {project.start_date}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-700">
                    {project.end_date}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm">
                    <span className="inline-block px-2 py-1 rounded-full text-xs font-semibold bg-orange text-white">
                      {project.lifecycle_status || "Active"}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </section>

        {/*** Pagination ***/}
        <div className="flex items-center justify-between mt-4 w-full max-w-4xl">
          <button
            onClick={() => setPage((p) => p - 1)}
            disabled={page === 1}
            className="px-4 py-2 text-sm font-medium text-primary border border-primary rounded-lg"
          >
            Previous
          </button>
          <span className="text-sm text-gray-600">
            Page {page} of {totalPages}
          </span>
          <button
            onClick={() => setPage((p) => p + 1)}
            disabled={page === totalPages}
            className="px-4 py-2 text-sm font-medium text-primary border border-primary rounded-lg"
          >
            Next
          </button>
        </div>
      </main>
    </div>
  );
}
