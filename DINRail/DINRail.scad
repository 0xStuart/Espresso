$fn = 200;

GMPLength = 90.6; // Y axis
GMPWidth = 46;    // X axis
GMPDepth = 3.89;     // Base thickness

ScrewPostDiameter = 6;
ScrewPostHole = 3 + 0.9; // Default hole size if needed
ScrewPostHeight = 5; // Height ON TOP of GMPDepth
ScrewPostRadius = ScrewPostDiameter / 2;

// DIN Rail Extension
DINRailExtention = true;
DINRailLength = 64.5; // Along X axis
DINRailWidth = 25;    // Along Y axis
DinRailScrewWidth = 47.7;
DinRailHole = 3 + 0.9;

// Total height of a post including the base thickness
TotalPostHeight = GMPDepth + ScrewPostHeight;

// All post positions: [X, Y, HoleDiameter]
PostPositions = [
    // Corner posts relative to GMP size
    [ScrewPostRadius, ScrewPostRadius, ScrewPostHole],
    [GMPWidth - ScrewPostRadius, ScrewPostRadius, ScrewPostHole],
    
    // Additional specified posts
    [6.5, 20.5, 2], //Third Screw hole
    [11, 83, ScrewPostHole], //PSU Support
    [40.6, 87, ScrewPostHole]  //Connector support
];

difference() {
    union() {
        // Base rounded rectangle (GMP)
        hull() {
            translate([ScrewPostRadius, ScrewPostRadius, 0])
                cylinder(d=ScrewPostDiameter, h=GMPDepth);
            translate([GMPWidth - ScrewPostRadius, ScrewPostRadius, 0])
                cylinder(d=ScrewPostDiameter, h=GMPDepth);
            translate([GMPWidth - ScrewPostRadius, GMPLength - ScrewPostRadius, 0])
                cylinder(d=ScrewPostDiameter, h=GMPDepth);
            translate([ScrewPostRadius, GMPLength - ScrewPostRadius, 0])
                cylinder(d=ScrewPostDiameter, h=GMPDepth);
        }

        // DIN Rail Extension (Cross shape)
        if (DINRailExtention) {
            translate([(GMPWidth - DINRailLength)/2, (GMPLength - DINRailWidth)/2, 0])
                cube([DINRailLength, DINRailWidth, GMPDepth]);
        }

        // All Posts (Cylinders sticking up)
        for (p = PostPositions) {
            translate([p[0], p[1], 0])
                cylinder(d=ScrewPostDiameter, h=TotalPostHeight);
        }
    }

    // All Post Holes
    for (p = PostPositions) {
        translate([p[0], p[1], -1])
            cylinder(d=p[2], h=TotalPostHeight + 2);
    }

    // DIN Rail Extension Holes
    if (DINRailExtention) {
        translate([GMPWidth/2 - DinRailScrewWidth/2, GMPLength/2, -1])
            cylinder(d=DinRailHole, h=GMPDepth + 2);
        translate([GMPWidth/2 + DinRailScrewWidth/2, GMPLength/2, -1])
            cylinder(d=DinRailHole, h=GMPDepth + 2);
    }
}
