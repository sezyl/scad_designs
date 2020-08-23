// case_with_gasket.scad - bottom part of casing

box_h = 20;
box_d = 40;
box_w = 60;
box_wall = 4;
screw_r = 1.3;
screw_head = 7;
screw_outer = 3.5;
gasket_size = 2;
latch_size = 1;
pipe_dia = 21.34;

screw_distance = box_wall + screw_r;
screw_x = box_w/2 - screw_distance + gasket_size/2;
screw_y = box_d/2 - screw_distance + gasket_size/2;

scr_pos = [
  [-screw_x,  screw_y],
  [ screw_x,  screw_y],
  [-screw_x, -screw_y],
  [ screw_x, -screw_y],
];

// place 3d model
union() {
    translate([0, -box_d/2 - 10, box_h/2]) difference() {
        union() {
            *main_case();
            translate([-(box_w/2 - 18), 5, -box_h/2 + 2])
                sensor_catch();
        }
        translate([-(box_w/2-16), -2+25.4*0.17, -14])
            rotate([20,0,0]) oxygen_path();
        translate([-(box_w/2-16), -2-11.268, -14-25.4*0.28])
            rotate([-20,0,0]) oxygen_path();
    } 
    *translate([0, box_d/2 + 10, box_wall])
        rotate([0, 0, 0])
            cover_case();
}

module sensor_catch() union() {
    translate([0,-5,5])
        rcube([pipe_dia + 5, pipe_dia + 15, 12]);
    translate([0, 0, -7.5]) difference(){
        cylinder(h=15, d=pipe_dia+box_wall, center = true, $fn=50);
        cylinder(h=17, d=pipe_dia, center = true, $fn=50);
    }
}

i_dia = 25.4*0.12;
module oxygen_path() union() {
    translate([0, 0, 4])
        cylinder(h=6, d=i_dia, $fn=25);
    translate([5, 0, 10])
        rotate([90, -90, 0]) 
            torus_quarter(5, i_dia/2);   
    translate([4.9, 0, 15])
        rotate([90, 0, 90]) 
            cylinder(h=25.4*0.25*0.5, d=i_dia, $fn=25);
    translate([8.0, 0, 15])
        rotate([90, 0, 90]) 
            cylinder(h=13.5, d=i_dia, $fn=25);
}

module cover_case() difference()
{
    // full box - cover generic shape
    rcube([box_w, box_d, 2*box_wall]);
        
    // extrude inside
    translate([0,0,box_wall/2 + 1])
        rcube([box_w - 2*(screw_distance+screw_r+box_wall), box_d - 2*box_wall, box_wall + 2]);

    translate([0,0,box_wall/2 + 1])
        rcube([box_w - 2*box_wall, box_d - 2*(screw_distance+screw_r+box_wall), box_wall +2]);
    
    // extrude inside a little to create a latch
    translate([0, 0, box_wall + 1])
        cube([box_w - 2*latch_size, box_d - 2*latch_size, latch_size + 2], center = true);

    // screw holes
    for( i = [0:3] )
        translate([scr_pos[i][0], scr_pos[i][1], -box_wall - 1])
                screw_drill();
}

// main case shell
module main_case() difference() {
    // full box - case body
    rcube([box_w, box_d, box_h]);
    
    // screw holes
    for( i = [0:3] )
        translate([scr_pos[i][0], scr_pos[i][1], 0])
            cylinder(box_h+2, r = screw_r, center = true);
    
    // extrude inside
    translate([0,0,box_wall])
        rcube([box_w - 2*(screw_distance+screw_r+box_wall), box_d - 2*box_wall, box_h - box_wall]);

    translate([0,0,box_wall])
        rcube([box_w - 2*box_wall, box_d - 2*(screw_distance+screw_r+box_wall), box_h - box_wall]);
    
    // extrude latch for top cover
    translate( [0, 0, box_h/2] )
        edge_latch(box_w, box_d, latch_size);
    
    // space for gasket
    if(gasket_size>0)
        translate ([0, 0, box_h/2 + 0.5])
            gasket(box_w - box_wall -1, box_d - box_wall -1, screw_distance + screw_r - 1 , gasket_size);

}

module screw_drill()
{
    cylinder(h = screw_head/3, d1 = screw_head, d2 = screw_outer, center = false, $fn=25);
    translate([0, 0, 2*box_wall])
        cylinder(h = 4 * box_wall, d = screw_outer, center = true, $fn=25);
}

module rcube(dim)
{
    minkowski(){
        cube([dim[0] - 4, dim[1] - 4, dim[2]], center = true );
        cylinder(r = 2, center = true, $fn = 25);
    }
}

module edge_latch(w, d, s)
{
    // make edge grove
    for(x = [ -(w-s)/2-1, (w-s)/2+1 ] )
        translate( [ x , 0, 1 ] )
            cube( [s+2, d, s+2], center = true );

    for(y = [ -(d-s)/2-1, (d-s)/2+1 ] ) 
        translate( [ 0, y , 1 ] ) 
            cube( [w, s+2, s+2], center = true );

}

// x,y - gasket frame size, c - round diameter, d - grove diameter
module gasket(x, y, c, d) {
    union() {
        // c-shaped gasket groves
        translate([0, -y/2, 0])
            rotate([90, 0, 180])
                gasket_l(x - 2*c, d/2, c/2);
        translate([0, y/2, 0])
            rotate([90, 0, 0])
                gasket_l(x - 2*c, d/2, c/2);
        translate([-x/2, 0, 0])
            rotate([90, 0, 90])
                gasket_l(y - 2*c, d/2, c/2);
        translate([x/2, 0, 0])
            rotate([90, 0, -90])
                gasket_l(y - 2*c, d/2, c/2);
        
        // connect 4 gasket groves
        translate( [-(x-c)/2, -(y-c)/2, 0] )
            rotate( [0, 0, 0 ] )
                torus_quarter(d = c/2, r = d/2);

        translate( [(x-c)/2, -(y-c)/2, 0] )
            rotate( [0, 0, 90 ] )
                torus_quarter(d = c/2, r = d/2);

        translate( [(x-c)/2, (y-c)/2, 0] )
            rotate( [0, 0, 180 ] )
                torus_quarter(d = c/2, r = d/2);

        translate( [-(x-c)/2, (y-c)/2, 0] )
            rotate( [0, 0, 270 ] )
                torus_quarter(d = c/2, r = d/2);
    }
}

module gasket_l(l, d, r) {
    union() {
        rotate([0,90,0]) 
            cylinder(l - 2*r +0.1, r = d, center = true, $fn=25);

        translate( [(l - 2*r)/2, 0, r] ) 
            rotate([90, 90, 0])
                torus_quarter(d = r, r = d);

        translate( [-(l - 2*r)/2, 0, r] ) 
            rotate([90, 180, 0])
                torus_quarter(d = r, r = d);
    }
}


module torus_quarter(d, r) {
    rotate_extrude( angle = 92, $fn = 25 ) // extra 2 degrees to avoid gaps
        translate([d, 0, 0 ])
            circle(r, $fn = 25);
}
