// DisplayCase.scad
// Standalone round display case (not machine-specific).
// Cylinder along +Z: z=0 is the solid back (print bed), +Z is the open front.

$fn = $preview ? 100 : 500;

DisplayCylinderDiameter = 74;
DisplayCylinderThickness = 10;
DisplayCylinderDepthOut = 6;
DisplayCylinderDepthIn = 9.86;

DisplayCylinderSlotTopLength=36;
DisplayCylinderSlotBottomLength=34;
DisplayCylinderSlotDepth=5.5;
DisplayCylinderSlotHeight=42; // Height of the trapezoid along y-axis (Diameter/2 + Thickness)

// SD card slot. Angle 0 is 6 o'clock (existing slot); -90 is 9, -180 is 12.
// -135 is 10:30, spanning about 10 to 11 o'clock at the inner diameter.
DisplayCylinderSDslotTopLength=19;
DisplayCylinderSDslotBottomLength=17;
DisplayCylinderSDslotDepth=5.5;
DisplayCylinderSDslotHeight=42;
DisplayCylinderSDslotAngle=-135;

CutCircleCenter=-5; // below the center of DisplayCylinder along its y
CutCircleDiameter=74;
CutCircleDepth=DisplayCylinderDepthIn; // from the front face back, along z

WireHoleDiameter = 10;
OuterHoleDiameter = 3.2; // M3 clearance, matches DisplayBracket_C-Beam
DiceHoleOffset = 12; // outer holes at ±this in X and Y from the back centre

// Waveshare ESP32-S3-Touch-LCD-2.8C 4*M2 standoffs (back view, mm from centre).
// Top pair: ±29.5 x, +14.14 y. Bottom pair: ±18.0 x, -26.56 y.
// 6 o'clock is the FPC/cable, matching DisplayCylinderSlot.
ScrewHoleDiameter = 2.5; // M2 clearance
ScrewHoles = [
    [-29.5,  14.14],
    [ 29.5,  14.14],
    [-18.0, -26.56],
    [ 18.0, -26.56]
];

DisplayCylinderHeight = DisplayCylinderDepthIn + DisplayCylinderDepthOut;

// Trapezoid cut through the DisplayCylinder wall. Angle 0 is 6 o'clock (+X right, +Y up).
module DisplayCylinderSlotCut(topLength, bottomLength, depth, height, angle = 0) {
    translate([0, 0, DisplayCylinderHeight - depth])
    rotate([0, 0, angle])
    linear_extrude(height = depth + 1) {
        polygon(points = [
            [-(topLength/2), -sqrt(pow(DisplayCylinderDiameter/2, 2) - pow(topLength/2, 2))],
            [ (topLength/2), -sqrt(pow(DisplayCylinderDiameter/2, 2) - pow(topLength/2, 2))],
            [ bottomLength/2, -height],
            [-bottomLength/2, -height]
        ]);
    }
}

module DisplayCase() {
    difference() {
        // Outer cylinder. DisplayCylinderDiameter is the INNER diameter.
        cylinder(h=DisplayCylinderHeight,
                 d=DisplayCylinderDiameter + 2*DisplayCylinderThickness);

        // Inner hole (tube) through the front protrusion
        translate([0, 0, DisplayCylinderDepthIn])
        cylinder(h=DisplayCylinderDepthOut + 1, d=DisplayCylinderDiameter);

        // Cut Circle: solid cylinder inside DisplayCylinder to cut away material
        translate([0, CutCircleCenter, DisplayCylinderHeight - CutCircleDepth])
        cylinder(h = CutCircleDepth, d = CutCircleDiameter);

        // Display Cylinder Slot
        // Cuts through the DisplayCylinder thickness from inner to outer surface
        DisplayCylinderSlotCut(
            DisplayCylinderSlotTopLength,
            DisplayCylinderSlotBottomLength,
            DisplayCylinderSlotDepth,
            DisplayCylinderSlotHeight);

        // SD card slot between 10 and 11 o'clock
        DisplayCylinderSlotCut(
            DisplayCylinderSDslotTopLength,
            DisplayCylinderSDslotBottomLength,
            DisplayCylinderSDslotDepth,
            DisplayCylinderSDslotHeight,
            DisplayCylinderSDslotAngle);

        // Wire hole through the solid back
        translate([0, 0, -1])
        cylinder(h = DisplayCylinderDepthIn + 2, d = WireHoleDiameter);

        // Dice-five mount holes, matching DisplayBracket_C-Beam
        for (dx = [-1, 1], dy = [-1, 1])
            translate([dx * DiceHoleOffset, dy * DiceHoleOffset, -1])
                cylinder(h = DisplayCylinderDepthIn + 2, d = OuterHoleDiameter);

        // M2 clearance holes through the back, aligned with the display standoffs
        for (xy = ScrewHoles) {
            translate([xy[0], xy[1], -1])
            cylinder(h = DisplayCylinderDepthIn + 2, d = ScrewHoleDiameter);
        }
    }
}

DisplayCase();
