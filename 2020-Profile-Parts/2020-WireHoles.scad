// 2020 wire-hole block. Slides into a 2020 V-slot profile.
// The extrusion face is y=0. +Y is into the slot. The block stands in -Y.
// X is across the 20 mm face, centered. Z runs along the extrusion.
// SlotLeft is the z=0 end. SlotRight is the z=BlockLength end.
// Each end key points out of that face and runs the full block height, so it
// slides into a vertical 2020 standing on that end.

$fn = $preview ? 64 : 128;


PanelWidth = 130;
PanelIntoVSlot=6.1 - 0.3; //Extend the panel out onto the slot area

BlockLength = (PanelWidth/2) - PanelIntoVSlot;
BlockWidth = 20;
BlockHeight = 20;

// Raised sides with a slot for a 3 mm panel. Set PanelSlot = false for a plain block.
PanelSlot = true;
PanelGap = 3.3;
SideRaise = 4;

// Through-holes across the block, centered on the block height.
// 90 degree countersink on both side faces. The hole is centered in BlockHeight,
// so the countersink has to stay under that height.
WireHoles = 3;
WireHoleDiameter = 10;
WireCountersinkDiameter = WireHoleDiameter + 3;

// T-keys on the ends, for vertical 2020s.
SlotLeft = false;
SlotRight = true;

// Slot section matches the V-slot groove used on the C-beam brackets.
SlotOpening = 6.25;
SlotInnerWidth = 9.16;
SlotDepth = 4.50;
SlotLip = 2;
SlotClearance = 0.2;
// Gap between a key head and the underside of the slot lip. The block sits flush
// on the profile face, so this is the total play across the lip (0 was too tight).
SlotLipClearance = 0.1;
KeyOverlap = 1;

ProfileSize = 20;
CenterBore = 4.2;

assert(BlockWidth > 0 && BlockHeight > 0 && BlockLength > 0, "Block size must be positive");
if (PanelSlot) {
    assert(PanelGap > 0 && PanelGap < BlockWidth, "Panel gap does not fit in the block");
    assert(SideRaise > 0, "Side raise must be positive");
}
assert(WireHoles >= 1 && WireHoleDiameter > 0, "Wire hole size must be positive");
assert(WireHoleDiameter < BlockHeight, "Wire hole is taller than the block");
assert(WireHoleDiameter < BlockLength / WireHoles, "Wire holes run into each other or the ends");
assert(WireCountersinkDiameter > WireHoleDiameter, "Countersink is smaller than the hole");
assert(WireCountersinkDiameter < BlockHeight, "Countersink breaks out of the block height");
assert(WireCountersinkDiameter < BlockLength / WireHoles, "Countersinks run into each other or the ends");
assert(SlotOpening < SlotInnerWidth, "Slot head is narrower than the opening");
assert(SlotLip < SlotDepth, "Slot lip is deeper than the slot");
assert(SlotOpening - 2 * SlotClearance > 0, "Clearance closes the slot opening");
assert(SlotInnerWidth / 2 < ProfileSize / 2, "Slot head is wider than the profile");

// +Y is into the slot. The stem overlaps the block by KeyOverlap.
module t_slot_key_profile() {
    stem_w = SlotOpening - 2 * SlotClearance;
    head_w = SlotInnerWidth - 2 * SlotClearance;
    head_start = SlotLip + SlotLipClearance;
    head_end = SlotDepth - SlotClearance;
    polygon(points = [
        [-stem_w / 2, -KeyOverlap],
        [ stem_w / 2, -KeyOverlap],
        [ stem_w / 2, head_start],
        [ head_w / 2, head_start],
        [ head_w / 2, head_end],
        [-head_w / 2, head_end],
        [-head_w / 2, head_start],
        [-stem_w / 2, head_start]
    ]);
}

// Centers split the length into equal parts.
module wire_holes() {
    cs_depth = (WireCountersinkDiameter - WireHoleDiameter) / 2;
    for (i = [0 : WireHoles - 1]) {
        z = BlockLength * (i + 0.5) / WireHoles;
        translate([0, -BlockHeight / 2, z])
            rotate([0, 90, 0])
                cylinder(h = BlockWidth + 2, d = WireHoleDiameter, center = true);
        for (side = [-1, 1])
            translate([side * BlockWidth / 2, -BlockHeight / 2, z])
                rotate([0, -side * 90, 0])
                    translate([0, 0, -0.02])
                        cylinder(h = cs_depth + 0.02, d1 = WireCountersinkDiameter, d2 = WireHoleDiameter);
    }
}

module slider() {
    difference() {
        union() {
            translate([-BlockWidth / 2, -BlockHeight, 0])
                cube([BlockWidth, BlockHeight, BlockLength]);

            // Channel runs along the extrusion. The Panel slides in from either end.
            if (PanelSlot) {
                side_w = (BlockWidth - PanelGap) / 2;
                for (x0 = [-BlockWidth / 2, PanelGap / 2])
                    translate([x0, -(BlockHeight + SideRaise), 0])
                        cube([side_w, SideRaise, BlockLength]);
            }

            linear_extrude(height = BlockLength)
                t_slot_key_profile();

            end_keys();
        }
        wire_holes();
    }
}

// Cross-section is the same T as the main key. Extrude it along Y, and point
// the head out of the end face. The stem overlaps the block by KeyOverlap.
module end_keys() {
    if (SlotRight)
        translate([0, 0, BlockLength])
            rotate([90, 0, 0])
                linear_extrude(height = BlockHeight)
                    t_slot_key_profile();
    if (SlotLeft)
        rotate([90, 0, 0])
            linear_extrude(height = BlockHeight)
                mirror([0, 1])
                    t_slot_key_profile();
}

module t_slot_void() {
    polygon(points = [
        [-SlotOpening / 2, 0],
        [ SlotOpening / 2, 0],
        [ SlotOpening / 2, SlotLip],
        [ SlotInnerWidth / 2, SlotLip],
        [ SlotInnerWidth / 2, SlotDepth + 0.2],
        [-SlotInnerWidth / 2, SlotDepth + 0.2],
        [-SlotInnerWidth / 2, SlotLip],
        [-SlotOpening / 2, SlotLip]
    ]);
}

// Horizontal 2020 under the block, plus a vertical 2020 on each enabled end.
module profile_ghost() {
    extra = 15;
    z0 = SlotLeft ? 0 : -extra;
    z1 = SlotRight ? BlockLength : BlockLength + extra;
    translate([-ProfileSize / 2, 0, z0])
        difference() {
            cube([ProfileSize, ProfileSize, z1 - z0]);
            translate([ProfileSize / 2, ProfileSize / 2, -1])
                cylinder(h = z1 - z0 + 2, d = CenterBore);
            translate([ProfileSize / 2, -0.1, -1])
                linear_extrude(height = z1 - z0 + 2)
                    t_slot_void();
        }

    if (SlotLeft)
        vertical_profile_ghost(-1);
    if (SlotRight)
        vertical_profile_ghost(1);
}

// outward +1 puts the profile on the z=BlockLength end. The slot faces the block.
module vertical_profile_ghost(outward) {
    z_face = outward > 0 ? BlockLength : 0;
    translate([0, 0, z_face])
        rotate([0, outward > 0 ? 0 : 180, 0])
            translate([-ProfileSize / 2, -ProfileSize, 0])
                difference() {
                    cube([ProfileSize, ProfileSize, ProfileSize]);
                    translate([ProfileSize / 2, -1, ProfileSize / 2])
                        rotate([-90, 0, 0])
                            cylinder(h = ProfileSize + 2, d = CenterBore);
                    translate([ProfileSize / 2, ProfileSize + 1, -0.1])
                        rotate([90, 0, 0])
                            linear_extrude(height = ProfileSize + 2)
                                t_slot_void();
                }
}

if ($preview)
    %profile_ghost();

slider();
