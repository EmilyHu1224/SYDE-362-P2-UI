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
boolean timeStampsRecieved = false;

// index of the last displayed timestamp
int lastDisplayedTimestamp = -1;

int listLen = 0;
// list to store error time stamps
int[] errorTimes = new int[100];
// list to store error names
String[] errorTypes = new String[100];
// define error names
String errA = "Error A";
String errB = "Error B";
String errC = "Error C";
String errD = "Error D";

void setup()
{
  size(1200, 600);
  //Initialize OSC communication
  oscP5 = new OscP5(this, 12000); //listen for OSC messages on port 12000 (Wekinator default)

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
    updated = false;
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
    timeStampsRecieved = true;
 } else if (timeStampsRecieved && theOscMessage.checkAddrPattern("/wek/outputs")) {
    if(theOscMessage.checkTypetag("ffff")) {
      p1 = theOscMessage.get(0).floatValue();
      p2 = theOscMessage.get(1).floatValue();
      p3 = theOscMessage.get(2).floatValue();
      p4 = theOscMessage.get(3).floatValue();

      // Update the UI data with the new error
      if (listLen < 100) {
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
      println(String.format("OSC Event at %s: %.2f, %.2f, %.2f, %.2f", str(millis()), p1, p2, p3, p4));
      updated = true;
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
    updateErrorTypes(errA);
  } else if (p2 < p3 && p2 < p4) {
    updateErrorTypes(errB);
  } else if (p3 < p4) {
    updateErrorTypes(errC);
  } else {
    updateErrorTypes(errD);
  }
}

String getLastChar(String s) {
  return s.substring(s.length() - 1);
}
