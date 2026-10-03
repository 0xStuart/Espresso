// BoilerPlate: wedge plate with a center circular cutout, four corner screw holes,
// and two T-rails on the thick edge for a vertical 4080.
// Hole pitch is center-to-center between adjacent holes.
// -Y is the front, +Y is the back. The hole face is flat on z=0.
// Thickness grows in -Z, from FrontThickness at the front to BackThickness at the back.

$fn = $preview ? 64 : 128;

PlateSize = 91.4;
FrontThickness = 8;
BackThickness = 32;

CutoutDiameter = 82.76; // 260 mm circumference
// Right-angled step in the flat hole face, cut downward. The through hole stays CutoutDiameter.
CounterSinkDia = CutoutDiameter + 6;
CounterSinkDepth = 2.5;

// Adjacent-hole spacing. Pattern is centered on the plate.
HoleSpacing = 73.3;
// ISO 273 medium clearance for an M5 screw.
M5HoleDiameter = 5.5;
// Square nut pockets open through the sloped bottom. The ceiling is horizontal,
// parallel to the top face. These are the distances from the top down to it.
NutSize = 8.2;
FrontNutRemain = FrontThickness - 3;
BackNutRemain = BackThickness - 10;
// Arc centered on each screw, so the corner wall matches the straight edges.
CornerRadius = (PlateSize - HoleSpacing) / 2;

// Two vertical T-rails on the thick back edge, for the outer slots of a vertical 4080.
// Slot section matches DisplayBracket_C-Beam.scad.
MountSpacing = 60;
SlotOpening = 6.25;
SlotInnerWidth = 9.16;
SlotDepth =4.50;
SlotLip = 2;
SlotClearance = 0.2;

CutoutRadius = CutoutDiameter / 2;
HoleCenterRadius = (HoleSpacing / 2) * sqrt(2);
assert(CutoutDiameter < PlateSize, "Cutout is larger than the plate");
assert(HoleSpacing + M5HoleDiameter < PlateSize, "Screw holes extend past the plate edge");
assert(HoleCenterRadius - M5HoleDiameter / 2 > CutoutRadius,
       "Screw holes intersect the center cutout");
assert(CornerRadius > M5HoleDiameter / 2, "Corner radius cuts into a screw hole");
assert(BackThickness > FrontThickness, "Back is not thicker than the front");
assert(CounterSinkDepth < FrontThickness, "Countersink goes through the front of the plate");
assert(CounterSinkDia < PlateSize, "Countersink is larger than the plate");
assert(HoleCenterRadius - M5HoleDiameter / 2 > CounterSinkDia / 2,
       "Countersink intersects a screw hole");
assert(MountSpacing / 2 + SlotInnerWidth / 2 < PlateSize / 2 - CornerRadius,
       "A mount runs into a rounded corner");
assert(FrontNutRemain > 0 && BackNutRemain > 0, "Nut pocket breaks through the top");
assert(NutSize / 2 * sqrt(2) < CornerRadius, "Square nut breaks out of a corner");
assert((HoleSpacing / 2 - NutSize / 2) * sqrt(2) > CounterSinkDia / 2,
       "Square nut intersects the countersink");

function plate_thickness(y) =
    FrontThickness
    + (BackThickness - FrontThickness) * (y + PlateSize / 2) / PlateSize;

assert(plate_thickness(-HoleSpacing / 2) > FrontNutRemain,
       "Front nut pocket comes out through the bottom");
assert(plate_thickness(HoleSpacing / 2) > BackNutRemain,
       "Back nut pocket comes out through the bottom");

module rounded_profile() {
    offset(r = CornerRadius)
        square([PlateSize - 2 * CornerRadius, PlateSize - 2 * CornerRadius], center = true);
}

// Flat face at z=0. Front (-Y) drops to -front_h, back (+Y) drops to -back_h.
module wedge_block(front_h, back_h) {
    extra = 2;
    hull() {
        translate([-PlateSize, -PlateSize / 2 - extra, -front_h])
            cube([PlateSize * 2, extra, front_h]);
        translate([-PlateSize, PlateSize / 2, -back_h])
            cube([PlateSize * 2, extra, back_h]);
    }
}

module rounded_plate() {
    intersection() {
        translate([0, 0, -(BackThickness + 1)])
            linear_extrude(height = BackThickness + 1)
                rounded_profile();
        wedge_block(FrontThickness, BackThickness);
    }
}

// +Y is into the slot. The stem overlaps the plate by 1 mm.
module t_slot_key_profile() {
    stem_w = SlotOpening - 2 * SlotClearance;
    head_w = SlotInnerWidth - 2 * SlotClearance;
    head_end = SlotDepth - SlotClearance;
    polygon(points = [
        [-stem_w / 2, -1],
        [ stem_w / 2, -1],
        [ stem_w / 2, SlotLip],
        [ head_w / 2, SlotLip],
        [ head_w / 2, head_end],
        [-head_w / 2, head_end],
        [-head_w / 2, SlotLip],
        [-stem_w / 2, SlotLip]
    ]);
}

module vertical_mounts() {
    intersection() {
        for (x = [-MountSpacing / 2, MountSpacing / 2])
            translate([x, PlateSize / 2, -BackThickness])
                linear_extrude(height = BackThickness)
                    t_slot_key_profile();
        union() {
            wedge_block(FrontThickness, BackThickness);
            translate([-PlateSize, PlateSize / 2, -BackThickness])
                cube([PlateSize * 2, SlotDepth, BackThickness]);
        }
    }
}

module through_cylinder(diameter) {
    translate([0, 0, -(BackThickness + 1)])
        cylinder(h = BackThickness + 2, d = diameter);
}

// Horizontal ceiling at z = -remain. Opens through the bottom of the wedge.
module square_nut_pocket(remain) {
    translate([0, 0, -(BackThickness + 1)])
        linear_extrude(height = BackThickness + 1 - remain)
            square([NutSize, NutSize], center = true);
}

module plate() {
    difference() {
        union() {
            rounded_plate();
            vertical_mounts();
        }

        through_cylinder(CutoutDiameter);

        translate([0, 0, -CounterSinkDepth])
            cylinder(h = CounterSinkDepth + 1, d = CounterSinkDia);

        for (x = [-1, 1], y = [-1, 1])
            translate([x * HoleSpacing / 2, y * HoleSpacing / 2, 0]) {
                through_cylinder(M5HoleDiameter);
                square_nut_pocket(y < 0 ? FrontNutRemain : BackNutRemain);
            }
    }
}

// 80 mm face of the 4080, shown only in preview. Slot voids are the real section.
module beam_ghost() {
    beam_width = 80;
    beam_depth = 40;
    ghost_h = BackThickness + 30;
    translate([-beam_width / 2, PlateSize / 2, -BackThickness - 15])
        difference() {
            cube([beam_width, beam_depth, ghost_h]);
            for (x = [-MountSpacing / 2, MountSpacing / 2])
                translate([beam_width / 2 + x, -0.1, -1])
                    linear_extrude(height = ghost_h + 2)
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
    %beam_ghost();

plate();
