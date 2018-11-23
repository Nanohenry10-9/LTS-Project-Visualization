PImage earth, logo, panel;
PShape globe;

float stars[][] = new float[100][2];

color palette[] = new color[256];
int flame[][] = new int[400][400];
PImage fire;

float scannerHeight = 10;
float scannerDirection = 0.2;

int animPhase = 0;

int landerHeight = -200;
float landerDoor = 0;
long doorTimer;
float landerFloor1 = 25, landerFloor2 = 25;

float roverLocation[] = {0, 0, 0};
float otherRovers[][] = {{0, 0, 0}, {0, 0, 0}};
float roverAngle;
float roverWheelMain, roverWheelSide;

float cameraSmoothFactor = 0.05;
float cameraLocation[] = {0, 0, 0};
int cameraPaths[][][] = {
  {{-200, -100, 0},
   {-172, -100, 86},
   {-86, -100, 172},
   {0, -100, 200},
   {50, -20, 100}},
   
  {{50, -20, 100},
   {50, -100, 75},
   {-80, -100, 75},
   {-80, -60, 100},
   {-50, -20, 150}},
  
  {{-50, -20, 150}},
  
  {{-50, -20, 150}},
  
  {{-50, -20, 150}},
  
  {{-50, -20, 150},
   {-30, -80, 150}},
   
  {{-30, -80, 150},
   {0, -120, 150},
   {100, -100, 200},
   {75, -100, 250},
   {0, -85, 300},
   {0, -70, 350}}
};

long lastCameraUpdate;
int cameraMovePart;
int cameraMovePhase;
int cameraMoveFrames = 100;
float cameraFocus[] = {0, 0, 0};
boolean cameraMoveDone;
void update() {
  updateCamera();
  updateFire();
  scannerHeight += scannerDirection;
  if (scannerHeight < 8 || scannerHeight > 30) {
    scannerDirection *= -1;
  }
  switch (animPhase) {
    case 0:
      roverLocation[0] = 0;
      roverLocation[1] = landerHeight - 8;
      roverLocation[2] = 0;
      
      if (landerHeight < -5) {
        landerHeight++;
      } else if (doorTimer == 0) {
        doorTimer = millis();
      } else if (millis() - doorTimer >= 750) {
        if (landerDoor > -100) {
          landerDoor -= 1;
        } else if (cameraMoveDone == true) {
          animPhase++;
          cameraMoveDone = false;
        }
      }
      break;
    case 1:
      if (roverLocation[2] < 100) {
        roverLocation[2]++;
        roverWheelMain -= 4;
      } else if (cameraMoveDone == true) {
        animPhase++;
        cameraMoveDone = false;
      }
      roverLocation[1] = getFloorHeight(roverLocation[0], roverLocation[1], roverLocation[2]) - 8;
      break;
    case 2:
      if (roverLocation[2] < 200 && landerFloor1 == 25) {
        roverLocation[2]++;
        roverWheelMain -= 4;
        roverLocation[1] = (noise(0, roverLocation[2] / 100.0) * -abs(pow(roverLocation[2] / 50.0, 2))) - 8;
      } else {
        roverLocation[0] = 0;
        roverLocation[1] = (landerHeight - landerFloor1) - 8;
        roverLocation[2] = 0;
      }
      if (roverLocation[2] == 0) {
        if (landerFloor1 > 0) {
          landerFloor1 -= 0.2;
        } else if (cameraMoveDone == true) {
          animPhase++;
          cameraMoveDone = false;
        }
      }
      break;
    case 3:
      if (roverLocation[2] < 200 && landerFloor2 == 25) {
        roverLocation[2]++;
        roverWheelMain -= 4;
      } else {
        roverLocation[0] = 0;
        roverLocation[1] = (landerHeight - landerFloor1 - landerFloor2) - 8;
        roverLocation[2] = 0;
      }
      roverLocation[1] = getFloorHeight(roverLocation[0], roverLocation[1], roverLocation[2]) - 8;
      if (roverLocation[2] == 0) {
        if (landerFloor2 > 0) {
          landerFloor2 -= 0.2;
        } else if (cameraMoveDone == true) {
          animPhase++;
          cameraMoveDone = false;
        }
      }
      break;
    case 4:
      if (roverLocation[2] < 200) {
        roverLocation[2]++;
        roverWheelMain -= 4;
      } else if (cameraMoveDone == true) {
        animPhase++;
        cameraMoveDone = false;
      }
      roverLocation[1] = getFloorHeight(roverLocation[0], roverLocation[1], roverLocation[2]) - 8;
      break;
    case 5:
      animPhase++;
    case 6:
      if (roverLocation[2] < 250) {
        roverWheelMain -= 4;
        roverLocation[2]++;
        roverLocation[1] = getFloorHeight(roverLocation[0], roverLocation[1], roverLocation[2]) - 8;
      }
      if (otherRovers[0][2] < 260) {
        roverWheelSide -= 4;
        otherRovers[0][2]++;
        otherRovers[0][1] = getFloorHeight(otherRovers[0][0], otherRovers[0][1], otherRovers[0][2]) - 8;
        
        otherRovers[1][2]++;
        otherRovers[1][1] = getFloorHeight(otherRovers[0][0], otherRovers[0][1], otherRovers[0][2]) - 8;
      } else if (roverAngle < 45) {
        roverAngle += 0.5;
        roverWheelSide -= 4;
      }
      break;
  }
}
void updateCamera() {
  switch (animPhase) {
    case 0:
      cameraFocus[0] += (-cameraFocus[0]) * cameraSmoothFactor;
      cameraFocus[1] += ((landerHeight - 8) - cameraFocus[1]) * cameraSmoothFactor;
      cameraFocus[2] += (-cameraFocus[2]) * cameraSmoothFactor;
      break;
    case 1:
      cameraFocus[0] += (roverLocation[0] - cameraFocus[0]) * cameraSmoothFactor;
      cameraFocus[1] += (roverLocation[1] - cameraFocus[1]) * cameraSmoothFactor;
      cameraFocus[2] += (roverLocation[2] - cameraFocus[2]) * cameraSmoothFactor;
      break;
    case 2:
      cameraFocus[0] += (-cameraFocus[0]) * cameraSmoothFactor;
      cameraFocus[1] += (((noise(0, 1) * -4) - 8) - cameraFocus[1]) * cameraSmoothFactor;
      cameraFocus[2] += (100 - cameraFocus[2]) * cameraSmoothFactor;
      break;
    case 3:
      cameraFocus[0] += (-cameraFocus[0]) * cameraSmoothFactor;
      cameraFocus[1] += (((noise(0, 1) * -4) - 8) - cameraFocus[1]) * cameraSmoothFactor;
      cameraFocus[2] += (100 - cameraFocus[2]) * cameraSmoothFactor;
      break;
    case 4:
      cameraFocus[0] += (-cameraFocus[0]) * cameraSmoothFactor;
      cameraFocus[1] += (((noise(0, 1) * -4) - 8) - cameraFocus[1]) * cameraSmoothFactor;
      cameraFocus[2] += (100 - cameraFocus[2]) * cameraSmoothFactor;
      break;
    case 5:
      cameraFocus[0] += (-cameraFocus[0]) * cameraSmoothFactor;
      cameraFocus[1] += (((noise(0, 1) * -4) - 8) - cameraFocus[1]) * cameraSmoothFactor;
      cameraFocus[2] += (200 - cameraFocus[2]) * cameraSmoothFactor;
      break;
    case 6:
      cameraFocus[0] += (roverLocation[0] - cameraFocus[0]) * cameraSmoothFactor;
      cameraFocus[1] += (roverLocation[1] - cameraFocus[1]) * cameraSmoothFactor;
      cameraFocus[2] += (roverLocation[2] - cameraFocus[2]) * cameraSmoothFactor;
      break;
  }
  if (millis() - lastCameraUpdate >= 10 && !cameraMoveDone) {
    cameraLocation[0] = map(cameraMovePhase, 0, cameraMoveFrames, cameraPaths[animPhase][min(cameraPaths[animPhase].length - 1, cameraMovePart)][0], cameraPaths[animPhase][min(cameraPaths[animPhase].length - 1, cameraMovePart + 1)][0]);
    cameraLocation[1] = map(cameraMovePhase, 0, cameraMoveFrames, cameraPaths[animPhase][min(cameraPaths[animPhase].length - 1, cameraMovePart)][1], cameraPaths[animPhase][min(cameraPaths[animPhase].length - 1, cameraMovePart + 1)][1]);
    cameraLocation[2] = map(cameraMovePhase, 0, cameraMoveFrames, cameraPaths[animPhase][min(cameraPaths[animPhase].length - 1, cameraMovePart)][2], cameraPaths[animPhase][min(cameraPaths[animPhase].length - 1, cameraMovePart + 1)][2]);
    
    cameraMovePhase++;
    if (cameraMovePhase >= cameraMoveFrames) {
      cameraMovePhase = 0;
      cameraMovePart++;
      if (cameraMovePart >= cameraPaths[animPhase].length) {
        cameraMoveDone = true;
        cameraMovePart = 0;
      }
    }
    lastCameraUpdate = millis();
  }
}

void cylinder(int l, int r) {
  fill(0);
  stroke(127);
  beginShape();
  for (int i = 0; i <= 360; i += 20) {
    vertex(sin(radians(i)) * r, cos(radians(i)) * r, -l / 2);
  }
  endShape(CLOSE);
  beginShape();
  for (int i = 0; i <= 360; i += 20) {
    vertex(sin(radians(i)) * r, cos(radians(i)) * r, l / 2);
  }
  endShape(CLOSE);
  beginShape(QUAD_STRIP);
  for (int i = 0; i <= 360; i += 20) {
    vertex(sin(radians(i)) * r, cos(radians(i)) * r, -l / 2);
    vertex(sin(radians(i)) * r, cos(radians(i)) * r, l / 2);
  }
  endShape(CLOSE);
  stroke(0);
}

float rover(float x, float y, float z, float r, int type, boolean act, boolean side) {
  translate(x, 0, z);
  rotateY(radians(90 + r));
  float flHeight = getFloorHeight(x - sin(radians(r - 45)) * 10, y, z - cos(radians(r - 45)) * 10) - 8;
  float frHeight = getFloorHeight(x - sin(radians(r + 45)) * 10, y, z - cos(radians(r + 45)) * 10) - 8;
  float rlHeight = getFloorHeight(x + sin(radians(r + 45)) * 10, y, z + cos(radians(r + 45)) * 10) - 8;
  float rrHeight = getFloorHeight(x + sin(radians(r - 45)) * 10, y, z + cos(radians(r - 45)) * 10) - 8;
  stroke(0, 255, 255);
  strokeWeight(5);
  line(10, frHeight + 3, -10, 10, flHeight + 3, 10);
  line(-10, rrHeight + 3, -10, -10, rlHeight + 3, 10);

  line(10, (flHeight + frHeight) / 2 + 3, 0, 6, (flHeight + frHeight) / 2 - 4, 0);
  line(-10, (rlHeight + rrHeight) / 2 + 3, 0, -6, (rlHeight + rrHeight) / 2 - 4, 0);
  
  line(6, (flHeight + frHeight) / 2 - 4, 0, -6, (rlHeight + rrHeight) / 2 - 4, 0);
  
  strokeWeight(1);
  stroke(0);
  fill(0, 0, 255);
  
  beginShape(QUAD_STRIP);
  vertex(10, flHeight - 6, 10);
  vertex(10, flHeight - 4, 10);
  vertex(-7, rlHeight - 6, 10);
  vertex(-7, rlHeight - 4, 10);
  vertex(-7, rrHeight - 6, -10);
  vertex(-7, rrHeight - 4, -10);
  vertex(10, frHeight - 6, -10);
  vertex(10, frHeight - 4, -10);
  vertex(10, flHeight - 6, 10);
  vertex(10, flHeight - 4, 10);
  endShape();
  
  noLights();
  fill(255);
  beginShape(QUAD);
  texture(panel);
  vertex(10, flHeight - 6, 10, 0, 0);
  vertex(-7, rlHeight - 6, 10, 1000, 0);
  vertex(-7, rrHeight - 6, -10, 1000, 850);
  vertex(10, frHeight - 6, -10, 0, 850);
  endShape();
  lights();
  
  if (type == 0) {
    strokeWeight(5);
    stroke(0, 255, 255);
    line(-6, (rlHeight + rrHeight) / 2 - 4, 0, -14, (rlHeight + rrHeight) / 2 - 7, 0);
    strokeWeight(1);
    stroke(0);
    translate(-14, (rlHeight + rrHeight) / 2 - 7, 0);
    rotateX(scannerHeight);
    beginShape(TRIANGLE_STRIP);
    for (float i = 0; i <= 360; i += 60) {
      vertex(0, cos(radians(i)) * 3, sin(radians(i)) * 3);
      vertex(-11, 0, 0);
    }
    endShape();
    beginShape();
    for (float i = 0; i <= 360; i += 60) {
      vertex(0, cos(radians(i)) * 3, sin(radians(i)) * 3);
    }
    endShape();
    rotateX(-scannerHeight);
    translate(14, -((rlHeight + rrHeight) / 2 - 7), 0);
  } else if (type == 1) {
    stroke(127);
    strokeWeight(5);
    
    line(-6, (rlHeight + rrHeight) / 2 - 4, 0, -9, (rlHeight + rrHeight) / 2 - 7, 0);
    line(-9, (rlHeight + rrHeight) / 2 - 7, 0, -13, (rlHeight + rrHeight) / 2 - 5, 0);
    if (!act) { 
      line(-13, (rlHeight + rrHeight) / 2 - 5, 0, -15, (rlHeight + rrHeight) / 2 - 5, 3);
      line(-13, (rlHeight + rrHeight) / 2 - 5, 0, -15, (rlHeight + rrHeight) / 2 - 5, -3);
      
      line(-15, (rlHeight + rrHeight) / 2 - 5, 3, -19, (rlHeight + rrHeight) / 2 - 5, 4);
      line(-15, (rlHeight + rrHeight) / 2 - 5, -3, -19, (rlHeight + rrHeight) / 2 - 5, -4);
    } else {
      line(-13, (rlHeight + rrHeight) / 2 - 5, 0, -15, (rlHeight + rrHeight) / 2 - 5, map(scannerHeight, 8, 30, 1, 3));
      line(-13, (rlHeight + rrHeight) / 2 - 5, 0, -15, (rlHeight + rrHeight) / 2 - 5, map(scannerHeight, 8, 30, -1, -3));
      
      line(-15, (rlHeight + rrHeight) / 2 - 5, map(scannerHeight, 8, 30, 1, 3), -19, (rlHeight + rrHeight) / 2 - 5, map(scannerHeight, 8, 30, 0, 4));
      line(-15, (rlHeight + rrHeight) / 2 - 5, map(scannerHeight, 8, 30, -1, -3), -19, (rlHeight + rrHeight) / 2 - 5, map(scannerHeight, 8, 30, 0, -4));
    }
  } else if (type == 2) {
    stroke(0);
    strokeWeight(1);
    beginShape(TRIANGLE);
    vertex(-6, (rlHeight + rrHeight) / 2 - 4, 0);
    vertex(-15, (rlHeight + rrHeight) / 2, -3);
    vertex(-15, (rlHeight + rrHeight) / 2, 3);
    endShape(CLOSE);
    
    beginShape(TRIANGLE);
    vertex(-6, (rlHeight + rrHeight) / 2 - 4, 0);
    vertex(-15, (rlHeight + rrHeight) / 2 - 4, -3);
    vertex(-15, (rlHeight + rrHeight) / 2 - 4, 3);
    endShape(CLOSE);
    
    beginShape(TRIANGLE);
    vertex(-6, (rlHeight + rrHeight) / 2 - 4, 0);
    vertex(-15, (rlHeight + rrHeight) / 2, -3);
    vertex(-15, (rlHeight + rrHeight) / 2 - 4, -3);
    endShape(CLOSE);
    
    beginShape(TRIANGLE);
    vertex(-6, (rlHeight + rrHeight) / 2 - 4, 0);
    vertex(-15, (rlHeight + rrHeight) / 2, 3);
    vertex(-15, (rlHeight + rrHeight) / 2 - 4, 3);
    endShape(CLOSE);
    
    if (act) {
      for (float i = -7; i <= 7; i++) {
        if (i <= -3) {
          stroke(255, 0, 0);
        } else if (i <= 2) {
          stroke(255);
        } else {
          stroke(100, 180, 230);
        }
        strokeWeight(1);
        line(-6, (rlHeight + rrHeight) / 2 - 4, 0, -90, (rlHeight + rrHeight) / 2 + scannerHeight, i * 3);
        if (i <= -3) {
          stroke(255, 0, 0, 63);
        } else if (i <= 2) {
          stroke(255, 63);
        } else {
          stroke(100, 180, 230, 63);
        }
        strokeWeight(8);
        line(-6, (rlHeight + rrHeight) / 2 - 4, 0, -90, (rlHeight + rrHeight) / 2 + scannerHeight, i * 3);
      }
    }
  }
  
  float angle = roverWheelMain;
  if (side) {
    angle = roverWheelSide;
  }
  
  stroke(0);
  strokeWeight(1);
  translate(10, flHeight + 3, 10);
  rotateZ(radians(angle));
  cylinder(2, 5);
  rotateZ(radians(-angle));
  translate(-10, -flHeight - 3, -10);
  translate(10, frHeight + 3, -10);
  rotateZ(radians(angle));
  cylinder(2, 5);
  rotateZ(radians(-angle));
  translate(-10, -frHeight - 3, 10);
  
  translate(-10, rlHeight + 3, 10);
  rotateZ(radians(angle));
  cylinder(2, 5);
  rotateZ(radians(-angle));
  translate(10, -rlHeight - 3, -10);
  translate(-10, rrHeight + 3, -10);
  rotateZ(radians(angle));
  cylinder(2, 5);
  rotateZ(radians(-angle));
  translate(10, -rrHeight - 3, 10);
  rotateY(radians(-90 - r));
  translate(-x, 0, -z);
  return (rrHeight + rlHeight + frHeight + flHeight) / 4;
}

void drawObjects() {
  lights();
  translate(0, getFloorHeight(0, 0, 290), 290);
  fill(127, 0, 127);
  rotateZ(radians(45));
  box(5);
  rotateZ(radians(-45));
  translate(0, -getFloorHeight(0, 0, 290), -290);
  translate(0, -1000, -10000);
  rotateY(radians(-90));
  shape(globe);
  rotateY(radians(90));
  translate(0, 1000, 10000);
  fill(100);
  noStroke();
  for (int y = -500; y < 500; y += 10) {
    beginShape(QUAD_STRIP);
    for (int x = -500; x < 500; x += 10) {
      vertex(x, noise(x / 100.0, y / 100.0) * -(abs(pow(x / 50.0, 2)) + abs(pow(y / 50.0, 2))), y);
      vertex(x, noise(x / 100.0, (y + 10) / 100.0) * -(abs(pow(x / 50.0, 2)) + abs(pow((y + 10) / 50.0, 2))), y + 10);
    }
    endShape(CLOSE);
  }
  for (int i = 0; i < 100; i++) {
    fill(255);
    noStroke();
    rotateX(stars[i][0]);
    rotateZ(stars[i][1]);
    translate(0, -20000, 0);
    box(30);
    translate(0, 20000, 0);
    rotateZ(-stars[i][1]);
    rotateX(-stars[i][0]);
  }
  stroke(0);
  //translate(0, -10, 0);
  //box(500, 20, 500);
  //translate(0, 10, 0);
  
  translate(0, landerHeight - 25, 0);
  fill(0, 0, 255);
  strokeWeight(3);
  
  beginShape(QUAD);
  vertex(-25, -50, 20);
  vertex(-20, -50, 25);
  vertex(-20, 25, 25);
  vertex(-25, 20, 20);
  endShape(CLOSE);
  beginShape(QUAD);
  vertex(25, -50, 20);
  vertex(20, -50, 25);
  vertex(20, 25, 25);
  vertex(25, 20, 20);
  endShape(CLOSE);
  beginShape(QUAD);
  vertex(-25, -50, -20);
  vertex(-20, -50, -25);
  vertex(-20, 25, -25);
  vertex(-25, 20, -20);
  endShape(CLOSE);
  beginShape(QUAD);
  vertex(25, -50, -20);
  vertex(20, -50, -25);
  vertex(20, 25, -25);
  vertex(25, 20, -20);
  endShape(CLOSE);
  
  beginShape(TRIANGLE);
  vertex(-25, -50, 20);
  vertex(-20, -50, 25);
  vertex(0, -90, 0);
  endShape(CLOSE);
  beginShape(TRIANGLE);
  vertex(25, -50, 20);
  vertex(20, -50, 25);
  vertex(0, -90, 0);
  endShape(CLOSE);
  beginShape(TRIANGLE);
  vertex(-25, -50, -20);
  vertex(-20, -50, -25);
  vertex(0, -90, 0);
  endShape(CLOSE);
  beginShape(TRIANGLE);
  vertex(25, -50, -20);
  vertex(20, -50, -25);
  vertex(0, -90, 0);
  endShape(CLOSE);
  
  beginShape(QUAD);
  vertex(-25, 20, 20);
  vertex(-20, 25, 25);
  vertex(-20, 25, -25);
  vertex(-25, 20, -20);
  endShape(CLOSE);
  beginShape(QUAD);
  vertex(25, 20, 20);
  vertex(20, 25, 25);
  vertex(20, 25, -25);
  vertex(25, 20, -20);
  endShape(CLOSE);
  
  beginShape(QUAD);
  vertex(-20, 25 - landerFloor1, -25);
  vertex(20, 25 - landerFloor1, -25);
  vertex(20, 25 - landerFloor1, 25);
  vertex(-20, 25 - landerFloor1, 25);
  endShape(CLOSE);
  beginShape(QUAD);
  vertex(-20, 25 - landerFloor1 - landerFloor2, -25);
  vertex(20, 25 - landerFloor1 - landerFloor2, -25);
  vertex(20, 25 - landerFloor1 - landerFloor2, 25);
  vertex(-20, 25 - landerFloor1 - landerFloor2, 25);
  endShape(CLOSE);
  
  beginShape(TRIANGLE);
  vertex(-25, -50, -20);
  vertex(-25, -50, 20);
  vertex(0, -90, 0);
  endShape(CLOSE);
  beginShape(TRIANGLE);
  vertex(20, -50, 25);
  vertex(-20, -50, 25);
  vertex(0, -90, 0);
  endShape(CLOSE);
  beginShape(TRIANGLE);
  vertex(25, -50, -20);
  vertex(25, -50, 20);
  vertex(0, -90, 0);
  endShape(CLOSE);
  beginShape(TRIANGLE);
  vertex(20, -50, -25);
  vertex(-20, -50, -25);
  vertex(0, -90, 0);
  endShape(CLOSE);
  
  beginShape(QUAD);
  vertex(-20, 25, -25);
  vertex(20, 25, -25);
  vertex(20, 25, 25);
  vertex(-20, 25, 25);
  endShape(CLOSE);
  beginShape(QUAD);
  vertex(-25, 20, 20);
  vertex(-25, -50, 20);
  vertex(-25, -50, -20);
  vertex(-25, 20, -20);
  endShape(CLOSE);
  beginShape(QUAD);
  vertex(25, 20, 20);
  vertex(25, -50, 20);
  vertex(25, -50, -20);
  vertex(25, 20, -20);
  endShape(CLOSE);
  beginShape(QUAD);
  vertex(-20, -50, -25);
  vertex(20, -50, -25);
  vertex(20, 25, -25);
  vertex(-20, 25, -25);
  endShape(CLOSE);
  beginShape(QUAD);
  fill(255);
  texture(logo);
  vertex(-20, -50, 25, 0, -75);
  vertex(20, -50, 25, 400, -75);
  vertex(20, 0, 25, 400, 225);
  vertex(-20, 0, 25, 0, 225);
  endShape(CLOSE);
  fill(0, 0, 255);
  translate(0, 25, 25);
  rotateX(radians(landerDoor));
  beginShape(QUAD);
  vertex(-20, -25, 0);
  vertex(20, -25, 0);
  vertex(20, 0, 0);
  vertex(-20, 0, 0);
  endShape(CLOSE);
  rotateX(radians(-landerDoor));
  translate(0, -25, -25);
  fill(0, 0, 127);
  translate(-14, (float(195 - abs(-5 - landerHeight)) / 195.0) * 30.4, -14);
  box(10, 10, 10);
  translate(14, 0, 14);
  translate(14, 0, -14);
  box(10, 10, 10);
  translate(-14, 0, 14);
  translate(-14, 0, 14);
  box(10, 10, 10);
  translate(14, 0, -14);
  translate(14, 0, 14);
  box(10, 10, 10);
  translate(-14, (float(195 - abs(-5 - landerHeight)) / 195.0) * -30.4, -14);
  noStroke();
  if (landerHeight < -5) {
    noLights();
    beginShape(TRIANGLE);
    texture(fire);
    vertex(-10, 25, 10, 0, 0);
    vertex(10, 25, 10, 400, 0);
    vertex(0, 100, 0, 200, 400);
    endShape(CLOSE);
    beginShape(TRIANGLE);
    texture(fire);
    vertex(10, 25, -10, 0, 0);
    vertex(-10, 25, -10, 400, 0);
    vertex(0, 100, 0, 200, 400);
    endShape(CLOSE);
    
    beginShape(TRIANGLE);
    texture(fire);
    vertex(-10, 25, -10, 0, 0);
    vertex(-10, 25, 10, 400, 0);
    vertex(0, 100, 0, 200, 400);
    endShape(CLOSE);
    beginShape(TRIANGLE);
    texture(fire);
    vertex(10, 25, 10, 0, 0);
    vertex(10, 25, -10, 400, 0);
    vertex(0, 100, 0, 200, 400);
    endShape(CLOSE);
    lights();
  }
  strokeWeight(1);
  translate(0, -landerHeight + 25, 0);
  
  if (animPhase > 0 || cameraMovePart > 1) {
    if ((animPhase == 2 && landerFloor1 < 25) || (animPhase == 3 && landerFloor2 == 25)) {
      roverLocation[1] = rover(roverLocation[0], roverLocation[1], roverLocation[2], 0, 2, false, false);
    } else if ((animPhase == 3 && landerFloor2 < 25) || animPhase == 4) {
      roverLocation[1] = rover(roverLocation[0], roverLocation[1], roverLocation[2], 0, 1, false, false);
    } else {
      if (animPhase > 5) {
        roverLocation[1] = rover(roverLocation[0], roverLocation[1], roverLocation[2], 0, 0, true, false);
      } else {
        roverLocation[1] = rover(roverLocation[0], roverLocation[1], roverLocation[2], 0, 0, false, false);
      }
    }
    if (animPhase == 5) {
      rover(roverLocation[0] + 30, 100, roverLocation[2], 0, 2, true, true);
      rover(roverLocation[0] - 30, 100, roverLocation[2], 0, 1, true, true);
      otherRovers[0][0] = roverLocation[0] + 30;
      otherRovers[0][1] = 100;
      otherRovers[0][2] = roverLocation[2];
      otherRovers[1][0] = roverLocation[0] - 30;
      otherRovers[1][1] = 100;
      otherRovers[1][2] = roverLocation[2];
    }
    if (animPhase == 6) {
      rover(otherRovers[0][0], 100, otherRovers[0][2], -roverAngle, 2, true, true);
      rover(otherRovers[1][0], 100, otherRovers[1][2], roverAngle, 1, true, true);
    }
  }
}

float getFloorHeight(float x, float y, float z) {
  if (abs(x) < 25 && abs(z) <= 25) {
    if (y > landerHeight - landerFloor1) {
      return landerHeight;
    } else if (y <= landerHeight - landerFloor1 && y > landerHeight - landerFloor1 - landerFloor2) {
      return landerHeight - landerFloor1;
    } else {
      return landerHeight - landerFloor1 - landerFloor2;
    }
  } else if (x >= -25 && x <= 25 && z > 25 && z <= 50) {
    return map(z, 25, 50, -5, 0);
  } else {
    return noise(x / 100.0, z / 100.0) * -(abs(pow(x / 50.0, 2)) + abs(pow(z / 50.0, 2)));
  }
}

void updateFire() {
  for (int x = 0; x < 400; x++) {
    flame[399][x] = (int)random(0, 256);
  }
  for (int y = 0; y < 400; y++) {
    for (int x = 0; x < 400; x++) {
      int l = 0, r = 0, b = 0, bb = 0;
      if (x > 0) {
        l = flame[y][x - 1];
      }
      if (x < 399) {
        r = flame[y][x + 1];
      }
      if (y < 399) {
        b = flame[y + 1][x];
      }
      if (y < 398) {
        bb = flame[y + 2][x];
      }
      flame[y][x] = (int)((l + r + b + bb) / (4 + EPSILON));
    }
  }
  fire.loadPixels();
  int fy = 398;
  for (int y = 0; y < 400; y++) {
    for (int x = 0; x < 400; x++) {
      fire.pixels[x + y * 400] = palette[flame[fy][x]];
      fire.pixels[x + y * 400] = palette[flame[fy][x]];
    }
    if (y % 4 == 0) {
      fy--;
    }
  }
  fire.updatePixels();
}

void setup() {
  earth = loadImage("globe.jpg");
  fire = createGraphics(400, 400, P2D);
  logo = loadImage("lts_logo.png");
  logo.loadPixels();
  for (int i = 0; i < logo.pixels.length; i++) {
    if (logo.pixels[i] == color(0, 0)) {
      logo.pixels[i] = color(0, 127);
    }
  }
  logo.updatePixels();
  panel = loadImage("panel.jpg");
  globe = createShape(SPHERE, 600);
  globe.setStroke(false);
  globe.setTexture(earth);
  for (int i = 0; i < 100; i++) {
    stars[i][0] = radians(random(-100, 100));
    stars[i][1] = radians(random(-100, 100));
  }
  colorMode(HSB);
  for (int i = 0; i < 256; i++) {
    palette[i] = color(i / 3, 255, min(255, i * 2), min(255, i * 4));
  }
  colorMode(RGB);
  for (int y = 0; y < 400; y++) {   
    for (int x = 0; x < 400; x++) {
      flame[y][x] = 0;
    }
  }
  for (int i = 0; i < 400; i++) {
    updateFire();
  }
  fullScreen(P3D);
  noCursor();
  frameRate(60);
  perspective(PI / 3.0, (float)width / height, 1, 100000);
}

void draw() {
  background(0);
  if (!(keyPressed && key == ' ')) {
    update();
  }
  drawObjects();
  //camera(-300, -300, 300, 0, 0, 0, 0, 1, 0);
  camera(cameraLocation[0], cameraLocation[1],  cameraLocation[2], cameraFocus[0], cameraFocus[1], cameraFocus[2], 0, 1, 0);
}
