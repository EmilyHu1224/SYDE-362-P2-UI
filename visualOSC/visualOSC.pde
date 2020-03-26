//Necessary for OSC communication with Wekinator:
import oscP5.*;
import netP5.*;
import java.util.concurrent.TimeUnit;
OscP5 oscP5;
NetAddress dest;

Table table;
float p1, p2, p3, p4;
boolean updated = false;
String filename = "log";
String CSV_PATH = String.format("data/%s.csv", filename);

// list of timestamps of failures
int[] errorTimestamps;

// index of the last displayed timestamp
int lastDisplayedTimestamp = -1;

int listLen = 0;
// list to store error time stamps
int[] errorTimes = new int[20];
// list to store error names
String[] errorTypes = new String[20];
// initiate the error color indicators to black
int errAColor = 0;
int errBColor = 0;
int errCColor = 0;
int errDColor = 0;
// initiate font styles
PFont headerStyle;
PFont listItemStyle;
// define error names
String errA = "Error A";
String errB = "Error B";
String errC = "Error C";
String errD = "Error D";

void setup()
{
  size(1200, 600);
  headerStyle = createFont("Arial", 20);
  listItemStyle = createFont("Arial", 18);
  //Initialize OSC communication
  oscP5 = new OscP5(this, 12000); //listen for OSC messages on port 12000 (Wekinator default)
  rectMode(CENTER);

  table = new Table();
  
  table.addColumn("Timestamp");
  table.addColumn("Error Type");
  table.addColumn("p1");
  table.addColumn("p2");
  table.addColumn("p3");
  table.addColumn("p4");

  saveTable(table, CSV_PATH);
}

void draw()
{ 
  if (updated) {
    String s = String.format("%.2f, %.2f, %.2f, %.2f", p1, p2, p3, p4);
    text(s, 20, 30);
    updated = false;
    // create the ui
    background(255);
    renderErrorsList();
    renderErrorIndicators();
  }
}

//This is called automatically when OSC message is received
void oscEvent(OscMessage theOscMessage) {
 if (theOscMessage.checkAddrPattern("/sc/outputs")) {
    int len = theOscMessage.arguments().length;
    errorTimestamps = new int[len];
    for (int i = 0; i < len; i++) {
      errorTimestamps[i] = theOscMessage.get(i).intValue();
    }
 } else if (theOscMessage.checkAddrPattern("/wek/outputs")) {
    if(theOscMessage.checkTypetag("ffff")) {
      p1 = theOscMessage.get(0).floatValue();
      p2 = theOscMessage.get(1).floatValue();
      p3 = theOscMessage.get(2).floatValue();
      p4 = theOscMessage.get(3).floatValue();

      // Skip garbage values
      if (p1 > 100 || p2 > 100 || p3 > 100 || p4 > 100) {
        return;
      }

      // Update the UI data with the new error
      if (listLen < 20) {
        listLen++;
      }
      
      updateErrorTimes();
      setCurrentErrorType(p1, p2, p3, p4);
  
      TableRow newRow = table.addRow();
      String timeStr = str(errorTimestamps[lastDisplayedTimestamp]);
      
      newRow.setString("Timestamp", timeStr);
      newRow.setString("Error Type", getLastChar(errorTypes[0]));
      newRow.setString("p1", str(p1));
      newRow.setString("p2", str(p2));
      newRow.setString("p3", str(p3));
      newRow.setString("p4", str(p4));
      
      saveTable(table, CSV_PATH);
      updated = true;
      println(String.format("OSC Event at %s: %.2f, %.2f, %.2f, %.2f", str(millis()), p1, p2, p3, p4));
    } else {
      println("Error: unexpected params type tag received by Processing");
    }
 }
}

void updateErrorTimes () {
  if (lastDisplayedTimestamp == errorTimestamps.length) {
    println("Arrived at the end of the error timestamps!");
    return;
  }

  if (listLen > 0) {
    for (int i = listLen - 1; i > 0; i--) {
        errorTimes[i] = errorTimes[i - 1];
    }
  }
  errorTimes[0] = errorTimestamps[++lastDisplayedTimestamp];
} 

void updateErrorTypes (String errType) {
  if (listLen > 0) {
    for (int i = listLen - 1; i > 0; i--) {
        errorTypes[i] = errorTypes[i - 1];
    }
  }
  errorTypes[0] = errType;
}

void setCurrentErrorType (float p1, float p2, float p3, float p4) {
  if (p1 < p2 && p1 < p3 && p1 < p4) {
    errAColor = 200;
    errBColor = 0;
    errCColor = 0;
    errDColor = 0;
    updateErrorTypes(errA);
  } else if (p2 < p3 && p2 < p4) {
    errAColor = 0;
    errBColor = 200;
    errCColor = 0;
    errDColor = 0;
    updateErrorTypes(errB);
  } else if (p3 < p4) {
    errAColor = 0;
    errBColor = 0;
    errCColor = 200;
    errDColor = 0;
    updateErrorTypes(errC);
  } else {
    errAColor = 0;
    errBColor = 0;
    errCColor = 0;
    errDColor = 200;
    updateErrorTypes(errD);
  }
}

String getLastChar(String s) {
  return s.substring(s.length() - 1);
}

String formatTime (int time) {
  int minutes = (time / 1000) / 60;
  int seconds = (time / 1000) % 60;
  int milliseconds = time % 100;
  return String.format("%02d:%02d:%02d", 
     minutes,
     seconds,
     milliseconds
  );
}

void renderErrorsList () {
  // define the horizontal text positions
  int col1Indent = 50;
  int col2Indent = 225;
  // set the font style
  fill(0);
  textFont(headerStyle);  
  // create the headers
  text("Error Type", col1Indent, 40);
  text("Error Time", col2Indent, 40);
  // iterate over the list and render the errors
  textFont(listItemStyle);
  int refYPos = 70;
  int YPos = 0; 
  for (int i = 0; i < listLen; i++) {
    YPos = refYPos + 25 * i;
    text(errorTypes[i], col1Indent + 15, YPos);
    text(formatTime(errorTimes[i]), col2Indent + 15, YPos);
  }
}

void renderErrorIndicators () {
    float textPosY =  height/2 + height*0.35 + 20;
    // Error Type A Indicator
    fill(errAColor, 0, 0);
    rect(width - 700, height/2, 170, height*0.7, 7); 
    fill(0);
    text(errA, width - 720, textPosY);
    // Error Type B Indicator
    fill(0, errBColor, 0);
    rect(width - 500, height/2, 170, height*0.7, 7);
    fill(0);
    text(errB, width - 520, textPosY);
    // Error Type C Indicator
    fill(0, 0, errCColor);
    rect(width - 300, height/2, 170, height*0.7, 7); 
    fill(0);
    text(errC, width - 320, textPosY);
    // Error Type D Indicator
    fill(errDColor, errDColor, 0);
    rect(width - 100, height/2, 170, height*0.7, 7);
    fill(0);
    text(errD, width - 120, textPosY);
}
