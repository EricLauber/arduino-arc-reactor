# arduino-arc-reactor
Uses pulse-width modulation to flash LEDs at different rates and create a cool dimming effect.

## Premise

The movie Iron-Man came out in 2008. In 2010 after the sequel was released, I wanted to create an arc reactor prop to use in Halloween costumes. I documented my build on Instructables here: [Build an Arc Reactor with Basic Tools and Skills](https://www.instructables.com/Build-an-Arc-Reactor-with-Basic-Tools-and-Skills/).

A few years later, I wanted to add something more to the arc reactor. It already could light-up - what if it could be programmed to light-up with patterns? My design wired 25 or so LEDs in parallel as one large load - individually controlling each LED was not possible. If I wanted to do anything, I would have to control the arc reactor all at once.

## The brightness challenge

I decided it would be cool to make the arc reactor flash. But not just on and off, but with a dimming effect.

LEDs are interesting. They require forward bias with some minimum amount of voltage - this is specific to each LED's make and model. Between that minimum voltage and the spec's ideal voltage, you might be able to dim the LED... but the range is poor, and the effect is inconsistent. Trying to tweak voltage or current in this way to control brightness or dimming is not an effective path forward.

I found leveraging **Pulse-Width Modulation (PWM)** would meet my goal. Using a computer, flash an LED or other light very quickly, far faster than our eyes and brains can comprehend. Full-on, full-off. For some unit of time, the light is on, and for some unit of time, the light is off. Our eyes will interpret this as a lower-intensity brightness.

You can select an vary the **duty cycle**. If during one second, you kept the light on half the time, and off half the time, that would be a 50% duty cycle. That is still true, even if you flash the light hundreds of time per second.

One more wrinkle in this challenge is that our eyes don't interpret this brightness change linearly. 25%, 50%, and 75% duty cycles don't look like 25%, 50%, and 75% brightness. Our eyes interpret this more like a [logarithm](https://en.wikipedia.org/wiki/Logarithm). In order to meet intended brightness goals, the light flashing must account for this difference in how our eyes perceive the flashing.

## Implementing this electronically

At the time of working on this project, I had been practicing with Arduino and Atmel ATmega128 microcontrollers (Microchip Technology has since bought Atmel). I wanted to use the Arduino to toggle a MOSFET, IGBT, or similar transitor as a switch. The transistor would then control power fed to the arc reactor load. I researched the ATmega128 processor and found that the analog output pins used PWM to create an output voltage. Perfect. The specs say that the PWM frequency was 490 Hz. Within the Arduino program, all you have to do is use [`analogWrite()`](https://www.arduino.cc/reference/en/language/functions/analog-io/analogwrite/) with a value of 0 to 255. The microcontroller handles the rest.

Theoretically, I could run tests and build an array of values that described a logarithmic curve. This array could take a human-understandable desired brightness and select a 0 to 255 value that `analogWrite()` could use to write an appropriate PWM duty cycle. Except, I was lazy. I found I could approximate a logarithmic curve by combining a square root with a program delay. The output put would write some PWM duty cycle for a short period of time (the delay), then change to another PWM duty cycle (and delay again).

```
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
```

This creates an effect of the arc reactor lighting up from nothing to full brightness, and then in reverse. It's not perfect, but it happens quickly enough that no one pays enough attention to care.

## Final details

The `flashing` method in this program accepts a `speed` and `bright` value. These are determined using digital inputs pins on the Arduino. My thought was I could have a few preset options for the rate of flashing (the `speed`), and that I could have a full-blast mode and a "low-power" mode that adjusted the target `bright` value (would preserve battery life). I also wrote a `heartbeat` method that had a fun double-flash pattern.

I ended up using a 9V battery, a power regulator that brought voltage down to 5V (the rest was wasted as heat - this could be done far better) and a MOSFET. The 5V ran the Arduino. The Arduino used the analog output pin to provide a PWM duty cycle to the MOSFET. The MOSFET switched the arc reactor on and off. And it worked! (unfortunately, at this time I don't have the specs on the specific power regular and MOSFET that I used).