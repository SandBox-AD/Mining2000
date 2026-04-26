local logger = {}

function logger.info(message)
  print("[Mining2000] " .. tostring(message))
end

function logger.warn(message)
  print("[Mining2000/WARN] " .. tostring(message))
end

function logger.error(message)
  print("[Mining2000/ERROR] " .. tostring(message))
end

return logger