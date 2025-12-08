// Set default resolution based on preview vs render mode
$fn = $preview ? 100 : 500;

MountPostHoleTopDiameter = 11;
MountPostHoleBottomDiameter = 12;
MountPostTopDiameter = 19;
MountPostBottomDiameter = 25;
MountPostHeight = 34;
MountPostSlotWidth = 10;
MountPostSlotDepth = 7;
MountPostDistance = 133.35;
PostHeight = 66;
PostDepth = 10;
PostWidth = 13;
PostTopOffset = -30;
PostBottomOffset = 10;

RotatePostDegreeLeft = 3;
RotatePostDegreeRight = 3;

SidePostLength = sqrt(PostHeight * PostHeight
                      + (PostTopOffset - PostBottomOffset)
                        * (PostTopOffset - PostBottomOffset));

DisplayBaseWidth = SidePostLength+6;
DisplayBaseLength = 116;
DisplayBaseDepth = 2;
DisplayCylinderDiameter = 73.5;
DisplayCylinderThickness = 4;
DisplayCylinderDepth = 4;
DisplayCylinderTilt = 10;
DisplayCylinderCenterOffset = -4;
DisplayCylinderGap = 0;
DisplayAssemblyOffset = MountPostDistance / 2 + DisplayBaseLength / 2 - 40;
DisplayCylinderHole = 10;
DisplayCylinderHoleOffset = 20;

WingStartAdjust = 0;
WingEndAdjust = 0;
WingThickness = 1.5;
WingSpacing = 113;
WingHeightAdjust = 5;

WingStartYRaw = -DisplayBaseWidth / 2 + WingStartAdjust;
WingEndYRaw = DisplayBaseWidth / 2 + WingEndAdjust;
WingStartY = min(WingStartYRaw, WingEndYRaw);
WingEndY = max(WingStartYRaw, WingEndYRaw);
WingSpan = WingEndY - WingStartY;
WingHeight = max(0,
                 abs(PostTopOffset - PostBottomOffset) - PostWidth)
             + WingHeightAdjust;
WingTopZ = DisplayBaseDepth + WingHeight;

DisplayCylinderInnerRadius = DisplayCylinderDiameter / 2;
DisplayCylinderOuterRadius = (DisplayCylinderDiameter + DisplayCylinderThickness) / 2;
DisplayCylinderCenterZ = DisplayBaseDepth
                         + DisplayCylinderGap
                         + DisplayCylinderOuterRadius * sin(DisplayCylinderTilt)
                         + (DisplayCylinderDepth / 2) * cos(DisplayCylinderTilt);
// Support needs to reach the highest point of the tilted cylinder
DisplayCylinderHighestZ = DisplayCylinderCenterZ 
                         + DisplayCylinderOuterRadius * sin(DisplayCylinderTilt)
                         + (DisplayCylinderDepth / 2) * cos(DisplayCylinderTilt);
DisplayCylinderLowestZ = DisplayCylinderCenterZ 
                         - DisplayCylinderOuterRadius * sin(DisplayCylinderTilt)
                         - (DisplayCylinderDepth / 2) * cos(DisplayCylinderTilt);

WingEdgeYOffset = (PostBottomOffset - PostTopOffset) / PostHeight
                  * WingHeight;
WingTopY = WingStartY + WingEdgeYOffset;

function MountPostHoleRadiusAt(z) =
    let(zc = min(max(z, 0), MountPostHeight))
        (MountPostHoleBottomDiameter +
         (MountPostHoleTopDiameter - MountPostHoleBottomDiameter) * (zc / MountPostHeight)) / 2;

module MountPost() {
    difference() {
        cylinder(h = MountPostHeight,
                 r1 = MountPostBottomDiameter / 2,
                 r2 = MountPostTopDiameter / 2);
        union() {
            cylinder(h = MountPostHeight,
                     r1 = MountPostHoleBottomDiameter / 2,
                     r2 = MountPostHoleTopDiameter / 2);
            translate([-MountPostSlotWidth / 2,
                       -MountPostBottomDiameter / 2,
                       0])
                cube([MountPostSlotWidth,
                      MountPostBottomDiameter,
                      MountPostSlotDepth],
                     center = false);
        }
    }
}

module MountPostPair() {
    translate([-MountPostDistance / 2, 0, 0]) MountPost();
    translate([ MountPostDistance / 2, 0, 0]) MountPost();
}

module SidePost(sign) {
    dir = -sign;
    bottom_radius = MountPostHoleRadiusAt(0);
    top_radius = MountPostHoleRadiusAt(PostHeight);
    center_x = sign * MountPostDistance / 2;
    bottom_inside = center_x + dir * bottom_radius;
    top_inside = center_x + dir * top_radius;
    bottom_start = bottom_inside - (dir < 0 ? PostDepth : 0);
    top_start = top_inside - (dir < 0 ? PostDepth : 0);
    y_bottom = PostBottomOffset - PostWidth / 2;
    y_top = PostTopOffset - PostWidth / 2;

    pivot = [bottom_start + PostDepth / 2,
             PostBottomOffset,
             0];

    angle = sign < 0 ? RotatePostDegreeLeft : -RotatePostDegreeRight;

    translate(pivot)
        rotate([0, 0, angle])
            translate(-pivot)
                polyhedron(points = [
                                [bottom_start,                 y_bottom,              0],
                                [bottom_start + PostDepth,     y_bottom,              0],
                                [bottom_start + PostDepth,     y_bottom + PostWidth,  0],
                                [bottom_start,                 y_bottom + PostWidth,  0],
                                [top_start,                    y_top,                 PostHeight],
                                [top_start + PostDepth,        y_top,                 PostHeight],
                                [top_start + PostDepth,        y_top + PostWidth,     PostHeight],
                                [top_start,                    y_top + PostWidth,     PostHeight]
                            ],
                            faces = [
                                [0, 1, 2, 3],
                                [4, 7, 6, 5],
                                [0, 4, 5, 1],
                                [1, 5, 6, 2],
                                [2, 6, 7, 3],
                                [3, 7, 4, 0]
                            ],
                            convexity = 8);
}

module MountPostAssembly() {
    union() {
        MountPostPair();
        SidePost(-1);
        SidePost(1);
    }
}

module DisplayBase() {
    difference() {
        translate([-DisplayBaseLength / 2,
                   -DisplayBaseWidth / 2,
                   0])
            cube([DisplayBaseLength,
                  DisplayBaseWidth,
                  DisplayBaseDepth]);
        translate([0,
                   DisplayCylinderCenterOffset + DisplayCylinderHoleOffset,
                   -0.1])
            cylinder(h = DisplayBaseDepth + 0.2,
                     r = DisplayCylinderHole / 2,
                     center = false);
    }
}

module DisplayWing(sign) {
    if (WingThickness > 0 && WingSpan > 0) {
        x_center = sign * WingSpacing / 2;
        multmatrix([[0, 0, 1, x_center],
                    [1, 0, 0, 0],
                    [0, 1, 0, 0],
                    [0, 0, 0, 1]])
            linear_extrude(height = WingThickness, center = true, convexity = 4)
                polygon(points = [
                             [WingStartY, DisplayBaseDepth],
                             [WingTopY, WingTopZ],
                             [WingEndY, DisplayBaseDepth]
                         ]);
    }
}

module DisplayCylinder() {
    translate([0,
               DisplayCylinderCenterOffset,
               DisplayCylinderCenterZ])
        rotate([DisplayCylinderTilt, 0, 0])
            difference() {
                cylinder(h = DisplayCylinderDepth,
                         r = DisplayCylinderOuterRadius,
                         center = true);
                cylinder(h = DisplayCylinderDepth + 0.2,
                         r = DisplayCylinderInnerRadius,
                         center = true);
            }
}

module DisplayCylinderSupport() {
    // Create a thin wall support that follows the tilted rim of the cylinder
    // Support extends beyond the base to fully support the cylinder
    
    support_thickness = 2;  // Thickness of the support wall
    support_downreach = DisplayCylinderOuterRadius * tan(DisplayCylinderTilt) + DisplayBaseDepth;
    support_height = DisplayCylinderCenterZ + DisplayCylinderDepth / 2 + support_downreach;
    support_overlap = 0.2;  // Overlap with the display cylinder to ensure fusion when sliced
    
    // Create support by cutting the cylinder volume from a tilted cylinder wall
    difference() {
        // A tilted cylinder shell that extends from z=0 up to the cylinder
        translate([0,
                   DisplayCylinderCenterOffset,
                   DisplayCylinderCenterZ])
            rotate([DisplayCylinderTilt, 0, 0])
                translate([0, 0, -DisplayCylinderCenterZ - support_downreach])  // Extend downward to reach base across tilt
                    difference() {
                        // Outer cylinder extending upward from z=0
                        cylinder(h = support_height,
                                 r = DisplayCylinderOuterRadius,
                                 center = false);
                        // Inner cutout to make it a rim/wall only
                        translate([0, 0, -0.1])
                            cylinder(h = support_height + 0.2,
                                     r = DisplayCylinderOuterRadius - support_thickness,
                                     center = false);
                    }
        
        // Remove the display cylinder itself to create just the support
        translate([0,
                   DisplayCylinderCenterOffset,
                   DisplayCylinderCenterZ])
            rotate([DisplayCylinderTilt, 0, 0])
                cylinder(h = DisplayCylinderDepth + 0.1,
                         r = DisplayCylinderOuterRadius - support_overlap,
                         center = true);
        
        // Cut off anything below z=0 (below the print bed)
        translate([-200, -200, -200])
            cube([400, 400, 200]);
    }
}

module DisplayAssemblyComponents() {
    translate([0,
               -DisplayAssemblyOffset,
               0])
        union() {
            DisplayBase();
            DisplayCylinder();
            DisplayCylinderSupport();
            DisplayWing(1);
            DisplayWing(-1);
        }
}

module DisplayAssembly() {
    union() {
        MountPostAssembly();
        DisplayAssemblyComponents();
    }
}

DisplayAssembly();
