using CGAL
using Test

using CGAL.Cxx

cxx"""
#include <CGAL/Exact_predicates_inexact_constructions_kernel.h>

typedef CGAL::Exact_predicates_inexact_constructions_kernel K;
typedef K::Point_3      Point_3;
typedef K::Vector_3     Vector_3;
typedef K::Triangle_3   Triangle_3;

"""


indexable_to_array(v::Cxx.CxxCore.CppValue, n) = [icxx"auto r =$(v)[$i]; r;" for i = 0:(n-1)]
indexable_to_array(v::Cxx.CxxCore.CppPtr, n) = [icxx"auto r =(*($(v)))[$i]; r;" for i = 0:(n-1)]

@testset "Vector_3 - construct/add" begin
    pv1 = @cxxnew Vector_3(10, 20, 30)
    pv2 = @cxxnew Vector_3(1, 2, 3)

    v3 = icxx"*$pv1 + *$pv2;"

    @test 11 == icxx"auto r = $(v3).x(); r;"
    @test 22 == icxx"auto r = $(v3).y(); r;"
    @test 33 == icxx"auto r = $(v3).z(); r;"

    @test indexable_to_array(pv1, 3) == [10, 20, 30]
    @test indexable_to_array(pv2, 3) == [1, 2, 3]
    @test indexable_to_array(v3, 3) == [11, 22, 33]
end

@testset "Triangle_3" begin
    tri1 = icxx"Triangle_3(Point_3(1,-1,0), Point_3(-1,-1,0), Point_3(0,1,0));"
    tri2 = icxx"Triangle_3(Point_3(1,-1,1), Point_3(-1,-1,1), Point_3(0,1,1));"
    tri3 = icxx"Triangle_3(Point_3(1,0,-1), Point_3(-1,0,-1), Point_3(0,0,1));"
    @test icxx"do_intersect($tri1, $tri1);" == true
    @test icxx"do_intersect($tri1, $tri2);" == false
    @test icxx"do_intersect($tri1, $tri3);" == true

    @test @cxx CGAL::do_intersect(tri1, tri3) == true

    @test icxx"$tri1.squared_area();" == 4
end
