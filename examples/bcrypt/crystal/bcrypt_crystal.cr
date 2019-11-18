require "crypto/bcrypt/password"
count = 100

tStart = Time.utc
1.upto(count) do
  crypt = Crypto::Bcrypt::Password.create("password", cost: 10)
  crypt.verify("password")
end
tEnd = Time.utc
puts (tEnd - tStart)/count
