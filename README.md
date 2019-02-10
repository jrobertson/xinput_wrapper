# Capturing a superkey button press using the xinput_wrapper gem

    require 'xinput_wrapper'

    XInputWrapper.new(device: '3', verbose: true).listen

Output:

<pre>
keycode: 133
super key presssed

keycode: 37
control key presssed
</pre>

xinput xinputwrapper keypress gem
