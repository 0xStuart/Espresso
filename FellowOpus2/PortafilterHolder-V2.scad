// PortafilterHolder-V2.scad
// Solid-cylinder Fellow Opus portafilter holder, second design.

$fn = $preview ? 64 : 160;

/* [Part] */
// preview = funnel seated on the body; body / funnel = single part
Part = "preview"; // [preview, body, funnel]

/* [Body] */
Height = 60;
Diameter = 80;

/* [Bore] */
HoleDiameter = 59;
HoleDepth = 29.3;

/* [Side slot] */
// How much deeper than the bore the slot cuts
SlotExtraDepth = 7;
SlotWidth = 20;
// Y where the slot stops; 0 = through to the axis, hole radius = wall only
SlotFromCenter = 25;

/* [Funnel] */
// Upright collar above the body, same diameter
CollarHeight = 5;
// Height of the outward flare
FlareHeight = 20;
// Extra radius at the top of the flare (outer wall)
FunnelFlare = 15;
// Wall thickness at the top rim (base ring is thicker)
FunnelTopWall = 7;

/* [Funnel ear slots] */
EarWidth = 21;
EarHeight = 7;
// Angles around +Z; 0 = 3 o'clock (+X), 180 = 9 o'clock (−X)
EarAngles = [0, 180];

eps = 0.05;

slot_depth = HoleDepth + SlotExtraDepth;
r_outer = Diameter / 2;
r_inner = HoleDiameter / 2;
funnel_top_outer = r_outer + FunnelFlare;
funnel_top_inner = funnel_top_outer - FunnelTopWall;

module Body() {
    difference() {
        cylinder(d = Diameter, h = Height);

        translate([0, 0, Height - HoleDepth])
        cylinder(d = HoleDiameter, h = HoleDepth + eps);

        // Slot toward +Y (handle), from SlotFromCenter out through the wall
        translate([-SlotWidth / 2, SlotFromCenter, Height - slot_depth])
        cube([SlotWidth, Diameter / 2 - SlotFromCenter + eps, slot_depth + eps]);
    }
}

module EarSlot() {
    // Through the whole ring: from the axis out past the flared wall
    translate([0, -EarWidth / 2, -eps])
    cube([
        r_outer + FunnelFlare + eps,
        EarWidth,
        max(EarHeight, CollarHeight) + eps
    ]);
}

// Ring matching the body OD, then a collar and an outward flare
module Funnel() {
    difference() {
        rotate_extrude()
        polygon([
            [r_inner, 0],
            [r_outer, 0],
            [r_outer, CollarHeight],
            [funnel_top_outer, CollarHeight + FlareHeight],
            [funnel_top_inner, CollarHeight + FlareHeight],
            [r_inner, CollarHeight]
        ]);

        for (a = EarAngles)
            rotate([0, 0, a])
                EarSlot();
    }
}

if (Part == "body") {
    Body();
} else if (Part == "funnel") {
    Funnel();
} else {
    Body();
    translate([-(Diameter / 2 + r_outer + FunnelFlare + 10), 0, 0])
        Funnel();
}
