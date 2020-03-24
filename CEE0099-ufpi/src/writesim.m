%Sets pwm(k) = duty
function writesim(duty)
    global pwm k
    pwm(k) = duty;
end