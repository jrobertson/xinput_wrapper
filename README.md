# Introducing the xinput_wrapper gem

    require 'xinput_wrapper'

    xiw = XInputWrapper.new device: '3', topic: 'jessie/input/keyboard', 
                            verbose: true
    xiw.listen

The above code listens for key presses using the Linux utility `xinput` and publishes a SimplePubSub message whenever the super key (keycode 133) is pressed. It also detects when the control key is pressed multiple times in quick succession as a secret knock message as defined by the secret_knock gem. 

## Output

### CLI verbose output

<pre>
keycode: 115
keycode: 36
keycode: 36
keycode: 37
control

1 knock
keycode: 37
control
2 knock
:: "e"
keycode: 133
super key pressed
:: "super key pressed"
</pre>

## SPS Output (in descending order)

<pre>
jessie/input/keyboard: e
jessie/input/keyboard: super key pressed
</pre>

## Resources

* xinput_wrapper https://rubygems.org/gems/xinput_wrapper

xinput secretknock superkey keycode sps
