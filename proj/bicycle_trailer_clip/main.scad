use <../../MCAD/boxes.scad>
include <../../round_anything/polyround.scad>

$fa=0.2;
$fs=0.2;
tiny = 0.005;

_r = 1.0;

deckel_h1 = 17.0;
deckel_t1 = 9.6;

deckel_h2 = 9.6;
deckel_t2 = 8.0;

deckel_h3 = 9.4;
deckel_t3 = 14.5;

deckel_h4 = 5.0;
deckel_t4 = 28.0; 

deckel_h5 = 12.2; 


hole_d = 4.0;
hole_dist =  13 - hole_d;
hole_height = 9.6/2;

hook_width = 18.2;
hook_top_hole_dist = 7.0 + hole_d/2;
inlay_depth=2.0;
inlay_height = hole_height + hook_top_hole_dist + 3.0;
inlay_width = hook_width + 1;

bracket_depth = 32.0;
bracket_height = 20.0;
bracket_widht = hook_width+6.0;

notch_height = 10.0; // more than deckel_h2/h3
notch_width = 8.5; // more than deckel_t2
notch_front_dist = 9.5 + inlay_depth; // deckel_t1 + inlay

foot_width = 15;

module bracket_base(extrude=true){
    _p = rel_radii_points([
        [notch_front_dist, 0],
        [0, notch_height], 
        [notch_width, 0],
        [0, -notch_height],
        [bracket_depth +inlay_depth - notch_front_dist-notch_width, 0],
        [0, bracket_height],
        [-(bracket_depth+inlay_depth), 0],
        [0, -bracket_height]
    ], _r =1*_r);
    if (extrude){
        translate([-inlay_depth, bracket_widht/2, 0]){
            rotate([90,0,0]){
                polyRoundExtrude(
                    _p, r1=_r, r2=_r, length=bracket_widht
                );
            }
        }
    } else {
        polygon(
            polyRound(_p)
        );
    }
};

module hook_inlay(extrude=true){
    /* subtraction to inlay and center hook */
    _p = rel_radii_points([
        [0, 0,0],
        [inlay_depth, 0,0],
        [0, inlay_height,0],
        [-inlay_depth, 0,0],
    ], _r =1*_r);
    if (extrude){
        translate([-inlay_depth, inlay_width/2, 0]){
            rotate([90,0,0]){
                extrudeWithRadius(length=inlay_width, r1=0, r2=0 ){
                    union(){
                        polygon(
                            polyRound(_p)
                        );
                        translate([inlay_depth-tiny, 0, 0])neg_champer(_r);
                    }
                }
            }
        }
    } else {
        union(){
            polygon(
                polyRound(_p)
            );
            translate([inlay_depth-tiny, 0, 0])neg_champer(_r);
        }
    }
};

module hook_holes() {
    /* holes to attach hoock to clip*/

    translate([0, -hole_dist/2 , 0])
    rotate([0, 90, 0])
    cylinder(h=3*bracket_depth, d1=hole_d, d2=hole_d, center=true);
    
    translate([0, +hole_dist/2 , 0])
    rotate([0, 90, 0])
    cylinder(h=3*bracket_depth, d1=hole_d, d2=hole_d, center=true);
}

module steg_hinten(extrude=true) {
    /* Connection of bracket base and left/right foot*/
    _back_width = bracket_depth + inlay_depth -notch_front_dist - notch_width; 
    _s = [
        [0,0],
        [0, notch_height ],
        [-1*(_back_width), 0],
        [0, -notch_height]
    ];
    _sr = rel_radii_points(_s, _r=_r);
    if (extrude){
        _l = 2.5*bracket_widht;
        _x = bracket_depth;
        translate([_x, _l/2, 0]){
            rotate([90, 0, 0]){
                polyRoundExtrude(_sr, r1=_r, r2=_r, length = _l);
            }
        }
    } else {
        polygon(
            polyRound(_sr)
        );
    }
}

module fuss_rechts(extrude=true) {
    _back_width = bracket_depth -notch_front_dist - notch_width; 
    _s = [
        [0,0],
        [deckel_t3, 0],
        [0, -deckel_h4],
        [deckel_t4-2, 0],
        [0, deckel_h4 + notch_height],
        [-(deckel_t4-2) - deckel_t3, 0]
    ];
    _sr = rel_radii_points(_s, _r=_r);
    if (extrude){
        _l = foot_width;//bracket_widht/2;
        _x = bracket_depth - _back_width - inlay_depth;
        difference(){
            translate([_x, 2.5*bracket_widht/2, 0]){
                rotate([90, 0, 0]){
                    polyRoundExtrude(_sr, r1=_r, r2=_r, length = _l);
                }

            }
            translate([_x + deckel_t3 + deckel_t4/2, 2.5*bracket_widht/2-_l/2, notch_height+2*tiny]){
                innen_6k();
            }
        }
    } else {
        polygon(
            polyRound(_sr)
        );
    }
}

module fuss_links(extrude=true){
    mirror([0, 1, 0])
        fuss_rechts(extrude);
}

module neg_champer(r=5, rot=[0,0,0]){ 
    /* helper shape to round of screw holes at the top of the clip */
    rotate(rot){
        translate([r, r, 0])
        rotate([0, 0, 180])
        intersection(){
            square(r);
            difference(){
                square(2*r, center=true);
                circle(r);
            }
        }
    }
};

module innen_6k(l=20, d_k=8.5, d_s=5.0, k=5.0, delta=.8, delta_r=1.0) {
    // default values for M5
    //d_k   head diameter
    //k     head height
    //l     length schraube ohne Kopf
    //d_s   durchmesser Schraube

    _d_k = d_k + delta;
    _d_s = d_s + delta;
    _k   = k + delta; 

    translate([0, 0, -_k])
    union(){
        extrudeWithRadius(length=_k, r1=delta_r){
            circle(_d_k/2);
        }
        translate([0, 0, _k-tiny]){
            mirror([0,0,1]){
                rotate_extrude(){
                    translate([_d_k/2-tiny, 0, 0])neg_champer(r=1);
                }
            }
        }
        translate([0, 0, -l-tiny]){
            cylinder(d=_d_s, h=l+tiny);
        }
    }


};

module bracket(){

    difference(){
        difference(){
            union(){
                bracket_base();
                fuss_rechts();
                fuss_links();
                steg_hinten();

            }
            translate([-tiny, 0, 0])hook_inlay();
        }
        translate([0, 0, hole_height])hook_holes();
    }
}

module deckel(){
    /* Abstract part the clip must fit to. (Debug and fit check only) */    
    deckel_points= rel_radii_points([
        [   0,0],
        [         0, deckel_h1],
        [ deckel_t1, 0],
        [         0, deckel_h2],
        [ deckel_t2, 0. ],
        [       0.0,-deckel_h3],
        [ deckel_t3, 0.],
        [ 0, -deckel_h4],
        [ deckel_t4, 0.],
        [ 0., -deckel_h5]
        ], _r=1.0);
    translate([0, 2*bracket_widht, -17]){
        rotate([90,0,0]){
            polyRoundExtrude(
                deckel_points, r1=_r, r2=_r, length=4*bracket_widht
            );
        }
    }
};

bracket();
color("red")deckel();
