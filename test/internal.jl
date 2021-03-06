import Circuitscape: construct_node_map

# Construct nodemap tests
let
        gmap = [0 1 2
                2 0 0
                2 0 2]
        nodemap = construct_node_map(gmap, Matrix{Float64}(0,0))
        @test nodemap == [0 3 4
                          1 0 0
                          2 0 5]
end

let
        gmap = [0 1 2
               2 0 0
               2 0 2]
        polymap = [1 0 1
                   2 1 0
                   0 0 2]
        nodemap = construct_node_map(gmap, polymap)
        @test nodemap == [4  3  4
                          1  4  0
                          2  0  1]
end

let 
        gmap = [1 0 1
                0 1 0
                1 0 1]

        polymap = [1 0 1
                0 2 0
                2 0 0]

        r = construct_node_map(gmap, polymap)

        @test r == [1 0 1
                    0 2 0
                    2 0 3]
end

let 
    polymap = [ 1.0  2.0  0.0  0.0  0.0
                0.0  0.0  0.0  0.0  0.0
                0.0  0.0  0.0  0.0  0.0
                0.0  0.0  0.0  0.0  0.0
                1.0  0.0  0.0  0.0  2.0]

    gmap = [0    0    0    1.0   1.0
            0    0    0    3.01  2.0
            1.0  2.0  2.0  1.0   1.0
            1.0  2.0  2.0  1.0   1.0
            1.0  2.0  2.0  0     1.0]

    nodemap = construct_node_map(gmap, polymap)

    @test nodemap == [ 3.0  18.0  0.0  10.0  14.0
                       0.0   0.0  0.0  11.0  15.0
                       1.0   4.0  7.0  12.0  16.0
                       2.0   5.0  8.0  13.0  17.0
                       3.0   6.0  9.0   0.0  18.0]
end

let 

    cfg = Circuitscape.parse_config("input/raster/one_to_all/11/oneToAllVerify11.ini")
    r, hbmeta = Circuitscape.load_maps(cfg)

    cellmap = r.cellmap
    polymap = r.polymap
    points_rc = r.points_rc
    point_map = [ 1.0  2.0  0.0  0.0  0.0
                  0.0  0.0  0.0  0.0  0.0
                  3.0  0.0  0.0  7.0  0.0
                  4.0  0.0  0.0  0.0  0.0
                  1.0  0.0  0.0  0.0  2.0 ]

    r = Circuitscape.create_new_polymap(cellmap, polymap, points_rc, point_map = point_map)

    @test r == [ 1.0  2.0  0.0  0.0  0.0
                 0.0  0.0  0.0  0.0  0.0
                 12.0  0.0  0.0  2.0  0.0
                 1.0  0.0  0.0  0.0  0.0
                 1.0  0.0  0.0  0.0  2.0 ]
end

import Circuitscape: resolve_conflicts

@test resolve_conflicts([1,0,0], [1,0,0], :rmvgnd) == ([1, 0, 0], [0, 0, 0], [1, 0, 0])
@test resolve_conflicts([1,0,0], [1,0,0], :rmvsrc) == ([0, 0, 0], [1, 0, 0], [1, 0, 0])
@test resolve_conflicts([1,0,0], [1,0,0], :keepall) == ([1, 0, 0], [1, 0, 0], [1, 0, 0])
@test resolve_conflicts([1,0,0], [1,0,0], :rmvall) == ([0, 0, 0], [1, 0, 0], [1, 0, 0])

# Construct graph
import Circuitscape: construct_graph
let 
        gmap = [0 1 2
                2 0 0
                2 0 2]
        nodemap = [0 3 4
                   1 0 0
                   2 0 5]
        A,g = construct_graph(gmap, nodemap, false, true)
        r = full(A) - [0 2 0 0 0 
                       2 0 0 0 0
                       0 0 0 1.5 0
                       0 0 1.5 0 0
                       0 0 0 0 0]
        @test sum(abs2, r) < 1e-6
        A, g = construct_graph(gmap, nodemap, true, true)
        r = full(A) - [0 2 0 0 0 
                       2 0 0 0 0
                       0 0 0 1.3333 0
                       0 0 1.33333 0 0
                       0 0 0 0 0]
        @test sum(abs2, r) < 1e-6
        A,g = construct_graph(gmap, nodemap, false, false)
        r = full(A) - [0 2 1.06066 0 0 
                       2 0 0 0 0
                       1.06066 0 0 1.5 0
                       0 0 1.5 0 0
                       0 0 0 0 0]
        @test sum(abs2, r) < 1e-6
        A,g = construct_graph(gmap, nodemap, true, false)
        r = full(A) - [0 2 0.942809 0 0 
                       2 0 0 0 0
                       0.942809 0 0 1.3333 0
                       0 0 1.3333 0 0
                       0 0 0 0 0]
        @test sum(abs2, r) < 1e-6

end 
