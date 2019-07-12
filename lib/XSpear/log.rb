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
  if @verbose.to_i > 1
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