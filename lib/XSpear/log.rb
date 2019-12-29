def log(t, message)
  # type, message
  # + type: safe, info, matched, vuln
  # + info: match percent

  # = format
  # detail
  # [09:16:53][PARAM] Message / Matched 70%
  # [09:16:54][XSS/INFO] Message / Matched 70%

  # system message
  # [+] start parameter analysis..
  # verbose 0 : only result
  # verbose 1(default) : show progress
  # verbose 2 : show normal log(info, payload)
  # verbose 3 : show details log(info, payload, packets, etc..)

  if @verbose.to_i == 1
    if t == 's' # system message
      puts '[*]'.green + " #{message}"
    end
  elsif @verbose.to_i > 1
    time = Time.now
    if t == 'd'
      puts '[-]'.white + " [#{time.strftime('%H:%M:%S')}] #{message}"
    elsif t == 's' # system message
      puts '[*]'.green + " #{message}"
    elsif t == 'i'
      puts '[I]'.blue + " [#{time.strftime('%H:%M:%S')}] #{message}"
    elsif t == 'v'
      puts '[V]'.red + " [#{time.strftime('%H:%M:%S')}] #{message}"
    elsif t == 'l'
      puts '[L]'.blue + " [#{time.strftime('%H:%M:%S')}] #{message}"
    elsif t == 'm'
      puts '[M]'.yellow + " [#{time.strftime('%H:%M:%S')}] #{message}"
    elsif t == 'h'
      puts '[H]'.red + " [#{time.strftime('%H:%M:%S')}] #{message}"
    end
  end
end