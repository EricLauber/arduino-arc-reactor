/*
 *	Author:		Eric Lauber
 *	Date:		10/22/2011
 *
 *	Startup and Running Overview:
 *	When ATMega chip powers on, it starts running an Arduino Bootloader.
 *	The Bootloader will run setup(), and then immediately follow
 *	by repeating loop() until the power is cycled.
 *
 *	Pin information:
 *	0 and 1 are the logic-low and logic-high values returned digitalRead(pin integer).
 *
 *	analogWrite(value) writes a square wave at 490 Hz to the specified analog pin.
 *	The duty cycle of the PWM output varies from 0 (off) to 255 (on).
 *
 */


// Pins 2-8 connected to DIP switches 7-1 respectively through 10k resistors
// Pin 5V connected to bottom of switches
// Pin GND connected to opposite end of resistors
const int buttonPin[] = {2, 3, 4, 5, 6, 7, 8};
const int ledPin =  13; //	Status LED
const int ctrlPin = 9; //	Connected to Base of TIP120 BJT


// Setup is run
void setup()
{          
	// Shut off the arc reactor
	analogWrite(ctrlPin, 0);  
	pinMode(ledPin, OUTPUT);
	for(int i = 0; i < 7; i++)
	{pinMode(buttonPin[i], INPUT);}
	// For testing purposes to ensure processor starts
	digitalWrite(ledPin, HIGH);   // set the LED on
	delay(1000);              // wait for a second
	digitalWrite(ledPin, LOW);    // set the LED off
	delay(1000);   
}

void loop()
{
	// High brightness or low-power mode
	int brightness = 255;
	if(1 == digitalRead(8)) {brightness = 190;}
	
	// Do not power the reactor unless pin 2 (switch 1) is on
	if(0 != digitalRead(2))
	{
		if(1 == digitalRead(3)) {flashing(1, brightness);} else
		if(1 == digitalRead(4)) {flashing(2, brightness);} else
		if(1 == digitalRead(5)) {flashing(4, brightness);} else
		if(1 == digitalRead(6)) {flashing(8, brightness);} else
		if(1 == digitalRead(7)) {heartbeat();} else
		{analogWrite(ctrlPin, brightness);}	
	}
}

// delay((16 - sqrt(i))/value) within a for loop approximates a logarithm close enough.
void flashing(float speed, int bright)
{
	for (float i = 0; i <= bright; i++)
	{
		analogWrite(ctrlPin, i);
		delay((16 - sqrt(i))/speed);
	}
	for (float i = bright; i >= 0; i--)
	{
		analogWrite(ctrlPin, i);
		delay((16 - sqrt(i))/speed);
	}
	analogWrite(ctrlPin, 0);
}  

void heartbeat()
{
	for (float i = 0; i <= 230; i++)
	{
		analogWrite(ctrlPin, i);
		delay((16 - sqrt(i))/3.5);
	}
	for (float i = 230; i >= 50; i--)
	{
		analogWrite(ctrlPin, i);
		delay((16 - sqrt(i))/2.5);
	}

	for (float i = 50; i <= 230; i++)
	{
		analogWrite(ctrlPin, i);
		delay((16 - sqrt(i))/2.5);
	}
	delay(20);
	for (float i = 230; i >= 0; i--)
	{
		analogWrite(ctrlPin, i);
		delay((16 - sqrt(i))/3.5);
	}
	analogWrite(ctrlPin, 0);
}
