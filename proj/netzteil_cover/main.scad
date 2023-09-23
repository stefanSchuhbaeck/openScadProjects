use <../../MCAD/boxes.scad>
/*
Bracket for power brick to cover the blue LED. The arms of the breaked are 
angelded to provided press fit. The 'fit_spring_dist' gives the distance 
of the arm is bend inwards in mm. In other words the bracket width is 
2*'fit_spring_dist' smaller at the open side compared to the closed side. 
*/
$fs=0.4;
$fa=1;
_c = 0.1; // union offset to ensure closed body
_cc = 0.2; // larger offset to ensure closed body

wall = 4.0; // thickness of clamp
height = 15.0; // heigth of clamp to cover LED
arm_length = 50.0; // 'arm'
radius = 1.2;
width_power_brick = 32.0;
fit_spring_dist = 1.3;  // 'spring' distance at 'arm_length'
                        // will reduce 'width_power_brick_outter' at 'arm_length' distance

// calculated variables
arm_length_outter = arm_length+2*wall;
width_power_brick_outter = width_power_brick+2*wall;
fit_angle = asin(fit_spring_dist/arm_length);


module arm(length=50, height=30, angle=0.0, width = 4.0, radius=2.0){
    rotate([0,0,angle])
    difference(){
        roundedCube([length, width+3*radius+_cc, height], radius, sidesonly=false, center=false);
        translate([0, width, 0])
        cube([length, width, height+_cc], center=false);
    }
}

// first arm
arm(length=arm_length_outter, height=height, angle=fit_angle, width=wall, radius=radius);

// second arm (mirrowed)
translate([0, width_power_brick_outter, 0])
mirror([0, 1, 0])
arm(length=arm_length_outter, height=height, angle=fit_angle, width=wall, radius=radius);

// front side (same shape as arms but shorter)
translate([-.1, _c, 0])
mirror([1, 0, 0])
arm(length=width_power_brick_outter-_cc, height=height, angle=90, width=wall, radius=radius);
