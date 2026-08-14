// StilosaLid.scad

$fn = $preview ? 100 : 500;
SplitObject = !$preview; // Set to true to split the object for printing

FaceWidth=128;
FaceThickness=3;
FrontFaceLength=78;
TopFaceLength=64;
DisplayCylinderDiameter = 73.3;
DisplayCylinderThickness = 10;
DisplayCylinderDepthOut = 6;
DisplayCylinderDepthIn = 9.86;
DisplayCylinderTilt = 90; // Angle from TopFace to FrontFace
DisplayCylinderCenterOffset = -4; // from the joint between TopFace and FrontFace

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
CutCircleDepth=DisplayCylinderDepthIn; // from the top of DisplayCylinderDepthIn down, along z

// Trapezoid cut through the DisplayCylinder wall. Angle 0 is 6 o'clock (+X right, +Y up).
module DisplayCylinderSlotCut(topLength, bottomLength, depth, height, angle = 0) {
    rotate([90 - DisplayCylinderTilt/2, 0, 0])
    translate([0, 0, DisplayCylinderCenterOffset])
    translate([0, 0, DisplayCylinderDepthOut - depth])
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

module LShapedObject() {
    difference() {
        union() {
            // Top Face
            // Aligned with +Y axis, Z=0 is inner surface
            // Origin (0,0,0) is the inner corner vertex.
            translate([-FaceWidth/2, 0, 0])
            cube([FaceWidth, TopFaceLength, FaceThickness]);

            // Front Face
            // Aligned with -Z axis (for Tilt=90), Y=0 is inner surface
            // We rotate around X axis to create the L-shape.
            // A rotation of -Tilt degrees around X axis moves the +Y axis towards -Z.
            rotate([-DisplayCylinderTilt, 0, 0])
            translate([-FaceWidth/2, 0, 0])
            cube([FaceWidth, FrontFaceLength, FaceThickness]);

            // Outer Cylinder
            // Extruded from the center of the L bend out, away from the L.
            // "Away from L" means the reflex angle direction.
            // Bisector angle logic:
            // TopFace is at 0 deg (relative to Y axis).
            // FrontFace is at -Tilt deg (relative to Y axis).
            // Bisector of the "inside" angle is -Tilt/2.
            // Bisector of the "outside" (reflex) angle is -Tilt/2 + 180.
            // We want the cylinder to point in this reflex direction.
            
            // Default cylinder is along +Z (which is 90 deg from Y).
            // We need to rotate the cylinder so its Z axis points to (-Tilt/2 + 180) deg in the YZ plane.
            // Angle difference = (-Tilt/2 + 180) - 90 = 90 - Tilt/2.
            
            rotate([90 - DisplayCylinderTilt/2, 0, 0])
            translate([0, 0, DisplayCylinderCenterOffset])
            // We extend it backwards to ensure it merges with the faces.
            // "DisplayCylinderDepthOut" is taken as the length of the cylinder protrusion.
            // We position the outer face at z = DisplayCylinderDepthOut (relative to the offset start).
            // DisplayCylinderDiameter is the INNER diameter. The outer diameter is Inner + 2*Thickness.
            translate([0, 0, -DisplayCylinderDepthIn]) // Start inside
            cylinder(h=DisplayCylinderDepthIn + DisplayCylinderDepthOut, d=DisplayCylinderDiameter + 2*DisplayCylinderThickness);
        }
        
        // Cut off the protrusion of the cylinder into the "inside" of the L-shape.
        // The "Inside" is the region under the Top Face (Z < 0) and behind the Front Face (Y > FaceThickness).
        // The Front Face occupies Y=[0, FaceThickness].
        // The Top Face occupies Z=[0, FaceThickness].
        // So any material in Y > FaceThickness AND Z < 0 is protruding into the empty corner space.
        translate([-500, FaceThickness, -500])
        cube([1000, 1000, 500]); 
        
        // Also clean up any protrusion above the Top Face? (Z > FaceThickness, Y < 0).
        // But the cylinder is going (-Y, +Z). So it is naturally in that quadrant.
        // We want to keep that.

        // Inner hole (Tube) - Subtracted from the entire union, restricted to L-shape faces

            intersection() {
                rotate([90 - DisplayCylinderTilt/2, 0, 0])
                translate([0, 0, DisplayCylinderCenterOffset])
                translate([0, 0, -DisplayCylinderDepthIn - 1 + DisplayCylinderThickness]) // Moved up by Thickness
                cylinder(h=DisplayCylinderDepthIn + DisplayCylinderDepthOut + 2, d=DisplayCylinderDiameter);

                union() {
                    // Top Face Mask
                    translate([-FaceWidth/2, 0, -50])
                    cube([FaceWidth, TopFaceLength, 100]);

                    // Front Face Mask
                    rotate([-DisplayCylinderTilt, 0, 0])
                    translate([-FaceWidth/2, 0, -50])
                    cube([FaceWidth, FrontFaceLength, 100]);
                    
                    // Cylinder Mask
                     rotate([90 - DisplayCylinderTilt/2, 0, 0])
                    translate([0, 0, DisplayCylinderCenterOffset])
                    translate([0, 0, 0])
                     cylinder(h=DisplayCylinderDepthOut + 1, d=(DisplayCylinderDiameter + 2*DisplayCylinderThickness)*2);
                }
            }
            

        
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

        // Cut Circle: solid cylinder inside DisplayCylinder to cut away material
        rotate([90 - DisplayCylinderTilt/2, 0, 0])
        translate([0, CutCircleCenter, DisplayCylinderCenterOffset + DisplayCylinderDepthOut - CutCircleDepth])
        cylinder(h = CutCircleDepth, d = CutCircleDiameter);
    }
}

module SplitLShapedObject() {
    if (SplitObject) {
        // Split into two parts along the bisector
        intersection() {
            LShapedObject();
             rotate([-DisplayCylinderTilt/2, 0, 0])
             translate([-500, -500, FaceThickness*sin(45)])
             cube([1000, 1000, 500]); // Keep "upper" half
        }
        
        // Part 2: Front Face Side, rotated to lay flat
        translate([0, -DisplayCylinderDepthOut, FaceThickness])
        rotate([DisplayCylinderTilt, 0, 180])
        mirror([0, 1, 0])
        intersection() {
            LShapedObject();
             rotate([-DisplayCylinderTilt/2, 0, 0])
             translate([-500, -500, -500 + FaceThickness*sin(45)])
             cube([1000, 1000, 500]); // Keep "lower" half
        }
    } else {
        LShapedObject();
    }
}

SplitLShapedObject();
