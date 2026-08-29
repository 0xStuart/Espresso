// PortafilterHolder.scad
// Parametric Fellow Opus portafilter holder (holder + foot).
//
// Recreates the two-part design published as "Fellow Opus Portafilter Holder"
// on Printables (model 1304051, alexandermeisel_, CC BY-NC): a C-shaped
// cradle that centres a bottomless portafilter under the grind chute, and a
// U-clip that snaps over the grinder base.
//
// Foot dimensions are taken from the original "Foot V2" STL: 134 x 20 x 25 mm
// overall, 129 mm inner span (Opus 1 body width), 2.5 mm walls, 1 mm lips,
// 20.5 mm channel height. Opus 2 is spec'd 130 mm wide; set GrinderWidth = 130
// if 129 is tight.

$fn = $preview ? 64 : 160;

/* [Part] */
// preview = both laid out; holder / foot = single printable part
Part = "preview"; // [preview, holder, foot]

/* [Portafilter (defaults: 58mm Gaggia)] */
BasketDiameter = 60.5;
EarSpan = 70;
EarThickness = 6.2;
Clearance = 0.6;

/* [Holder] */
// Underside of ears above the tray when the basket sits on the tray
ShelfHeight = 35;
RetainingLip = 4.0;
// Wall arc in degrees (opening is 360 minus this, facing +Y / the handle)
WallSweep = 200;
WallThickness = 8.5;
BaseThickness = 4;
LipChamfer = 3.0;

/* [Foot clip — from original Foot V2 STL] */
// Inner wall-to-wall span. Original STL is 129 (Opus 1); Opus 2 is 130 mm
GrinderWidth = 129;
// Extra plate beyond the holder (handle side is front)
// Back extra is derived so C-centre to foot back is FootBackFromCenter
FootBackFromCenter = 42;
FootFrontExtra = 0;
// Radial clearance so the holder drops into the foot
CutoutClearance = 0.1;
FootBase = 4;
FootWall = 2.5;
FootLip = 0.1;
FootChannel = 20.5;
FootLipThickness = 2.0;

eps = 0.05;

opening_angle = 360 - WallSweep;
r_inner = BasketDiameter / 2 + Clearance;
// Groove radius is large enough that the ears clear the opening chord
r_groove = (EarSpan / 2 + Clearance) / sin(opening_angle / 2) + 0.4;
r_outer = r_groove + WallThickness;
groove_h = max(EarThickness + Clearance, LipChamfer + 1.2);
groove_top = ShelfHeight + groove_h;
wall_h = groove_top + RetainingLip;
FootBackExtra = FootBackFromCenter - r_outer;
foot_depth = 2 * r_outer + FootBackExtra + FootFrontExtra;

module WallProfile() {
    chamfer = min(LipChamfer, r_groove - r_inner);
    chamfer_z = groove_top - chamfer;
    // Starts at z=0 so the wall fuses with the base plate
    polygon([
        [r_inner, 0],
        [r_outer, 0],
        [r_outer, wall_h],
        [r_inner, wall_h],
        [r_inner, groove_top],
        [r_inner + chamfer, groove_top],
        [r_groove, chamfer_z],
        [r_groove, ShelfHeight],
        [r_inner, ShelfHeight]
    ]);
}

module Holder() {
    difference() {
        union() {
            cylinder(r = r_outer, h = BaseThickness);

            rotate([0, 0, 90 + opening_angle / 2])
            rotate_extrude(angle = WallSweep)
                WallProfile();
        }

        translate([0, 0, -eps])
        cylinder(r = r_inner, h = wall_h + 2 * eps);

        // U-slot so the basket can slide in from the handle side (+Y)
        translate([-r_inner, 0, -eps])
        cube([2 * r_inner, r_outer + 5, BaseThickness + 2 * eps]);
    }
}

// C-ring of the holder base. The foot pocket follows this so the oval
// inside (where the basket sits) stays filled.
module HolderRing2D() {
    difference() {
        circle(r = r_outer);
        circle(r = r_inner);
        translate([-r_inner, 0])
            square([2 * r_inner, r_outer + 5]);
    }
}

module Foot() {
    outer = GrinderWidth + 2 * FootWall;
    lip_z = FootBase + FootChannel;
    top_z = lip_z + FootLipThickness;

    difference() {
        // U-clip: width along X, depth along Y, centred on the holder
        translate([outer / 2, -(r_outer + FootBackExtra), 0])
        rotate([0, 0, 90])
        rotate([90, 0, 90])
        linear_extrude(height = foot_depth)
        polygon([
            [0, 0],
            [outer, 0],
            [outer, top_z],
            [outer - FootWall - FootLip, top_z],
            [outer - FootWall - FootLip, lip_z],
            [outer - FootWall, lip_z],
            [outer - FootWall, FootBase],
            [FootWall, FootBase],
            [FootWall, lip_z],
            [FootWall + FootLip, lip_z],
            [FootWall + FootLip, top_z],
            [0, top_z]
        ]);

        // Through-cut for the holder ring; inner oval remains as a basket pad
        translate([0, 0, -eps])
        linear_extrude(height = FootBase + 2 * eps)
            offset(delta = CutoutClearance)
                HolderRing2D();
    }
}

module Preview() {
    Foot();
    translate([(GrinderWidth + 2 * FootWall) / 2 + r_outer + 10, 0, 0])
        Holder();
}

if (Part == "holder") {
    Holder();
} else if (Part == "foot") {
    Foot();
} else {
    Preview();
}

echo(str(
    "Holder OD=", 2 * r_outer,
    " hole=", 2 * r_inner,
    " groove ID=", 2 * r_groove,
    " wall_h=", wall_h,
    " opening=", opening_angle, "deg ",
    "Foot ", GrinderWidth + 2 * FootWall, "x", foot_depth, "x",
    FootBase + FootChannel + FootLipThickness,
    " inner=", GrinderWidth,
    " cutout r=", r_outer + CutoutClearance
));
