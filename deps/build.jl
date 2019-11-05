cgal_base_dir = joinpath(@__DIR__, "cgal")
download_dir = joinpath(@__DIR__, "downloads")

if !ispath(cgal_base_dir)
    mkpath(download_dir)
    zipfile = download("https://github.com/CGAL/cgal/archive/master.zip", joinpath(download_dir, "master.zip"))

    cd(download_dir) do
        run(`unzip $zipfile`)
    end

    mv(joinpath(download_dir, "cgal-master"), cgal_base_dir)
end

# TODO this is a fragile way to find the include dirs for boost, same as what CGAL would find.

sys_include_dir = joinpath(@__DIR__, "usr/include")
mkpath(sys_include_dir)

# cmake makes a bunch of files
cmake_out = begin cd(mktempdir()) do
 read(pipeline(`cmake -L $(cgal_base_dir)`), String)
end
end

m = match(r"Boost include dirs: (?<boost_include_dir>[^\s]*)", cmake_out)
sys_boost_include_dir = joinpath(m[:boost_include_dir], "boost")
symlink(sys_boost_include_dir, joinpath(sys_include_dir, "boost"))
