// Waveshare_P4_7B_Case.scad
// Tray enclosure for the Waveshare ESP32-P4-WIFI6-Touch-LCD-7B.
// The glass drops in from the front and sits flush with the rim; four M2.5
// screws go through the back into the board's threaded standoffs.
// z=0 is the solid back (print bed), +Z is the open front.
// X/Y are as seen from the front: +X right, +Y up (C6 module/RTC edge at top).
//
// Dimensions from Waveshare drawing ESP32-P4-WIFI6-Touch-LCD-7B-20251108.
// The drawing is a back view, so board X positions are mirrored via BoardXY().

$fn = $preview ? 48 : 96;

/* [Display] */
LensWidth = 164.28;
LensHeight = 99.17;
StackDepth = 15.3;       // glass front to tallest part (standoffs / USB-A)
PcbWidth = 164;
PcbHeight = 97;
PcbBackDepth = 8.8;      // glass front to PCB back face
PcbBelowLens = 1.58;     // PCB bottom edge above the lens bottom edge

// M2.5 threaded standoffs, back view, mm from PCB bottom-left
StandoffInset = 4;       // 156 x 89 pattern on a 164 x 97 board

/* [Case] */
Fit = 0.3;               // clearance per side around the glass
Wall = 2.4;
Floor = 2.4;
OuterRadius = 3;
FrontChamfer = 0.8;
BossHeight = 1.0;        // gap between floor and standoff ends
BossDiameter = 6.5;
FrontProud = 0;          // >0 lets the glass stand proud of the rim

/* [Screws] */
ScrewHoleDiameter = 2.9; // M2.5 clearance
ScrewHeadDiameter = 5.2;
ScrewHeadDepth = 1.4;    // counterbore from the back

/* [Cutouts - left wall (front view)] */
Cut_USB_UART = false;
Cut_USB_C = true;
Cut_USB_A = false;
Cut_PowerSwitch = false;

/* [Cutouts - right wall (front view)] */
Cut_Boot = false;
Cut_Reset = false;

/* [Cutouts - bottom wall] */
Cut_TFCard = false;
Cut_Mic1 = false;
Cut_Mic2 = false;
Cut_FPCRelief1 = true;
Cut_FPCRelief2 = true;

/* [Cutouts - back] */
Cut_RS485 = true;
Cut_CAN = true;
Cut_UART = true;
Cut_I2C = true;
Cut_GPIO1 = true;   // 12-pin header, front-view right
Cut_GPIO2 = true;   // 12-pin header, front-view left
Cut_ScrewHoles = true;
Cut_Vents = true;
Cut_ConnectorBackSlot = false; // cable exit through the back behind the PH2.0 row
Cut_MountHoles = true;  // M3 pattern for DisplayBracket_C-Beam_7B.scad

/* [Bracket mount] */
// Centred on the case; flat-head M3 from inside, flush with the floor
MountHoleSpacingX = 60;
MountHoleSpacingY = 56;
MountHoleDiameter = 3.4;
MountHeadDiameter = 6.4;
MountHeadDepth = 1.8;

/* [Vents] */
VentLength = 50;
VentWidth = 2.2;
VentPitch = 5.5;
VentCount = 8;

InnerWidth = LensWidth + 2*Fit;
InnerHeight = LensHeight + 2*Fit;
OuterWidth = InnerWidth + 2*Wall;
OuterHeight = InnerHeight + 2*Wall;
InnerDepth = StackDepth + BossHeight - FrontProud;
CaseHeight = Floor + InnerDepth;
GlassFrontZ = CaseHeight + FrontProud;

PcbOriginX = Wall + Fit + (LensWidth - PcbWidth)/2;
PcbOriginY = Wall + Fit + PcbBelowLens;

// Back-view board coords (from Waveshare drawing) -> case XY.
function BoardXY(bx, by) = [PcbOriginX + PcbWidth - bx, PcbOriginY + by];
// Depth behind the glass front -> case Z.
function DepthZ(d) = GlassFrontZ - d;

StandoffPositions = [
    [StandoffInset,             StandoffInset],
    [PcbWidth - StandoffInset,  StandoffInset],
    [StandoffInset,             PcbHeight - StandoffInset],
    [PcbWidth - StandoffInset,  PcbHeight - StandoffInset]
];

// Side-wall openings: [enabled, board y from PCB bottom, depth behind glass, width, height]
// Left wall (front view) = right edge in the back-view drawing.
LeftWallCuts = [
    [Cut_USB_UART,    13.6, 10.4, 12.5, 7.0],   // USB-C, USB to UART
    [Cut_USB_C,       28.9, 10.4, 12.5, 7.0],   // USB-C, USB 1.1 / power
    [Cut_USB_A,       47.7, 12.0, 16.0, 8.5],   // USB-A OTG
    [Cut_PowerSwitch, PcbHeight - 15.1, 10.2, 9.0, 5.0]
];

// Right wall (front view) = left edge in the back-view drawing.
RightWallCuts = [
    [Cut_Boot,  PcbHeight - 20.0, 10.8, 6.0, 5.0],
    [Cut_Reset, PcbHeight - 10.5, 10.8, 6.0, 5.0]
];

// PH2.0 4-pin connectors, plugged in through the back: [enabled, board y from PCB bottom]
BackConnectorCuts = [
    [Cut_RS485, 17.7],
    [Cut_CAN,   32.6],
    [Cut_UART,  47.5],
    [Cut_I2C,   62.4]
];
BackConnectorInset = 4.0;   // housing centre from the PCB edge, back view x
BackConnectorWidth = 12.0;  // along the board edge (Y)
BackConnectorLength = 7.5;  // across the board edge (X)

// Bottom wall: [board x from left in back view, depth, width, height]
TfSlot = [85.1, 10.4, 16, 3.6];
// 12-pin GPIO headers, plugged in through the back: [enabled, board x from left in back view]
GpioCuts = [
    [Cut_GPIO1, 36.2],
    [Cut_GPIO2, 113.2]
];
GpioCutY = 2.3;       // housing centre above the PCB bottom edge
GpioCutWidth = 28.0;  // along the board edge (X), PH2.0 12-pin body is ~26
GpioCutLength = 7.0;  // across the board edge (Y)
// [enabled, board x from left in back view]
Mics = [[Cut_Mic1, 14.2], [Cut_Mic2, 150]];
MicDepth = 9.8;
MicHoleDiameter = 2;

// LCD FPC/tabs that wrap below the glass: [enabled, front-view x from lens left start, end]
FpcReliefs = [[Cut_FPCRelief1, 64, 98], [Cut_FPCRelief2, 135, 157]];
FpcReliefDepth = 1.2;
FpcReliefFromFront = [1.0, 8.0];

module RoundedRect(w, h, r) {
    translate([r, r]) offset(r = r) square([w - 2*r, h - 2*r]);
}

module Shell() {
    hull() {
        linear_extrude(CaseHeight - FrontChamfer)
            RoundedRect(OuterWidth, OuterHeight, OuterRadius);
        translate([FrontChamfer, FrontChamfer, 0])
            linear_extrude(CaseHeight)
                RoundedRect(OuterWidth - 2*FrontChamfer, OuterHeight - 2*FrontChamfer,
                            OuterRadius - FrontChamfer);
    }
}

module Pocket() {
    translate([Wall, Wall, Floor])
        cube([InnerWidth, InnerHeight, InnerDepth + 1]);
}

// Rounded slot through a wall. axis "x" cuts the left/right walls, "y" the bottom wall.
module WallSlot(axis, along, depth, w, h, wallFrom, wallTo) {
    r = min(w, h)/2 - 0.01;
    z = DepthZ(depth);
    if (axis == "x")
        translate([wallFrom, along, z]) rotate([0, 90, 0])
            linear_extrude(wallTo - wallFrom)
                offset(r = r) square([h - 2*r, w - 2*r], center = true);
    else
        translate([along, wallTo, z]) rotate([90, 0, 0])
            linear_extrude(wallTo - wallFrom)
                offset(r = r) square([w - 2*r, h - 2*r], center = true);
}

module SideCuts() {
    for (c = LeftWallCuts) if (c[0])
        WallSlot("x", BoardXY(0, c[1])[1], c[2], c[3], c[4], -1, Wall + Fit + 1);
    for (c = RightWallCuts) if (c[0])
        WallSlot("x", BoardXY(0, c[1])[1], c[2], c[3], c[4],
                 OuterWidth - Wall - Fit - 1, OuterWidth + 1);

    if (Cut_TFCard)
        WallSlot("y", BoardXY(TfSlot[0], 0)[0], TfSlot[1], TfSlot[2], TfSlot[3],
                 -1, Wall + Fit + 1);

    for (m = Mics) if (m[0])
        translate([BoardXY(m[1], 0)[0], -1, DepthZ(MicDepth)])
            rotate([-90, 0, 0]) cylinder(h = Wall + 2, d = MicHoleDiameter);

    for (r = FpcReliefs) if (r[0])
        translate([Wall + Fit + r[1], Wall - FpcReliefDepth, DepthZ(FpcReliefFromFront[1])])
            cube([r[2] - r[1], FpcReliefDepth + 0.01,
                  FpcReliefFromFront[1] - FpcReliefFromFront[0]]);
}

module BackCuts() {
    if (Cut_ScrewHoles) for (s = StandoffPositions) {
        p = BoardXY(s[0], s[1]);
        translate([p[0], p[1], -1]) cylinder(h = CaseHeight, d = ScrewHoleDiameter);
        translate([p[0], p[1], -1]) cylinder(h = ScrewHeadDepth + 1, d = ScrewHeadDiameter);
    }

    for (c = BackConnectorCuts) if (c[0]) {
        p = BoardXY(BackConnectorInset, c[1]);
        translate([p[0], p[1], -1])
            linear_extrude(Floor + 2)
                offset(r = 1) square([BackConnectorLength - 2, BackConnectorWidth - 2], center = true);
    }

    for (g = GpioCuts) if (g[0]) {
        p = BoardXY(g[1], GpioCutY);
        translate([p[0], p[1], -1])
            linear_extrude(Floor + 2)
                offset(r = 1) square([GpioCutWidth - 2, GpioCutLength - 2], center = true);
    }

    if (Cut_MountHoles)
        for (dx = [-1, 1], dy = [-1, 1])
            translate([OuterWidth/2 + dx * MountHoleSpacingX/2,
                       OuterHeight/2 + dy * MountHoleSpacingY/2, 0]) {
                translate([0, 0, -1]) cylinder(h = Floor + 2, d = MountHoleDiameter);
                translate([0, 0, Floor - MountHeadDepth])
                    cylinder(h = MountHeadDepth + 0.01, d1 = MountHoleDiameter,
                             d2 = MountHeadDiameter);
            }

    if (Cut_Vents) {
        span = (VentCount - 1) * VentPitch;
        for (i = [0 : VentCount - 1], side = [-1, 1])
            translate([OuterWidth/2 + side * (VentLength/2 + 8),
                       OuterHeight/2 - span/2 + i * VentPitch, -1])
                linear_extrude(Floor + 2)
                    hull() {
                        translate([-VentLength/2 + VentWidth/2, 0]) circle(d = VentWidth);
                        translate([ VentLength/2 - VentWidth/2, 0]) circle(d = VentWidth);
                    }
    }

    if (Cut_ConnectorBackSlot) {
        lo = BoardXY(0, 17.7 - 6)[1];
        hi = BoardXY(0, 62.4 + 6)[1];
        translate([OuterWidth - Wall - Fit - 9, lo, -1])
            cube([8, hi - lo, Floor + 2]);
    }
}

module Bosses() {
    for (s = StandoffPositions) {
        p = BoardXY(s[0], s[1]);
        translate([p[0], p[1], Floor - 0.01])
            cylinder(h = BossHeight + 0.01, d = BossDiameter);
    }
}

module Case() {
    difference() {
        union() {
            difference() {
                Shell();
                Pocket();
            }
            Bosses();
        }
        SideCuts();
        BackCuts();
    }
}

Case();
