// PortafilterHolder.scad
// Parametric Fellow Opus portafilter holder (holder + foot).
//
// Recreates the two-part design published as "Fellow Opus Portafilter Holder"
// on Printables (model 1304051, alexandermeisel_, CC BY-NC): a C-shaped
// cradle that centres a bottomless portafilter under the grind chute, and a
// U-clip that snaps over the grinder base.
//
// Foot is a circular plate with a C-ring pocket and short U-clips that snap
// over the grinder base. Clip span is from the original "Foot V2" STL: 129 mm
// inner (Opus 1); Opus 2 is spec'd 130 mm — set GrinderWidth = 130 if 129 is
// tight. Walls 2.5 mm, lips 1 mm, channel 20.5 mm.

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
// Raise the outer rim so the top slopes down into the basket
RimSlope = 5.0;

/* [Foot clip — from original Foot V2 STL] */
// Inner wall-to-wall span. Original STL is 129 (Opus 1); Opus 2 is 130 mm
GrinderWidth = 130.2;
FootDiameter = 120;
// Clip run along the grinder, centred on the C
ClipLength = 40;
// Shift the C pocket along Y; + is toward the handle, − toward the grinder
CCutoutY = 5;
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

module WallProfile() {
    chamfer = min(LipChamfer, r_groove - r_inner);
    chamfer_z = groove_top - chamfer;
    // Starts at z=0 so the wall fuses with the base plate
    polygon([
        [r_inner, 0],
        [r_outer, 0],
        [r_outer, wall_h + RimSlope],
        [r_inner, wall_h],
        [r_inner, groove_top],
        [r_inner + chamfer, groove_top],
        [r_groove, chamfer_z],
        [r_groove, ShelfHeight],
        [r_inner, ShelfHeight]
    ]);
}

// Circular plate minus the handle-side U-slot; clips the wall to the base C
module HolderFootprint2D() {
    difference() {
        circle(r = r_outer);
        translate([-r_inner, 0])
            square([2 * r_inner, r_outer + 5]);
    }
}

// Same slot profile, swept straight along +Y so the portafilter can slide in
module WallArm() {
    translate([0, r_outer + eps, 0])
    rotate([90, 0, 0])
    linear_extrude(height = r_outer + 2 * eps)
        WallProfile();
}

module Holder() {
    difference() {
        union() {
            cylinder(r = r_outer, h = BaseThickness);

            intersection() {
                union() {
                    // Back half ends on the X axis so the straight arms meet flush
                    rotate([0, 0, 180])
                    rotate_extrude(angle = 180)
                        WallProfile();

                    WallArm();
                    mirror([1, 0, 0])
                        WallArm();
                }

                linear_extrude(height = wall_h + RimSlope)
                    HolderFootprint2D();
            }
        }

        translate([0, 0, -eps])
        cylinder(r = r_inner, h = wall_h + RimSlope + 2 * eps);

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
        union() {
            cylinder(d = FootDiameter, h = FootBase);

            // U-clip: width along X, ClipLength along Y, centred on the C
            translate([outer / 2, -ClipLength / 2, 0])
            rotate([0, 0, 90])
            rotate([90, 0, 90])
            linear_extrude(height = ClipLength)
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
        }

        // Through-cut for the holder ring; inner oval remains as a basket pad
        translate([0, CCutoutY, -eps])
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
    "Foot d=", FootDiameter,
    " clip=", ClipLength, "x", GrinderWidth + 2 * FootWall, "x",
    FootBase + FootChannel + FootLipThickness,
    " inner=", GrinderWidth,
    " cutout r=", r_outer + CutoutClearance
));
