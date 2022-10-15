f = function(x)
  return x + 2
end

thing = {
  ["some"] = f(3),
}

print(thing["some"])


print((function () return "somebutter" end)())