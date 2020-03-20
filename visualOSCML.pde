//Necessary for OSC communication with Wekinator:
import oscP5.*;
import netP5.*;
OscP5 oscP5;
NetAddress dest;

// These are needed for the moving average calculation
float[] data1 = new float[2];
float total1 = 0, average1 = 0;
int m1 = 0, n1 = 0;

float[] data2 = new float[2];
float total2 = 0, average2 = 0;
int m2 = 0, n2 = 0;

float[] data3 = new float[2];
float total3 = 0, average3 = 0;
int m3 = 0, n3 = 0;

float[] data4 = new float[2];
float total4 = 0, average4 = 0;
int m4 = 0, n4 = 0;

int decay1 = 200;
int decay2 = 200;
int decay3 = 200;
int decay4 = 200;

int decayStart = 200;
int decayAmount = 10;

float lowLim = 0.2;
float highLim = 0.8;

Table table;
String TABLE_PATH = "data/ControlTest10.csv";

void setup()
{
  size(800, 400);
  //Initialize OSC communication
  oscP5 = new OscP5(this,12000); //listen for OSC messages on port 12000 (Wekinator default)
  dest = new NetAddress("127.0.0.1",6448); //send messages back to Wekinator on port 6448, localhost (this machine) (default)
  rectMode(CENTER);

  table = new Table();
  
  table.addColumn("timestamp");
  table.addColumn("p1");
  table.addColumn("p2");
  table.addColumn("p3");
  table.addColumn("p4");

  saveTable(table, TABLE_PATH);
  
float[] numbers = {1,2,3,4,5,6,7,8,9,10};
  for(int i = 0; i < numbers.length; i++){
    nextValue1(numbers[i]);
    nextValue2(numbers[i]);
    nextValue3(numbers[i]);
    nextValue4(numbers[i]);
    //println(average1);
    //println(average2);
    //println(average3);
    //println(average4);
  }
}

void draw()
{
  if((average1 > highLim) && (average2 < lowLim) && (average3 < lowLim)  && (average4 < lowLim)) {
    decay1 = decayStart;
    decay2 -= decayAmount;
    decay3 -= decayAmount;
    decay4 -= decayAmount;
  } else if((average1 < lowLim) && (average2 > highLim) && (average3 < lowLim) && (average4 < lowLim)){
    decay1 -= decayAmount;
    decay2 = decayStart;
    decay3 -= decayAmount;
    decay4 -= decayAmount;
  } else if((average1 < lowLim) && (average2 < lowLim) && (average3 > highLim) && (average4 < lowLim)){
    decay1 -= decayAmount;
    decay2 -= decayAmount;
    decay3 = decayStart;
    decay4 -= decayAmount;
  } else if((average1 < lowLim) && (average2 < lowLim) && (average3 < lowLim) && (average4 > highLim)){
    decay1 -= decayAmount;
    decay2 -= decayAmount;
    decay3 -= decayAmount; 
    decay4 = decayStart;
  } else {
    decay1 -= decayAmount;
    decay2 -= decayAmount;
    decay3 -= decayAmount; 
    decay4 -= decayAmount;
  }
    if(decay1 < 0){decay1 = 0;}
    if(decay2 < 0){decay2 = 0;}
    if(decay3 < 0){decay3 = 0;}
    if(decay4 < 0){decay4 = 0;}
    background(200-decay4);
    fill(decay1,0,0);
    rect(width/4, height/2, width/5, height*0.9, 7);
    fill(0,decay2,0);
    rect(width/2, height/2, width/5, height*0.9, 7);
    fill(0,0,decay3);
    rect(3*width/4, height/2, width/5, height*0.9, 7);  
    
}

//This is called automatically when OSC message is received
void oscEvent(OscMessage theOscMessage) {
 if (theOscMessage.checkAddrPattern("/wek/outputs")==true) {
     if(theOscMessage.checkTypetag("ffff")) { //Now looking for parameters
        float p1 = theOscMessage.get(0).floatValue(); //get first parameter
        float p2 = theOscMessage.get(1).floatValue(); //get second parameter
        float p3 = theOscMessage.get(2).floatValue(); //get third parameter
        float p4 = theOscMessage.get(3).floatValue(); //get fourth parameter
        
        nextValue1(p1);
        nextValue2(p2);
        nextValue3(p3);
        nextValue4(p4);

        TableRow newRow = table.addRow();
        String timestamp = str(millis());
        newRow.setString("timestamp", timestamp);
        newRow.setString("p1", str(p1));
        newRow.setString("p2", str(p2));
        newRow.setString("p3", str(p3));
        newRow.setString("p4", str(p4));
        
        saveTable(table, TABLE_PATH);
        
        String s = String.format("Received new params value from Wekinator: %.2f, %.2f, %.2f, %.2f", p1, p2, p3, p4);
        println(s);
      } else {
        println("Error: unexpected params type tag received by Processing");
      }
 }
}

// Use the next value and calculate the

// moving average1
public void nextValue1(float value){
  total1 -= data1[m1];
  data1[m1] = value;
  total1 += value;
  m1 = ++m1 % data1.length;
  if(n1 < data1.length) n1++;
  average1 = total1 / n1;
}

// moving average2
public void nextValue2(float value){
  total2 -= data2[m2];
  data2[m2] = value;
  total2 += value;
  m2 = ++m2 % data2.length;
  if(n2 < data2.length) n2++;
  average2 = total2 / n2;
}

// moving average3
public void nextValue3(float value){
  total3 -= data3[m3];
  data3[m3] = value;
  total3 += value;
  m3 = ++m3 % data3.length;
  if(n3 < data3.length) n3++;
  average3 = total3 / n3;
}

// moving average4
public void nextValue4(float value){
  total4 -= data4[m4];
  data4[m4] = value;
  total4 += value;
  m4 = ++m4 % data4.length;
  if(n4 < data4.length) n4++;
  average4 = total4 / n4;
}
