// 2020 wire-hole block. Slides into a 2020 V-slot profile.
// The extrusion face is y=0. +Y is into the slot. The block stands in -Y.
// X is across the 20 mm face, centered. Z runs along the extrusion.

$fn = $preview ? 64 : 128;

BlockWidth = 20;
BlockHeight = 10;
BlockLength = 30;

// Raised sides with a slot for a 3 mm sheet. Set SheetSlot = false for a plain block.
SheetSlot = true;
SheetGap = 3.1;
SideRaise = 4;

// Through-holes across the block, centered on the block height.
// 90 degree countersink on both side faces. The hole is centered in BlockHeight,
// so the countersink has to stay under that height.
WireHoles = 2;
WireHoleDiameter = 8;
WireCountersinkDiameter = 9.5;

// Slot section matches the V-slot groove used on the C-beam brackets.
SlotOpening = 6.25;
SlotInnerWidth = 9.16;
SlotDepth = 4.50;
SlotLip = 2;
SlotClearance = 0.2;
KeyOverlap = 1;

ProfileSize = 20;
CenterBore = 4.2;

assert(BlockWidth > 0 && BlockHeight > 0 && BlockLength > 0, "Block size must be positive");
if (SheetSlot) {
    assert(SheetGap > 0 && SheetGap < BlockWidth, "Sheet gap does not fit in the block");
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
    head_end = SlotDepth - SlotClearance;
    polygon(points = [
        [-stem_w / 2, -KeyOverlap],
        [ stem_w / 2, -KeyOverlap],
        [ stem_w / 2, SlotLip],
        [ head_w / 2, SlotLip],
        [ head_w / 2, head_end],
        [-head_w / 2, head_end],
        [-head_w / 2, SlotLip],
        [-stem_w / 2, SlotLip]
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

            // Channel runs along the extrusion. The sheet slides in from either end.
            if (SheetSlot) {
                side_w = (BlockWidth - SheetGap) / 2;
                for (x0 = [-BlockWidth / 2, SheetGap / 2])
                    translate([x0, -(BlockHeight + SideRaise), 0])
                        cube([side_w, SideRaise, BlockLength]);
            }

            linear_extrude(height = BlockLength)
                t_slot_key_profile();
        }
        wire_holes();
    }
}

// 2020 section, shown only in preview. The slot void is the simplified T the key uses.
module profile_ghost() {
    extra = 15;
    ghost_len = BlockLength + 2 * extra;
    translate([-ProfileSize / 2, 0, -extra])
        difference() {
            cube([ProfileSize, ProfileSize, ghost_len]);
            translate([ProfileSize / 2, ProfileSize / 2, -1])
                cylinder(h = ghost_len + 2, d = CenterBore);
            translate([ProfileSize / 2, -0.1, -1])
                linear_extrude(height = ghost_len + 2)
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
}

if ($preview)
    %profile_ghost();

slider();
