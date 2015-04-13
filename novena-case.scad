
$fs = 0.01;
$fa = 6;

board_width = 121;
board_height = 150;
board_thickness = 1.8;
board_under_clearance = 1.7;
board_around_clearance = 0.5;
board_hole_offset = 3;

port_wall_thickness = 2;
normal_wall_thickness = 3;
floor_thickness = 4.1;
ceiling_thickness = 3.7;

screw_hole_radius = 1.4;
spacer_barrel_length = 30;
mounting_nut_depth = 2.25;
mounting_nut_radius = 3;
mounting_screw_head_depth = 1.4 + 0.25;
mounting_screw_head_radius = 2.6;

vertical_split_height = 10.35;

full_width = board_width + (board_around_clearance * 2) + port_wall_thickness + normal_wall_thickness;
full_height = board_height + (board_around_clearance * 2) + (normal_wall_thickness * 2);
full_depth = floor_thickness + ceiling_thickness + spacer_barrel_length + board_under_clearance + board_thickness;

show_placeholder_board = false;

module novena_case() {
    difference() {
        union() {
            difference() {
                outside_volume();
                inside_volume();
            }
            
            translate([0, 0, (board_under_clearance / 2) + floor_thickness])
            board_mounting_holes(
                h=board_under_clearance,
                r=screw_hole_radius + 1
            );
        }
        
        // Top-to-bottom holes for the screw threads.
        board_mounting_holes(h=full_height * 3);
        
        // Countersink for nuts at the bottom
        board_mounting_holes(
            h=mounting_nut_depth * 2,
            r=mounting_nut_radius
        );

        // Countersink for screws at the top
        translate([0, 0, full_depth])
        board_mounting_holes(
            h=mounting_screw_head_depth * 2,
            r=mounting_screw_head_radius
        );
    }
}

module outside_volume() {
    translate([-full_width / 2, -full_height / 2, 0])
    cube([full_width, full_height, full_depth]);
}

module inside_volume() {
    translate([
        (-full_width / 2) + port_wall_thickness,
        (-full_height / 2) + normal_wall_thickness,
        floor_thickness]
    )
    cube([
        full_width - port_wall_thickness - normal_wall_thickness,
        full_height - (normal_wall_thickness * 2),
        full_depth - floor_thickness - ceiling_thickness]
    );
}

module board_mounting_hole(h, r) {
    cylinder(r=r, h=h, center=true);
}

module board_mounting_holes(h=1, r=screw_hole_radius) {
    translate([
        (board_width / 2) - board_hole_offset,
        (board_height / 2) - board_hole_offset,
        0
    ])
    board_mounting_hole(h, r);

    translate([
        -(board_width / 2) + board_hole_offset,
        (board_height / 2) - board_hole_offset,
        0
    ])
    board_mounting_hole(h, r);

    translate([
        (board_width / 2) - board_hole_offset,
        -(board_height / 2) + board_hole_offset,
        0
    ])
    board_mounting_hole(h, r);

    translate([
        -(board_width / 2) + board_hole_offset,
        -(board_height / 2) + board_hole_offset,
        0
    ])
    board_mounting_hole(h, r);

    translate([
        board_width / 2 - 35.619,
        board_height / 2 - 72.781,
        0
    ])
    board_mounting_hole(h, r);

}

module placeholder_board() {
    z_offset = floor_thickness + board_under_clearance;

    color([0, 0.25, 0])
    difference() {
        translate([-board_width / 2, -board_height / 2, z_offset])
        cube([board_width, board_height, board_thickness]);

        board_mounting_holes(h=(z_offset + floor_thickness + board_under_clearance + 1) * 2);
    }
}

module bottom_volume() {
    cube([full_width + 2, full_height + 2, vertical_split_height * 2], center=true);
}

module novena_case_bottom() {
    color([0.5, 0.5, 0.5])
    intersection() {
        novena_case();
        bottom_volume();
    }
}

module novena_case_top() {
    color([0.5, 0.5, 0.5])
    difference() {
        novena_case();
        bottom_volume();
    }
}

translate([-full_width / 1.5, 0, 0]) {
    if (show_placeholder_board) placeholder_board();
    novena_case_bottom();
}

translate([full_width / 1.5, 0, full_depth]) {
    rotate(v=[0, 1, 0], a=180) {
        if (show_placeholder_board) placeholder_board();
        novena_case_top();
    }
}
