//Necessary for OSC communication with Wekinator:
import oscP5.*;
import netP5.*;
OscP5 oscP5;
NetAddress dest;

Table table;
int starting_timestamp = 0;
boolean starting_timestamp_printed = false;
float p1, p2, p3, p4;
boolean updated = false;
String CSV_PATH = "data/ControlTest10.csv";

void setup()
{
  size(800, 400);
  
  //Initialize OSC communication
  oscP5 = new OscP5(this, 12000); //listen for OSC messages on port 12000 (Wekinator default)
  rectMode(CENTER);

  table = new Table();
  
  table.addColumn("timestamp");
  table.addColumn("p1");
  table.addColumn("p2");
  table.addColumn("p3");
  table.addColumn("p4");

  saveTable(table, CSV_PATH);
}

void draw()
{
  if (starting_timestamp > 0 && starting_timestamp_printed == false) {
    String s = String.format("Starting Timestamp: %i", starting_timestamp);
    text(s, 20, 30);
    println(s);
    starting_timestamp_printed = true;
  }
  
  if (updated) {
    String s = String.format("%.2f, %.2f, %.2f, %.2f", p1, p2, p3, p4);
    text(s, 20, 30);
    updated = false;
  }
}

//This is called automatically when OSC message is received
void oscEvent(OscMessage theOscMessage) {
 if (theOscMessage.checkAddrPattern("/sc/outputs")) {
   starting_timestamp = millis();
   println(starting_timestamp);
 } else if (theOscMessage.checkAddrPattern("/wek/outputs")) {
    if(theOscMessage.checkTypetag("ffff")) {
      p1 = theOscMessage.get(0).floatValue();
      p2 = theOscMessage.get(1).floatValue();
      p3 = theOscMessage.get(2).floatValue();
      p4 = theOscMessage.get(3).floatValue();
      
      TableRow newRow = table.addRow();
      String timestamp = str(millis() - starting_timestamp);
      
      newRow.setString("timestamp", timestamp);
      newRow.setString("p1", str(p1));
      newRow.setString("p2", str(p2));
      newRow.setString("p3", str(p3));
      newRow.setString("p4", str(p4));
      
      saveTable(table, CSV_PATH);
      updated = true;
    } else {
      println("Error: unexpected params type tag received by Processing");
    }
 }
}
