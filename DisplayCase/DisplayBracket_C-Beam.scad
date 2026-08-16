// DisplayBracket_C-Beam.scad
// Bracket that slides into the 40 x 20 mm C-channel of a vertical 4080 profile.
// z=0 is the top end of the profile. +Z is up. +Y is out of the channel (toward the user).
// The insert occupies z=-InsertLength..0. The arm rises from z=0 at LeanAngle, leaning back.

$fn = $preview ? 100 : 500;

ChannelWidth = 40;
ChannelDepth = 20;
InsertLength = 30;
ArmLength = 40;
LeanAngle = 20; // degrees from vertical, top of the arm leans away from the user
Clearance = 0.2;
Overlap = 1;
ArmRecessMargin = 2; // border around the back-face recess
ArmRecessDepthFraction = 0.5; // fraction of arm depth, from the back
CenterHoleDiameter = 10;
OuterHoleDiameter = 3.2; // M3 clearance
DiceHoleOffset = 12; // outer holes at ±this in X and Z from the face centre

// T-slots inside the C-channel, from the 4080 drawing
SlotPitch = 20;
SlotOpening = 6.25;
SlotInnerWidth = 9.16;
SlotDepth = 4.30;
SlotLip = 1.80;

InsertW = ChannelWidth - 2*Clearance;
InsertD = ChannelDepth - 2*Clearance;

// 2D T-key. Origin is the channel face; +Y is into the slot, -Y into the insert.
module TSlotKeyProfile() {
    stem_w = SlotOpening - 2*Clearance;
    head_w = SlotInnerWidth - 2*Clearance;
    head_top = SlotDepth - Clearance;
    polygon(points = [
        [-stem_w/2, -1],
        [ stem_w/2, -1],
        [ stem_w/2, SlotLip],
        [ head_w/2, SlotLip],
        [ head_w/2, head_top],
        [-head_w/2, head_top],
        [-head_w/2, SlotLip],
        [-stem_w/2, SlotLip]
    ]);
}

module TSlotKey() {
    linear_extrude(height = InsertLength)
        TSlotKeyProfile();
}

module Insert() {
    translate([-InsertW/2, Clearance, -InsertLength])
        cube([InsertW, InsertD, InsertLength]);

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

// Dice-five holes through the front face, centred on the arm
module ArmHoles() {
    translate([0, -1, ArmLength/2])
        rotate([-90, 0, 0]) {
            cylinder(h = InsertD + 2, d = CenterHoleDiameter);
            for (dx = [-1, 1], dz = [-1, 1])
                translate([dx * DiceHoleOffset, dz * DiceHoleOffset, 0])
                    cylinder(h = InsertD + 2, d = OuterHoleDiameter);
        }
}

module Arm() {
    difference() {
        translate([-InsertW/2, 0, -Overlap])
            cube([InsertW, InsertD, ArmLength + Overlap]);
        // Rectangular recess in the back face, inset ArmRecessMargin on all sides
        translate([
            -InsertW/2 + ArmRecessMargin,
            -1,
            ArmRecessMargin
        ])
            cube([
                InsertW - 2*ArmRecessMargin,
                1 + InsertD * ArmRecessDepthFraction,
                ArmLength - 2*ArmRecessMargin
            ]);
        ArmHoles();
    }
}

// Solid wedge between the horizontal insert and the leaned arm
module Junction() {
    hull() {
        translate([-InsertW/2, Clearance, -0.01])
            cube([InsertW, InsertD, 0.01]);
        translate([0, Clearance, 0])
            rotate([LeanAngle, 0, 0])
                translate([-InsertW/2, 0, 0])
                    cube([InsertW, InsertD, 0.01]);
    }
}

module ChannelGhost() {
    translate([0, 0, -InsertLength])
        difference() {
            translate([-ChannelWidth, -ChannelDepth, 0])
                cube([ChannelWidth*2, ChannelDepth*2, InsertLength]);
            translate([-ChannelWidth/2, 0, -1])
                cube([ChannelWidth, ChannelDepth + 1, InsertLength + 2]);
        }
}

module DisplayBracket() {
    union() {
        Insert();
        Junction();
        translate([0, Clearance, 0])
            rotate([LeanAngle, 0, 0])
                Arm();
    }
}

if ($preview)
    %ChannelGhost();

DisplayBracket();
