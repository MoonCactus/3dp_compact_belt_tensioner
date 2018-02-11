/*
 * Belt/puller tensioner for 2020 Aluminum Extrusion
 * This was made for a Tronxy X1 printer, but it obviously
 * would be suitable to any 6mm belt on 20x20 extrusion systems.
 * 
 * jeremie.francois@gmail.com
 * 
 * This thing is inspired by fessyfoo's https://www.thingiverse.com/thing:2502801,
 * but it was rewritten from scratch in Openscad (source was not provided anyway).
 * My goal was mostly to make it more compact and easier to print even.
 * 
 */
print_what="ring"; // all, body, plunger, ring

tol=0.01;
debug=0;

rail_insert_length=6;

belt_width= 1+6+1;

bearing_width= 5.2;
bearing_id= 5;
bearing_ids= 8; // internal shoulder diameter
bearing_od= 16;

screw_d= 4.8;
screw_head_d= 8;
screw_head_recess=2.2;

thread_delta_d= 0.4; // freeplay, added diameter on the ring/nut
thread_angle=50; // make printing easier
thread_pitch=1.8;
thread_size= 2.1;

tot_height=25;
thread_h= 14;

plunger_d=21;
plunger_notch_depth=1.8;
plunger_freeplay=0.3;

ring_h= 6;


thread_segment_len= 10; // [2:30]

gutterh=tot_height-1;

module ccube(s)     { translate([-s[0]/2,-s[1]/2,0]) cube(s); }
module cxcube(s)    { translate([-s[0]/2,0,0]) cube(s); }
module chain_hull() { for(c=[1:$children-1]) hull() { children(c-1); children(c); } }

axis_dh= tot_height - bearing_od/2 + ring_h;

module axis_pos()
{
	translate([0,0,axis_dh])
		rotate([90,0,0])
			for(c=[0:$children-1])
				children(c);
}


module tslot(h,below=false)
{
	translate([0,4.375,0])
	{
		if(below==false)
			cxcube([5.24,7,h]); // arrow body
		hull()
		{
			cxcube([5.24,0.01,h]); // arrow head
			translate([0,2.99,0])
				cxcube([11.24,0.26,h]); // arrow shoulders
		}
	}
}

module tslot_head()
{
	for(s=[-1,1]) scale([1,s,1])
	{
		translate([-10,10,0])
			hull()
			{
				cube([20,3,rail_insert_length-2]);
				translate([1,0,rail_insert_length-1])
					cube([18,2,1]);
			}
		tslot(h=rail_insert_length);
		hull() // overhang friendly bevel
		{
			tslot(0.01);
			translate([0,2.6,-2])
				scale([1,0.8,1])
				tslot(0.01,false);
		}
	}
}

module plunger_rails(delta=0, added_h=0)
{
	for(sx=[-1,1]) for(sy=[-1,1]) scale([sx,sy,1])
		rotate([0,0,45])
			translate([plunger_d/2-plunger_notch_depth-delta*1.44,0,-tol])
				rotate([0,0,-45])
					cube([3,3,gutterh+added_h+tol*2]);
}

module plunger_body(delta=0., added_h=0, add_delta_d=0,add_delta_h=8)
{
	difference()
	{
		union()
		{
			hull()
			{
				cylinder(d=plunger_d-delta*2,h=gutterh-4-delta+added_h);
*				cylinder(d=plunger_d-8-delta*2,h=gutterh-delta+added_h);
				ccube([(plunger_d-8)*2/3, (plunger_d-8), gutterh-delta+added_h]);
			}
			union()
			{
				cylinder(d=plunger_d-delta*2+add_delta_d,h=thread_h-ring_h);
				translate([0,0,thread_h-ring_h-tol])
					cylinder(d1=plunger_d-delta*2+add_delta_d, d2=plunger_d-delta*2, h=1);
			}
		}
		plunger_rails(delta=delta, added_h=added_h);
	}
}

module body()
{
	difference()
	{
		// Main body
		union()
		{
			tslot_head();
			hull() // outer shape
			{
				translate([0,0,-tot_height+tol])
					cylinder(d=26,h=tol, $fs=0.8,$fa=0.8);
				cube([20,26,0.02],center=true);
			}
		}

		// Main openings
		translate([0,0,4-tot_height-tol])
		{
			ccube([30, belt_width+2*tol, tot_height+rail_insert_length]); // pulley
			ccube([screw_head_d+2*tol, 30, tot_height-7-tol]); // screw (bearing axis)
		}
		
		translate([0,0,-tot_height])
			plunger_body(delta=0, add_delta_d=1,add_delta_h=8);
	}
}

module plunger()
{
	difference()
	{
		union()
		{
			difference()
			{
				plunger_body(delta=plunger_freeplay, added_h=ring_h);
				cylinder(d=plunger_d+2, h=thread_h-tol);
			}
			metric_thread(diameter=plunger_d, length=thread_h, pitch=thread_pitch, thread_size=thread_size, angle=thread_angle, leadin=2, internal=false);
		}
		plunger_rails(delta=plunger_freeplay, added_h= ring_h);

		// Flats for head and screw
		axis_pos()
		{
			for(s=[-1,1]) scale([1,1,s])
				translate([0,0,plunger_d/2-screw_head_recess])
					cylinder(d1=screw_head_d, d2=screw_head_d+3, h=screw_head_recess+tol);
			
		}
		
		difference()
		{
			axis_pos()
				union()
			{
				cylinder(d=bearing_od+6, h=belt_width, center=true);
				cube([30, bearing_od, belt_width],center=true);
			}
			
			axis_pos()
			{
				for(s=[-1,1]) scale([1,1,s])
					translate([0,0,bearing_width/2])
						cylinder(d1=bearing_ids, d2=bearing_ids+3, h=(belt_width-bearing_width)/2+tol);
				%cylinder(d=bearing_od, h=bearing_width, center=true);
			}
		}
		
		axis_pos()
		{
			cylinder(d=screw_d,h=30, $fa=1,$fs=1);
			scale([1,1,-1]) cylinder(d=bearing_id,h=30, $fa=1,$fs=1);
		}
	}
}

module ring()
{
	hex_flat_distance= 26;

	module nut_shape(d,h)
	{
		x1=d/2; x2=x1+h/2;
		intersection()
		{
			cylinder(h=h, r=(d/2)/sin(60), $fn=6);
			rotate_extrude(convexity=1, $fn=6*round(d*PI/3))
				polygon([ [0,0],[x1,0],[x2,h/2],[x1,h],[0,h] ]);
		}
	}
	
	difference()
	{
		nut_shape(d=hex_flat_distance,h=ring_h);
		translate([0,0,-tol])
			metric_thread(diameter=plunger_d+thread_delta_d, length=ring_h+2*tol, pitch=thread_pitch, thread_size=thread_size, angle=thread_angle, internal=true);
	}
}

difference()
{
	union()
	{
		if(print_what=="all" || print_what=="body") color([0.9,1,1]) body();
	
		if(print_what=="all" || print_what=="plunger") translate([0,0,-tot_height-ring_h])
			plunger();
		
		if(print_what=="all" || print_what=="ring") translate([0,0,-tot_height-ring_h-0.1])
			color([1,0.2,0.2]) ring();
	}
	if(debug) translate([0,0,-tot_height-1]) rotate([0,0,15]) cube(100);
}

include <threads.scad>  // from http://dkprojects.net/openscad-threads/
