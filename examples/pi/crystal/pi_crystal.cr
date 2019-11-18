count = UInt16::MAX
divisor = 1
pi = 0
sign = 1
1.upto(count) do |x|
    pi += (1 / divisor)*sign
    divisor += 2
    sign *= -1
end
puts pi * 4