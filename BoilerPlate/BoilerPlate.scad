// BoilerPlate: wedge plate with a center circular cutout and four corner screw holes.
// Hole pitch is center-to-center between adjacent holes.
// -Y is the front, +Y is the back. The hole face is flat on z=0.
// Thickness grows in -Z, from FrontThickness at the front to BackThickness at the back.

$fn = $preview ? 64 : 128;

PlateSize = 91.4;
FrontThickness = 5;
BackThickness = 25;

CutoutDiameter = 82.76; // 260 mm circumference
// Right-angled step in the flat hole face, cut downward. The through hole stays CutoutDiameter.
CounterSinkDia = CutoutDiameter + 6;
CounterSinkDepth = 2.5;

// Adjacent-hole spacing. Pattern is centered on the plate.
HoleSpacing = 73.3;
// ISO 273 medium clearance for an M5 screw.
M5HoleDiameter = 5.5;
// Arc centered on each screw, so the corner wall matches the straight edges.
CornerRadius = (PlateSize - HoleSpacing) / 2;

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

module through_cylinder(diameter) {
    translate([0, 0, -(BackThickness + 1)])
        cylinder(h = BackThickness + 2, d = diameter);
}

module plate() {
    difference() {
        rounded_plate();

        through_cylinder(CutoutDiameter);

        translate([0, 0, -CounterSinkDepth])
            cylinder(h = CounterSinkDepth + 1, d = CounterSinkDia);

        for (x = [-1, 1], y = [-1, 1])
            translate([x * HoleSpacing / 2, y * HoleSpacing / 2, 0])
                through_cylinder(M5HoleDiameter);
    }
}

plate();
