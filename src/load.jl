# https://github.com/JuliaInterop/Cxx.jl/blob/d74704b3eeb6dfd9c82e21fad4bd55a700e2256b/src/bootstrap.cpp#L1419-L1427
# Need RTTI due to:
# cgal/STL_Extension/include/CGAL/Handle_for_virtual.h:39:14: error: cannot use typeid with -fno-rtti
ENV["JULIA_CXX_RTTI"] = 1
# note, if you get `error: run-time type information was disabled in PCH file but is currently enabled`
# then you should do `Pkg.build("Cxx")`
# https://github.com/JuliaInterop/Cxx.jl/pull/313#issuecomment-324859107
using Cxx

deps_path = realpath(joinpath(@__DIR__, "..", "deps"))
cgal_base_path = joinpath(deps_path, "cgal")

boost_include_path = joinpath(deps_path, "usr/include")
Cxx.addHeaderDir(boost_include_path, kind=C_System)

find_cgal_package_include_dir_path(cgal_package) = joinpath(cgal_base_path, cgal_package, "include")

function find_dependencies0(cgal_package_name, depth=0)
  dependencies_file_path = joinpath(cgal_base_path, cgal_package_name, "package_info", cgal_package_name, "dependencies")
  return readlines(open(dependencies_file_path))
end

expand_deps(deps) = reduce(union, (Set(find_dependencies0(dep)) for dep in deps))

"""
dependencies of P contain P
"""
function find_dependencies(cgal_package_name)
  deps = Set([cgal_package_name])
  n = 0
  # iterate until fixed point
  while n != length(deps)
    n = length(deps)
    deps = expand_deps(deps)
  end
  return deps
end

for P in setdiff(find_dependencies("Intersections_3"), Set([]))
  #println("include dir for $P")
  Cxx.addHeaderDir(find_cgal_package_include_dir_path(P), kind=Cxx.C_System)
end

# to choose Geometry Kernel ??
geom_kernel_include_dir_path = joinpath(cgal_base_path, "Kernel_23/include")
#println("include dir for geometry kernel")
Cxx.addHeaderDir(geom_kernel_include_dir_path)


#println("")
Cxx.cxxinclude(joinpath(find_cgal_package_include_dir_path("Intersections_3"), "CGAL/Intersections_3/Triangle_3_Triangle_3.h"))
