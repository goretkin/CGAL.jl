using Documenter, CGAL

makedocs(
    modules = [CGAL],
    format = Documenter.HTML(),
    checkdocs = :exports,
    sitename = "CGAL.jl",
    pages = Any["index.md"]
)

deploydocs(
    repo = "github.com/goretkin/CGAL.jl.git",
)
