// DisplayBracket_C-Beam_7B.scad
// Bracket for Waveshare_P4_7B_Case.scad on a vertical 4080 C-beam.
// Slides into the 40 x 20 mm C-channel like DisplayBracket_C-Beam.scad, and a
// front flange adds two T-keys in the outer slots of the 80 mm face (as BoilerPlate.scad).
// z=0 is the top end of the profile. +Z is up. +Y is out of the channel (toward the user).
// y=0 is the channel floor, y=ChannelDepth is the beam's front face.
// The insert occupies z=-InsertLength..0. The arm rises from z=0 at LeanAngle, leaning back.

$fn = $preview ? 64 : 200;

/* [Beam] */
BeamWidth = 80;
ChannelWidth = 39.95;
ChannelDepth = 20;
Clearance = 0.2;

// T-slots inside the C-channel, from the 4080 drawing
SlotPitch = 20;
SlotOpening = 6.25;
SlotInnerWidth = 9.16;
SlotDepth = 4.50;
SlotLip = 2.2;

// Outer T-slots on the 80 mm face, from BoilerPlate.scad
OuterSlotSpacing = 60;
OuterSlotLip = 2;

/* [Bracket] */
InsertLength = 30;
FlangeThickness = 4;     // plate in front of the beam face carrying the outer keys
ArmLength = 75;
LeanAngle = 40;          // degrees from vertical, top of the arm leans away from the user
Overlap = 1;
ArmRecessMargin = 3;     // border around the back-face recess
ArmRecessDepthFraction = 0.8; // fraction of arm depth, from the back

/* [Display mount] */
// M3 pattern matching MountHole* in Waveshare_P4_7B_Case.scad
MountHoleSpacingX = 60;
MountHoleSpacingZ = 56;
MountHoleDiameter = 3.4;
Cut_CableWindow = true;  // through window between the holes, for cables and airflow
CableWindowWidth = 40;
CableWindowLength = 40;

InsertW = ChannelWidth - 2*Clearance;
FaceY = ChannelDepth + Clearance;       // back of the flange
FrontY = FaceY + FlangeThickness;       // front of the flange and arm
ArmDepth = FrontY - Clearance;

assert(MountHoleSpacingX/2 + MountHoleDiameter/2 < BeamWidth/2 - ArmRecessMargin,
       "Mount holes run off the arm");
assert(MountHoleSpacingZ/2 + MountHoleDiameter/2 < ArmLength/2 - ArmRecessMargin,
       "Mount holes run off the arm");
assert(CableWindowWidth/2 < MountHoleSpacingX/2 - MountHoleDiameter,
       "Cable window cuts into the mount holes");
assert(OuterSlotSpacing/2 + SlotInnerWidth/2 < BeamWidth/2, "Outer keys overhang the beam");

// 2D T-key. Origin is the slot face; +Y is into the slot, -Y into the bracket.
module TSlotKeyProfile(lip) {
    stem_w = SlotOpening - 2*Clearance;
    head_w = SlotInnerWidth - 2*Clearance;
    head_top = SlotDepth - Clearance;
    polygon(points = [
        [-stem_w/2, -1],
        [ stem_w/2, -1],
        [ stem_w/2, lip],
        [ head_w/2, lip],
        [ head_w/2, head_top],
        [-head_w/2, head_top],
        [-head_w/2, lip],
        [-stem_w/2, lip]
    ]);
}

module TSlotKey(lip = SlotLip) {
    linear_extrude(height = InsertLength)
        TSlotKeyProfile(lip);
}

module Insert() {
    translate([-InsertW/2, Clearance, -InsertLength])
        cube([InsertW, FrontY - Clearance, InsertLength]);

    // Floor slots, facing up into the channel, 20 mm pitch
    for (x = [-SlotPitch/2, SlotPitch/2])
        translate([x, 0, -InsertLength])
            mirror([0, 1, 0])
                TSlotKey();

    // Inner wall slots, facing into the channel, centred 10 mm above the floor
    translate([ChannelWidth/2, ChannelDepth/2, -InsertLength])
        rotate([0, 0, -90])
            TSlotKey();
    translate([-ChannelWidth/2, ChannelDepth/2, -InsertLength])
        rotate([0, 0, 90])
            TSlotKey();
}

// Plate across the 80 mm face with keys into the outer slots
module Flange() {
    translate([-BeamWidth/2, FaceY, -InsertLength])
        cube([BeamWidth, FlangeThickness, InsertLength]);

    for (x = [-OuterSlotSpacing/2, OuterSlotSpacing/2])
        translate([x, FaceY, -InsertLength])
            mirror([0, 1, 0])
                TSlotKey(OuterSlotLip + 2*Clearance); // FaceY sits Clearance off the face
}

module ArmHoles() {
    translate([0, -1, ArmLength/2])
        rotate([-90, 0, 0]) {
            for (dx = [-1, 1], dz = [-1, 1])
                translate([dx * MountHoleSpacingX/2, dz * MountHoleSpacingZ/2, 0])
                    cylinder(h = ArmDepth + 2, d = MountHoleDiameter);
            if (Cut_CableWindow)
                translate([-CableWindowWidth/2, -CableWindowLength/2, 0])
                    cube([CableWindowWidth, CableWindowLength, ArmDepth + 2]);
        }
}

module Arm() {
    difference() {
        translate([-BeamWidth/2, 0, -Overlap])
            cube([BeamWidth, ArmDepth, ArmLength + Overlap]);
        // Rectangular recess in the back face for nut access, inset ArmRecessMargin
        translate([-BeamWidth/2 + ArmRecessMargin, -1, ArmRecessMargin])
            cube([
                BeamWidth - 2*ArmRecessMargin,
                1 + ArmDepth * ArmRecessDepthFraction,
                ArmLength - 2*ArmRecessMargin
            ]);
        ArmHoles();
    }
}

// Solid wedge between the top of the beam and the leaned arm
module Junction() {
    hull() {
        translate([-BeamWidth/2, Clearance, -0.01])
            cube([BeamWidth, ArmDepth, 0.01]);
        translate([0, Clearance, 0])
            rotate([LeanAngle, 0, 0])
                translate([-BeamWidth/2, 0, 0])
                    cube([BeamWidth, ArmDepth, 0.01]);
    }
}

module SlotVoid(lip) {
    polygon(points = [
        [-SlotOpening/2, -0.1],
        [ SlotOpening/2, -0.1],
        [ SlotOpening/2, lip],
        [ SlotInnerWidth/2, lip],
        [ SlotInnerWidth/2, SlotDepth],
        [-SlotInnerWidth/2, SlotDepth],
        [-SlotInnerWidth/2, lip],
        [-SlotOpening/2, lip]
    ]);
}

// Top of the 4080: channel plus the two outer slots, shown only in preview
module BeamGhost() {
    translate([0, 0, -InsertLength])
        linear_extrude(InsertLength)
            difference() {
                translate([-BeamWidth/2, ChannelDepth - 40]) square([BeamWidth, 40]);
                translate([-ChannelWidth/2, 0]) square([ChannelWidth, ChannelDepth + 1]);
                for (x = [-OuterSlotSpacing/2, OuterSlotSpacing/2])
                    translate([x, ChannelDepth]) mirror([0, 1]) SlotVoid(OuterSlotLip);
                for (x = [-SlotPitch/2, SlotPitch/2])
                    translate([x, 0]) mirror([0, 1]) SlotVoid(SlotLip);
                translate([ChannelWidth/2, ChannelDepth/2]) rotate(-90) SlotVoid(SlotLip);
                translate([-ChannelWidth/2, ChannelDepth/2]) rotate(90) SlotVoid(SlotLip);
            }
}

module DisplayBracket() {
    union() {
        Insert();
        Flange();
        // The arm is full beam width, so nothing above may dip below the beam's top end
        intersection() {
            union() {
                Junction();
                translate([0, Clearance, 0])
                    rotate([LeanAngle, 0, 0])
                        Arm();
            }
            translate([-BeamWidth, -2*ArmLength, 0])
                cube([2*BeamWidth, 4*ArmLength, 2*ArmLength]);
        }
    }
}

if ($preview)
    %BeamGhost();

DisplayBracket();
